// The function in this library are used for orbit adjustments for the ship.
// Fx. setOrbit (Parameter AP, Pe, )
run "r2.ks".

Clearscreen.

declare function adjust_Periapsis
{
    parameter new_apoapsis to target:apoapsis.
   
    Local vA to ((2*body:mass*constant:g)*ship:periapsis/(ship:apoapsis*(ship:apoapsis+ship:periapsis)))^0.5.
    Local vA_new to ((2*body:mass*constant:g)*ship:periapsis/(new_Apoapsis*(new_Apoapsis+ship:periapsis)))^0.5.
    Local delta_pro to vA_new-va.
    Local nd to node(time:seconds+eta:apoapsis,0,0,deltaPro).
    add nd.
    
}
Declare function adjust_Apoapsis
{
    parameter new_periapsis to target:periapsis.
    local vP to ((2*body:mass*constant:g)*ship:apoapsis/(ship:apoapsis*(ship:apoapsis+ship:periapsis)))^0.5.

    Local vp_new to ((2*body:mass*constant:g)*ship:periapsis/(new_Apoapsis*(new_Apoapsis+ship:periapsis)))^0.5.
    Local delta_pro to vP_new-vP.
    local nd to node(time:seconds+eta:Periapsis,0,0,deltaPro).
    add nd.
}
    

// 



}

Declare function orbit_Hud
{
    
    Print "  Target Semi Major Axis : " + Round(setSemiMajAxis) +"   " at (0,2).
    Print " Current Semi Major Axis : " + Round(CurrentSemiMajAxis) +"   " at (0,3).
    Print "                     LAN : " + round(ship:orbit:lan,1) +"   "at (0,4).
    Print "            Eccentricity : " + Round (ship:orbit:eccentricity,3) +"   "at (0,5).
    print "           True Anomaly  : " + Round (ship:orbit:trueAnomaly,1) +"   " at (0,6).

    //print " ______________________________" at (0,7).



}

orbit_hud().



