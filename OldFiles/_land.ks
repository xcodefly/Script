// all the functions for landing are in this file. 
// order of landing is planned to be simple to complex as it goes down.
// "_global" should be inclued to use this file and all the new global vairables should be update in that "_global" file. 

// softLand uses about 75% of max thrust to do the basic soft landing without working about the location of landing. It monitors when it should start to accelerate in order to softland. Should only be used with ship in gyro of stable landing. Uses retrograde mode for landing untill 100 meter from ground and switchs to pitch hold of last part of landing. 

runPath ("_hover.ks") .
runPath ("_TargetPlus.ks").

// should be used when horizontal velocity is low. only vertial speed.  

lock verticalStopDistance to 1.05*(ship:verticalspeed^2 / (2 * MaxLandingAcc)).	// 105% to compensate for error.

Declare function HoverSlam     // this is the basic hoverslam. 
{
    clearscreen.
    parameter rocketHeight to 40.
    set tPID to pidloop(0.05,0.1,0.001,0,1).
    set tPID:setpoint to rocketHeight.
    lock steering to up:vector.
    until (verticalStopDistance>alt:radar)
    {
        Landing_hud().
    }
    until (VerticalSpeed>-1)
    {
        lock steering to srfretrograde.
        // v^2 - u^2 = 2as
        Landing_hud().
        lock throttle to tPID:update(time:seconds,Alt:radar-verticalStopDistance).
        IF ALT:RADAR<500
        {
            Gear On.
        }
        wait 0.01.
    }
}

// SoftLanding, calls for landing Contorl funciton to slow donw and land softly. 
Declare Function SoftLand
{
    parameter shipHeight to 10.
    set targetHDG to shipHDG.
    LandControl().
    lock steering to heading(targetHDG,90).
    set tPID to pidloop(0.08,0.2,0.001,0,1).
    
    set targetspeed to 0. set targetSlip to 0.
    until status="landed"
    {
        //   BasicInfo().
       
        if groundSpeed<1
        {
            set targetVS to -3.//(alt:radar-shipHeight)/4.
        } else 
        {
            set targetVS to -3.//-(alt:radar-shipHeight-10)/4.
        }
        set tPid:setPoint to targetVS.
        lock throttle to tpid:update(time:seconds,verticalspeed).
        wait 0.01.
    }
}

// The function to land the ship at the selcted location

Declare function Descent_at_Waypoint{
        // Call this afte orbit is mostly aligned.
        Sas Off.

        local Parameter LandLoc.
        local Parameter Descent_Deck to 2000.
        // Initial burn to lower the altitude at 45 degee from landing point.
        clearscreen.
        Local wAngle to 90.
        local errorAngle to 0.
        local autoSteer to retrograde.
        lock steering to autosteer.
        Local autoThrottle to 0.
        lock throttle to autoThrottle.
        until wAngle<45
        {
            print " Current Angle : " + round(wAngle)+"  " at (0,4).
            Print "   Angle Error : " + round(errorAngle,1)+"  " at (0,5).
            print "     Periapsis : " +Round(periapsis) + "  " at (0,6).
            print "    Target Per : " + Round(landLoc:altitude+descent_deck) + "  " at (0,7).
            set wAngle to waypoint_angle(Ship:position,LandLoc:position,ship:velocity:orbit).
            set errorAngle to vang(ship:velocity:orbit,vxcl(up:vector,LandLoc:position-ship:position)).
            set kuniverse:timeWarp:rate to 10.
            wait 1.

        }
        // Lower the periapsis to few thousand feet above landing 
        lock steering to retrograde.
        set kuniverse:timeWarp:rate to 0.
        Wait until vang(ship:facing:vector,ship:retrograde)<0.5.

        Until false{
            local descentNode to node(time:seconds+60, 0,0,0).
            add descentNode.
            local retroburn to 0.
            
         
        }

        set autoThrottle to 0. 
        wait 0.1.
        Sas On.
    }





// Hud Functions as required
Declare Function Landing_hud
{
    parameter offset to 2.
    Print "   Vertial Speed : "+Round(VerticalSpeed)+ "     "                at (0,offset+0).
    Print "     GroundSpeed : "+Round(GroundSpeed)+ "     "                  at (0,offset+1).
    Print " Distance Error: : "+Round(Alt:radar-verticalStopDistance)+"  "   at (0,offset+2).
    Print "Stoping distnace : "+round(verticalStopDistance)+"    "           at (0,offset+3).
}

Declare function info_Land
{
    
   // set xx to holdPosition:bearing.
   parameter offset to 0.
   print "MaxAcc/LocalG : "+ Round(MaxAcc,1)+"/"+round(localG,1) + "      " at (0,offset+1).
   print " GroundSpeed : " +Round(groundspeed,1) at (0,offset+2).
   
}

