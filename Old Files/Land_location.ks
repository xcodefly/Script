// Ship DeOrbit and LAND in non-Atmosphere
clearscreen.
Parameter Lat to 2.
Parameter Lng to -160.
Parameter SafeAlt to 1000.
Set Stabalizer to 50.
set aThrottle to 0.
Set aSteer to Retrograde.
//Common Variables doen't need update

set LandLoc to LatLng(lat,lng).
set surfaceAlt to Round (landLoc:TerrainHeight).
set BurnDistance 		to	20000.
set burntime			to	1000.
set MaxVertical 		to	0.	

// Variable need update
set BurnDistance to 0.
//Set TargetDistance to 1000.

// lock 
Lock East to vCRS (up:vector,north:vector).
Lock East to vCRS (up:vector,north:vector).
Lock MaxAcc to  ship:availableThrust/ship:mass.





lock velocityVecH to vxcl(up:vector,ship:velocity:orbit).
lock targetVecH to vxcl(up:vector,ship:position-LandLoc:position).
// Vectors used to align with the targetVector
// 90 degree before landing latitude.


until lights
{
    vDisp().
    hud().
    wait 0.01.
}




declare function vdisp
{
    clearvecdraws().
    vecdraw(ship:position,velocityVecH,red,"Horizental Veloctiy",1,true).
    vecdraw(ship:position,landLoc:position,green,"Landing Target",1,true).
}

declare function hud
{

    print " Target Distance : " + round(landLoc:distance) + "   " at (0,1).
    print " Target Angle    : " + round(vang(north:vector,targetVecH)-vang(north:vector,ship:velocity:orbit),1) +"  " at (0,2).
    print " Landing Lng     : " + Round(ship:geoposition:lng,1)+"/"+lng +"  " at (0,3).
}