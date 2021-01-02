// Simplfied math for Pitch and better Apopsis function to make it faster and effecient. 
RUN Display_fx.
Print " Launch Profile 2. Uncrewwed. ".
Wait 1.

Parameter MaxSpeed to 2300.
Parameter tApoapsis to 75000.
Parameter hdg to 90.
// Common Vairables

set oldThrust to 0.
set iniApoapsis to tApoapsis-1000.
set AStageTrigger to true.

set autoSteer to heading (hdg,90).
Set athrottle to 0.

Lock steering to autoSteer.
Lock throttle to athrottle.      

SAS off.
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
            SET athrottle to 0.1.
            wait 0.5.
            stage.
            Print "Staging..".
            wait 0.5.
            set oldThrust to availablethrust.
            
        }
        
           
	}
}

Declare Function HUD_accent
{
    Print "   Target Max Speed(q/e) : " + Maxspeed +"  " at (0,1).
    Print "           AutoStage (H) : " + AStageTrigger + "  "at (0,2).
    Print "    Target Apopsis (w/s) : " + tApoapsis+" " at (0,3).
   
    print " ----------------------------- " at (0,4).
    
    Print "  apoapsis (time) : " + round(alt:apoapsis)+"("+round(eta:apoapsis)+")    " at (0,5).
    if altitude<12000
    {
        print "         Ship Q : "+Round(ship:q,2)+"   " at (0,7).
    }else
    {
        Print "                               " at (0,7).
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
					set MaxSpeed to Maxspeed - 10.
				}
                if ch = "E"
                {
                    Set MaxSpeed to Maxspeed + 50.
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

Declare Function Accent
{
	
	set tQ to .27.
	SET SpeedOFFset TO 0.

	set PitchOffset to 0.
	set athrottle to 1.
	set tPitch to 0.
	set stageAttemp to 0.
	set PitchTimeOFfset to 0.
	set pitchTimePID to PIDLoop(0.1,    0.002,  .01,    -2, 15).
	
	CLEARSCREEN.
	set tPID to pidloop(0.12,0.003,0.03  ,0.1,1).
    set pitchComp to 0.
	until ship:apoapsis>iniApoapsis and Lights
	{
		
		AutoStage().
        HUD_accent().
        userInput().
        SET pitch to ((((ship:altitude-60)/1000)/(70))^0.54)*90.
      
     // 	print " Ship Q : "+Round(ship:q,2)+"   " at (0,1).
      //  set pitchComp to Min(0,((80-Altitude/1000)-eta:apoapsis))*0.4.
      set pitchComp to 0.
        set autosteer to  heading (hdg,Max(3,90-pitch+pitchComp)).
        if ship:altitude<12000
        {
            set tPID:setpoint to .25*100.
            
            set athrottle to tpid:update(time:seconds,ship:q*100).
        }else 
        {
            set tpid:setPoint to MaxSpeed.
            //set athrottle to 1.
            set athrottle to tpid:update(time:seconds,airspeed).
            if (eta:apoapsis<30)
            {
                set pitchComp to 35-eta:apoapsis.
            }
           
        }
        wait .01.

	
	}
}


Declare Function MonitorApoapsis
{
	until Ship:altitude>60000and  eta:apoapsis<30
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
	
	until ship:Periapsis>71000 
	{
		autostage().
		set etaApo to eta:apoapsis.
		
		set athrottlePID to PidLoop(0.1,.01,.01,0.4,1).
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