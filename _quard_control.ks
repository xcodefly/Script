// This file control the altitude, pitch and bank control.

// Initilized engine 

// Set torque.
// Initilize engines ( Need Work with auto detection)
run "_quard_engine.ks".
set engList to Engine_ClockWise().

set mainRPM to list(0,0,0,0).
set rpm to 0.
set bankOffset to 0.
set pitchOffset to 0.
set hdgOffset to 0.



set rpmPID to pidLoop(25,	5,	    60,  0,460).


set bankPID to pidLoop(1.1,	0.012,	0.85,	-10,10).

set pitchPID to pidLoop(1.1,	0.012,	0.85,	-10,10).

set hdgPID to pidLoop(0.8,	0.01,	0.7,	-10,10).
// PID loops to control Speed and attitude
rotor_torque(20).
Declare function rotor_torque
{
   
    Parameter tq.
    for eng in engList{
        eng:getmodule("ModuleRoboticServoRotor"):setfield("torque Limit(%)",tq).
    }
}

Declare function quard_Basic
{
    Parameter _shipAtt.
    Parameter _shipControl.
    _alt(_shipControl:Alt).
    _bank(_shipATT:bank,_shipControl:bank).
    _pitch(_shipATT:pitch,_shipControl:pitch).
    _hdg(_shipATT:hdg,_shipControl:hdg).
    _setRPM().
    set _shipControl:rpm to rpm.
    
 //   pRINT " rpm set TO " + round(mainRPM[0],1) at (2,6).
}
Declare function _setRPM
{
    engList[0]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",rpm-bankoffset+pitchoffset-hdgOffset).
    engList[1]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",rpm-bankoffset-pitchoffset+hdgOffset).
    engList[2]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",rpm+bankoffset-pitchoffset-hdgOffset).
    engList[3]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",rpm+bankoffset+pitchoffset+hdgOffset).
  //  engList[0]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[0]).
   // engList[1]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[1]).
  //  engList[2]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[2]).
  //  engList[3]:getmodule("ModuleRoboticServoRotor"):setfield("rpm Limit",mainRPM[3]).
}
Declare function _alt
{
   
    Parameter targetALT.
    
    set rpmPID:setPoint to targetAlt.
    set x to min(1,max(-5,ship:altitude-targetALT)).
  //  set autoThrottle to climbPID:update(time:seconds,ship:VerticalSpeed).
    set rpm to rpmPID:update(time:seconds,altitude).
   
    print round(x,1)+"    " at (0,8).
    
 }

Declare function _Bank{
    parameter currentBank.
    parameter targetBank.
    set bankPID:setPoint to targetBank.
    set bankoffset to bankPID:update(time:seconds,currentBank).
    
    print "Bank  Correction : " + round(Bankoffset,1)+"     " at (0,5).
    

}
Declare function _Pitch
{
    parameter currentPitch.
    parameter targetPitch.
    set pitchPID:setPoint to targetPitch.
    set pitchoffset to pitchPID:update(time:seconds,currentPitch).
  
    print "Pitch Correction : " + round(pitchoffset,1)+"     " at (0,6).
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
    
  //  print "targetHDG+360: "+round(targetHDG+360,1)+" curr " + Round(currentHDG+360) at (5,5).

  //  print "targetHDG+360: "+round(updateHDG) at (5,6).

    print "  HDG Correction : " + round(HDGoffset,1)+"     " at (0,7).

    set hdgOffset to hdgPID:update(time:seconds,updateHDG).
  
}
