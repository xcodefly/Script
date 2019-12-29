//   KEYSs  
// **** need to work on . 
//  
// Script used to fly hovercraft/QuardCopter without using any reaction wheel. 
// This scrip have the following functions: ShipALT, FLightMode, HoverMode, HDGFunction, HUD and UserInput
	Clearscreen.
	Print " This is hover Craft Script - Using Engine Control.".
	Parameter targetAlt to Round(ship:altitude).
//Global Variables
	set shipHeight to alt:radar. 
	set athrottle to 1.
	set seekHDG to 0.
	Set aThrust to 0.
	set targetHdg to 0.
	set asteer to heading(TargetHDG,90).
	set SpeedList to		 list(-1,    0,     1,   3,    5,   10,	 20, 45).
	set HoverList to		 List(-1, -0.5, -0.25,   0, 0.25,  0.5,   1,  2).
	set HoverTranslate to	 List(-1, -0.5, -0.25,   0, 0.25,  0.5,   1,  1).
	set speedstep to 1.
	set TranslateStep to 3.
	set shipHDG to 0.
	Set OLDhdg to shiphdg.
	set OldTime to time:seconds.
	Set targetSpeed to speedList[speedstep].
	
	set targetRadar to 50.
	set requestPitch to 0.
	set Anchor to False.
	set AnchorLocation to ship:geoPosition.
	set Mode to "FlightMode".
	set autoThrust to List (0,0,0,0).

//PID Loops
	Set altPID    to pidLoop(6,0.3,0.7,-10,20).
	set thrustPID to pidLoop(70,1,10,0,100).
	set speedFrontPID to  pidLoop(1,	0.03,	0.4 ,-20,20).
	set speedSlipPID  to  pidLoop(1.4,	0.03,	0.55	 ,-20,20).

	set pitchPID to pidLoop(0.75, 0 , 1.15, -14, 14).
	set slipPID to  PIDLoop(0.75, 0 , 1.15, -14,14).

//HDG PIDS
	set hdgPID to pidLoop(0.6,	0.03,	0.55,	-20,20).
	set hdgPID:SetPoint to 0.
	set rollPID to pidLoop(1.1,0.1,0.8,-5,5).
// Initializing/Declare vairables to avoid undefined variable errors or zero/NAN errors. 
	set RequredRollCorrection to 0.
	wait 0.1.
	stage.
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
	set vSlip to vdot(ship:velocity:surface,ship:facing:rightvector).
	if vang(frontHDGV,east)<90 {	set ShipHDG to  vang(frontHDGV,north:vector).	}
		else	{	set shipHDG to  360-vang(frontHDGV,north:vector).}
	set TargetHDG to Round(shipHdg).
	List Engines in Elist.

// Detecting engines. 
    List Engines in EngineList.
	For E in enginelist
	{
		if vdot(front,e:position)>0.1 and vdot(e:position,ship:facing:rightvector)> 0.1
		{
			set elist[1] to e.
		}
		
		if vdot(front,e:position)>0.1 and vdot(e:position,ship:facing:rightvector)< 0.1
		{
			set elist[0] to e.
		}
		
		if vdot(front,e:position)<0.1 and vdot(e:position,ship:facing:rightvector)>0.1
		{
			set elist[2] to e.
		}
		
		if vdot(front,e:position)<0.1 and vdot(e:position,ship:facing:rightvector)< 0.1
		{
			set elist[3] to e.
		}
		Wait 0.1.
		Print "setting up eingiens".
	}




