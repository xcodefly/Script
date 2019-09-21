// Hovercraft.ks has the orignal setting.
// Control Keys  - Q,E to change target Alt. 
	// WASD for forward, back, left right.

// **** need to work on . 
//  
// Script used to fly hovercraft/QuardCopter without using any reaction wheel. 
// This scrip have the following functions: ShipALT, FLightMode, HoverMode, HDGFunction, HUD and UserInput
	Clearscreen.
	Print " This is hover Craft Script - Using Engine Control.".
	Parameter targetAlt to Round(ship:altitude).
//Global Variables
	set shipHeight to alt:radar. 
	set tlimit to 0.
	
	set seekHDG to 0.
	Set aThrust to 1.
	set athrottle to 1.
	set targetHdg to 0.
	set asteer to heading(TargetHDG,0).
	set SpeedList to		 list(-1,    0,     1,   3,    5,   10,	 20, 45).
    set speedstep to 1.
	set HoverList to		 List(-1, -0.5, -0.25,   0, 0.25,  0.5,   1,  2).
	set HoverTranslate to	 List(-1, -0.5, -0.25,   0, 0.25,  0.5,   1,  1).
	
	set vspeed to 0.
	set targetRadar to 50.
    set requestPitch to 0.
	
	set Anchor to False.
	set AnchorLocation to ship:geoPosition.
	set Mode to "FlightMode".
	set autoThrust to List (0,0,0,0).

//PID Loops
	Set altPID to pidLoop(0.4, 0.01, 0.025, -05,5). // (10,0.3,0.7,-10,20).
    set altPID:setPoint to 0.
   
	set thrustPID to      pidLoop(20,   3,   3,    0,  100).        // (70,1,10,0,100). Contorl Engine
	set thrustPID:setpoint to 0.


	set JetThrustPID to pidLoop(1.1,	0.08,	0.07,	0,	100).
	set jetThrustPID:setpoint to 90.
    set jLimit to 0.
    set speedFrontPID to  pidLoop(2,	0.08,	0.8 ,   -25,    25). //(1,	0.03,	0.4 ,-20,20).
	set speedSlipPID  to  pidLoop(1.7,	0.09,	1 ,   -15,    15). //(1.4,	0.03,	0.55	 ,-20,20).


	set pitchPID to pidLoop(0.75, 0 , 0.5, -14, 14). //(0.75, 0 , 1.15, -14,14).
	set slipPID to  PIDLoop(0.5, 0.003 , 5, -0.1,0.1).  //(0.75, 0 , 1.15, -14,14).

//HDG PIDS
	set hdgPID to pidLoop(0.6,	0.03,	0.55,	-20,20).
	set hdgPID:SetPoint to 0.
	set rollPID to pidLoop(1.1,0.1,0.8,-5,5).
// Initializing/Declare vairables to avoid undefined variable errors or zero/NAN errors. 
	set RequredRollCorrection to 0.
	wait 0.1.
    if availableThrust<1
    {
        	stage.
    }

	wait 1.
// Locks

	Lock throttle to athrottle.
	Lock steering to aSteer.
	lock front to ship:facing:FOREVECTOR.
	lock shipPItch to -(arccos(vdot(up:vector,Front))-90).
	lock shipRoll to ArcCos(vdot(up:vector,Ship:facing:rightvector))-90.
	lock east to vcrs(up:vector,north:Vector).
	lock frontHDGV to vxcl(up:vector,front).
// Syncing you Target Heading with Current Facing Vactor
	set vFront to vdot(ship:velocity:surface,front).
	lock vSlip to vdot(ship:velocity:surface,ship:facing:rightvector).
	if vang(frontHDGV,east)<90 {	set ShipHDG to  vang(frontHDGV,north:vector).	}
		else	{	set shipHDG to  360-vang(frontHDGV,north:vector).}
	set TargetHDG to Round(shipHdg).
	List Engines in Elist.

// Detecting engines. 
List parts in Plist.
set jetEngine to ship:partstagged("JET"). // Two jet engines for effeciency, and two rocket engines for faster response
set controlEngine to ship:partstagged("Control").





