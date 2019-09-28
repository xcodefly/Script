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

declare function target_positionAt
{
    Parameter testTime.
    Local shipV to velocityat(ship,testtime+time:seconds):orbit:normalized.
    local shipP to positionAt(ship,testtime+time:seconds).
    Local TargetP to positionat(target,testtime+time:seconds).
    set targetPosition to targetP-shipP.
    set targetDistance to 0.
    if vdot(shipV,targetPosition)<0
    {
        set targetDistance to targetPosition:mag*-1.

    }else
    {
         set targetDistance to targetPosition:mag.
    }
 //   Print round(targetDistance).
    Return targetDistance.
    

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
    set t_apoapsis to t_periapsis-target:orbit:period/2.
    if t_apoapsis<0
    {
        set t_apoapsis to t_apoapsis+target:orbit:period.
    }
    
    set Target_Info to lexicon().
    target_Info:add("ETA_periapsis",t_periapsis).
    target_info:add("ETA_apoapsis",t_apoapsis).
    target_info:add("MeanAnomaly",M).

    return target_info.
}