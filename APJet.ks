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
declare local rollPID to  pidLoop(0.02,0.01,0.020,-0.2,0.2).
declare local hdgPID to pidLoop(1.0,0.005,0.2,-30,30).  // This should give to turn rate base on how quickly you are turing. 
declare local deltaHDG to 0.
declare local pitchPID to  pidLoop(0.1,0.02,0.01,-1,1).
declare local altPID to  pidLoop(0.25,0.04,0.65,-20,20).
declare local iasPID to pidLoop(1.0,0.2,0.35,-30,30).

declare local targetIAS to 200.
declare local targetRoll to 30.
declare local targetHDG to 10.
declare local targetpitch to 5.
declare local alt to 0.
declare local targetAlt to ship:altitude.


// AutoPilot Modes
declare local pitchList to List("Pit","IAS","Alt").

declare Local rollList to List("Roll","HDG","NAV").


declare local pitchMode to 1.
declare local rollMode to 2.

declare local NavList to list().
declare Local FullNavList to List().
declare local AirportList to list().
declare local AllResource to list().
declare local LiquidFuel to 0.


declare local FuelFlow to 0.
declare Local FuelEndurance to 0.
declare local NavDistance to 0.
declare local TimeStep to Time:Seconds.
declare local FuelStep to 0.
declare local loop to true.

list resources in AllResource.
for r in AllResource
{
    if r:name="LiquidFuel"
    {
        set LiquidFuel to r.
    }
}
set fuelStep to LiquidFuel:amount.

// Lock 

lock east to vcrs(up:vector,north:vector).
declare local APList to pitchList:join(",").
set APList to apList+" /  "+rolllist:join(",").

set FullNavList to allwaypoints().

// Main Loop.
until(not loop)
{


    attitude().
 //  EngineController ().
   // Help().
    Hud(2,10).
    FuelManager().

    AutoPilot().
    UserInput().
    
    wait(0).
}
clearscreen.
toggle rcs.
Print " Manual Control, AP Off.".
SET SHIP:CONTROL:NEUTRALIZE to True.

function FuelManager
{
    if (round(time:seconds)>timeStep)
    {   
        set FuelFlow to Round(fuelStep-LiquidFuel:amount,4).
        set timeStep to round(time:seconds).
        set fuelStep to LiquidFuel:amount.
    }

    if FuelFlow>0
    {
       set  FuelEndurance to LiquidFuel:amount/FuelFlow.
    }



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

    if ( Pitchlist[pitchmode]="Alt")
    {
        print   " ALT : "+ round(altitude)+" [" +round(targetAlt/10)*10 +"]    "  at (0,2+offset).
    }
    else if (Pitchlist[pitchmode]="Pit")
    {
        print   " PIT : "+ round(pitch,1)+" [" +round(targetPitch,1) +"]  "   at (0,2+offset).
    }
    else if (Pitchlist[pitchmode]="IAS")
    {
        print   " IAS : "+ round(pitch)+" [" +round(targetIAS) +"]   "   at (0,2+offset).
    }

    print "Target Roll : "+round(targetRoll,2)+ "    " at(0,8).
    

    if (RollList[rollMode]="Roll")
    {
        print   "ROll : "+ round(roll)+" [" +round(targetRoll) +"]        "  at (20,2+offset).
    }
    else if (RollList[rollMode]="HDG")
    {
        print   "HDG : "+ round(hdg)+" [" +round(targetHDG) +"] DeltaHDG : ["+Round(deltaHDG,1)+"]      "  at (20,2+offset).
    }else if (RollList[rollMode]="NAV")
    {
        print   "NAV : "+ round(hdg)+" [" +round(targetHDG) +"] DeltaHDG : ["+Round(deltaHDG,1)+"]      "  at (20,2+offset).
    }
  
    print "Fuel : " + Round(LiquidFuel:amount/LiquidFuel:Capacity*100,1)+"%  " at (0,5).
    print "FuelFlow : " +   round (FuelFlow,4) at (0,6).
    print "Fuel Endurance/ Time : " +   round (FuelEndurance/60)+" Min / "+Round(NavDistance/1000/airspeed*60) +"   "   at (0,7).
    

}

