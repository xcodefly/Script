// The file to have all the launch function for GA.

lazyglobal off.
// Accent
// Monitor
// Circulize.
parameter tApoapsis to 80000.
run "_GALKO.ks".


Declare function AccentHUD
    {

    }

declare function checkStatus
{
    local flightstatus to true.
    if ship:apoapsis>tApoapsis
    {
        set flightstatus to true.
    }
    return flightstatus.
}

Declare function Accent_GA{  // function to create the automatic launch profile. 
    // have different alitutde for each 1000 feet step. and then follow that heading.   
        
        Local Parameter waypoints.  // waypoint lexicon contains the following info  Altitude - index*1000, heading, pitch, maxQ, throttle, 
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
            set throttle to waypoints[pointer]:throttle.
            set steering to heading(waypoints[pointer]:heading,waypoints[pointer]:pitch).
            set pointer to Round(altitude/1000).
            set status to checkStatus().
           
            print " Pointer : " + pointer at (0,1).
            print " Heading : " +waypoints[pointer]:heading at (0,2).
            print " Heading : " +waypoints[pointer]:pitch at (0,3).
            print " Throttle : "+ waypoints[pointer]:throttle at (0,4).

            wait 0.
        
        }
        print nextstage.
        set throttle to 0.
        unlock steering.
        sas on.
    }

Clearscreen.

Local testAccent to list().
Set testAccent to accentGene().

Accent_GA(testAccent).