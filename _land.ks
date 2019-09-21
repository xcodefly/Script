// all the functions for landing are in this file. 
// order of landing is planned to be simple to complex as it goes down.
// "_global" should be inclued to use this file and all the new global vairables should be update in that "_global" file. 

// softLand uses about 75% of max thrust to do the basic soft landing without working about the location of landing. It monitors when it should start to accelerate in order to softland. Should only be used with ship in gyro of stable landing. Uses retrograde mode for landing untill 100 meter from ground and switchs to pitch hold of last part of landing. 

run "_hover.ks".

// should be used when horizontal velocity is low. only vertial speed.  

lock verticalStopDistance to 1.05*(ship:verticalspeed^2 / (2 * MaxLandingAcc)).	// 110% to compensate for error.


Declare function HoverSlam     // this is the basic hoverslam. 
{
    clearscreen.
    set tPID to pidloop(0.05,0.1,0.001,0,1).
    set tPID:setpoint to 30.
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
    parameter shipHeight to 5.
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


Declare function track_location
{

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

