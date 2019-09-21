run "_global.ks".
run "_hover.ks".
run "_land.ks".
run "_deOrbit.ks".
clearscreen.
Sas Off.
lock steering to retrograde.
until  vdot(-ship:facing:vector,ship:velocity:orbit:normalized)>-0.9
{
    print round(vdot(ship:facing:vector,ship:velocity:orbit:normalized),2)+ "   " at (0,1).
     wait 0.1.
}
wait 1.
Parameter targetLoc to SHIP:BODY:GEOPOSITIONOF(SHIP:POSITION + 16000*(SHIP:velocity:orbit):normalized).
deorbitloc(targetLoc).
hoverslam().
softLand().

