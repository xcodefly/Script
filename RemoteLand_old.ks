// Ship DeOrbit and LAND in non-Atmosphere

Parameter Lat to 0.
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


Lock East to vCRS (up:vector,north:vector).
Lock MaxAcc to  ship:availableThrust/ship:mass.
Lock velocityEast 		to	round (vDot(East,ship:velocity:surface),2).
Lock velocityNorth 		to	Round (vDOt(North:vector,Ship:velocity:surface),2).
Lock TargetEast		 	to	Round (vdot(landloc:position,East),1). // Needs Work with East Vector. 
Lock TargetNorth		to 	Round (Vdot(LandLoc:position,North:vector),1).

set TargetHDG to ship:retrograde:vector:normalized. 

if maxAcc <0.1
{
	Stage.	
}


Lock throttle to aThrottle.
Lock steering to aSteer.

Lock g to constant:g * body:mass / body:radius^2.
lock aSteer to retrograde-R(0,0,0).

set tPID to PidLoop (.001,0.0002,.0001,0,1).
set tPID:setPoint to 0.



Set EastError to PidLoop  (2,	0,	0.2,		-10,10).
Set NorthError to PidLoop (2,	0,	0.2,		-10,10).
set EastError:setPoint to 0.
Set NorthError:setPoint to 0.
set EastAlign to PidLoop(15,.005,.01,-30,30).
set NorthAlign to PidLoop(15,.005,.01,-30,30).
set climbPID to pidLoop (0.9,.02,.04,-8,20).
set throttlePID to pidLoop (.40,	0.3,	0.015,	0,	1).
sas Off.



DeOrbit().

lock aSteer to Heading (0,90).
//climb().
//Hover().
AutoLand().
rcs Off.

Declare Function Align
	{
		Parameter deltaEast to TargetEast.
		Parameter deltaNorth to TargetNorth.
		set TEast to -EastError:update(time:seconds,DeltaEast/12).
		set EastAlign:setPoint to tEast.
		set EastPitch to EastAlign:update(Time:seconds,velocityEast).
		set tNorth to -NorthError:update(time:seconds,DeltaNorth/12).
		set NorthAlign:setPoint to tNorth.
		set NorthPitch to NorthAlign:update(Time:seconds,velocityNorth).
		print " Total Distance - " + Round(landLoc:distance).
	//	Print " East Pitch : "+EastPitch.
	
		Print " East Error      : "+TargetEast .
		print " East Velocity   : " + velocityEast + " ("+round (Teast,2)+")".
	
	//	Print " Target East Velocity " + round (Teast,2).
	//	Print " North Pitch : "+NorthPitch.
		
		Print " North Error     : "+TargetNorth.
		print " North Velocity  : " + velocityNorth  + " ("+ round (tNorth,2)+")".
	
	//	Print " Target North Velocity " + round (tNorth,2).
		set aSteer to heading (0,90) + R(-northPitch,-eastPitch,0).
}

Declare Function visual{
	ClearVecdraws().
	//vecdraw(ship:position, east*3,White,"East",1,true).
	vecdraw(Ship:position, ship:velocity:surface,Blue,		"Ship Velocity",1,True).   // Ship Velocity
	//	Vecdraw(Ship:Position, east*velocityEast,Red,			"Velocity East",1,true).
	//	Vecdraw(Ship:Position, North:vector*velocityNorth,Red,	"Velocity North",1,true).
	//	Vecdraw(Ship:Position,North:Vector*TargetNorth,Yellow,	"Target North",1,True).
	Vecdraw(LandLoc:position,Up:vector*500,Red,				"Landing Marker",2,True).
	//	vecdraw(ship:position,targetHDG*10,White,"Target HDG",1,true).
	vecdraw(Ship:position,targetHDG*5,White,					"Target hdg",1,true).
	
	vecdraw(Ship:position,vxcl(UP:vector,landLoc:position),Green,"Target",1,True).
	
	
}


