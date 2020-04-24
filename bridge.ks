// need to clear the bridge.

// help me with the speed control. 
// nee help with altitude control. Because I am an Idiot. :(

parameter filename to "Bridge1.json".
Local activeplan to readjson(filename).
// Locks
    Lock East to vCRS (up:vector,north:vector).
    Lock hdgVector to vxcl(up:vector,ship:facing:vector).
    lock bankAngle to vang(up:vector,ship:facing:rightvector)-90.
    lock pitchAngle to 90-vang(up:vector,ship:facing:vector).
// Variables

    set targetALT to 111.
    set targetHDG to 90.
    set targetVS to 0.
    set targetSpeed to 65.
    set targetBank to 0.
    set minSpeed to 60.  // used for takeoff and control senstiving dampning as speed builds up.
    set shihHDG to HDG_update().
    set hdgError to shipHDG-targetHDG.
    
    set distTofix to 100.

    set nextAngle to 0.
    set aileron to 0.

// Autopilot variables
    set autoSpeed to true.
    set autoNavigate to false.
    set vMode to "Pitch".
    set lNav to "Roll".
    set targetPitch to 0.

// PID's
    set maxBank to 40.
    set elevator to 0.
    set aileron to 0.

    set throttlePID to pidLoop (0.065,0.006,0.33,0,1).
    set throttlePID:setpoint to targetSpeed.

    set altPID to pidloop(2.8,0.3,3,-10,20).
    set altPID:setpoint to targetAlt.

    set vsPID to pidloop (.01,0.01,0.027,-0.5,1).
    set vsPID:setpoint to 0.

    set pitchPID to pidLoop (.031,0.01,0.033,-0.5,0.5).
    set pitchPID:setpoint to 15.

    set elevatorPID to pidLoop(.031,0.01,0.027,-0.5,1).
    set elevatorPID:setpoint to 0.

    set hdgPID to pidLoop(2.5,0,0.10,-maxBank,maxBank).
    set hdgPID:setpoint to 0.

    set bankPID to pidloop(0.035,0.01,0.065,-.75,.75).
    set bankPID:setpoint to 0.
// Stage if requried.


if availablethrust<1
{
    stage.
    brakes off.
}
set power to 0.
lock throttle to power.
clearscreen.


set currentFix to 0.
set nextfix to currentfix+1.
updatePID().
updateVmode().
until false
{
    userINput().
    display().
    navDisplay().
    set power to throttlePID:update(time:seconds,airspeed).
    elevatorControl().
    set ship:control:roll to headingControl(activePlan[currentFix]:pos:bearing).
    wait 0.
}
unlock throttle.

Declare function updateVmode
    {
        // read the navigation (json) file and determing the waypoint and type of navication.
        // auto navigation should be on to fly the nav file automaticall.
        if activePLan[currentFix]:vmode:contains("pitch")
        {
            set vMode to "Pitch".
            set targetPitch to activePlan[currentFix]:vModeValue.
            set pitchPID:setpoint to targetPitch.
            
            
        } else if activePLan[currentFix]:vmode:contains("vs")
         { 
            set vMode to "alt".
            set targetVS to activePlan[currentFix]:vmodeValue.
           
        } else if activePLan[currentFix]:vmode:contains("alt")
        {
            set vMode to "Alt".
        }
        set targetAlt to activePlan[currentFix]:Alt.
    }

Declare function display
    {
        // print bassic airplane stats.
        print " Auto Throttle(Z) : "+autoSpeed at (0,0).
        print " Auto Navigate(N) : "+autoNavigate at (0,1).
        print " _____________________________ " at (0,3).
        Print "|  ALT   |   HDG   |  Speed   |   " at (0,4).
        //  print "|--------|---------|----------|   " at (0,5).
        print "|--------|---------|----------|   " at (0,6).
        print "|________|_________|__________|" at (0,8).
        // can we make it one string. 
        set currentValueStr to "|"+round(altitude):tostring:padLeft(5)+"   |"+(round(shipHDG)):tostring:padLeft(6)+"   |"+(round(groundspeed)):tostring:padLeft(6)+"    |".
        print currentValueStr at (0,5).
        set targetValueStr to "|"+targetALT:tostring:padLeft(5)+"   |"+"  Auto   |"+(round(targetSpeed)):tostring:padLeft(6)+"    |".
        print targetValueStr at (0,7).
        set selectedModeStr to "|"+ vmode:padLeft(6).
        print selectedModeStr at (0,9).
        print " Elevator " + Round(elevator,2) at (0,10).
        print " Pitch/TG " + round(pitchAngle)+"/ " + round (targetPitch)+"  " at (0,11).
     
      
    }
declare function nextwayPoint
    {
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
            
           
            updatePID().
            updateVmode().
        }
    }
declare function NavDisplay
    {
     //   print " Fix/Next : "+activeplan[currentfix]:info+" / "+activeplan[nextfix]:info +"   " at (0,13).
     //   print "Bearing/Distance  active Fix : "+round(activeplan[currentFix]:pos:bearing)+ " / " +round(distTofix)+ "   "at (0,12).
        nextwayPoint().
     //   print " Inbound/ Next Angle : "  +activePLan[currentFix]:inbound+" / " +Round(nextAngle)+"   "at (0,11).
        // radius of turn

        print " radius of turn : " + round (radiusOfturn)  + "   " at (0,14).
    }

declare function headingControl 
    {
        local parameter Error.
        HDG_update().
        set targetBank to -hdgPID:update(time:seconds,Error).
        
        set bankPID:setpoint to targetBank.
        set aileron to bankPID:update(time:seconds,bankangle)*minSpeed/groundspeed.
        // heading will use bankangle to maintain target heading.
    //  

        return aileron.
    }
declare function elevatorControl
    {
        if abs(targetAlt-altitude)<20
        
        {
            set vMode to "alt".
       //     print "AAAAAA".
        }
       
        if vMode="Pitch"
        {
            pitchMode().
        }else if vmode="vs"
        {
            vsMode().
        }else if vmode="Alt"
        {
            altMode().
        }
        
    }
declare function pitchMode
    {   
        
        if groundspeed > minSpeed-15
        {
            set elevator to pitchPID:update(time:seconds,pitchAngle).
        
        }else 
        {
            set elevator to 0.
        }
      //  print "AA".
        set ship:control:pitch to elevator.
        
    }
declare function vsMode
    {
        set elevator to vsPID:update(time:seconds,verticalSpeed).
        set ship:control:pitch to elevator.
    }

declare function altMode
    {
        set targetPitch to altPID:update(time:seconds,altitude).
        set pitchPID:setPoint to targetPitch.
        pitchMode().

    }


declare function userInput
    {
    if terminal:input:haschar 
    {
        set ch to terminal:input:getChar().
        Terminal:input:clear.
        if ch="e"
        {
            set vmode to "alt".
        }
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
        set targetALT to activePLan[currentFix]:alt.
        set targetSpeed to activePlan[currentFix]:speed.
         
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


