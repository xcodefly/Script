// Autopilot for the Prop plane. 
@lazyglobal off.
clearscreen.
declare local pitch to 0.
declare local roll to 0.
declare local  yaw to 0.
declare global east to 0.
declare local hdg to 0.
declare local alt to 0.


declare local airspeed to 0.


// List of PID loops to control the aircraft. 
declare local rollPID to  pidLoop(0.0151,0.011,0.02,-0.3,0.3).
declare local hdgPID to pidLoop(2,0.01,0.1,-45,45).  // This should give to turn rate base on how quickly you are turing. 
declare local deltaHDG to 0.
declare local pitchPID to  pidLoop(0.1,0.02,0.01,-1,1).
declare local altPID to  pidLoop(0.25,0.03,0.5,-20,20).
declare local iasPID to pidLoop(1.2,0.1,0.4,-20,20).
declare local targetIAS to 70.

declare local targetRoll to 10.
declare local targetHDG to 90.
declare local targetpitch to 2.
declare local targetAlt to ship:altitude.

// AutoPilot Modes
declare local pitchList to List("Pit"," VS","Alt","IAS").
declare local pitchMode to 3.
declare Local rollList to List("Roll"," HDG"," NAV").
declare local rollMode to 0.
declare local alt to 0.



// Lock 

lock east to vcrs(up:vector,north:vector).




// Main Loop.
until(false)
{


    attitude().
 //  EngineController ().
   // Help().
    Hud(2,10).


    AutoPilot().
    UserInput().
    wait(0).
}

function Hud
{
    parameter offset.
    parameter pad to 5.
//    print " Pitch : "+ round(pitch,1)   +"    " at (pad,2+offset).
//    print "  Roll : "+ round (roll,1 )  +"    " at (pad,3+offset).
//    print " Speed : "+ round(airspeed)  +"    " at (pad,4+offset).
//    print "   HDG : "+ round(hdg)       +"    " at (pad,5+offset).
//   print "   ALT : "+ round(altitude) + "     "  at (pad,6+offset).

    if (pitchMode=2)
    {
        print   " ALT : "+ round(altitude)+" [" +round(targetAlt/10)*10 +"]    "  at (0,2+offset).
    }
    else if pitchMode=0
    {
        print   " PIT : "+ round(pitch,1)+" [" +round(targetPitch,1) +"]    "   at (0,2+offset).
    }
    else if pitchMode=3
    {
        print   " IAS : "+ round(pitch,1)+" [" +round(targetIAS) +"]    "   at (0,2+offset).
    }




    if (rollMode=0)
    {
        print   "ROll : "+ round(roll)+" [" +round(targetRoll) +"]    "  at (20,2+offset).
    }
    else{
        print   "HDG : "+ round(hdg)+" [" +round(targetHDG) +"]    "  at (20,2+offset).
    }
  

}

function Attitude
{
    set pitch to 90-vang(up:vector,ship:facing:vector).
    set roll to vang(up:vector,ship:facing:rightvector)-90.
    set alt to ship:altitude.
    set airspeed to ship:velocity:Surface:mag.
    local tempHDG to vang(north:vector,ship:facing:vector).
    local temp to vang(east,ship:facing:vector).
    if abs(temp)<90
    {
        set hdg to tempHDG.
    }else {
        set hdg to 360-tempHDG.
    }
}




function AutoPilot
{
    // AutoPilot AG
    print " AG1 (Pit, VS,ALT,ISA)/  AG2 (Roll, HDG)" at (0,0).
    print "     Mode: " +pitchList[pitchMode] + "   "+rollList[rollMode] +"   " at (0,1).
    
    
    PitchControl().
    RollControl().
}   


function UserInput 
{
    if abs(ship:control:pilotpitch)>0.05
    {
        if (pitchmode=0)
        {
            set targetpitch to targetpitch+ ship:control:pilotpitch*0.5.
        }else if  (pitchmode=2)
        {
            set targetAlt to targetAlt + ship:control:pilotpitch*10.
        }else if  (pitchmode=3)
        {
            set targetIAS to targetIAs - ship:control:pilotpitch*1.
        }

    }
    

    if AG1
    {
        set pitchMode to pitchMode+1.
        Toggle Ag1.
        if (pitchMode>=(pitchList:length))
        {
            set pitchMode to 0.
        }
        if (pitchMode = 3)
        {
            set targetias to ship:airspeed.
            set iasPID:setpoint to targetIAS.
        }



    }
    if AG2{
        set rollMode to rollMode+1.
        Toggle Ag2.
        if (rollMode>=(rollList:length))
        {
            set rollMode to 0.
        }
        if rollMode=1
        {
            set targetHDG to hdg.
        }
    }
    if (pitchMode <>2)
    {
        set targetAlt to round(ship:altitude/100)*100.
    }


    if abs(ship:control:pilotRoll)>0.05
    {
        if (rollMode=0)
        {
            set targetRoll to targetRoll+ ship:control:pilotRoll*1.
        }else if rollmode=1
        {
            set targetHdg to targethdg+ ship:control:pilotRoll*1.
            if targetHDG<0
            {
                set targetHDG to 360-targetHDG.
            }else if targetHDG>360
            {
                set targetHDG to targetHDG-360.
            }
        }
    }
}

Function PitchControl
{
    if (pitchmode=0)
    {
       
        
    }
    else if (pitchmode=2)
    {
        set altPID:setpoint to round(targetAlt/10)*10.
        set targetPitch to altPID:update(Time:seconds,altitude).
       
      //  PRINT (" Values : "+Round(altPID:iterm,2) at (25,6).
    }
    else if(pitchmode=3)
    {
        set iasPID:setpoint to Round(targetIAS).
        set targetPitch to -iasPID:update(Time:seconds,airspeed).
    }
    ElevatorControl().
}

function ElevatorControl
{
   // parameter tPitch.
   
    set pitchPID:setpoint to targetPitch.
    set SHIP:CONTROL:pitch to pitchPID:update(Time:seconds,pitch).
}

function RollControl{
    if rollMode=0
    {
        SetRoll().
    }else if rollMode=1
    {
        HdgControl().
    }
    
}

function HdgControl
{
    set hdgPid:setpoint  to 0.
    set deltaHDG to hdg-targetHDG.
    if deltaHDG>180
    {
        set deltaHDG to 360-deltaHDG.
    }else if deltaHDG<-180
    {
        set deltaHDG to deltaHDG+360.
    }

    set targetroll to hdgPID:update(Time:seconds, deltaHDG).
    SetRoll().
}

function SetRoll
{
    set rollPID:setpoint to targetRoll.
  
    set SHIP:CONTROL:ROLL to rollPID:update(Time:seconds,roll).
}


