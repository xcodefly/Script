
clearscreen.
//print out node's basic parameters - ETA and deltaV


lock max_acc to ship:maxthrust/ship:mass.
lock vError to target:velocity:orbit - ship:velocity:orbit.
lock steering to vError:Normalized.
set ut_burntime to BurnStartTime().
clearscreen.

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

until vError:mag<0.1
{
    HUD().
    if verror:mag>3
    {
        PowerBurn().
    }
    else 
    {
        MatchV().
    }
  //  vecHelp().
    Target_connect().
    wait 0.
}


Declare function Target_connect
{
    Parameter targetShip to Target.
    set targetConnection to targetShip:connection.
    if targetConnection:isconnected = true{
        Print " Connection estalbised."  at (0,1).
    } else 
    {
         Print " Waiting to Connect .. "  at (0,1).
    }
    
}
Declare function MatchV{
    
    set throttle to min(1,vError:mag/1.5)/10.

}


declare function HUD
{
    Print " V Error Mag : " + Round(vError:mag)+ "   " at (0,3).
    print " Burn in : " + Round(ut_burntime-time:seconds)+ "  " at (0,4).
}
Declare function vecHelp
{
    clearvecdraws().
    vecdraw(ship:position,target:velocity:orbit-ship:velocity:orbit,Red,"VelocityError",1,true).

}
clearscreen.
Declare function PowerBurn{
    if time:seconds>ut_burntime-2
    {
        set throttle to min(1,vError:mag/1.5).

    }else 
    {
        set throttle to 0.
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
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.