function Attitude
{
    set pitch to 90-vang(up:vector,ship:facing:vector).
    set roll to vang(up:vector,ship:facing:rightvector)-90.
    set alt to ship:altitude.
    set airspeed to ship:velocity:Surface:mag.
    local tempHDG to vang(north:vector,vxcl(up:vector, ship:facing:vector)).
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
  //  print "Pit,IAS,Alt / (Roll, HDG)" at (0,0).
    print APList at (0,0).
    print " Airport/Nav : "+AirportList:length+"/"+NavList:length at (0,1).

    print "     Mode: " +pitchList[pitchMode] + "   "+rollList[rollMode] +"   " at (0,2).
    
    
    PitchControl().
    RollControl().
}   


function UserInput 
{
    if abs(ship:control:pilotpitch)>0.05
    {
        if (Pitchlist[pitchmode]="PIT")
        {
            set targetpitch to targetpitch+ ship:control:pilotpitch*0.5.
        }else if  (Pitchlist[pitchmode]="ALT")
        {
            set targetAlt to targetAlt + ship:control:pilotpitch*10.
        }else if  (Pitchlist[pitchmode]="IAS")
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
        if (Pitchlist[pitchmode]="IAS")
        {
            set targetias to ship:airspeed.
            set iasPID:setpoint to targetIAS.
        }
        if (Pitchlist[pitchmode]="ALT")
        {
            set targetALt to ship:altitude.
            set altPID:setpoint to targetALt.
        }
      


    }
    if AG2{
        set rollMode to rollMode+1.
        Toggle Ag2.
        if (rollMode>=(rollList:length))
        {
            set rollMode to 0.
        }
        if (Rolllist[rollmode]="HDG")
        {
            set targetHDG to hdg.
            print " HDG HDG" at (0,4).
        }
        
    }
   
    if RCS{
        set loop to false.
    }
    
   
    if abs(ship:control:pilotRoll)>0.05
    {
        if (Rolllist[rollmode]="Roll")
        {
            set targetRoll to targetRoll+ ship:control:pilotRoll*1.
        }else if (Rolllist[rollmode]="HDG")
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
    if (Pitchlist[pitchmode]="PIT")
    {
       
        
    }
    else if (Pitchlist[pitchmode]="Alt")
    {
        set altPID:setpoint to round(targetAlt/10)*10.
        set targetPitch to altPID:update(Time:seconds,altitude).
       
      //  PRINT (" Values : "+Round(altPID:iterm,2) at (25,6).
    }
    else if(Pitchlist[pitchmode]="IAS")
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
    if Rolllist[rollmode]="Roll"
    {
        SetRoll().
    }else if Rolllist[rollmode]="HDG"
    {
        HdgControl().
    }else if Rolllist[rollmode]="NAV"
    {
        
        FindActiveWaypoint().
        HdgControl().
    }
    
}

function FindActiveWaypoint
{
    for point in FullNavList
    {
        if point:isSelected
        {
            set targetHDG to point:Geoposition:heading.
            set NavDistance to point:Geoposition:Distance.
        }
    }
}
function HdgControl
{
    set hdgPid:setpoint  to 0.
    set deltaHDG to (targethdg-hdg).
    if (SIN(DELTAHDG)>0)
    {
        if(abs(deltaHDG)>180)
        {
            set  deltaHDG to abs(deltaHDG+360).
        }else
        {
            set  deltaHDG to abs(deltaHDG).
        }
        
    }else
    {

        if(abs(deltaHDG)>180)
        {
            set  deltaHDG to -abs(360-deltaHDG).
        }else
        {
            set  deltaHDG to -abs(deltaHDG).
        }
       
    }
    set targetroll to hdgPID:update(Time:seconds, -deltaHDG).
    SetRoll().
}

function SetRoll
{
    set rollPID:setpoint to targetRoll.
  
    set SHIP:CONTROL:ROLL to rollPID:update(Time:seconds,roll)*(min(altitude,4000)+2000)/7000.
}


