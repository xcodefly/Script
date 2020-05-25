// add node that is 90 degree from the waypoint to make an inclination node.
@LazyGlobal off.
declare function Waypoint_align
{
    // this funciton need lots of cleaning.
    // At 90 degree, burn until velocity vector  aligh with target vector.

    // find a time when positon will be 90 degree to waypoint.
    Local autoSteer to ship:facing:vector.
    lock steering to autoSteer.
    sas off.
    parameter selectedWaypoint.
    local wTime to 0.
    local wPosition to ship:position.
    local wAngle to 100.

    until Round(wAngle)=91
   
    {
        set wAngle to WayPoint_Angle(PositionAt(Ship,time:seconds+wtime),selectedWaypoint:position,velocityat(ship,time:seconds+wtime):orbit).
        set wtime to wtime+10.
        print " Current Waypoint " + round(wAngle) +   "  " at (0,1).
        print " Seeking position at  + " + wtime at (0,2).
        wait 0.01.
    }
    
    clearscreen.
    kuniverse:timeWarp:warpto(time:seconds+wtime-5).
    local previousError to 90.
    local errorAngle to 0.
    clearscreen.

    until   round(wAngle)=90
    {   
        Print " Press 'Control C' to exit " at (0,1).
        set wAngle to WayPoint_Angle(PositionAt(Ship,time:seconds+wtime),selectedWaypoint:position,velocityat(ship,time:seconds+wtime):orbit).
     
        set wAngle to WayPoint_Angle(Ship:position,selectedWaypoint:position,ship:velocity:orbit).
        print "waypoint Angle : "+ round(wAngle,1) +"  "at (0,3).
        set autoSteer to (vxcl(up:vector,selectedWaypoint:position-ship:position):normalized- ship:velocity:orbit:normalized).
        set errorAngle to vang(ship:velocity:orbit,vxcl(up:vector,selectedWaypoint:position-ship:position)).
        Print " Error Target : " + round (errorANgle,1)+"  " at (0,4).
        wait 0.1.
        
       
        clearvecdraws().

    }

   
    until errorAngle > previousError+0.1{
        vecdraw(ship:position,ship:velocity:orbit:normalized*5,green,"Velocity", 1,true).
        vecdraw(ship:position,vxcl(up:vector,(selectedWaypoint:position-ship:position)):normalized*3,red,"target Angle",1,true).
        lock  throttle to .2.
        if errorAngle>1
        {
            set autoSteer to (vxcl(up:vector,selectedWaypoint:position-ship:position):normalized- ship:velocity:orbit:normalized).
        }
        set errorAngle to vang(ship:velocity:orbit,vxcl(up:vector,selectedWaypoint:position-ship:position)).
        Print " Error Target : " + round (errorANgle,1)+" / " + round(previousError+0.1,1) + "    " at (0,4).
        wait 0.1.
        if errorAngle<previousError{
              set previousError to errorAngle.
        }
      
        clearvecdraws().

    }

    lock steering to retrograde.
    
    lock throttle to 0.
    wait 5.
    sas on.
    

   
    
   



    
}
// Called by Waypoint_align to warp to 91 and then align lock steering to cancel the angle. 

declare function WayPoint_Angle
    {
        Local parameter p1,p2,v1.
        Local returnAngle to vang(p1-body:position,p2-body:position).
        if (vdot(v1,p1-p2)>0)
        {
            set returnAngle to -returnangle.    
        }
        return returnAngle.
    }
