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