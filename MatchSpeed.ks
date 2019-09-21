
clearscreen.
//print out node's basic parameters - ETA and deltaV


set max_acc to ship:maxthrust/ship:mass.
lock vError to target:velocity:orbit - ship:velocity:orbit.
lock targetVec to target:position-ship:position.
lock steering to vError:Normalized.
set ut_burntime to BurnStartTime().
set aThrottle to pidLoop(1,0.01,0.5,0,1).
set aThrottle:setpoint to 10.
lock ApproachSpeed to (target:velocity:orbit-ship:velocity:orbit):Mag.
lock burnDistance to 1.1*ApproachSpeed^2/(2*max_Acc).
sas off.
rcs off.
// closed approach time
Declare function burnStartTime
{
    
    set tick to time:seconds.
    lock thisDistance to (positionat(ship,tick)-positionat(target,tick)):mag.
    lock nextdistance to  (positionat(ship,tick+1)-positionat(target,tick+1)):mag.
    until nextDistance>thisDistance
    {   
        set tick to tick+1.
        
         
    }
    Return tick.
}

until vError:mag<2
{
    HUD().
    if verror:mag>2
    {
        Burn().
    }
    else 
    {
        Dock().
    }
    vecHelp().
    wait 0.
}

Declare function Dock{

}


declare function HUD
{
    Print " V Error Mag : " + Round(vError:mag)+ "   " at (0,3).
    print " Burn in : " + Round(ut_burntime-time:seconds)+ "  " at (0,4).
    Print " Closer Rate : " +Round(approachSPeed,1)+ "  " at (0,5).
    Print " Burn Distance : " +Round(burnDistance,1)+ "  " at (0,6).
    print " Target Distance : " + round(target:distance) +"  " at (0,7).
}
Declare function vecHelp
{
    clearvecdraws().
    vecdraw(ship:position,target:velocity:orbit-ship:velocity:orbit,Red,"VelocityError",1,true).
    vecdraw(ship:position,targetVec,Red,"VelocitytargetError",1,true).

}
clearscreen.
Declare function burn{
    IF TARGET:DISTANCE<burnDistance
    {
        SET THROTTLE TO aThrottle:UPDATE(time:seconds,approachSPeed).
    }
    

}
set throttle to 0.
unlock throttle.
lock steering to north.   
Print "Pointing north. (5s)".
wait 5.

unlock steering. 
sas on.


//we no longer need the maneuver node


//set throttle to 0 just in case.
