// need to clear the bridge.

// help me with the speed control. 
// nee help with altitude control. Because I am an Idiot. :(

parameter filename to "Bridge1.json".
Local activeplan to readjson(filename).
// constants
Lock East to vCRS (up:vector,north:vector).
Lock hdgVector to vxcl(up:vector,ship:facing:vector).
lock bankAngle to vang(up:vector,ship:facing:rightvector)-90.
// Variables

    set targetALT to 200.
    set targetHDG to 90.
    set targetVS to 0.
    set targetSpeed to 65.
    set targetBank to 0.
    set minSpeed to 60.  // used for takeoff and control senstiving dampning as speed builds up.
    set shihHDG to HDG_update().
    set hdgError to shipHDG-targetHDG.
    set maxBank to 40.
    set distTofix to 100.
    set nextAngle to 0.

    set aileron to 0.
// PID's



    set throttlePID to pidLoop (0.05,0.003,0.35,0,1).
    set throttlePID:setpoint to targetSpeed.

    set altPID to pidloop(0.33,0.001,0.08,-20,20).
    set altPID:setpoint to targetAlt.

    set vsPID to pidloop (.031,0.01,0.027,-0.5,1).
    set vsPID:setpoint to 0.


    set hdgPID to pidLoop(2.5,0,0.10,-maxBank,maxBank).
    set hdgPID:setpoint to 0.
    set bankPID to pidloop(0.035,0.01,0.065,-.75,.75).
// Stage if requried.


if availablethrust<1
{
  //  stage.
}
set auto_Throttle to 0.
lock throttle to auto_Throttle.
clearscreen.
print "Auto Throttle = ON " at (0,0).

set currentFix to 0.
set nextfix to currentfix+1.
until false
{
   
    userINput().
    display().
    navDisplay().
   
    set auto_Throttle to throttlePID:update(time:seconds,airspeed).
    set ship:control:pitch to pitchControl().
    set ship:control:roll to headingControl(activePlan[currentFix]:pos:bearing).
    wait 0.
}
unlock throttle.

declare function display_OLD
    {
    print "                      " at (0,2).                   // Clear previous value
    print " Ship HDG : "+round(shipHDG)+" [ "+targetHDG+" ]  " +"  "+round(hdgError)+"    "  at (0,2).    
    print " ship ALT : "+round(altitude)+" [ "+targetAlt+" ]    " at (0,3).
    print " ship VS  : "+round(VerticalSpeed)+" [ "+Round(targetVS)+" ]    " at (0,4).
    print "    Speed : "+round(groundspeed)+" [ "+Round(targetSpeed)+" ]    " at (0,5).
 //   print " Bank Angle : "+ round(bankAngle)+"    " at (0,6).
    print "Press 'CTL+C' to exit " at (0,15).


    
    
}

Declare function display
{
    // print bassic airplane stats.
    print " _____________________________ " at (0,2).
    Print "|  ALT   |   HDG   |  Speed   |   " at (0,3).
    print "|--------|---------|----------|   " at (0,4).
    
    // can we make it one string. 
    set currentValueString to "|"+round(altitude):tostring:padLeft(5)+"   |"+(round(shipHDG)):tostring:padLeft(6)+"   |"+(round(groundspeed)):tostring:padLeft(6)+"    |".
    print currentValueString at (0,5).
    print "|--------|---------|----------|   " at (0,6).
    set targetValueString to "|"+targetALT:tostring:padLeft(5)++"   |"+(round(activePlan[currentFix]:pos:bearing)):tostring:padLeft(6)+"   |"+(round(targetSpeed)):tostring:padLeft(6)+"    |"..
    print targetValueString at (0,7).
     print "|_____________________________|" at (0,8).
}
Declare function dislplay_Mode
{

}

declare function nextwayPoint{
    if currentFix<activePlan:length-1
    {
        set nextfix to currentFix+1.
    }else 
    {
        set nextFix to 0.
    }
    set distTofix to (activePlan[currentfix]:pos:position-ship:geoposition:position):mag.
    set nextAngle to vang(activePlan[currentfix]:pos:position-ship:geoposition:position,activePlan[nextfix]:pos:position-activePlan[currentfix]:pos:position).
    set radiusOfturn to groundspeed^2/(9.81*tan(maxBank)).
    if (abs(activeplan[currentFix]:pos:bearing)>150 or distTofix < radiusOfturn/2)
    {
        set currentfix to nextFix.
        
        print "                       " at (20,0).
        set targetALT to activePLan[currentFix]:alt.
        set targetSPeed to activePlan[currentFix]:speed.
        
        updatePID().
    }
   
}
declare function NavDisplay{
    print " Fix/Next : "+activeplan[currentfix]:info+" / "+activeplan[nextfix]:info +"   " at (0,13).
    print "Bearing/Distance  active Fix : "+round(activeplan[currentFix]:pos:bearing)+ " / " +round(distTofix)+ "   "at (0,9).
    nextwayPoint().
    print " Inbound/ Next Angle : "  +activePLan[currentFix]:inbound+" / " +Round(nextAngle)+"   "at (0,10).
    // radius of turn

    
    print " radius of turn : " + round (radiusOfturn)  + "   " at (0,11).
}

declare function headingControl 
    {
    local parameter Error.
    HDG_update().
    set TargetBank to -hdgPID:update(time:seconds,Error).
    
    set bankPID:setpoint to targetBank.
    set aileron to bankPID:update(time:seconds,bankangle)*minSpeed/groundspeed.
    // heading will use bankangle to maintain target heading.
  //  

    return aileron.
}

declare function pitchControl
    {   
    if groundspeed > minSpeed-15
    {
        set targetVS to min(groundspeed/5,altPID:update(time:seconds,altitude)).
      
    }else 
    {
        set targetVS to 0.
    }
    set vsPID:setPoint to targetVS.
   
    set elevator to vsPID:update(time:seconds,VerticalSpeed)*minSpeed/groundspeed..
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
            
        }
        if ch = "e"
        {
            set targetAlt to targetAlt+1.
            
        }
         if ch = "w"
        {
            set targetSpeed to targetSpeed+1.
           
        }
        if ch = "s"
        {
            set targetSpeed to targetSpeed-1.
            
        }
        if ch = "n"
        {
            set activeplan to readjson(filename).
            print " Flight Plan refreshed " at (20,0).
        }
        updatePID().
    }
}

Declare function updatePID
    {
        set throttlePID:setpoint to targetSpeed.
        set altPID:setpoint to targetAlt.
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
    
    set hdgError to targetHDG-shipHDG.
    if hdgError<-180
    {
        set hdgError to hdgError+360.
    }
    else if hdgError >180
    {
        set hdgError to hdgError-360.
    }
}


