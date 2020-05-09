// Simplfied math for Pitch and better Apopsis function to make it faster and effecient. 

Print " Launch Profile 2. Uncrewwed. ".
Wait 1.

Parameter hdg to 90.
Parameter autostageDelay to 0.5.
Parameter autostageThrottle to 0.
Parameter tApoapsis to 74000.
Parameter tPeriaposis to 70500.

// Common Vairables

set oldThrust to 0.
set iniApoapsis to tApoapsis-500.
set AStageTrigger to true.

set autoSteer to heading (hdg,90).
Set athrottle to 0.

set engineStart to time:seconds+2.

Lock steering to autoSteer.
Lock throttle to athrottle.      

SAS off.
// find it rockets have launch clamp.
wait 2.
set launchClamps to ship:partsdubbedpattern("Launch").
print launchClamps.

//autostage().
accent().
MonitorApoapsis().
circularize().
Declare Function AutoStage
{
   
	if availablethrust < 1 or availablethrust<oldThrust*.95
	{
        if AStageTrigger = true
        {
           
            wait autostageDelay.
            lock throttle to autostageThrottle.
            stage.
          //  Print "Staging..".
            wait 0.5.
            lock throttle to athrottle.
            set oldThrust to availablethrust.
        }
        
    }
}

Declare Function HUD_accent
{
   
    Print "           AutoStage (H) : " + AStageTrigger + "  "at (0,2).
    Print "    Target Apopsis (w/s) : " + tApoapsis+" " at (0,3).
       
    print " ----------------------------- " at (0,4).
    
    Print "  apo (time) Per : " + round(alt:apoapsis/1000)+"("+round(eta:apoapsis)+" s) "+round(alt:Periapsis/1000)+"       " at (0,5).
    Print "       Pitch Comp : "+Round( PitchComp,1) + "     " at (0,6).
    if altitude<12000
    {
        print "         Ship Q : "+Round(ship:q,2)+"   " at (0,8).
    }else
    {
        Print "                               " at (0,8).
    }
    
    
}

Declare Function userInput
	{
        
		if terminal:input:haschar 
			{
				set ch to terminal:input:getChar().
				Terminal:input:clear.
				
				if ch = "Q"
				{
				
				}
                if ch = "E"
                {
                   
                }
                if CH="H"
                {
                    if AStageTrigger=true{
                        set AStageTrigger to false.
                    }else
                    {
                        set aStageTrigger to true.
                    }

                }
                if ch = "w"
                {
                    Set tApoapsis to tApoapsis + 500.
                }
                if ch = "s"
                {
                    Set tApoapsis to tApoapsis - 500.
                }
            }    
    }



declare function checkClamp
{
    
    if launchClamps:length>0
    {
         
        if time:seconds>engineStart
        {
     //       print launchClamps.
            WAIT 0.5.
            stage.
            LAUNCHCLAMPS:CLEAR().
     //       print " NO of clamps : "+launchClamps.
        }
        
    }
}

Declare Function Accent
{
	
    
    
	set tQ to 0.19.
	SET SpeedOFFset TO 0.
    set pitchComp to 0.
	set PitchOffset to 0.
	set athrottle to 0.
	set tPitch to 0.
	set stageAttemp to 0.
	set PitchTimeOFfset to 0.
	set pitchTimePID to PIDLoop(0.1,    0.002,  .01,    -2, 15).
	
	CLEARSCREEN.
	set tPID to pidloop(0.4,0.007,0.01  ,0.2,1).
    set pitchComp to 0.
   
	until ship:apoapsis>iniApoapsis and Lights = false
	{
		
		AutoStage().
        HUD_accent().
        userInput().
         checkClamp().
        SET pitch to ((((ship:altitude)/1000)/(tApoapsis/1000))^0.48)*90.
      
     // 	print " Ship Q : "+Round(ship:q,2)+"   " at (0,1).

      
        set autosteer to  heading (hdg,Max(5,90-pitch+pitchComp)).
        if ship:altitude<12000
        {
            set tPID:setpoint to .21*100.
            set athrottle to tpid:update(time:seconds,ship:q*100).
            
        }else if Ship:altitude>12000
        {
            set tPID to pidloop(0.4,0.001,0.01  ,0.5,1).
            set tPID:setpoint TO 90.
          //  set athrottle to 1.
         
          
            SET athrottle to tpid:update(time:seconds,eta:apoapsis).
            if (eta:apoapsis<30)
            {
                set pitchComp to (30-eta:apoapsis)/3.
            } else if eta:apoapsis>40
            {
                set pitchComp to Max(-4,(40-Eta:apoapsis)/3).
            }
           
        }
        wait .01.

	
	}
}


Declare Function MonitorApoapsis
{
    warpto(time:seconds+eta:apoapsis-40).
	until eta:apoapsis<30
	{	
		lock autoSteer to Prograde.
		set athrottle to 0.
		if Ship:apoapsis<iniApoapsis-1000
		{
			Accent().
		}
		Print " Monitoring Apoapsis ".
		Print " Current Apoapsis : "+Round(ship:apoapsis).
        Print " ETA apoapsis(30) : "+Round (eta:Apoapsis).
        
		Wait 0.1.
		Clearscreen.
	}
}



Declare Function Circularize{
	set athrottle to 0.
	set autoSteer to Heading(hdg,0).
	
	until ship:Periapsis>tPeriaposis
	{
		autostage().
		set etaApo to eta:apoapsis.
		
		set athrottlePID to PidLoop(0.1,.01,.01,0.01,1).
		set athrottlePID:setpoint to 30.
		
		set PitchPID to pidLoop(1,.01,.002,0,45).
		set PitchPID:setpoint to 20.
		if ship:verticalspeed<0
			{	set etaApo to 0.	}
		set pOffset to pitchPID:update(time:seconds,etaApo).
		set autoSteer to Heading(hdg,pOffset).
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
	// Need to work on lifting Apoapsis.



    // need to find 
	

}