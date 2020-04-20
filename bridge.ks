// need to clear the bridge.

// help me with the speed control. 
// nee help with altitude control. Because I am an Idiot. :(

// constants

set target_radar to 10.
set avg_terrain to 0.
// PID's
set throttle_PID to pidLoop (0.04,0.025,0.3,0,1).

set throttle_PID:setpoint to 45.

set radar_PID to pidloop(0.14,0.035,0.075,-0.7,0.7).
set targetALT to 77.
set radar_PID:setpoint to targetAlt.

// Stage if requried.


if availablethrust<1
{
    stage.
}
set auto_Throttle to 0.
lock throttle to auto_Throttle.
clearscreen.
print "Auto Throttle = ON " at (0,0).

until false
{
    
    display().
    altError().
    set auto_Throttle to throttle_PID:update(time:seconds,groundspeed).
    set ship:CONTROL:PITCH  to radar_PID:update(time:seconds,altitude). 
    if lights=true{
        set targetALT to targetALT+1.
        set radar_PID:setpoint to targetAlt.
        lights off.
    }
    else if brakes= true {
        set targetALT to targetALT-1.
        set radar_PID:setpoint to targetAlt.
        
        brakes off.
    }
    IF GEAR=false{
        SET targetALT to 120.
        set radar_PID:setpoint to targetAlt.
    }
  
    wait 0.
}
unlock throttle.

declare function display
{
    print "                      " at (0,2).                   // Clear previous value
    print " Throttle : "+round(auto_Throttle,1) at (0,2).    
    print "                      " at (0,3).                   // Clear previous value
    print "TargetAlt : "+round(targetALT,1) at (0,3).
  
    print "Press 'CTL+C' to exit " at (0,7).
    
}

declare function altError
{
    set avg_terrain to (ship:geoposition:terrainHeight).
}