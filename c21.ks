set athrottle to 1.
Parameter tPitch to 3.
lock steering to heading(90,tPitch).
lock throttle to aThrottle.
list engines in elist.

// variables for different ships.

set iniClimbMax to 29.
set iniClimbMin to 3.
set iniClimbAlt to 5500.
set accAlt to 25000.
set accClimbMin to 17.
set accClimbMax to 21.

brakes off.
if availableThrust<1
{
    stage.
}
clearscreen.
declare function hud
{
    Print "     Airspeed : " + Round(airspeed)+ "  " at (0,1).
    print "  Ship tPitch : " + round(tpitch,1) + "  " at (0,2).
    print "Engine Thurst : " +Round(Elist[0]:availableThrust) + "  "at (0,3).
    print " target Speed : "+ round(200+ship:altitude*0.05)+ "  " at (0,4).
}


declare function initialClimb
{
    set pitchPID to pidLoop(0.4,0.001,1.7,0,iniClimbMax-iniClimbMin).
    set pitchPID:setpoint to 200+ship:altitude*0.05.
    until ship:altitude>iniClimbAlt
    {
        hud().
        set pitchPID:setpoint to 200+ship:altitude*0.05.
        if groundspeed >90
        {
            
        }
        if alt:radar>50
        {
            gear off.
            set tPitch to iniClimbMax-pitchPID:update(time:seconds,airspeed)-ship:altitude/iniClimbAlt*(iniClimbMax-accClimbMax).
        }
        wait 0.
    }
    
}

declare function acceleratedClimb
{
    set pitchPID to pidLoop(0.4,0.01,0.6,0,accClimbMax-accClimbMin).
    set pitchPID:setPoint to 330.
    until ship:apoapsis>75000
    {
        hud().
        set tPitch to accClimbMin+(accClimbMax-accClimbMin)*(1-(ship:altitude-iniClimbAlt)/(accAlt-iniClimbAlt)).
        set tpitch to max(accClimbMin,tpitch).
        wait 0.
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
		Wait 0.1.
	}
}



Declare Function Circularize{
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
			{	set etaApo to 0.	}
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

acceleratedClimb().
MonitorApoapsis().  
Circularize().
