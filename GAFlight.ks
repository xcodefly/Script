// The file to have all the launch function for GA.

@lazyglobal off.
// Accent
// Monitor
// Circulize.
parameter tApoapsis to 1000.



Declare function AccentHUD
    {   local parameter displayDNA,x.
        print " Pointer : " + x at (0,1).
        print " Heading : " +displayDNA[x]:heading at (0,2).
        print " Heading : " +displayDNA[x]:pitch at (0,3).
        print " Throttle : "+ displayDNA[x]:throttle at (0,4).
    }

declare function checkStatus
{
    parameter lapstime.
    local flightstatus to false.
    if ship:apoapsis>tApoapsis
    {
        set flightstatus to true.
    }
    if lapstime>3 and ( status="prelaunch" or status="landed")
    {
        set flightstatus to true.
    }
    return flightstatus.
}

Declare function Accent_GA{  // function to create the automatic launch profile. 
    // have different alitutde for each 1000 feet step. and then follow that heading.   
        
        Local Parameter candidate.  // waypoint lexicon contains the following info  Altitude - index*1000, heading, pitch, maxQ, throttle, 
        local cDNA to candidate:DNA.
        local starttime to time:seconds.
        local nextStage to false.
        local pointer to Round(altitude/1000).
        sas off.
        if maxthrust <1
        {
            stage.    
            wait 1.    
        }
        until nextstage
        {
            set throttle to cDNA[pointer]:throttle.
            set steering to heading(cDNA[pointer]:heading,cDNA[pointer]:pitch).
            set pointer to Round(altitude/1000).

            set nextstage to checkStatus(round(time:seconds-starttime)).
            accentHUD(candidate:DNA,pointer).
         
            wait 0.
        
        }
        set throttle to 0.
        unlock steering.
        sas on.
    }




