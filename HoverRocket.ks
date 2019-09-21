Print " Welcome to Hover Test 1.".
Wait 1.
Parameter TargetHdg to 0.
Parameter TargetAlt to 70.
Set TargetRadar to -1.
set TargetSpeed to 0.
Set aThrottle to 0.
set shipHeight to alt:radar.
set speedlist to List (-1,0,1,4,10,20,40).
set speedstep to 1.

Set HeightStep to 1.
set ClimbSpeed to 10.
Lock throttle to aThrottle.
Lock aSteer to Heading(TargetHdg,90).
Lock steering to aSteer.


Set LandPos to LatLng(0.0,-74).
if Ship:availablethrust<1
{
	Wait .1.
	Stage.
	Print " Stage!!".
}

set throttlePID to pidLoop (0.40,	.3,	0.015,	0,	1).
set climbPID to pidLoop (0.9,.02,.04,-8,20).


set movePID to pidLoop (3,.1,.05,-20,20).

set alignPID to pidLoop (3,.1,.05,-20,20).
display().


//Climb(TargetAlt).
//Hover(TargetAlt).
//Land().
Declare Function Display
	{
		until gear
		{
			Clearscreen.
			Print " Ship Target Heading  : " + TargetHdg.
			Print " Ship Target SPeed    : " + TargetSpeed.
			if alt:radar-shipHeight<10
				{
					set heightStep to 1.
				}else if Alt:radar-shipHeight>10 and alt:radar<50
				{
					set heightStep to 5.
				}else 
				{
					Set heightStep to 10.
				}
			
			if terminal:input:haschar 
			{
				set ch to terminal:input:getChar().
				Terminal:input:clear.
				if ch = "a"
				{
					set TargetHdg to TargetHdg - 5.
					if TargetHdg<0{
						Set TargetHdg to TargetHdg+360.
					}
				}
				if ch = "d"
				{
					set TargetHdg to TargetHdg + 5.
					if TargetHdg>360{
						Set TargetHdg to TargetHdg-360.
					}
				}
				if ch = "w"
				{
					
					set TargetAlt to TargetAlt + HeightStep.
					set targetRadar to TargetRadar+heightStep.
				}
				if ch = "s"
				{
					set TargetAlt to max (0,TargetAlt -heightStep).
					set targetRadar to Max(TargetRadar-heightStep,-1).
				}
				if ch = "q"
				{
					set speedstep to Max(speedstep-1,0).
					set TargetSpeed to speedlist[speedstep].
				}
				if ch = "e"
				{
					set speedstep to min(speedstep+1,6).
					set TargetSpeed to speedlist[speedstep].
				}
			}
			if Lights
			{
				
				HoverRadar().
				set TargetAlt to Round(ship:geoPosition:TERRAINHEIGHT+targetRadar+4).
			}else{
				Hover().
				set TargetRadar to Round(ship:altitude-ship:geoPosition:terrainheight).
			}
			Munover().
			
			wait .04.
		}
	}
Declare Function Munover
	{
		set movePID:setPoint to TargetSpeed.
		set alignPID:setPoint to 0.
		set cV to -vDot(ship:velocity:surface,ship:facing:topVector).
		set vAlign to vDot(ship:velocity:surface,ship:facing:rightVector).
		
		set movePitch to movePID:update(time:seconds,cV).
		set alignPitch to alignPID:update (time:seconds,vAlign).
		
		
		
		Print "  Current Pitch      : "+round (movePitch,1).
		print "  Current Velocity   : "+Round (cV,1).
		Print " -------------------" .
		
		Print "  Slip Angle         : "+round(vang(-ship:facing:topvector,ship:velocity:surface),1).
		clearvecdraws().
		Lock aSteer to Heading(TargetHdg,90)-R(movePitch*Cos(TargetHDG)+alignPitch*Cos(TargetHDG+90),movePitch*Sin(TargetHDG)+alignPitch*Sin(TargetHDG+90),0).
	//	vecdraw(ship:position,ship:facing:rightVector*3,RED,"StarBoard",1,True).
	//	vecdraw(ship:position,ship:facing:topvector*-3,green,"UP",1,True).
	//	vecDraw (V(-5,0,0),-ship:facing:TopVector*TargetSpeed,White,"Targe Velocity",1,True).
		
	}

Declare Function HoverRadar
	{
		
		set climbPID:setpoint to targetRadar.
		set tClimb to ClimbPID:update(time:seconds,alt:radar-shipHeight).
		set throttlePID:SetPoint to tClimb.
		lock aThrottle to throttlePID:update(time:seconds,ship:VerticalSpeed).
		Print " Altitude Hover(Radar): " + TargetRadar + " | "+round(alt:radar-shipHeight,1).
		print " Target Climb         : "  + Round (tClimb,2) + " | " + round(ship:verticalSpeed,2).
	}

