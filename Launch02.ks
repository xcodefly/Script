// Simplfied math for Pitch and better Apopsis function to make it faster and effecient. 
run "_orbit.ks".  // This will add the munover node to circuilze at the apoapsis. 
run "_exeNode.ks".  // This file will execude the next node in the orbit. 


Print " Launch Profile 2. Uncrewwed. ".


Parameter hdg to 90.

Parameter tApoapsis to 80000.
Parameter tPeriaposis to 79000.
parameter targetQ to 0.3.
Parameter autostageDelay to 0.1.
Parameter autostageThrottle to 0.

// Common Vairables

set oldThrust to 0.
set iniApoapsis to tApoapsis-500.
set AStageTrigger to true.

set autoSteer to heading (hdg,90).
Set athrottle to 0.

set engineStart to time:seconds+2.

Lock steering to autoSteer.
Lock throttle to athrottle.      


// find it rockets have launch clamp.
wait 1.
set launchClamps to ship:partsdubbedpattern("Launch").
set protectiveShell to ship:partsdubbedpattern("shell").



accent().
MonitorApoapsis().
circularize().

declare function QuickStage
{
    set tempQuick to 0.
    until availablethrust>1
    {
        wait autostageDelay.
        stage.
        wait autostageDelay.
        set tempQuick to tempQuick+1.
        PRINT "   Quick stage count " +tempQuick.
    }
    
    
}
Declare Function AutoStage
{
   
	if availablethrust < 1 or availablethrust<oldThrust*.50
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
    Print " Protective shell :"+protectiveShell:length  at (0,1).
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
    if protectiveShell:length>0 and altitude>70000
    {
        protectiveShell[0]:getmodule("moduleproceduralfairing"):doAction("Deploy",true).
        Print " Shell on " at (0,10).
    }
    }





Declare Function Accent
    {
        Set tQ to 0.19.
        Set SpeedOFFset TO 0.
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
            
            SET pitch to ((((ship:altitude)/1000)/(tApoapsis/1000))^0.48)*90.
        
        // 	print " Ship Q : "+Round(ship:q,2)+"   " at (0,1).

        
            set autosteer to  heading (hdg,Max(5,90-pitch+pitchComp)).
            if ship:altitude<12000
            {
                set tPID:setpoint to targetQ*100.
                set athrottle to tpid:update(time:seconds,ship:q*100).
                
            }else if Ship:altitude>12000
            {
                set tPID to pidloop(0.4,0.001,0.01  ,0.8,1).
                set tPID:setpoint TO 90.
                //  set athrottle to 1.
                 SET athrottle to tpid:update(time:seconds,eta:apoapsis).
                if (eta:apoapsis<30)
                {
                    set pitchComp to (30-eta:apoapsis)/3.
                } else if eta:apoapsis>40
                {
                    set pitchComp to Max(-6,(40-Eta:apoapsis)/3).
                }
            }
            wait 0.

        }
        unlock steering.
    }

// function will wait until ship is out of the atmosphere. It will call circulize to do the circulizaiton part.
Declare Function MonitorApoapsis
    {
    set kuniverse:timeWarp:mode to "Physics".
    set kuniverse:timeWarp:rate to 4.
    lock steering to Prograde.
    clearscreen.
    set athrottle to 0.
    until altitude > 70400
    {
        Print " Monitoring Apoapsis " at (0,2).
		Print " Current Apoapsis : "+Round(ship:apoapsis) + "  "at (0,3).
        Print " ETA apoapsis(30) : "+Round (eta:Apoapsis)+ "  " at (0,4).
      
		
		if Ship:apoapsis<iniApoapsis-1000
		{
			Accent().
		}
    }
 
}




Declare Function Circularize
    {
	
    kuniverse:timeWarp:cancelWarp().
    adjust_Periapsis(tPeriaposis).    // Function from the _orbit.ks
    exeNextNode().   
}