Declare Function DeOrbit{
	set throttlePID:SetPoint to 0.
	until BurnDistance>TargetEast
	{
		Disp().
		visual().
		Lock targetHDG 			to vxcl(up:vector,landLoc:position:normalized)-vxcl(up:vector,ship:velocity:surface:normalized).
		set aSteer to 	targetHDG:direction+R(0,0,90).
		set BurnDistance 		to	Round (velocityEast^2/(2*MaxAcc*.68),1)*velocityEast/Abs(velocityEast).
		set burntime			to	Round(velocityEast/maxAcc,1).
		set MaxVertical 		to	-min(50,(ship:altitude-surfaceALt-SafeAlt)/Burntime).
		wait 0.01.
	}
	
	until velocityEast<20
	{	
		Lock targetHDG 			to vxcl(up:vector,landLoc:position:normalized)-vxcl(up:vector,ship:velocity:surface:normalized).
		set aThrottle to tPID:update(time:seconds,(TargetEast-burnDistance)).
		disp().
		Visual().
		
		
		set BurnDistance 		to	Round (velocityEast^2/(2*MaxAcc*.68),1)+50.
		set burntime			to	velocityEast/(maxAcc*Max(.001,aThrottle)).
		set MaxVertical 		to	-min(40,(ship:altitude-surfaceALt-safeAlt)/Burntime).
		set mVerticalPitch 		to  Min (50,Max(0,(maxVertical-ship:verticalSpeed))*3).
		set aSteer to targetHDG:direction+R(0,-mVerticalPitch,90).
		Wait .01.
	}
}

Declare Function Disp{
		Clearscreen.
		ClearVecdraws().
		print " Distance default : " + Round (landLoc:distance,1).
		print " East  Velocity   : " + velocityEast.
		print " Target East      : " + TargetEast.
		
		Print " Burn Distance    : " + BurnDistance.
		Print " ---------------- : " + Round(TargetEast-BurnDistance).
		Print " Target North     : " + TargetNorth.
		Print " North Velocity   : " + VelocityNorth.
		Print " Target North Ve  : " + Round (TargetNorth/(BurnTime+15),1).
	//	Print " Ship max acc     : " + Round (MaxAcc,1).
	//	Print " Burn Time        : " + Round(Burntime).
		Print " Vertical Speed   : " + Round(ship:verticalSpeed)+" ( "+Round(MaxVertical)+" ) ".
		
	//	Print " target HDG       : " +targetHDG.
		
}

Declare function alignInc {
    until 

}

Declare Function AutoLand{
	{
		
		Until ship:status = "landed"	
		{
			disp().
			clearvecdraws().
            print " main AutoLand".
			if sqrt(targetEast*TargetEast+TargetNorth*TargetNorth)>5 and Alt:radar>Stabalizer+100
			{
				set LandPID to PIDLOOP(0.3,.01,.01, .25,1).
			}else{
				set LandPID to PIDLOOP(0.3,.01,.01, 0,1).
			}
			
			Vecdraw(LandLoc:position,Up:vector*5,Red,"Landing Marker",1,True).
			clearscreen.
			
			if Alt:radar<Stabalizer
			{
				
				Set EastError to PidLoop  (2,	0,	0.1,		-0.5,0.5).
				Set NorthError to PidLoop (2,	0,	0.1,		-0.5,0.5).
				Align().
				if Ship:groundspeed>5
				{
					Hover().
                    Print "Hover".
				}
				set LandPID:setPoint to -Min(100,Alt:radar/12+0.5).
			}
			else 
			{
				Align().
				set LandPID:setPoint to -Min(100,Alt:radar/12+0.5).
			}
			
			Set aThrottle to LandPID:update(time:seconds,Ship:VerticalSpeed).
			Print "Throttle Position : "+ Round (aThrottle,2).
			Print "Target V Speed    : "+ Round (LandPID:setpoint,1). 
			Print "Vessel V Speed    : "+ Round(ship:verticalSpeed,1).		
			Wait 0.1.
		
		}
	}
}

Declare Function Hover
	{
        
    set HoverPID to PidLoop(0.5,.005,.01,0,1).
    Set HoverPID:setPoint to (50-Alt:radar)/10.
    set Stabalizer to Stabalizer+100.
    set EastAlign to PidLoop(15,.005,.01,-20,20).
    set NorthAlign to PidLoop(15,.005,.01,-20,20).
    ClearVecdraws().
    Vecdraw(LandLoc:position,Up:vector*5,Red,"Landing Marker",1,True).
    
    until ship:groundspeed <1
    {
        Set HoverPID:setPoint to (50-Alt:radar)/10.
        Align(0,0).
        set aThrottle to HoverPID:update(time:seconds,ship:verticalSpeed).
        Print " ------------".
        Print " Radar Alt  : " + Round(Alt:radar).
        Print " Ground Speed : " + Round(GroundSpeed,1).
        Print " Vertcal Speed: " + Round(shiP:verticalSpeed,1)+" ( " + Round((50-Alt:radar)/10,1) +" ) ".
        Wait .01.	
      Clearscreen.	
    }
}