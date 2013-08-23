function [ output_args ] = sendWPCommandToFlightgear( u, cmd_str )
%sendWPCommandToFlightgear Sends a command to a flightgear via udp
%   Sends the given command to flightgear via the udp stream u.
%   Valid commands are either route-manager commands, or update commands.
%   Route manager commands can be:
%       @CLEAR - clears the waypoint list
%       @DELETE# - deletes the waypoint with the given index from the list
%   Update commands can be:
%       waypoint - draws all listed waypoint and legs between
%       initialpoint - draws the most recently added waypoint as an initial point
%
%   udp packets are in the following format:
%       waypoint, update_waypoints, l2_vecx, l2_vecy, l2_vecz, l2_veclen, l2_draw
%   except fields are separated by the tab character '\t' instead of commas
%
k = findstr(cmd_str, '@');
if length(k) > 1
    k = k(1);
end

if k == 1
    % Route manager command
    fwrite(u,sprintf('%s\t0\t0\t0\t0\n',cmd_str));
else
    % Update command
    fwrite(u,sprintf('\t%s\t0\t0\t0\n',cmd_str));
end


end

