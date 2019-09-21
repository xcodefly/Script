Print " Launch Profile 1. Uncrewwed. ".
Wait 1.

Parameter hdg to 90.
// Common Vairables

set oldThrust to 0.

set tApoapsis to 75000.

Lock autoSteer to heading (hdg,90).
Set athrottle to 0.

Lock steering to autoSteer.
Lock throttle to athrottle.

SAS off.
autostage().
accent().
MonitorApoapsis().
circularize().
Declare Function AutoStage
{
	if availablethrust < 1 or availablethrust<oldThrust*0.98
	{
		SET athrottle to 0.
		wait 0.5.
		stage.
		Print "Staging..".
		wait 0.1.
		set oldThrust to availablethrust.
	}
}


Declare Function Accent
{
	
	set tQ to 0.27.
	SET SpeedOFFset TO 0.
	set MaxSpeed to 310.
	set PitchOffset to 0.
	set athrottle to 1.
	set tPitch to 0.
	set stageAttemp to 0.
	set PitchTimeOFfset to 0.
	set pitchTimePID to PIDLoop(0.1,.002,.01,-2,15).
	set pitchTimePID:Setpoint to 60.
	
	
	until ship:apoapsis>71000
	{
		Clearscreen.
		AutoStage().
		
		
		set tPitch to Min(80,log10((ship:altitude/1000)*.2+1)*33+log10((ship:altitude/10000)*2+1)*45).
		set tpitch to Min(90,tpitch).	
		Set SpeedOFFset to ((ship:altitude/1000)^1.45)*5.
		print " Target Pitch : " + Tpitch.
		IF SHIP:ALTITUDE<12000
		{
			set speedPID to PIDLoop(25,2,5,0.5,1).
			set speedPID:setpoint to tQ.
			set athrottle to speedPID:update(time:seconds,ship:q).
			set PitchOffset to (1-athrottle)*15.
			set autoSteer to heading(hdg,90-tPitch+PitchOffset).
			Print "Ship Q         : " + Round(ship:q,2).
		}
		IF Ship:altitude>12000 and Ship:altitude<35000
		{
			Print " Target Pitch mode.".
			set speedPID to PIDLoop(0.05,0.05,0.05,0.8,1).
			set speedPID:setpoint to MaxSpeed+SpeedOFFset.
			set athrottle to speedPID:update(time:seconds,ship:airspeed).
			set PitchOffset to (1-athrottle)*20.
			set pitchtimePID:Setpoint to 60.
			set PitchTimeOFfset to pitchtimePID:update(time:seconds,eta:apoapsis).
			set autoSteer to heading(hdg,90-tPitch+PitchOffset+pitchTimeOffset).
		} 
		
		If Ship:altitude >35000
		{
			
			set speedPID to PIDLoop(0.3,0.01,0.05,0.5,1).
			set speedPID:setpoint to 60.
			
			set PitchPID to pidLoop(0.1,0.1,0.1,-10,0).
			set PitchPID:setpoint to MaxSpeed+SpeedOFFset.
			set overspeedControl to pitchPID:update(time:seconds,ship:airspeed).
			set PitchOffset to (1-athrottle)*5.
			set athrottle to speedPID:update(time:seconds,eta:apoapsis).
			set PitchTimeOFfset to pitchTimePID:update(time:seconds,eta:apoapsis).
			
			set autoSteer to prograde+R((pitchTimeOffset-overspeedControl-PitchOffset)*cos(hdg),(pitchTimeOffset-overspeedControl-PitchOffset)*sin(hdg),0). 
			Print " Ship OverSpeed Control : " + overspeedControl.
			Print " SHip Overspeed         : " + ship:airspeed.
		} 
			
		
		Print "Ship Max Speed : " + Round  (MaxSpeed+SpeedOFFset).
		Print "Ship Target Pit: " + Round (tPitch,1).
		Print "Pitch SpeedOFF : " +Round (PitchOffset,1).
		Print "Pitch T Offset : " + Round (PitchTimeOFfset,1).
 		wait .01.
		Clearscreen.
	}
}


Declare Function MonitorApoapsis
{
	until Ship:altitude>55000 and  eta:apoapsis<30
	{	
		lock autoSteer to Prograde.
		set athrottle to 0.
		if Ship:apoapsis<70500
		{
			Accent().
			
		}
		Print " Monitoring Apoapsis ".
		Print " Current Apoapsis : "+Round(ship:apoapsis).
		Wait .1.
		Clearscreen.
	}
}



Declare Function Circularize{
	set athrottle to 0.
	set autoSteer to Heading(hdg,0).
	
	until ship:Periapsis>70000 
	{
		autostage().
		set etaApo to eta:apoapsis.
		
		set athrottlePID to PidLoop(.1,.01,.01,.02,1).
		set athrottlePID:setpoint to 30.
		
		set PitchPID to pidLoop(.5,.05,.002,0,45).
		set PitchPID:setpoint to 20.
		if ship:verticalspeed<0
			{	set etaApo to 0.	}
		set pOffset to pitchPID:update(time:seconds,etaApo).
		set autoSteer to Heading(hdg,pOffset).
		set athrottle to athrottlePID:update(time:seconds,etaApo).
		
		Print " Lifting Periapsis out of Atmosphere ".
		Print " ETA apoapsis : "+Round (etaApo,1).
		Print " Eccentricity : "+Round (orbit:eccentricity,6).
		Print " Throttle     : "+Round(athrottle,3).
		Print " Pitch Lift   : "+pOffset.
		wait .01.
		Clearscreen.
	}
	// Need to work on lifting Apoapsis.
	until ship:Apoapsis>tApoapsis
	{
		autostage().
		set athrottle to .01.
		lock autoSteer to Prograde.
		Print " Setting Apoapsis to "+tApoapsis.
		wait .04.
		Clearscreen.
		
	}
	

	set athrottlePID to PidLoop(.0001,.0001,.02,.1,1).
	set athrottlePID:setpoint to 15.
	until orbit:eccentricity<0.00001
	{
		autostage().
		Lock autoSteer to Heading(hdg,0).
		set etaApo to eta:apoapsis.
		set athrottle to athrottlePID:update(time:seconds,etaApo).
		Print " Circulizing ".
		Print " ETA apoapsis : "+Round (etaApo,2).
		Print " Eccentricity : "+Round (orbit:eccentricity,6).
		Print " Throttle     : "+round(athrottle,3).
		wait .01.
		Clearscreen.
	}

}