Declare Function Hover
	{
	
		set climbPID:setpoint to targetAlt.
		
		set tClimb to ClimbPID:update(time:seconds,Ship:Altitude).
		set throttlePID:SetPoint to tClimb.
		lock aThrottle to throttlePID:update(time:seconds,ship:VerticalSpeed).
		Print " Altitude Hover(Radar): " + Round(TargetAlt) + " | "+round(ship:altitude).
		print " Target Climb         : "  + Round (tClimb,2) + " | " + round(ship:verticalSpeed,2).
	}	
	
	// OLd heading lock 
	
	
Declare Function Move
	{
		Parameter LandingLoc to LatLng(0,-75).
		Print " Translate in Progress !".
		//set target to 
		Set maxDriftSpeed to 10.
		Set maxPitch to 10.
		Visual(LandingLoc).
		Set TargetHeading  to landingLoc:Heading.
		set TargetDistance to LandingLoc:distance-alt:radar.
		
		Set MovePID to PidLoop(5,1,.5,-20,20).
		Set MovePID:setpoint to 0.
		Set TargetSpeed to MovePID:update(time:seconds,-TargetDistance/10).
		
		Set TargetPID to PidLoop(5,1,.5,-20,20).
		
		Set TargetPID:setPoint to TargetSpeed.
		set TargetPitch to TargetPID:Update(time:seconds,ship:airspeed).
		set NorthPitch to TargetPitch*Cos(TargetHeading).
		Set EastPitch to TargetPitch*Sin(TargetHeading).
		Lock aSteer to Heading(0,90)-R(NorthPitch,EastPitch,0).
		
	
		Print " Target Heading   : "+TargetHeading.
		Print " Target Distance  : "+TargetDistance.
		Print " Target Speed     : "+TargetSpeed.
		Print " East   Pitch     : "+EastPitch.
		Print " North  Pitch     : "+NorthPitch.
		
		
	//	Print " East Distance    : "+LandingLoc:position:X.
	//	Print " East Target Speed: "+EastTargetSpeed.
	//	Print " East  Speed      : "+Ship:velocity:Surface:X.
	//	Print " East  Steer Angle: "+ESteer.
		
		Print "                    ".
		
	//	Print " North Distance   : "+LandingLoc:position:Y.
	//	Print " North TargetSpeed: "+EastTargetSpeed.
	//	Print " North Speed      : "+Ship:velocity:Surface:Y.
	//	Print " North SteerAngle : "+NSteer.
		
		
	//	Lock aSteer to Heading(0,90) - R(NSteer,ESteer,0). //Cos(steer)*steerPitch
		//	set NSteer to PidLoop(1,.5,.7,
		
	}
		

Declare Function Visual
	{
		Parameter LandPos to LatLng(0.05,-73).
		Vecdraw(ship:position,LandPos:position,RED,"Target",1,True).
		Vecdraw(ship:position, ship:velocity:Surface,White,"Velocity",1,True).
	}

Declare Function HoverOLD
	{
		Parameter HoverAlt to 300.
		Set HoverPID to PidLoop(.1,.05,.1,0,1).
		Set HoverPID:setPoint to HoverAlt.
		Until ship:status="Landed"
		{
			
			set aThrottle to HoverPID:update(time:seconds,Ship:Altitude).
			Print " Throttle Postion : "+aThrottle.
			Print " Target           : " + HoverPID:SetPoint. 
			Print " Vessel Radar Alt: " + Ship:altitude.
			Wait .04.
			ClearVecdraws().
			Clearscreen.
			if Lights
			{			
				Move(LandPos).
			}
			if Brakes
			{
				Brakes Off.
				Set HoverAlt to HoverAlt + 100.
				Set TargetAlt to TargetAlt +100.
			}
			
			if HoverALt-ship:altitude>75
			{
				Hover(Climb(HoverAlt)).
			}
		}
		RCS off.
	}

	Declare Function Climb
	{
		Parameter ClimbALT to 300.
		Set ClimbPID to PidLoop(.2,0.04,.01,0,1).
		Set ClimbPID:setPoint to ClimbSpeed.
		until Ship:Altitude > ClimbALT
		{
			Clearscreen.
			Print " Target Alt     : "+ClimbALT.
			Print " Target VSpeed  : "+ClimbSpeed.
			Print " Ship   VSpeed  : "+Ship:verticalSpeed.
			set aThrottle to ClimbPID:update(time:seconds,ship:verticalSpeed).
			set Climbspeed to (ClimbAlt-ship:altitude)/5+5.
			set ClimbPID:setpoint to Climbspeed.
			Wait 0.04.
			
		}
		Return ClimbALT.
	}


Declare Function Land
	{
		set LandPID to PIDLOOP(.7,.01,.01, 0,1).
		Set LandPID:setpoint to -5.
		Until ship:status = "landed"	
		{
			set aThrottle to LandPID:update(time:seconds,Ship:VerticalSpeed).
			
			set LandPID:setPoint to -Min(75,Alt:radar/5+1).
			Print "Throttle Position : "+aThrottle.
			Print "Target V Speed    : "+ LandPID:SetPoint. 
			Print "Vessel V Speed    : "+ ship:verticalSpeed.		
			Wait 0.04.
			Clearscreen.
		}
	}
	

	
	
Set aThrottle to 0.
Print "AutoLand Compplete.".

Wait 2.
	
