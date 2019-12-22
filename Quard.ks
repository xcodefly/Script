// This scrip it used to find to fly the Quard Copter without any stabilization.

// Find the engine at all for corners.
run "_engine_Quard.ks".
run "_quard_control.ks".

// Front vector 
set eList to Engine_ClockWise().
// Sort engines.
clearscreen.
//Print " Engine List " + eList.
print elist.
set eSetting to elist[0]:allmodules.
set rot_module to elist[0]:getmodule(eSetting[1]).

print elist[0]:getmodule("ModuleRoboticServoRotor"):allfields.
elist[0]:getmodule("ModuleRoboticServoRotor"):setfield("RPM Limit",100).
// Basic takeoff using.

