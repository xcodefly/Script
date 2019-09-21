    
    
Declare Function drawVisual
{
	ClearVecdraws().
	//vecdraw(ship:position, east*3,White,"East",1,true).

  //  vecdraw(TargetPosition:position,up:vector*2,Red," LockedPos",1,true).
    vecdraw(ship:position,facing:vector,green,"front",1,true).
    vecdraw(ship:position,facing:starvector,green,"right",1,true).
    vecdraw(ship:position,facing:upVector,green,"Up",1,true).
    vecdraw(ship:position,velocity:surface,Blue,"velocity",1,true).
    //	vecdraw(Ship:position, ship:velocity:surface,Blue,		"Ship Velocity",1,True).   // Ship Velocity
	//	Vecdraw(Ship:Position, east*velocityEast,Red,			"Velocity East",1,true).
	//	Vecdraw(Ship:Position, North:vector*velocityNorth,Red,	"Velocity North",1,true).
	//	Vecdraw(Ship:Position,North:Vector*TargetNorth,Yellow,	"Target North",1,True).
    //	Vecdraw(LandLoc:position,Up:vector*500,Red,				"Landing Marker",2,True).
	//	vecdraw(ship:position,targetHDG*10,White,"Target HDG",1,true).
    //	vecdraw(Ship:position,targetHDG*5,White,					"Target hdg",1,true).
	
    //	vecdraw(Ship:position,vxcl(UP:vector,landLoc:position),Green,"Target",1,True).
}