until Gear and Lights
	{
		HUD().
		Shipalt().
		HDGFunction().
		if Mode = "FlightMode"
			{
				FlightMode().
			}
			else{
		//		HoverMode().
                
            }
		SetThrust().
		userInput().
		Draw().
		wait .01.
	}

// ShipALT   - two pids are used to control the altitude of the craft. 
// altPID    - calculate the erron in target altitude vs current altitude and request vertical speed to get to its target altitude. 
// ****  need to work so four engines are automatically or semi-automatically seleced in case ship is edited. Had to be adjusted manually for now. 
Declare Function shipALt
	{
        
        set vSpeed to altPID:update(time:seconds,altitude-targetAlt).
        set thrustPID:setpoint to vspeed.

        set tlimit to thrustPID:update(time:seconds,verticalspeed).
      	set jLimit to JetThrustPID:update(time:seconds,100-tlimit).	
		
	}
// FlightMode is used to calculate tilt and bank. Switchs to HoverMode when seleced speed to low and craft is moving slowly. 
// **** lots of redundent lines to set pitch using autothrust variable in FlightMode and Hover Mode. needs to clean. 
Declare Function FlightMode
	{
	//	if Abs(speedlist[speedstep])<2 and ship:groundspeed<2
	//	{
	//		set Mode to "HoverMode ".
	//		set speedstep to 3.
	//		set Translatestep to 3.
	//	}
		// Pitch Calculation for Speed Control
	
			set speedFrontPID:setpoint to -speedlist[speedstep].
			set vFront to vdot(ship:velocity:surface,front).
			set requestPitch to speedFrontPID:Update(time:seconds,-vFront).
			set PitchPID:setpoint to requestPitch.
		
		
			
			set speedSlipPID:setpoint to 0.
			set RequstedRoll to speedSlipPID:update(time:seconds, -vslip).
		//	SET SHIP:CONTROL:ROLL TO RequstedRoll.
		//	print "slipRe - " + round(RequstedRoll,2) + "   "at (0,14).
		//Bank Calculation to cancel any slip Velocity.	
		//	set asteer to ship:facing:rightvector+R(requestPitch,0,0).
			set asteer to heading(TargetHDG,requestPitch)+r(0,0,RequstedRoll).

			
		
	
	
	}

Declare Function HoverMode
	{
		if speedstep=7 and vFront>0.5
			{
				set Mode to "FlightMode".
				set speedstep to 3.
			}
		if speedstep=3 and Translatestep = 3 and ship:groundspeed<0.5 and Anchor = False
			{
				Set Anchor to true.
				set AnchorLocation to ship:geoPosition.
				
			}
			Else if Speedstep<>3 or TranslateStep<>3
			{
				Set Anchor to False.
			}
		
		// Anchoring the ship to a locaiton and putting some constrains so it it is not too aggresive in correciton. 
		
	
		
		//Bank Calculation to cancel any slip Velocity.	
		
	
		
	
	}
// Calculate heading. value is calculate excluding up from ship(to account for tilt) and vdot with the North vector. 
// ***** senstive need work and 0 degree and 360 degree need some rework. 
Declare Function HDGFunction
	{	
			
			if vang(frontHDGV,east)<90 
			{
				set ShipHDG to  vang(frontHDGV,north:vector).
			}else
			{
				set shipHDG to  360-vang(frontHDGV,north:vector).
			}
		
			// Diagnostic Display	
				//Print " HDG offset -----------> " + Round(ThrustOffset,3).
				//Print " Seek HDG "+ Round(SeekHDG).
				//Print " ROll Rate " + round(rollrate,2) + " ["+Round(TargetRollRate,2)+"]".	
		
		
	}

Declare Function SetThrust
	{
		set JetEngine[0]:ThrustLimit to jLimit.
		set JetEngine[1]:ThrustLimit to jLimit.
        set JetEngine[2]:ThrustLimit to jLimit.
		set JetEngine[3]:ThrustLimit to jLimit.

		set controlEngine[0]:ThrustLimit to tlimit.
		set controlEngine[1]:ThrustLimit to tlimit.
	}


