	# Slugs backend for drawing waypoints, legs in between, aim points, initial points,
# and L2+ vectors.
#
	
var WP_MARKER = "Models/Geometry/bead_wp.xml";	# path bead
var MARKER = "Models/Geometry/bead.xml";	# wp bead			
#var AP_MARKER = "Models/Geometry/bead_aim.xml"; # aim point bead
var IP_MARKER = "Models/Geometry/bead_aim.xml"; # initial point bead
var L2_MARKER = "Models/Geometry/line_l2.xml"; # L2+ marker
var BEAD_DIST = 10;			# (m) distance between leg beads
var HOFFSET = 0;				# distance in meters to offset leg altitude	
var SOFFSET = 0;			# distance to offset the line's starting point

var L2_HOFFSET = 0;
var L2_LENGTH = 28;
var L2_ANGLEOFFSET = 90;

var CLEAR_ROUTES_AFTER = 1;
var L2_DEBUG_PRINT = 1;

# Leg pieces
var beads = [];
var bead_count = 0;

# Initial, aimpoint, and L2 pieces
var ip_bead = nil;
var l2_boxes = [];
var l2_count = 0;

# Waypoints
var wps = [];
var wp_num = 0;
var initial_point = nil;


#var floor1 = func(x) {
#   var n = 1;
#	while (n + 1 <= x) {
#		n += 1;
#	}
#	
#    return n;
#}

# Rounds down, but will never be less than 1
var floor1 = func(v) v < 2.0 ? 1 : int(v);

# Clear route manager waypoints.
var clear_route_wps = func() {
	print("Clearing route manager waypoints.");
	setprop("/autopilot/route-manager/input", "@CLEAR");
}

# Erase all legs.
var clear_legs = func() {

	print("Erasing old legs: "~ bead_count);
	
	forindex(var i; beads) {
		if (beads[i] != nil) {
			beads[i].remove();
			beads[i] = nil;
		}
	}
	
	beads = [];
	bead_count = 0;
}

# Erase l2 vector.
var clear_l2 = func() {
	
	forindex(var i; l2_boxes) {
		if (l2_boxes[i] != nil) {
			l2_boxes[i].remove();
			l2_boxes[i] = nil;
		}
	}
	
	l2_boxes = [];
	l2_count = 0;
}

# Draws an L2+ vector in space
var draw_L2_vector = func() {
	l2_lat = getprop("/autopilot/l2/lat");
	l2_lon = getprop("/autopilot/l2/lon");
	if (l2_lat == nil or l2_lon == nil)
		die("Bad L2+ vector given with nil coordinates.");
	
	# Get UAV's position
	var wp1 = geo.Coord.new();
	var alt = (getprop("/position/altitude-ft") * 0.3048) + HOFFSET; # want in meters
	wp1.set_latlon( getprop("/position/latitude-deg"), getprop("/position/longitude-deg"), alt);
	
	# Second point is l2_vector coordinate with same altitude as UAV
	var wp2 = geo.Coord.new();
	wp2.set_latlon(l2_lat, l2_lon, wp1.alt());
	
	
	if (L2_DEBUG_PRINT)
		print("Drawing L2 from wp1 (" ~ wp1.lat() ~ "," ~ wp1.lon() ~ "," ~ wp1.alt() ~ ") to wp2 (" ~ wp2.lat() ~ "," ~ wp2.lon() ~ "," ~ wp2.alt() ~ ").");

	# Determine heading and distance from wp1 to wp2
	var hdg = wp1.course_to(wp2);
	var dist = wp1.direct_distance_to(wp2);
	

    var new_l2 = [];
	
	# Determine number of boxes to draw
	var new_l2_count = floor1(dist / L2_LENGTH); #number of line pieces needed
	
	setsize(new_l2, new_l2_count);
	
	if (L2_DEBUG_PRINT)
		print("Drawing " ~ new_l2_count~ " l2 pieces.");
		
	var curr_pos = geo.Coord.new();
	curr_pos.set_latlon(wp1.lat(), wp1.lon(), wp1.alt());
	curr_pos.apply_course_distance(hdg, L2_LENGTH / 2); # initial offset to start at end of line
	
	# Append new piece pieces to end of array and move leg starting coordinate
	for( var i = 0; i < new_l2_count; i += 1) {
		new_l2[i] = geo.put_model(L2_MARKER, curr_pos, hdg + L2_ANGLEOFFSET);
		curr_pos.apply_course_distance(hdg, L2_LENGTH);
	}
	
	
	# Clear old L2 line
	clear_l2();
	
	l2_boxes = new_l2;
	l2_count = new_l2_count;
	
	if (L2_DEBUG_PRINT)
		print("Drew " ~ l2_count~ " l2 pieces.");
}


