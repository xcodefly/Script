// Hover function 1. Hover 2. HoverLoc


// Vertical Speed PID
set vsPID to pidLoop(0.35,0.007,0.18,-5,5). // Electric engine optimized

//set HoverPID to PidLoop(0.095,0.1,0.08,0,1). // Electic ducted engine optimized
 set HoverPID to PidLoop(0.07,0.1,0.015,0,1). // rocket engine ducted engine optimized

set vsPID:SetPoint to 0.


// tAlt, vspeed
set targetvs to 0.
Set targetAlt to 0.

Declare Function Climb{
    
	

	set autoThrottle to climbPID:update(time:seconds,ship:VerticalSpeed).
	
}

declare function altControl{
    Parameter newAlt to 0.
    Parameter hoverMode to 0.  
    // HoverMode have the following modes
    // 0 - Hold Altitude
    // 1 - Hold radar Alt. 
    set TargetAlt to newAlt.
    set HoverPID:setPoint to TargetALT.
    if HoverMode =0
    {
        
        set targetVS to vsPID:update(time:Seconds,Altitude-targetALT).
        set HoverPID:setpoint to targetVS.
        set autoThrottle to HoverPID:update(time:seconds,verticalSpeed).
	} else if HoverMode =1
    {
        set targetVS to vsPID:update(time:Seconds,Alt:radar-targetAlt).
        set HoverPID:setpoint to targetVS.
        set autoThrottle to HoverPID:update(time:seconds,verticalSpeed).
    }
 
}

Declare Function land{
    
	moveSpeed(0,0,targetHDG).
    if groundspeed>0.5
    {
         altControl(5,1).
    } else 
    {
        altControl(0,1).
    }

    
}
