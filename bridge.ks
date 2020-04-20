// need to clear the bridge.

// help me with the speed control. 
// nee help with altitude control. Because I am an Idiot. :(

// constants
Lock East to vCRS (up:vector,north:vector).
Lock hdgVector to vxcl(up:vector,ship:facing:vector).
lock bankAngle to vang(up:vector,ship:facing:rightvector)-90.
// Variables

set targetALT to 80.
set targetHDG to 95.
set targetVS to 0.
set targetSpeed to 50.

set shihHDG to HDG_update().
// PID's



set throttlePID to pidLoop (0.048,0.007,0.38,0,1).
set throttlePID:setpoint to targetSpeed.

set altPID to pidloop(0.4,0.001,0.08,-15,20).
set altPID:setpoint to targetAlt.

set vsPID to pidloop (.02,0.03,0.015,-1,1).
set vsPID:setpoint to 0.


set   bankPID to pidLoop(0.1,0.01,0.05,-30,30).
set bankPID:setpoint to targetHDG.
// Stage if requried.


if availablethrust<1
{
 //   stage.
}
set auto_Throttle to 0.
lock throttle to auto_Throttle.
clearscreen.
print "Auto Throttle = ON " at (0,0).

until false
{
    hdg_update().
    userINput().
    display().
    
    set auto_Throttle to throttlePID:update(time:seconds,airspeed).
    set ship:control:pitch to pitchControl().
    
    wait 0.
}
unlock throttle.

declare function display
{
    print "                      " at (0,2).                   // Clear previous value
    print " Ship HDG : "+round(shipHDG)+" [ "+targetHDG+" ]    " at (0,2).    
    print " ship ALT : "+round(altitude)+" [ "+targetAlt+" ]    " at (0,3).
    print " ship VS  : "+round(VerticalSpeed)+" [ "+Round(targetVS)+" ]    " at (0,4).
    print " Speed : "+round(groundspeed)+" [ "+Round(targetSpeed)+" ]    " at (0,5).
    print "Press 'CTL+C' to exit " at (0,7).

    print " Bank Angle : "+ round(bankAngle)+"    " at (0,6).
    
}

declare function headingControl
{
    // heading will use bankangle to maintain target heading.
    set targetBank to bankPID:update(time:seconds,shipHDG).


}

declare function pitchControl
{   
    set targetVS to altPID:update(time:seconds,altitude).
    set vsPID:setPoint to targetVS.
    set elevator to vsPID:update(time:seconds,VerticalSpeed).
    return elevator.
}

declare function userInput
{
    if terminal:input:haschar 
    {
        set ch to terminal:input:getChar().
        Terminal:input:clear.
        if ch = "d"
        {
            set targetHDG to targetHDG+1.
            if targetHDG>360
            {
                set targetHDG to 1.
            }
        }
        if ch = "a"
        {
            set targetHDG to targetHDG-1.
            if targetHDG<1
            {
                set targetHDG to 360.
            }
        }
        if ch = "q"
        {
            set targetAlt to targetAlt-1.
            set altPID:setpoint to targetAlt.
        }
        if ch = "e"
        {
            set targetAlt to targetAlt+1.
            set altPID:setpoint to targetAlt.
        }
         if ch = "w"
        {
            set targetSpeed to targetSpeed+1.
            set throttlePID:setpoint to targetSpeed.
        }
        if ch = "s"
        {
            set targetSpeed to targetSpeed-1.
            set throttlePID:setpoint to targetSpeed.
        }
    }
}

Declare function HDG_update
{
    if vang(hdgVector,east)<90 
        {
            set ShipHDG to  vang(hdgVector,north:vector).
        }
    else
        {
            set shipHDG to  360-vang(hdgVector,north:vector).
        }
      
}