## SLUGS Waypoint Visualizer ##

*   Website: http://byron.soe.ucsc.edu/wiki/autopilot/flightgear
*   Source: https://github.com/dagoodma/slugs_flightgear
*   Mailing list: none yet

The SLUGS Waypoint Visualizer is an addon for FlightGear that allows you
to plot waypoints form the route manager. Currently, waypoints are shown
as red beads, and legs between waypoints are plotted as yellow beads.

![SLUGS FlightGear Addon](http://m4l3.com/slugs/slugs_flightgear.png)

### Installation ###

To install this addon, copy the ```data``` folder into your FlightGear
directory (aka *FGROOT* , typically ```C:\Program Files\FlightGear```).

The above step will add the bead models to ```data\Models\Geometry```, 
add the backend script to ```data\Nasal```, and add the UDP protocol
to ```data\Protocol```. You could also copy the backend script to your
home directory, but the models and protocol will need to be located
under *FGROOT*.


### License ###

The SLUGS Waypoint Visualizer project is protected under GPLv2.
See the *LICENSE* file for more info.


### Credits ###

&copy; 2013 [David Goodman](mailto:dagoodma@ucsc.edu)