Declare Function draw
	{
			clearvecdraws().
	//		Vecdraw(ship:position, front*2,White,"Front", 1, True).
		//	vecdraw(ship:position,elist[0]:position,Red,"LeftFront",1,true).
		//	vecdraw(ship:position,elist[1]:position,Red,"RightFront",1,true).
		//	vecdraw(ship:position,elist[2]:position,Red,"RightBack",1,true).
		//	vecdraw(ship:position,elist[3]:position,Red,"LeftBack",1,true).
		//	vecdraw(ship:position,Ship:facing:rightVector,white,"RightVector",1,true).
		//	vecdraw(ship:position, east*5,yellow,"east",1,true).
	//	if anchor=true{
	//		vecdraw(anchorlocation:position,up:vector*2,White,"Anchor",1,True).
		//}
	}
// Display Function. 
//  **** need to use 'AT' to stop the text from jumping around. [used to display target values]
Declare Function hud
	{
		
		Print " -------------------" at (0,0).
		Print " |    " + Mode + "   | "at (0,1)..
		Print " -------------------"at (0,2)..
		if alt:Radar < 10
			{
				Print "  Altitude  : " + Round (Ship:altitude) + " ["+ TargetAlt+"]"+" RA:"+round(alt:radar,1)+"  " at (0,3)..
			}
			else
			{
				Print "  Altitude  : " + Round (Ship:altitude) + " ["+ TargetAlt+"]                        " at (0,3).
			}
		Print "        HDG : " + Round (SHipHDG) + " ["+TargetHDG+"]      "     at (0,4).
		print "         VS : " + round(verticalSpeed,1)+ " ["+round(vspeed,1)+"]   " at (0,5).
		
        if mode = "FlightMode"
			{	
				Print "     Speed  : " + Round(vFront) +" ["+speedlist[Speedstep]+"]      "    at (0,6). 
			}
			Else if Mode = "HoverMode "
			{	
				Print "     Speed  : " + Round(vFront,1) +" ["+Round (HoverList[Speedstep],1)+"]   " at (0,6).
			}

		
		if mode = "FlightMode"
			{
				Print "      Slip  : " + round (vslip,2) +"      "  at (0,7).
			} 
			else if "HoverMode "
			{
				Print "      Slip  : " + round (vslip,2) + " ["+Round (HoverTranslate[Translatestep],1)+"]     " at (0,7).
			}
			
//		Print "     Pitch  : " + round(shipPitch,1) + " ["+Round(requestPitch,1)+"]"./
//		Print "      Roll  : " + Round(shiproll,1) + " ["+Round(-RequredRollCorrection,1)+"]".
//		Print " ------------------------".
//		Print " Anchor Mode: "+ anchor.
		print "tLimit/JLimit - " + round(tlimit)+"/"+round(jLimit) + "    "at (0,9).
		//Print Elist.
	}


Declare Function userInput
	{
		if terminal:input:haschar 
			{
				set ch to terminal:input:getChar().
				Terminal:input:clear.
				if ship:groundspeed<5 or abs(shipHDG-TargetHDG)<2
					{
						set hdgstep to 1.
					}else 
					{
						set hdgstep to 5.
					}
				if ch = "a"
				{
					set TargetHdg to TargetHdg - hdgstep.
					if TargetHdg<0
					{
						Set TargetHdg to TargetHdg+360.
					}
				}
				if ch = "d"
				{
					
					set TargetHdg to TargetHdg + hdgstep.
					if TargetHdg>360
					{
						Set TargetHdg to TargetHdg-360.
					}
				}
				if ch = "s"
				{
					set speedstep to Max(speedstep-1,0).
					set TargetSpeed to speedlist[speedstep].
				}
				if ch = "w"
				{
					set speedstep to min(speedstep+1,7).
					set TargetSpeed to speedlist[speedstep].
				}
				if ch = "n"
				{
					set targetAlt to targetAlt-1.
			
				}
				if ch = "h"
				{
					set targetAlt to targetAlt+1.
				}
				if CH = "j"
				{
					set Translatestep to Max(TranslateStep-1,0).
				
				}
				if ch = "l"
				{
					set Translatestep to min(Translatestep+1,7).
				}
			}

	}


