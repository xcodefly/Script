// This file control the altitude, pitch and bank control.

// Initilized engine 

// Set torque.
// Initilize engines ( Need Work with auto detection)
run "_quard_engine.ks".
set engList to Engine_ClockWise().

set mainRPM to list(0,0,0,0).
set rpm to 0.
set rpmPID to pidLoop(10	1,	1,	0,460).
// PID loops to control Speed and attitude
rotor_torque().
Declare function rotor_torque
{
   
    Parameter tq.
    for eng in engList{
        eng:getmodule("ModuleRoboticServoRotor"):setfield("torque Limit(%)",tq).
    }
}

Declare function set_RPM
{
    engList[0]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[0]).
    engList[1]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[1]).
    engList[2]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[2]).
    engList[3]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[3]).
    pRINT " rpm set TO " + round(mainRPM[0],1) at (2,2).
}

Declare function quard_ALT
{
    local Parameter _shipControl.
    parameter targetALT.
    set rpmPID:setPoint to targetALT.
    set x to targetALT-ship:altitude.
  //  set autoThrottle to climbPID:update(time:seconds,ship:VerticalSpeed).
    set rpm to rpmPID:update(time:seconds,targetALT-x).
    set mainRPM[0] to rpm.
    set mainRPM[1] to rpm.
    set mainRPM[2] to rpm.
    set mainRPM[3] to rpm.
    set_RPM().
    set _shipControl:rpm to rpm.
    return _shipControl.
 
 }