# Plots most recently added waypoint as an initial point.
var draw_initial_point = func() {
	wp_num = getprop("/autopilot/route-manager/route/num");	
	
	if (wp_num <= 1)
		die("No waypoints loaded for drawing initial point.");
		
	# Erase old aimpoint
	if (ip_bead != nil) {
		ip_bead.remove();
		ip_bead = nil;
	}
	
	# Take most recently added waypoint as aim point (highest index)
	var ip_wp = geo.Coord.new();
	var wp_idx = wp_num - 1;
	var lat = getprop(get_waypoint_path(wp_idx) ~ "/latitude-deg");
	var lon = getprop(get_waypoint_path(wp_idx) ~ "/longitude-deg");
	var alt = getprop(get_waypoint_path(wp_idx) ~ "/altitude-m");
	ip_wp.set_latlon(lat,lon,alt);
	
	print("Drawing initial point (" ~ ip_wp.lat() ~ "," ~ ip_wp.lon() ~ "," ~ ip_wp.alt() ~ ").");
	ip_bead = geo.put_model(IP_MARKER, ip_wp, 0); # heading used to be offset by 90
}


# Draw a leg from wp1 to wp2, adding to the existing leg piece array
var draw_leg = func(wp1, wp2) {
	if (wp1 == nil or wp2 == nil)
		die("An invalid waypoint was given.");
		
	print("Drawing leg from wp1 (" ~ wp1.lat() ~ "," ~ wp1.lon() ~ "," ~ wp1.alt() ~ ") to wp2 (" ~ wp2.lat() ~ "," ~ wp2.lon() ~ "," ~ wp2.alt() ~ ").");

	# Determine heading and distance from wp1 to wp2
	var hdg = wp1.course_to(wp2);
	var dist = wp1.direct_distance_to(wp2);
	
	# Determine number of legs to draw
	var leg_beads_needed = floor1(dist / BEAD_DIST); #number of line pieces needed
	print("Drawing " ~ leg_beads_needed ~ " leg pieces.");
	
	# Expand size of leg_piece array to fit new pieces
	var new_bead_count = leg_beads_needed + bead_count + 2; # 2 extra for WPs
	setsize(beads, new_bead_count);
	
	# Starts current leg length at wp1, and draws a waypoint bead here
	var curr_pos = geo.Coord.new();
	curr_pos.set_latlon(wp1.lat(), wp1.lon(), wp1.alt());
	
	# Draws a WP bead at WP1 and moves the curr_pos
	#curr_pos.apply_course_distance(hdg,SOFFSET);
	beads[bead_count - 1] = geo.put_model(WP_MARKER, curr_pos, 0);
	curr_pos.apply_course_distance(hdg,BEAD_DIST);
	var new_alt = curr_pos.alt() + (wp2.alt() - wp1.alt())/leg_beads_needed;
	curr_pos.set_alt(new_alt);
	
	# Append new piece pieces to end of array and move leg starting coordinate
	for( var i = bead_count; i < new_bead_count - 2; i += 1) {
		beads[i] = 	geo.put_model(MARKER, curr_pos, hdg); # heading used to be offset by 90
		curr_pos.apply_course_distance(hdg, BEAD_DIST);
		# Change altitude of next leg piece
		var new_alt = curr_pos.alt() + (wp2.alt() - wp1.alt())/leg_beads_needed;
		curr_pos.set_alt(new_alt);
	}
	
	# Draw WP bead at WP2
	beads[new_bead_count - 2] = geo.put_model(WP_MARKER, wp2, 0);
	
	# Update counter to new size
	bead_count = new_bead_count;
}

