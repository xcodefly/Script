// The function in this library are used for orbit adjustments for the ship.
// Fx. setOrbit (Parameter AP, Pe, )
run "r2.ks".

Clearscreen.

declare function adjust_Periapsis
{
    
    parameter new_periapsis to target:periapsis.
    local rA to body:radius +ship:apoapsis.
    local rP to body:radius + ship:periapsis.
    local rP_new to body:radius+new_periapsis.
   
    
   
    Local vA to ((2*body:mass*constant:g)*rP/(rA*(rA+rP)))^0.5.
    Local vA_new to ((2*body:mass*constant:g)*rP_new/(rA*(rA+rP_new)))^0.5.
    Local delta_pro to vA_new-va.
    Local nd to node(time:seconds+eta:apoapsis,0,0,delta_Pro).
    add nd.
    
}

Declare function adjust_Apoapsis
{
    parameter new_apoapsis to target:apoapsis.

    local rA to body:radius +ship:apoapsis.
    local rP to body:radius + ship:periapsis.
    local rA_new to body:radius+new_Apoapsis.


    Local vP to ((2*body:mass*constant:g)*rA/(rP*(rA+rP)))^0.5.
    Local vp_new to ((2*body:mass*constant:g)*rA_new/(rP*(rA_New+rP)))^0.5.
    Local delta_pro to vP_new-vP.
    local nd to node(time:seconds+eta:Periapsis,0,0,delta_Pro).
    add nd.
}
    

// 





Declare function orbit_Hud
{
    
    Print "  Target Semi Major Axis : " + Round(setSemiMajAxis) +"   " at (0,2).
    Print " Current Semi Major Axis : " + Round(CurrentSemiMajAxis) +"   " at (0,3).
    Print "                     LAN : " + round(ship:orbit:lan,1) +"   "at (0,4).
    Print "            Eccentricity : " + Round (ship:orbit:eccentricity,3) +"   "at (0,5).
    print "           True Anomaly  : " + Round (ship:orbit:trueAnomaly,1) +"   " at (0,6).

    //print " ______________________________" at (0,7).



}





