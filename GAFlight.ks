// The file to have all the launch function for GA.

lazyglobal off.
// Accent
// Monitor
// Circulize.
parameter tApoapsis to 80000.
run "_GA_launchDNA.ks".


Declare function AccentHUD
    {

    }

Declare function Accent_GA{  // function to create the automatic launch profile. 
    // have different alitutde for each 1000 feet step. and then follow that heading.   
        
        Local Parameter waypoints.  // waypoint lexicon contains the following info  Altitude - index*1000, heading, pitch, maxQ, throttle, 
        
        local pointer to Round(altitude/1000).
        sas off.
        stage.        
        until ship:apoapsis>tApoapsis
        {
            set throttle to waypoints[pointer]:throttle.
            set steering to heading(waypoints[pointer]:heading,waypoints[pointer]:pitch).
            set pointer to Round(altitude/1000).
            wait 0.
            print " Pointer : " + pointer at (0,1).
            print " Heading : " +waypoints[pointer]:heading at (0,2).
            print " Heading : " +waypoints[pointer]:pitch at (0,3).
        
        }
        set throttle to 0.
        unlock steering.
        sas on.
    }

clearscreen.

Local testAccent to list().
Set testAccent to accentGene().

Accent_GA(testAccent).