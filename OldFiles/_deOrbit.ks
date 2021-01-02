

// This function will use the periapsis as its initial target distance and attemtps to make it as its touchdown point. 
// Working concept - ship will start its retro burn to arrest its orbital speed zero by the time it reaches its Orignal periapsis. (It DOESN'T activily monitor it)
// Safety - it will try to bring Horizental speed to zero(App) but make sure it is not descending too fast. It might pitch up if it is falling to fast for low powered engines. once horizental speed is slow enought it should stop. 

// Roughly land at its orignal Periapsis. 


run "_global.ks".


Declare function DeorbitRetro
{
    local burntime to ship:velocity:orbit:mag/maxAcc.
    lock steering to retrograde.
    sas off.
    until (eta:periapsis<burntime)
    {
        info_Orbit().
        info_land(4).
        print " Burn Time : "+round(burnTime,1) at (0,3). 
      
        wait 0.01.

    } 
    // ** This causes the ship to point down, will work on it later. 
    //   set initialDirection to -ship:velocity:orbit:normalized.
    sas off.
    lock steering to -vxcl(up:vector, ship:velocity:orbit):normalized.
    set throttle to 0.8.
    clearscreen.
    until (vxcl(up:vector,ship:velocity:orbit):mag<10) // Comparing velocity in direction of orignal orbital velocity vector. 
    {
        info_Orbit().
        info_land(4).
        wait 0.01.
     //   clearvecdraws().
        print " Orbital Velocity orignal "+round(vxcl(up:vector,ship:velocity:orbit):mag,1)+"  " at (0,10).
    //   vecdraw(ship:position, -vxcl(up:vector,ship:velocity:orbit):normalized*5,Red,"Heading Hold",1,true).
    //  vecdraw(ship:position, ship:velocity:orbit,Yellow,"Current V vector",1,true).
        
    }
    set throttle to 0.
}
// the function need the locaiton of landing sight in LatLong.

// Land at the selected locaiton. Pass geo-Locaiton as ( to implement later - paramter and OffsetLocation North, East). 
Declare Function Deorbit_Location     // Non - atmosphere body.
    {
        Local Parameter landingLoc.
        // get to somewhat circular orbit.
        // use node to find correction burn. 
        




        // find the 90 before landing location to align the orbit with the landing location.
        // do retrograde burn to X altitude to lower the periapsis. 

        // slowdown at top of the landing location. 

    }
Declare Function DeorbitLoc
{
    // v2-u2=2as
    sas off.
    parameter landingLoc.
    set autoThrottle to pidLoop(0.005,0.01,0.0002,0,1).
    set autoThrottle:setpoint to 0.
    
    lock deAccDistance to (ship:velocity:surface):mag^2/(2*maxAcc*0.9).
    lock targetDistance to vdot(landingLoc:position,ship:velocity:orbit:normalized).
    lock correctionVec to -((vxcl(up:vector,landingLoc:position-ship:position):Normalized)-ship:velocity:orbit:normalized).
    // at 90 degree, do an deorbital burn.
    // adjust the inclinaiton at this point to make it cheap burn. 
    lock Steering to -(ship:velocity:orbit:normalized+correctionVec).
    // correction angle for steering. 
   
    until targetDistance<deAccDistance*1.15
    {
        deorbitLoc_hud().
     //   set kuniverse:timewarp:rate to 10.
        vecdraw(ship:position,correctionVec, red," correction Angle",10,true).
        wait 1.
        clearvecdraws().
    }

    set kuniverse:timewarp:rate to 0.

    until targetDistance<deAccDistance
    {
        deorbitLoc_hud().
    }
    until targetDistance<300
    {
        deorbitLoc_hud().
        set throttle to autoThrottle:update(time:seconds,targetDistance-deAccDistance).
        wait 0.01.
    }
    set throttle to 0.
}
 

// waypoint at the ground as a landing target.
declare function deOrbit_At_Waypoint{
    Local parameter landingPoint to "NO fix".
    {
        if landingPoint = "No Fix"
        {
            Print " Select fix for landing.".
        }
        else
        {
            
            deorbitLoc(waypoint(landingPoint):geoposition).
        }
    }
   
}

Declare function info_orbit
{   
   parameter offset is 0.
   Print " Orbit Info " at (0, offset).
   Print "  Apoapsis : " +  Round(Apoapsis)+" ("+Round(eta:Apoapsis)+"s)          "  at (0,offset+1).
   print " Periapsis : " +  Round(periapsis)+" ("+Round(eta:periapsis)+"s)          "at (0,offset+2).
}


Declare function BasicInfo
{
    parameter Offset is 2.   // Row offset
    print "     Speed : " + round(groundspeed) + "   " at (0,2+Offset).
    print "      Slip : " + round(vdot(velocity:surface,facing:starvector),1)  at (0,5+Offset).
    print "       HDG : " + Round(ship:heading)+" ["+Round(targetHDG)+"]  " at (0,6+Offset).
}


declare Function deorbitLoc_hud
{
    clearvecdraws().
   // vecdraw(ship:position,LandingLoc:position,red,"Landing Location",1,true).
    print "DeAcc Distance : "+Round(deAccDistance)+"    " at (0,12).
    print "Target Distance : "+Round(targetDistance)+"   " at (0,13).
}

