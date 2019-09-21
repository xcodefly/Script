Print " Aircraft AP version 0.1".

Parameter v1 to 90.
set tALt to 7000.
set tHdg to 90.
set tSpeed to 200.
set tBank to 30.
set tRoll to 3.
set FlightMode to 0.
Set aThottle to 0.
set tStatus to " *** Unlocked ***".
//Lock Throttle to aThottle.
set mode to List("TakeOff","Climb","Cruise","Descent","Approach","Land").


set PowerPID to pidloop(.015,.0025,.012,0,1).
set PowerPID:SetPoint to tSpeed.
Lock throttle to aThottle.
//Takeoff().
//set tALt to ClimbDescent(tALt,10).
Cruise(tALt).
//Descent().
//Approach().
//Land().
//SET SHIP:CONTROL:NEUTRALIZE to TRUE.

Declare Function UserInput{
	Parameter tAlt to 1000.
		if SAS
		{	
			SAS off.
			Set tSpeed to tSpeed +10.
		set PowerPID:SetPoint to tSpeed.
			
		}
		if RCS
		{
			RCS off. 
			Set tSpeed to tSpeed -10.
			set PowerPID:SetPoint to tSpeed.
		}
		if Brakes
		{
			Brakes off.
			set tAlt to tAlt -50.
		}
		if Lights
		{
			lights OFF.
			set tAlt to tAlt +50.
		}
		ON AG9
		{
			Lock throttle to 0.
			set tStatus to  "**  Throttle Idle  **".
		}
		ON AG10
		{
			Lock Throttle to aThottle.
			set tStatus to  "**  Auto Throttle **".
			
		}
	return tAlt.
}


Declare Function ClimbDescent
{
	Parameter tAlt to 1000.
	Parameter tClimbDec to 10.
	set pInput to 0.
	set VFactor to 1.
	set pitchPID to pidLoop(.003,0.0004,.00015, -.5, 1).
	until abs(ship:altitude - tAlt)<Abs(tClimbDec*vFactor*4)
	{
		Clearscreen.
		
		set pitchPID:setpoint to tClimbDec*vFactor.
		if ship:airspeed>v1
		{
			set pInput to pitchPID:update(time:seconds,ship:verticalspeed).
			
		}
		set ship:control:pitch to pInput.
		set aThottle to PowerPID:update(time:seconds,ship:airspeed).
		set tALt to userInput(tALt).
		Print " Flight         :   Climb/Descent " .
		Print " PitchC Input   : " +Round (pInput,3).
		Print " Vertical Speed : " +round (Ship:verticalspeed,2)	+ " / "	+Round(tClimbDec*vFactor).
		Print " Altitude       : " +Round (ship:altitude)			+ " / "	+tALt.
		Print " Throttle input : " +Round (aThottle,2) + tStatus .
		Print " Target Speed.  : " +round (ship:airspeed)			+ " / " +tSpeed.
		set tALt to userInput(tALt).
		
		wait .01.
		ON ag8
		{
			set VFactor to VFactor + .1.
		}
		ON AG7
		{
			set VFactor to VFactor - .1.
		}
		
		
		
	}
	Return tAlt.
}

Declare Function Cruise
{	
	Parameter tAlt to 1000.
	set pInput to 0.
	set vTarget to 0.
	
	set AltCorrection 	to 	PIDLoop(.015,  .0003, .002, -10,  10).	
	
	set pitchPID 		to 	pidLoop(.0032,0.00035,.00015, -.5, 1).
	until False
	{
		
		Clearscreen.
		set aThottle to PowerPID:update(time:seconds,ship:airspeed).
		if Abs(ship:altitude-tAlt)>200
		{
			if ship:Altitude<tAlt
			{
				Cruise(ClimbDescent(tALt,20)).
			} 
			else
			{
				Cruise(ClimbDescent(tALt,-20)).
			}
		}
		
		set vTarget to AltCorrection:update (time:seconds,Ship:altitude-tAlt).
		
	
		set pitchPID:setpoint to vTarget.
		
		set pInput to pitchPID:update(time:seconds,Ship:verticalspeed).
		set ship:control:pitch to pInput.
		set tAlt to userInput(tALt).
		
		Print " Flight         :   Cruise " .
		Print " PitchC Input   : " +Round (pInput,3).
		Print " Vertical Speed : " +round (Ship:verticalspeed,2)+ " / "	+Round(vTarget,2).
		Print " Altitude       : " +Round (ship:altitude)		+ " / "	+tALt.
		Print " Throttle input : " +Round (aThottle,2) + tStatus.
		Print " Target Speed.  : " +Round (ship:airspeed) 		+ " / " +tSpeed.
		
		
		
		wait .01.
		
		
	}
	
}