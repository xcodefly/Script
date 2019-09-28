// File contain functions that will help get more information about the target ex. Mean Anomaly, eta to periapsis, etc. 
Declare function Target_anomalyAt
{
    parameter checkTime.
    Return target_v.
}

Declare function target_periapsis_eta
{
    set v to target:orbit:trueanomaly.
    set e to target:orbit:eccentricity.
    set E_v to arccos((e+cos(v))/(1+e*cos(v))).
    if v<180
        {
            set M to (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
        
        }
        else 
        {
            set M to 360 - (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
        }
        set t_periapsis to target:orbit:period/360*(360-M).
        return t_periapsis.

}

declare function target_meanAnomalyAt
{
    Local Parameter setTime.
    set a to target_Orbit_info.
    Local X to setTime-a:ETA_periapsis.
    Local M to a:MeanAnomaly.
    Print M.
}

declare function target_orbit_info{
    
    Local v to target:orbit:trueanomaly.
    Local e to target:orbit:eccentricity.
    Local E_v to arccos((e+cos(v))/(1+e*cos(v))).
    if v<180
    {
        set M to (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
    }
    else 
    {
        set M to 360 - (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
    }
    set t_periapsis to target:orbit:period/360*(360-M).
    if t_periapsis-target:orbit:period/2<time:seconds
    {
        set t_apoapsis to t_periapsis+target:orbit:period/2.
    }
    else
    {
        set t_apoapsis to t_periapsis-target:orbit:period/2.
    }
    
    set Target_Info to lexicon().
    target_Info:add("ETA_periapsis",t_periapsis).
    target_info:add("ETA_apoapsis",t_apoapsis).
    target_info:add("MeanAnomaly",M).
    return target_info.
}