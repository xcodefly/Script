run "_global.ks".

 // Hover control have the following functions.
// Alt Control
// Speed control in atomosphere


    set targetAlt to Ship:altitude+1.
    set targetRadar to 10.
    set targetSpeed to 0.
    set slipSpeed to 0.
    set targetVS to 0.
    set shipHDG to 0.
    set targetVector to V(0,0,0).
    set ErrorVector to v(0,0,0).
    set holdLocation to ship:geoposition.
    set holdPosition to true.

    set hoverMode to 0.
    // PID to contorl altitude, speed and slip. 
    set tPID to pidLoop(0.1,0.15,0.01,0,1).
    set tPID:setpoint to 0.

    set vsPID to pidLoop(0.28,0.00,0.15,-10,10).
    set vsPID:setPoint to 0.

    set speedPID to pidLoop(4,0.1, 0.4,-20,20).
    set speedPID:setpoint to 0.

    set slipPID to pidLoop(4,0.1,0.4,-20,20).
    set slipPID:setpoint to 0.

    set front to -ship:facing:upvector.
    set PitchOffset to 90.

    set vectorPID to pidLoop(0.01,0.001,0.04,-1,1).
    set vectorPID:setpoint to 0.

    // Front was initialized.

    if vang(ship:facing:vector,up:vector)<25
    {
        lock front to -ship:facing:upvector.
        set PitchOffset to 90.
        
    } else if vang(ship:facing:upVector,up:vector)<25
    {
        lock front to ship:facing:vector.
        set pitchOffset to 0.
    }

    // Heading is initialized. 
    lock frontHDGV to vxcl(up:vector,front).



HDG_update().  
set targetHDG to shipHDG.

Declare Function AltControl
    {
        Parameter offset to 3.
        if hoverMode = 0
        {
            set altError to altitude- targetAlt.
            print "  Altitude : " + Round(altitude) + "  ["+ Round(targetAlt)+"] Alt    " at (0,Offset+1).
        }else if hovermode =1
        {
            set altError to  alt:radar-targetRadar.
            print "   Rad Alt : " + Round(alt:radar) + "  ["+ Round(targetRadar)+"] RA    " at (0,Offset+1).
        }
        set targetVS to vsPID:update(time:seconds,altError).
        set tPID:setpoint to targetVS.
        Lock throttle to tPID:update(time:seconds,VerticalSPeed).
        
    }

Declare function PitchControl
    {
        if hastarget= true and lights = true{
            targetAlign().
        }
        else if brakes = true{
            Print " Pitch Control Mode : Hold Position " at (0,1).
            
            hoverHold().
        } else if brakes = false
        {
            Print " Pitch Control Mode : Speed Contorl " at (0,1).
            set holdLocation to ship:geoposition.
        //    VecHelp().
            speedControl().
        }
    }

Declare Function SpeedControl
    {

        // All will go in targetApproach.
        
        Landing_Hud().
        set speedPID:setpoint to targetSpeed.
        set pitchInput to speedPID:update(time:seconds,vdot(velocity:surface,front)).
        set slipPID:setpoint to slipSpeed.
        set yawInput to slipPID:update(time:seconds,vdot(velocity:surface,ship:facing:rightVector)).
        Lock steering to  heading (targetHDG,pitchOffset-pitchInput)-R(-sin(targetHDG)*yawInput,cos(targetHDG)*yawInput,0).
    }

Declare function HoverHold{
        Landing_hud().
        positionHold_Hud().
   //     vecHelp().

        set errorVector to vxcl(up:Vector, holdLocation:position-ship:position).
        set speedPID:setpoint to vdot(front,errorVector)/5.
        set pitchInput to speedPID:update(time:seconds,vdot(velocity:surface,front)).
        set slipPID:setpoint to vDot(ship:facing:rightVector,errorVector)/5.
        set yawInput to slipPID:update(time:seconds,vdot(velocity:surface,ship:facing:rightVector)).
        Lock steering to  heading (targetHDG,pitchOffset-pitchInput)-R(-sin(targetHDG)*yawInput,cos(targetHDG)*yawInput,0).
    }

Declare Function TargetAlign
    {
      
    //    VecHelp().
        Landing_Hud().
        target_hud().
        set targetVector to vxcl(up:Vector, target:position-ship:position).
        set speedPID:setpoint to vdot(front,targetVector)/5.
        set pitchInput to speedPID:update(time:seconds,vdot(velocity:surface,front)).
        set slipPID:setpoint to vDot(ship:facing:rightVector,targetVector)/5.
        set yawInput to slipPID:update(time:seconds,vdot(velocity:surface,ship:facing:rightVector)).
        Lock steering to  heading (targetHDG,pitchOffset-pitchInput)-R(-sin(targetHDG)*yawInput,cos(targetHDG)*yawInput,0).

    }


// Same function as speed contorl except forward and slip speed is hard coaded to ZERO. cant be overwritten for safety. 

// ****  redundent, should be deleted at some point. 
Declare Function LandControl{
    
    set speedPID:setpoint to 0.
    set pitchInput to speedPID:update(time:seconds,vdot(velocity:surface,front)).
    set slipPID:setpoint to 0.
    set yawInput to slipPID:update(time:seconds,vdot(velocity:surface,ship:facing:rightVector)).
    Lock steering to  heading (targetHDG,pitchOffset-pitchInput)-R(-sin(targetHDG)*yawInput,cos(targetHDG)*yawInput,0).
    }

Declare Function HDG_Update
    {
        if vang(frontHDGV,east)<90 
        {	set ShipHDG to  vang(frontHDGV,north:vector).	}
        else	
        {	set shipHDG to  360-vang(frontHDGV,north:vector).    }
    }

Declare Function Landing_HUD
    {
        HDG_update().
        Parameter Offset to 3.
        print "   Vertial : " + round(verticalspeed,1)+ " ["+Round(targetVS,1)+"]     " at (0,Offset+2).
        print "       HDG : " + Round(shipHDG)+" ["+Round(targetHDG)+"]    " at (0,3+Offset).
        print "   Forward : " + round(vdot(velocity:surface,front),1)+" ["+targetSpeed+"]     "  at (0,4+Offset).
        print "      Slip : " + round(vdot(velocity:surface,ship:facing:rightVector),1)+" ["+slipSpeed+"]     "  at (0,5+Offset).
    }


Declare Function target_Hud
    {
        Parameter Offset to 3.
        Print " Distance Front : " + Round(vdot(front,targetVector),1) + "    " at (0,Offset +7).
        print " Distance Right : " + round(Vdot(facing:rightVector,targetVector),1)+ "   " at (0,Offset+8).
    }


Declare Function positionHold_Hud
    {
        Parameter Offset to 3.
        Print " Distance Front : " + Round(vdot(front,errorVector),3) + "      " at (0,Offset +7).
        print " Distance Right : " + round(Vdot(facing:rightVector,errorVector),3)+ "      " at (0,Offset+8).
    }

Declare Function VecHelp
{
    Clearvecdraws().
    vecdraw(ship:position,targetVector,Yellow,"Target",1,true).
    vecdraw(ship:position,errorVector, Red, "Error in Position",1,true).
    vecdraw(holdLocation:position,up:vector,Green," Target Position", 1, true).
}