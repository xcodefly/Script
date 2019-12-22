// This file control the altitude, pitch and bank control.

// Initilized engine 

// Set torque.
// Initilize engines ( Need Work with auto detection)
run "_quard_engine.ks".
set engList to Engine_ClockWise().

set mainRPM to list(0,0,0,0).
set rpm to 0.


set rpmPID to pidLoop(10,	5,	50,	0,460).
set pitchPID to pidLoop(2,	0.1,	1,	-20,20).
set bankPID to pidLoop(2,	0.1,	1,	-20,20).
set hdgPID to pidLoop(3,	0.1,	1,	-20,20).
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
    
 }

Declare function _Bank{
    parameter currentBank.
    parameter targetBank.
    set bankPID:setPoint to targetBank.
    set bankoffset to bankPID:update(time:seconds,currentBank).
    set mainRPM[0] to mainRPM[0]-bankoffset.
    set mainRPM[1] to mainRPM[1]-bankoffset.
    set mainRPM[2] to mainRPM[2]+bankoffset.
    set mainRPM[3] to mainRPM[3]+bankoffset.
    print round(bankoffset,1)+ "    " at (4,4).
    

}
Declare function _Pitch
{
    parameter currentPitch.
    parameter targetPitch.
    set pitchPID:setPoint to targetPitch.
    set pitchoffset to pitchPID:update(time:seconds,currentPitch).
    set mainRPM[0] to mainRPM[0]+pitchoffset.
    set mainRPM[1] to mainRPM[1]-pitchoffset.
    set mainRPM[2] to mainRPM[2]-pitchoffset.
    set mainRPM[3] to mainRPM[3]+pitchoffset.
    print round(pitchoffset,1)+"     " at (5,5).
}
declare function _HDG
{
    parameter currentHDG.
    parameter targetHDG.
    set hdgPID:setPoint to 360.
    local updateHDG to currentHDG+360-targetHDG.
    if updateHDG>360+180
    {
        set updateHDG to updateHDG-360.
    } else if updateHDG<180
    {
        set updateHDG to updateHDG+360.
    }
    
    print "targetHDG+360: "+round(targetHDG+360,1)+" curr " + Round(currentHDG+360) at (5,5).

    print "targetHDG+360: "+round(updateHDG) at (5,6).

    

    set hdgOffset to hdgPID:update(time:seconds,updateHDG).
    set mainRPM[0] to mainRPM[0]-hdgOffset.
    set mainRPM[1] to mainRPM[1]+hdgOffset.
    set mainRPM[2] to mainRPM[2]-hdgOffset.
    set mainRPM[3] to mainRPM[3]+hdgOffset.
}
