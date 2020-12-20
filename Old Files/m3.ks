// run the functions from -_deOrbit and _land files.
runpath("_global.ks").
Runpath("_deOrbit.ks").
runPath("_land.ks").
RunPath("_WaypointPlus.ks").
runPath ("_TargetPlus.ks").

Local Parameter selectedPoint is "mun_3".
local landWaypoint to waypoint(selectedPoint).


Waypoint_align(landWaypoint).
Descent_at_Waypoint(landwayPoint).
print 


//HoverSlam().
//SoftLand().
