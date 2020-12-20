// Autopilot for the Prop plane. 
@lazyglobal off.
clearscreen.
declare local pitch to 0.
declare local roll to 0.
declare local  yaw to 0.
declare global east to 0.
declare local hdg to 0.
declare local alt to 0.
declare local partlist to 0.
declare local x to 0.
declare local airspeed to 0.
declare local engine to 0.

declare local enginePower to 10.
declare local prop to list().
declare local targetRPM to 400.
declare local currentRPM to 0.
declare local targetPropAngle to 90.

// List of PID loops to control the aircraft. 
declare local rollPID to  pidLoop(0.0251,0.011,0.007,-0.3,0.3).
declare local hdgPID to pidLoop(0.1,0.01,0.03,-5,5).  // This should give to turn rate base on how quickly you are turing. 
declare local pitchPID to  pidLoop(0.04,0.03,0.016,-1,1).
declare local altPID to  pidLoop(0.3,0.07,0.3,-20,20).


declare local targetRoll to 0.
declare local targetpitch to 8.
declare local targetAlt to ship:altitude.

// AutoPilot Modes
declare local pitchList to List("Pit"," VS","Alt","IAS").
declare local pitchMode to 2.
declare Local rollList to List("Roll"," HDG").
declare local rollMode to 0.
declare local alt to 0.

// Lock 

lock east to vcrs(up:vector,north:vector).
list parts in partlist.
for x in partlist
{
    if x:name:contains("engine")
    {
        set engine to x.
    } 
    if x:name:contains("Mediumpropeller")
    {
        prop:add(x).
    } 
    
}



// Main Loop.
until(false)
{


    attitude().
 //  EngineController ().
   // Help().
    Hud(2,10).
    HudEngine(13).
    PropControl().
    AutoPilot().
    UserInput().
    wait(0).
}

function Hud
{
    parameter offset.
    parameter pad to 5.
    print " Pitch : "+ round(pitch,1)   +"    " at (pad,2+offset).
    print "  Roll : "+ round (roll,1 )  +"    " at (pad,3+offset).
    print " Speed : "+ round(airspeed)  +"    " at (pad,4+offset).
    print "   HDG : "+ round(hdg)       +"    " at (pad,5+offset).
    print "   ALT : "+ round(altitude)  +"    " at (pad,6+offset).
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
    
    if AG1
    {
        set pitchMode to pitchMode+1.
        Toggle Ag1.
        if (pitchMode>=(pitchList:length))
        {
            set pitchMode to 0.
        }
    }
    if AG2{
        set rollMode to rollMode+1.
        Toggle Ag2.
        if (rollMode>=(rollList:length))
        {
            set rollMode to 0.
        }
    }
    if (pitchMode <>2)
    {
         set targetAlt to round(ship:altitude/100)*100.
    }
    PitchControl().
    RollControl().
}   


function UserInput // 
{
    if (pitchmode=0)
    {
        if abs(ship:control:pilotpitch)>0.3
        {
            set targetpitch to targetpitch+ ship:control:pilotpitch*1.
           
        }
    }else if  (pitchmode=2)
    {
        if abs(ship:control:pilotpitch)>0.3
        {
            set targetAlt to targetAlt+ ship:control:pilotpitch*100.
            set targetAlt to  round( targetAlt/100) * 100.
         
        }
    }
}

Function PitchControl
{
    if (pitchmode=0)
    {
       
        ControlPitch().
    }
    else if (pitchmode=2)
    {
        set altPID:setpoint to targetAlt.
        
        set targetPitch to altPID:update(Time:seconds,altitude).
        ControlPitch().
      //  PRINT (" Values : "+Round(altPID:iterm,2) at (25,6).
    }
}

function ControlPitch
{
   // parameter tPitch.
   
    set pitchPID:setpoint to targetPitch.
    set SHIP:CONTROL:pitch to pitchPID:update(Time:seconds,pitch).
}

function RollControl{
    help().
}

function Help
{
    if abs(ship:control:pilotRoll)>0.05
    {
        set targetRoll to targetRoll+ ship:control:pilotRoll*1.
        set rollPID:setpoint to targetRoll.
    }
    set SHIP:CONTROL:ROLL to rollPID:update(Time:seconds,roll).
}


function HudEngine
{
    parameter line.
    declare local offset to 1.
    set currentRPM  to  engine:getmodule("ModuleRoboticServoRotor"):getField("Current RPM").
    set targetRPM   to  engine:getmodule("ModuleRoboticServoRotor"):getField("rpm limit")*0.95.

    print "   Eng Tq :" + engine:getmodule("ModuleRoboticServoRotor"):getField("torque limit(%)")+"   " at (0,line+offset).
    print "      RPM :" + round( currentRPM)+"/"+Round(targetrpm)+"  " at (0,line+1+offset).
    print " Prop Ang :"  +ROUND( prop[0]:getmodule("ModuleControlSurface"):getField("deploy Angle"),1)+ "       " at (0,line+2+offset).
    print "Target Ang:"  +ROUND( targetPropAngle,1)+ "       " at (0,line+3+offset).
    
}


function PropControl
{

    set x to 0.
    if currentRPM>targetRPM*1.02
    {
        set targetPropAngle to targetPropAngle-0.13.
     //   print "    ON Seed." at (0,15).

    }else if currentRPM<targetRPM*0.98{
      //    print " UNder Seed." + currentRPM +"/ "+ targetRPM *0.9 at (0,15).
          set targetPropAngle to targetPropAngle+0.13.

    }

    set targetPropAngle to Max(55,min(80,targetPropAngle)).
    for p in prop
    {
        p:getmodule("ModuleControlSurface"):setfield("deploy Angle",targetPropAngle).
        set x to x+1.
    }
}