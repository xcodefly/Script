// land in the retrograde direciton an roughly periapsis.

// 75% thurst for retro until horizontal speed is rougly 10 m/s

// 75% thrust for hoverslam. 
clearscreen.
declare function disp{
    parameter dispOffset to 0.
    print " ETA to periapsis : " + round(eta:periapsis) + "  " at (0,1+dispOffset).
    Print " Velocity Horz : " +round(velHorizontal:mag) + "  " at (0,2+dispOffset).
    Print " Burn to Periapsis : " + Round(burntimePer)+"  " at (0,3+dispOffset).
    print " Throttle : " + round(aThrottle,2)+" " at (0,4+dispOffset).
    print " Max Acc  : " + round(maxAcc,1)+"  " at (0,5+dispOffset).
}

// Lock 

Lock MaxAcc to  ship:availableThrust/ship:mass.
lock maxDeAcc to MaxAcc - g.
Lock velHorizontal to vxcl(up:vector,ship:velocity:orbit).
lock g to constant:g * body:mass / body:radius^2.	
Lock timePer to eta:periapsis.
lock burntimePer to velHorizontal:mag/(0.75*maxAcc).



set throttlePID to pidLoop(0.5,0.01,0.05,0,1).
set throttlePID:setPoint to 0.
set aThrottle to 0.
Lock steering to retrograde.
Lock throttle to aThrottle.

until lights
{

    disp().
    align().
    wait 0.01.
}
lights off.
set Burntime to eta:periapsis.
set BurnStartTime to time:seconds.
until velHorizontal:mag<5
{
    disp().
    print " AA " at (0,5).
    set aThrottle to throttlePID:update(time:seconds,Burntime-(time:seconds-BurnStartTime) - burntimePer).
   // set aThrottle to 0.75.
    wait 0.1.
}



Declare Function Align
{   


}