until Gear and Lights
	{
		HUD().
		Shipalt(TargetAlt).
		HDGFunction().
		if Mode = "FlightMode"
			{
				FlightMode().
			}
			else{
				HoverMode().
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
		parameter MaintainAlt to 70.
		set altPID:setPoint to 0.
		set targetVspeed to altPID:update(time:seconds,(ship:altitude-TargetALt)/8).
		set thrustPID:setPoint to targetVspeed.
		set athrust to thrustPID:update(time:seconds,ship:verticalSpeed).
		set autoThrust[0] to athrust.
		set autoThrust[1] to athrust.
		set autoThrust[2] to athrust.
		set autoThrust[3] to athrust.
		Print "    V Speed : "+Round(Ship:verticalSpeed,1) + " [" + Round(TargetVspeed,1)+"]".
		Print " Ave Thrust : "+Round(athrust)+" %".
	}
// FlightMode is used to calculate tilt and bank. Switchs to HoverMode when seleced speed to low and craft is moving slowly. 
// **** lots of redundent lines to set pitch using autothrust variable in FlightMode and Hover Mode. needs to clean. 
Declare Function FlightMode
	{
		if Abs(speedlist[speedstep])<2 and ship:groundspeed<2
		{
			set Mode to "HoverMode ".
			set speedstep to 3.
			set Translatestep to 3.
		}
		// Pitch Calculation for Speed Control
			set speedFrontPID:setpoint to -speedlist[speedstep].
			set vFront to vdot(ship:velocity:surface,front).
			set requestPitch to speedFrontPID:Update(time:seconds,-vFront).
			set PitchPID:setpoint to requestPitch.
			set differentialThrust to PitchPID:update(time:seconds,shipPitch).
		//Front Engines
			set autoThrust[0] to autoThrust[0]+differentialThrust.
			set autoThrust[1] to autoThrust[1]+differentialThrust.
		//Back Engines
			set autoThrust[2] to autoThrust[2]-differentialThrust.
			set autoThrust[3] to autoThrust[3]-differentialThrust.
			
		//Bank Calculation to cancel any slip Velocity.	
			set speedSlipPID:setpoint to 0.
			set vSlip to vdot(ship:velocity:surface,ship:facing:rightvector).
			set requredRollCorrection to SpeedSlipPID:update(time:seconds,-vslip).
			set SlipPID:setpoint to RequredRollCorrection.
			set requestSlipCorrection to SlipPID:Update(time:seconds,-shiproll).
		
		//Left Engines
		set autoThrust[0] to autoThrust[0]-requestSlipCorrection.
		set autoThrust[3] to autoThrust[3]-requestSlipCorrection.

		//Right Engines
		set autoThrust[1] to autoThrust[1]+requestSlipCorrection.
		set autoThrust[2] to autoThrust[2]+requestSlipCorrection.
	
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
		if Anchor = True and Alt:radar<100
			{
				set speedFrontPID:setpoint to -vdot(front,AnchorLocation:position)/3.
				set speedSlipPID:setpoint to -Vdot(ship:Facing:rightvector,AnchorLocation:Position)/3.
			}else
			{
				set speedFrontPID:setpoint to -HoverList[speedstep].
				set speedSlipPID:setpoint to -HoverTranslate[Translatestep].
			}

		
		set vFront to vdot(ship:velocity:surface,front).
		set requestPitch to speedFrontPID:Update(time:seconds,-vFront).
		set PitchPID:setpoint to requestPitch.
		set differentialThrust to PitchPID:update(time:seconds,shipPitch).
		
		//Front Engines
			set autoThrust[0] to autoThrust[0]+differentialThrust.
			set autoThrust[1] to autoThrust[1]+differentialThrust.
		//Back Engines
			set autoThrust[2] to autoThrust[2]-differentialThrust.
			set autoThrust[3] to autoThrust[3]-differentialThrust.


		
		//Bank Calculation to cancel any slip Velocity.	
		
		set vSlip to vdot(ship:velocity:surface,ship:facing:rightvector).
		set requredRollCorrection to SpeedSlipPID:update(time:seconds,-vslip).
		set SlipPID:setpoint to RequredRollCorrection.
		set requestSlipCorrection to SlipPID:Update(time:seconds,-shiproll).
		
		
		//Left Engines
		set autoThrust[0] to autoThrust[0]-requestSlipCorrection.
		set autoThrust[3] to autoThrust[3]-requestSlipCorrection.

		//Right Engines
		set autoThrust[1] to autoThrust[1]+requestSlipCorrection.
		set autoThrust[2] to autoThrust[2]+requestSlipCorrection.
	
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
			set seekhdg to ArcSin(Round(Sin(TargetHDG-ShipHDG),3)).
			set TargetRollRate to -hdgPID:update(time:seconds,seekHDG).
			set rollPID:setPoint to TargetRollRate.
			set rollrate to Round((shiphdg-oldhdg)/(time:seconds-oldtime),3).
			set rollPID:SetPoint to TargetRollRate.
			set OldTime to time:seconds.
			Set OLDhdg to shiphdg.
			Set ThrustOffset to -rollPID:update(time:seconds,rollrate). 
			
			//Clockwise twist
				set autoThrust[0] to autoThrust[0]+ThrustOffset.
				set autoThrust[2] to autoThrust[2]+ThrustOffset.
			//Counter Clockwise Twist
				set autoThrust[1] to autoThrust[1]-ThrustOffset.
				set autoThrust[3] to autoThrust[3]-ThrustOffset.
					
			// Diagnostic Display	
				//Print " HDG offset -----------> " + Round(ThrustOffset,3).
				//Print " Seek HDG "+ Round(SeekHDG).
				//Print " ROll Rate " + round(rollrate,2) + " ["+Round(TargetRollRate,2)+"]".	
		
		
	}

Declare Function SetThrust
	{
		set Elist[0]:ThrustLimit to max(0,Min(100,autoThrust[0])).
		set Elist[1]:ThrustLimit to max(0,Min(100,autoThrust[1])).
		set Elist[2]:ThrustLimit to max(0,Min(100,autoThrust[2])).
		set Elist[3]:ThrustLimit to max(0,Min(100,autoThrust[3])).
	}


Declare Function draw
	{
			clearvecdraws().
		//	Vecdraw(ship:position, front*2,White,"Front", 1, True).
		//	vecdraw(ship:position,elist[0]:position,Red,"LeftFront",1,true).
		//	vecdraw(ship:position,elist[1]:position,Red,"RightFront",1,true).
		//	vecdraw(ship:position,elist[2]:position,Red,"RightBack",1,true).
		//	vecdraw(ship:position,elist[3]:position,Red,"LeftBack",1,true).
		//	vecdraw(ship:position,Ship:facing:rightVector,white,"RightVector",1,true).
		//	vecdraw(ship:position, east*5,yellow,"east",1,true).
		if anchor=true{
			vecdraw(anchorlocation:position,up:vector*2,White,"Anchor",1,True).
		}
	}
// Display Function. 
//  **** need to use 'AT' to stop the text from jumping around. [used to display target values]
Declare Function hud
	{
		Clearscreen.
		Print " -------------------".
		Print " |    " + Mode + "   | ".
		Print " -------------------".
		if alt:Radar < 10
			{
				Print "  Altitude  : " + Round (Ship:altitude) + " ["+ TargetAlt+"]"+" RA:"+round(alt:radar,1)+"  ".
			}
			else
			{
				Print "  Altitude  : " + Round (Ship:altitude) + " ["+ TargetAlt+"]".
			}
		Print "       HDG  : " + Round (SHipHDG) + " ["+TargetHDG+"]".
		if mode = "FlightMode"
			{	
				Print "     Speed  : " + Round(vFront) +" ["+speedlist[Speedstep]+"]". 
			}
			Else if Mode = "HoverMode "
			{	
				Print "     Speed  : " + Round(vFront,1) +" ["+Round (HoverList[Speedstep],1)+"]".
			}

		
		if mode = "FlightMode"
			{
				Print "      Slip  : " + round (vslip,2).
			} 
			else if "HoverMode "
			{
				Print "      Slip  : " + round (vslip,2) + " ["+Round (HoverTranslate[Translatestep],1)+"]".
			}
			
		Print "     Pitch  : " + round(shipPitch,1) + " ["+Round(requestPitch,1)+"]".
		Print "      Roll  : " + Round(shiproll,1) + " ["+Round(-RequredRollCorrection,1)+"]".
		Print " ------------------------".
		Print " Anchor Mode: "+ anchor.
		//Print Elist.
	}





