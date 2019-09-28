// The function in this library are used for orbit adjustments for the ship.
// Fx. setOrbit (Parameter AP, Pe, )
Run "_targetPlus.ks".

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
    

// This function to find the optimal orbit to adjust orbit. 
// assuming your either periaps or apoapsis heigh is withing 1000 feet. // Roughly.
Declare function WarpTo_optimal_Periapsis_orbit
{   
    set Counter to 0.
        
    if target:orbit:SemiMajorAxis>ship:orbit:SemiMajorAxis
    {   
        until false
        {
            if target_positionAt(eta:periapsis+ship:orbit:period*counter)>0 and target_positionAt(eta:periapsis+(Counter+1)*ship:orbit:period)<0
            {
                break.
            }
            else 
            {
                set counter to counter+1.
            }
        }
    }else{
        
        until false
        {
            if target_positionAt(eta:periapsis+ship:orbit:period*counter)<0 and target_positionAt(eta:periapsis+(Counter+1)*ship:orbit:period)>0
            {
                break.
            }
            else 
            {
                set counter to counter+1.
            }
        }
    }
    return (time:seconds+eta:periapsis+ship:orbit:period*counter-ship:orbit:period/2).
}


Declare function WarpTo_optimal_Apoapsis_orbit
{   
    set Counter to 0.
    set warptime to 0.  
    if target:orbit:SemiMajorAxis>ship:orbit:SemiMajorAxis
    {   
        until false
        {
            if target_positionAt(eta:periapsis+ship:orbit:period/2+ship:orbit:period*counter)>0 and target_positionAt(eta:periapsis+ship:Orbit:period/2+(Counter+1)*ship:orbit:period)<0
            {
                set warptime to (time:seconds+eta:periapsis+ship:orbit:period*counter).
                break.
            }
            else 
            {
                set counter to counter+1.
            }
        }
    }else{
        
        until false
        {
            if target_positionAt(eta:periapsis+ship:period/2+ship:orbit:period*counter)<0 and target_positionAt(eta:periapsis+ship:period/2+(Counter+1)*ship:orbit:period)>0
            {
                set warptime to (time:seconds+eta:periapsis+ship:orbit:period*counter-ship:orbit:period/2).
                break.
            }
            else 
            {
                set counter to counter+1.
            }
        }
    }return warptime.
    
}
Declare function Periapsis_closedApp_Burn
{
    set tt to WarpTo_optimal_Periapsis_orbit().
    warpto (tt).
    wait until time:seconds>tt.
    Print " Next step.".
    set next to target_orbit_info().
    if target:orbit:semimajorAxis>ship:orbit:semimajorAxis
    {
       set next_Period to next:eta_periapsis-eta:periapsis+target:orbit:period.
    }else
    {
       set next_period to next:eta_periapsis-eta:periapsis+target:orbit:period.
    }
   // set next_Period to next:eta_periapsis-eta:periapsis.
   
    //print next_period.
    set current_period to ship:orbit:period.
    set current_SemiMajorAxis to ship:orbit:semimajorAxis.
    set next_semiMajorAxis to (current_SemiMajorAxis^3*((next_Period/current_period)^2))^(1/3).
    set Next_apoapsis to next_semiMajorAxis*2-(ship:periapsis+body:radius)-body:radius.
    print " Current Period "+ Round(current_Period).
    print " NExt Period " +  Round(Next_Period).
    print next_semiMajorAxis.
    print " Next Apoapsis " + next_apoapsis.
   
    adjust_Apoapsis(next_apoapsis).
    exenode.
    // Keplers third law P^2 pro to A^3
    adjust_apoapsis(target:apoapsis).
    exenode.

    
}

Declare function Apoapsis_closedApp_Burn
{
    set tt to WarpTo_optimal_Apoapsis_orbit().
    warpto (tt).
    wait until time:seconds>tt.
    Print " Next step.".
    set next to target_orbit_info().

    set next_Period to target:orbit:period-eta:apoapsis+next:eta_apoapsis.
  
 //   set next_Period to next:eta_periapsis -eta:periapsis+target:orbit:period.
   // set next_Period to next:eta_periapsis-eta:periapsis.
   
    //print next_period.
    set current_period to ship:orbit:period.
    set current_SemiMajorAxis to ship:orbit:semimajorAxis.
    set next_semiMajorAxis to (current_SemiMajorAxis^3*((next_Period/current_period)^2))^(1/3).
    set Next_periapsis to next_semiMajorAxis*2-(ship:Apoapsis+body:radius)-body:radius.
    print " target time to Apo " +  Round(next:eta_apoapsis).
    print " ship time to apo "+Round(eta:apoapsis).
    print " Current Period "+ Round(current_Period).

    print " NExt Period " +  Round(Next_Period).
    print next_semiMajorAxis.
    print " Next Periapsis " + next_periapsis.
   
    adjust_Periapsis(next_Periapsis).
    
    exenode.
    // Keplers third law P^2 pro to A^3
    adjust_periapsis(target:Periapsis).
    exenode.

    
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