# Returns the property path for the waypoint with the given index
var get_waypoint_path = func(idx) {
	var wp_max = getprop("/autopilot/route-manager/route/num") - 1;
	
	if (idx < 0 or idx > wp_max)
		die("Invalid waypoint index given:" ~ idx);
	
	# Inconsistant naming for first waypoint
	if (idx == 0)
		return("/autopilot/route-manager/route/wp");
	else
		return("/autopilot/route-manager/route/wp[" ~ idx ~ "]");
}

# Iterate through waypoints and draw legs
var update_waypoint_legs = func() {

	wp_num = getprop("/autopilot/route-manager/route/num");	
	
	if (wp_num <= 1)
		die("No waypoints loaded.");
		
	# Erase old leg pieces
	if (bead_count > 0)
		clear_legs();
	
	setsize(wps,wp_num);
	
	forindex (var i; wps) {
		# Acquire waypoint coordinates
		wps[i] = geo.Coord.new();
		var wp_path = get_waypoint_path(i);
		var lat = getprop(wp_path ~ "/latitude-deg");
		var lon = getprop(wp_path ~ "/longitude-deg");
		var alt = getprop(wp_path ~ "/altitude-m") + HOFFSET; # model height offset 
		wps[i].set_latlon(lat,lon,alt);
		wps[i].set_alt(alt); # is this necessary?
		
		# Draw a leg between this and the previous WP
		if (i > 0) {
			var j = i-1;
			draw_leg(wps[j], wps[i]);
			print("Drew leg from wps["~j~"] to wps["~i~"].");
		}
	}
	var legs_drawn = wp_num - 1;
	print("Finished drawing "~ legs_drawn ~" legs.");
}

# Initialization handler
var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener); # uninstall, so we're only called once
	print("Slugs backend module initialized.");
	
	setlistener("/autopilot/route-manager/update_waypoints", func(n) {
		if (n.getValue() and n.getValue() != "") {
			#if (n.getValue() == "aimpoint") {
			#	print("Drawing aim point.");
			#	draw_aim_point();
			#}
			else if (n.getValue() == "initialpoint") {
				print("Drawing inital point.");
				draw_initial_point();
			}
			else {
				print("Drawing waypoints and legs.");
				update_waypoint_legs();
			}
			if (CLEAR_ROUTES_AFTER)
				clear_route_wps();
			setprop("/autopilot/route-manager/update_waypoints","");
		}
	}, 1);
	print("Started waypoint listener.");
	
	setlistener("/autopilot/l2/draw_l2", func(n) {
		if (n.getValue()) {
			if (L2_DEBUG_PRINT)
				print("Drawing L2 vector.");
			draw_L2_vector();
			setprop("/autopilot/l2/draw_l2",0);
		}
	}, 1);
	print("Started L2 listener.");
});


#--------------- Test functions --------------------

# Tests draw_leg by passing it two waypoints near the aircraft
var test = func() {
	# Just use current postion as waypoint
	var wp1 = geo.Coord.new();
	var alt = (getprop("/position/altitude-ft") * 0.3048) + HOFFSET; # want in meters
	wp1.set_latlon( getprop("/position/latitude-deg"), getprop("/position/longitude-deg"), alt);
	wp1.set_alt(alt); # need to call this or it goes undefined? (maybe not)
	
	# Second waypoint is offset from first
	var wp2 = geo.Coord.new();
	print("wp1: lat=" ~ wp1.lat() ~", lon=" ~ wp1.lon() ~ ", alt=" ~ wp1.alt() ~ ".");
	wp2.set_latlon(wp1.lat() + 0.000, wp1.lon() + 0.01, wp1.alt() + 50);
	
	draw_leg(wp1, wp2);
}

# Tests the l2 vector drawing function
var test_l2 = func() {
	var l2_coord = geo.Coord.new();
	l2_coord.set_latlon(getprop("/position/latitude-deg"), getprop("/position/longitude-deg") + 0.003);
	setprop("/autopilot/l2/lat", l2_coord.lat());
	setprop("/autopilot/l2/lon", l2_coord.lon());
	
	draw_L2_vector();
}

