// This is used to find the ANDN without the map.

// Vector function

// Hud Display.

// variables.
sas off.
lock myOrbitNormal to -vcrs(ship:position-ship:body:position,ship:velocity:orbit):normalized.
lock targetOrbitNormal to -vcrs(target:position-target:body:position,target:velocity:orbit):normalized.
lock ANDN_line to vcrs(myOrbitNormal,targetOrbitNormal).
set anNodeAnomaly to 0.
set relativeAngle to 0.
clearscreen.
gear off. 
declare function vec_help
{
    clearvecdraws().
 //   vecdraw(ship:body:position,ship:position-ship:body:position,Green,"shipNormal",1,true).
  //  vecdraw(target:body:position,target:position-target:body:position,Red,"targetNormal",1,true).
   // vecdraw(ship:body:position,myOrbitNormal,Green, " My Normal",1,true).
//    vecdraw(ship:position,-vcrs(ship:velocity:orbit,body:position-ship:position),Green, "Normal",1,true).
    
 //   vecdraw(ship:position,vcrs(ship:velocity:orbit,body:position-ship:position),Red, "AntiNormal",1,true).
    
}

declare Function hud_ANDN
{
    parameter offset to 0.
    set relativeAngle to vang(myOrbitNormal,targetOrbitNormal).
    // Angular Velocity.
    print " AN Node in : "+ round(ANnode,1)+"   " at (0,offset+0).
    print " True Anomaly    : " + round(ship:orbit:trueAnomaly,3) + "   " at (0,offset+2).
    print " Mean Anomaly    : " + round(ship:orbit:meanAnomalyatEpoch,3) + "   " at (0,offset+3).
  
    Print " AN true Anomaly : " + round(anNodeAnomaly,1)+"  " at (0,offset+4).
  //  Print "       dV change : " + Round (2*velocityat(ship,time:seconds+eta:periapsis+108):orbit:mag*sin(relativeAngle/2)) at (0,offset+5).
    print "  Time since Per : "+round(ship:orbit:period-eta:periapsis) +"   " at (0,offset+6). 
}




function EccAnomT {
    set  ec to ship:orbit:eccentricity.   //eccentricity
    declare parameter T.    //True anomaly
    local tanE2 is  sqrt((1-ec)/(1+ec))	* tan(T/2).                    // tan(E/2)
        
    return 2 * arctan(tanE2).
}

declare function MeanAnomE 
{
    Local Parameter E.
    Local ec to Ship:orbit:eccentricity . 
    return E - ec*sin(E) * Constant:RadToDeg.
}

Declare Function TimeToM{
    Local Parameter M.
    Local u to sqrt(constant:G*Body:mass/ship:orbit:semiMajorAxis^3).

    Return Round(M*constant:degToRad/u).
}



Declare function test
{
    set EE to EccAnomT(anNodeAnomaly).
    if ee<0
    {
        set ee to 360+ee.
    }
    set M to MeanAnomE(EE).
    set t to TimeToM(M).
    print " EE : " +Round(ee,1) at (0,10).
    print " M : " + Round(M,1) at (0,11).
    print " Ecc " + Round(ship:orbit:eccentricity,4) at (0,12).
    print " Time to AN node : "+T  at (0,15).
    if hasnode{

    }else
    {
        set dV to 2*velocityAt(ship,time:seconds+eta:periapsis+T):orbit:mag*sin(relativeAngle/2).
        set a to node(time:seconds+eta:periapsis+T,0,-dV,0).
        add a.
    
    }
}


until Gear
{
    alignOrbit().
    hud_ANDN().
    vec_help().
 //   ascNodeTime(0).
  //  ascNodeTime(anNodeAnomaly,5).
   test().
    wait 0.01.
}

declare function alignOrbit
{
   



 //This give an and dn with sign.*/

   if vang(positionat(ship,time:seconds+5)-body:position,ANDN_line)-vang(ship:position-body:position,ANDN_line)>0
    {
        set anNode to vang(ship:position-body:position,ANDN_line).
        set dnNode to -vang(ship:position-body:position,-ANDN_line).
     

    } else
    {
        set AnNode to -vang(ship:position-body:position,ANDN_line). 
        set dnNode to +vang(ship:position-body:position,-ANDN_line).
     

   }

    if vang(positionat(ship,time:seconds+eta:periapsis+5)-body:position,ANDN_line)<vang(positionat(ship,time:seconds+eta:periapsis)-body:position,ANDN_line)
    {
        set anNodeAnomaly to (vang(positionat(ship,time:seconds+eta:periapsis)-body:position,ANDN_line)).
    }
    else 
    {
        set anNodeAnomaly to 360-(vang(positionat(ship,time:seconds+eta:periapsis)-body:position,ANDN_line)).

    }
   
  //  set anNodeAnomaly to (vang(positionat(ship,time:seconds+eta:periapsis)-body:position,ANDN_line)).
    set relativeAngle to vang(myOrbitNormal,targetOrbitNormal).
   if anNode<5
   {
    //   print "An" at (0, 8).
       lock steering to vcrs(-(ship:body:position-ship:position),ship:velocity:orbit).
   }
   else 
   {
     //  print "dn" at (0, 8).
        lock steering to vcrs((ship:body:position-ship:position),ship:velocity:orbit).
   }
}