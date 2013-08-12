## SLUGS Waypoint Visualizer ##

*   Website: http://lifeguardrobotics.com
*   Source: https://github.com/dagoodma/slugs_flightgear
*   Mailing list: [Google Groups](https://groups.google.com/a/ucsc.edu/forum/#!forum/slugs-group)

The SLUGS Waypoint Visualizer is an addon for FlightGear that allows you
to plot waypoints form the route manager. Currently, waypoints are shown
as red beads, and legs between waypoints are plotted as yellow beads.


### Installation ###

To install this addon, copy the ```data``` folder into your FlightGear
directory (FGROOT, typically ```C:\Program Files\FlightGear```).

The above step will add the bead models to ```data\Models\Geometry```, 
add the backend script to ```data\Nasal```, and add the UDP protocol
to ```data\Protocol```. You could also copy the backend script to your
home directory, but the models and protocol will need to be located
under FGROOT.


### License ###

The SLUGS Waypoint Visualizer project is protected under either LGPL or GPLv3+.
See the *COPYING* file for more info.


### Credits ###

&copy; 2013 [David Goodman](mailto:dagoodma@ucsc.edu),
