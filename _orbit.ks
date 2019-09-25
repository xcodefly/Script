// The function in this library are used for orbit adjustments for the ship.
// Fx. setOrbit (Parameter AP, Pe, )
run "r2.ks".

Clearscreen.

declare function adjust_apoapsis
{

}
Declare function adjust_periapsis
{
    
}
Declare function adjust_Orbit{
    // Two burns to do transfer. One at periapsis and next at Apoapsis.
    Parameter new_Apoapsis.
    Parameter new_Periapsis.
    
    set rA_new to body:radius+new_apoapsis.
    set rP_new to body:radius+new_periapsis.
    // Burn at periapsis to lift the Apoapsis.
    set rA to body:radius+ship:apoapsis. 
    set rP to body:radius+ship:periapsis.


    // First Burn
    set vP to ((2*body:mass*constant:g)*rA/(rP*(rA+rP)))^0.5.
    set vP_burn1 to ((2*body:mass*constant:g)*rA_new/(rP*(rA_new+rP)))^0.5.
    set burn1_prograde to vP_burn1-vP.
    set burn1_node to node(time:seconds+eta:periapsis,0,0,burn1_prograde).
   
    add burn1_node.
    exenode().
    set rA to body:radius+ship:apoapsis. 
    set rP to body:radius+ship:periapsis.
    //Second Burn
    
    set vA to ((2*body:mass*constant:g)*rP/(rA_new*(rA_new+rP)))^0.5.
    set vA_new to ((2*body:mass*constant:g)*rP_new/(rA_new*(rA_new+rP_New)))^0.5.
    set burn2_prograde to vA_new-vA.
    set burn2_node to node(time:seconds+eta:apoapsis,0,0,burn2_prograde).

    add burn2_node.
    exenode().


    set vA to ((2*body:mass*constant:g)*rP/(rA*(rA+rP)))^0.5.
    set vP to ((2*body:mass*constant:g)*rA/(rP*(rA+rP)))^0.5.

    set vA_new to ((2*body:mass*constant:g)*rP_new/(rA_new*(rA_new+rP_new)))^0.5.
    set vP_new to ((2*body:mass*constant:g)*rA_new/(rP_new*(rA_new+rP_new)))^0.5.
 
    print "           vA : " + Round (vA,1) +"   " at (0,7).
    print "           vP : " + Round (vP,1) +"   " at (0,8).
    print "       vA_new : " + Round (vA_new,1) +"   " at (0,9).
    print "       vP_new : " + Round (vP_new,1) +"   " at (0,10).
    print " ETA Periapsis : " + Round(eta:periapsis) at (0,11).
    

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

adjust_Orbit (149296,147853).
orbit_hud().



