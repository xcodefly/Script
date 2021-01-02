
//run vec_fx.
//run display_fx.
clearscreen. 
parameter targetPort is "test".

// Orbital varaibles
//n : Mean Notion
//P: Orbital Period
//M: Mean Anomaly (Current)
//E: Eccentric Anomaly
//e: Eccentricity
//theta: True Anomaly
//a: Semi-Major Axis


lock targetV to target:position-ship:position.




lock dv to ship:velocity:orbit-target:velocity:orbit.
lock vfront to vdot(ship:facing:vector,dV).
lock vright to vdot(ship:facing:rightvector,dv).
lock vup to vdot(ship:facing:upvector,dv).
lock vTarget to vdot((target:position-ship:position):Normalized,dv).
//set  readyport to target:partstagged("Dock").
lock dFront to vdot(Ship:facing:vector,target:position).
lock dright to vdot(Ship:facing:rightvector,target:position).
lock dup to vdot(Ship:facing:upvector,target:position).
SET targetHeading to v(0,0,0).
lock dVel to vdot(targetV:normalized,dv).


// throttle pid to slow down or speedup.
set tpid to pidloop(0.03,0,0.02,-1,1).
set tpid:setpoint to 0.
set aThrottle to 0.

lock throttle to aThrottle.
lock steering to aSteer.
// going towards and target.
// target vector.normalized , velocityV.normalz

    set alignXPID to pidLoop(0.15,0.015,0.5,-2,2).
    set alignYPID to pidLoop(0.15,0.015,0.5,-2,2).
    set alignZPID to pidLoop(0.15,0.015,0.5,-2,2).

    set frontPID to PIDloop(0.55,0.95,0.04,-1,1).
    set rightPID to PIDloop(0.55,0.95,0.04,-1,1).
    set upPID to    pidLOop(0.55,0.95,0.04,-1,1).

rcs off.
sas off.
until target:distance<200
{
    //vv().
  //  orbitinfo().
    
   // if vtarget< target:distance*0.01
    if vtarget> target:distance*0.015
    {
        
        awaytarget(). 
      
        print " from "+round(target:distance*0.02,2)+ " " at (0,3).
        set tpid:setpoint to target:distance*0.02.
        if vang(ship:facing:vector,aSteer)<1
        {
             set aThrottle to tpid:update(time:seconds,vtarget).
        } else 
        {
            set aThrottle to 0.
        }
       
       
       
    } else  if vtarget< target:distance*0.0075
   
    {
        approachTarget().
    
        print " to   "+round(target:distance*0.008,2)+ " " at (0,3).
        set tpid:setpoint to target:distance*0.005.
        if vang(ship:facing:vector,aSteer)<1
        {
            set aThrottle to tpid:update(time:seconds,vfront).
        } else
        {
           
        }
    } 
    
    

   wait 0.01.
}
// target Vessel doesn't load until 2 miles so had to wait for dock.

set  readyport to target:partstagged(targetPort).
lock targetV to readyPort[0]:position-ship:position.
lock vTarget to vdot((readyPort[0]:position-ship:position):Normalized,dv).
lock dockVector to readyPort[0]:portfacing:vector.
lock dFront to vdot(Ship:facing:vector,readyPort[0]:position).
lock dright to vdot(Ship:facing:rightvector,readyPort[0]:position).
lock dup to vdot(Ship:facing:upvector,readyPort[0]:position).
lock steering to -dockVector.
set athrottle to 0.


wait 5.
set movex to 100.
set movey to 20.
set movez to 20.
set align to false.
set step to 1.
position().
rcs on.
until HASTARGET = FALSE
    {
       // orbitinfo().
       // vv().
        
        lock steering to -dockVector.
        
       
        if round(dright)=0 and round(dUp)=0
        {
            set align to true.
        }else 
        {
            set align to false.
        }

        if align = false
        {
            if round(dFront) = -50 and Round(dright)=moveY and Round(dup)=moveZ
            {
                set moveX to  50.
            } 
            
            if round(dFront) = 50 and Round(dright)=moveY and Round(dup)=moveZ
            {
                set moveX to  50.
                set moveY to 0.
                set movez to 0.
            }
            positionxyz(movex,movey,movez,align).
           
        }  
        else {
            positionXYZ(moveX,0,0,align).
        }
        print " Move X : " +    round(moveX) + " dfront : "+round(dfront,1)+ " ALIGN:"+align+ "     " at (0,7).
        wait 0.01.
    }



rcs off.

Function approachTarget
    {
        set aSteer to targetV:normalized-dv:normalized*0.5.
        
    }
Function awayTarget
    {
    set aSteer to -dV:normalized+targetV:normalized*0.7.
    
   
    }
function position{
    //helper function to decide where to position the docking ship. 
    // if the target ship is in front, you can move to (100,0,0) else move to 50 meter side. 
        // find if the dfront is positive or negitive. 
        if dFront > 0
        {
            set moveX to MoveX.
            set moveY to 0.
            set moveZ to 0.
        }
        else{
            if movex-dFront>movex+dFront
            {
                set movex to -moveX.
            }
            if movey-dright>movey+dright
            {
                set movey to -movey.
            }
            if movez-dup>movez+dup
            {
                set movez to -moveZ.
            }
        }
        
    }

function positionxyz
    {
    parameter x,y,z.
    parameter shipAlign to false.
    set AlignXPID:setpoint to X.
    set AlignYPID:setpoint to Y.
    set AlignZPID:setpoint to Z.
    if shipAlign=true{
        set moveX to dFront.
        set xx to dfront/20+0.1.
        } else{
            set xx to -alignXPID:Update(time:seconds,dFront).
        
        }

    set yy to -alignYPID:update(time:seconds,dRight).
    set zz to -alignZPID:update(time:seconds,dup).
    set frontPID:setpoint to xx.
    set rightPID:setpoint to yy.
    set upPid:setpoint to   zz.
    
    set SHIP:CONTROL:FORE to frontPID:update(time:seconds,vfront).
    set SHIP:CONTROL:STARBOARD to rightPID:update(time:seconds,vright).
    set SHIP:CONTROL:top to upPID:update(time:seconds,Vup).
    print "XX:"+Round(xx,2)+" yy:"+Round(yy,2)+" zz:"+Round(zz,2)+"       " at (0,10).
    }