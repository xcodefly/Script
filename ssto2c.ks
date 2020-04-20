set athrottle to 1.
set tPitch to 6.
lock steering to heading(90,tPitch).
lock throttle to aThrottle.
list engines in elist.

// variables for different ships.

set iniClimbMax to 30.
set iniClimbMin to 10.
set iniClimbAlt to 6500.

brakes off.
declare function autostage
{
    if availableThrust<1
{
    stage.
}
}

clearscreen.
declare function hud
{
    Print "     Airspeed : " + Round(airspeed)+ "  " at (0,1).
    print "  Ship tPitch : " + round(tpitch) + "  " at (0,2).
    print "Engine Thurst : " +Round(Elist[0]:availableThrust) + "  "at (0,3).
    print " target Speed : "+ round(200+ship:altitude*0.03)+ "  " at (0,4).
}
set pitchPID to pidLoop(0.45,0.01,0.9,0,iniClimbMax-iniClimbMin).

declare function initialClimb
{
    autostage().
    set pitchPID:setpoint to 200+ship:altitude*0.03.
       
    until ship:altitude>iniClimbAlt
    {
        hud().
        if groundspeed >60
        {
            set tPitch to iniClimbMax-pitchPID:update(time:seconds,airspeed).
        }
    IF alt:radar>15 
    {
        gear off.
    }
    wait 0.01.
    }
    
}

declare function acceleratedClimb
{
    set pitchPID:setPoint to 390.
    autostage().
    until ship:apoapsis>75000
    {
        hud().
        set tPitch to 60-pitchPID:update(time:seconds,elist[0]:availableThrust).
        wait 0.01.
    }
    lock steering to prograde.

}
Declare Function MonitorApoapsis
{
    clearscreen.
	until eta:apoapsis<30
	{	
		lock autoSteer to Prograde.
		set athrottle to 0.
	
		Print " Monitoring Apoapsis " at (0,1).

		Print " Current Apoapsis : "+Round(ship:apoapsis)+ "  " at (0,2).
        Print " ETA apoapsis(30) : "+Round (eta:Apoapsis)+ "  " at (0,3).
		Wait 0.01.
	}
}



Declare Function Circularize{
    autostage().
	set athrottle to 0.
	set autoSteer to Heading(90,0).
	
	until ship:Periapsis>71000
	{
		
		set etaApo to eta:apoapsis.
		set athrottlePID to PidLoop(0.1,.01,.01,0.01,1).
		set athrottlePID:setpoint to 30.
		set PitchPID to pidLoop(1,.01,.002,0,45).
		set PitchPID:setpoint to 20.
		if ship:verticalspeed<0
			{	set etaApo to 5.	}
            
		set pOffset to pitchPID:update(time:seconds,etaApo).
		set autoSteer to Heading(90,pOffset).
		set athrottle to athrottlePID:update(time:seconds,etaApo).
		
		Print " Lifting Periapsis out of Atmosphere ".
		Print " ETA apoapsis : "+Round (etaApo,1).
		Print " Eccentricity : "+Round (orbit:eccentricity,6).
		Print "     Throttle : "+Round(athrottle,3).
		Print "   Pitch Lift : "+round(pOffset,1).
        print "     Apoapsis : "+Round(alt:apoapsis).
        print "    Periapsis : "+Round(alt:Periapsis).
        
		wait .01.
		Clearscreen.
	}
}
initialClimb().
set pitchPID to pidLoop(0.7,0.005,0.5,38,43).
acceleratedClimb().
MonitorApoapsis().
Circularize().
