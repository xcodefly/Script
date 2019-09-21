// All the pitch movements are in this file. 
    //Lock East to vCRS (up:vector,north:vector).
    //Lock velocityEast 		to	round (vDot(East,ship:velocity:surface),2).
    //Lock velocityNorth 		to	Round (vDOt(North:vector,Ship:velocity:surface),2).
    //Lock TargetEast		 	to	Round (vdot(Landloc:position,East),2). // Needs Work with East Vector. 
    //Lock TargetNorth		to 	Round (Vdot(LandLoc:position,North:vector),2).

set TargetLoc to LatLng(0,0).
set pitchX to 0.

Set PitchPID to PidLoop(1,.005,.01,-30,30).
set pitchpid:setPoint to 0.
Set RollPID to PidLoop(1,.005,.01,-30,30).

// Hold the given position
Declare Function HoldPosition{
    lock frontDistance to vdot(ship:facing:vector,TargetLoc:Position).
    
    set pitchX to pitchPID:update(time:seconds,-frontdistance).
    return R(pitchX,0,0).
   
}