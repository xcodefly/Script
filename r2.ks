// Rendezvous.
// Match Inclination
// Add MunouverNode to get closed approach.
// Match the orbit
// Rendezvous

// Locking Common Variables
Lock MaxAcc to Ship:maxThrust/Ship:mass.
//set closedApp_time to fx_CloseApp_time().
Clearscreen.
Declare function Hud
    {
        Print "       Close Approach in : " + Round() + "  " at (0,0).
        Print " Close Appraoch Distance : " + Round() +"  " at (0,1).
        Print " Orbital Period : " + Round(ship:orbit:period) + "  " at (0,2).
    }

Declare function MatchInclination {}
Declare function createCloseApp_Node
{
    // Create Node.
    set testNode to node(time:seconds,0,0,0).
    set nodeLex to lexicon().
    nodeLex:add("n0",testNode).
    if target:orbit:semiMajorAxis>ship:orbit:semiMajorAxis
    {
         nodeLex:add("step",20).
         set testNode:eta to eta:apoapsis+2.
    }else
    {
        nodeLex:add("step",-20).
        set testNode:eta to eta:periapsis+2.
    }
    
    set nodeLex to tuneNode_closeApp(nodeLex).
   
    print nodeLex.
   
}


declare function tuneNode_closeApp
{
    parameter nodeLex.
    set testNode to nodeLex:n0.
    add testNode.
    set dis_Now to (positionat(ship,time:seconds+testNode:eta)-positionat(target,time:seconds+testNode:eta+testNode:orbit:period)):mag.
    until dis_Now<300or Abs(nodeLex:step)<0.005
    {
        set testNode:prograde to testNode:prograde+nodeLex:step.
        set dis_next to (positionat(ship,time:seconds+testNode:eta)-positionat(target,time:seconds+testNode:eta+testNode:orbit:period)):mag.
        if dis_next<dis_now
        {
            set dis_now to dis_Next.
        } else
        {
            set testNode:prograde to testNode:prograde-nodeLex:step.
            set nodeLex:step to -nodeLex:step/1.7.
        }
        
        print round(dis_Now)+"     " at (0,1).
        print round(dis_next)+"     " at (0,2).
       
        print round(nodeLex:step,5)+ "     " at (0,3).
        wait 0.
    }
    wait 0.1.
    return nodeLex.
    
}
declare function tuneNode_matchVelocity{

    parameter nodeLex.
    set testNode to nodeLex:n0.
    add testNode.
    set deltaV_now to (velocityat(target,time:seconds+testNode:eta):orbit-velocityat(ship,time:seconds+testNode:eta):orbit):mag.
    until deltaV_Now<0.11or Abs(nodeLex:step)<0.01
    {
        set testNode:prograde to testNode:prograde+nodeLex:step.
        set deltaV_next to (velocityat(target,time:seconds+testNode:eta):orbit-velocityat(ship,time:seconds+testNode:eta):orbit):mag.
        if deltaV_now>deltaV_Next
        {
            set deltaV_Now to deltaV_Next.
        } else
        {
            set testNode:prograde to testNode:prograde-nodeLex:step.
            set nodeLex:step to -nodeLex:step/1.7.
        }
        
        print round(deltaV_Now)+"     " at (0,1).
        print round(deltaV_next)+"     " at (0,2).
       
        print round(nodeLex:step,5)+ "     " at (0,3).
       
    }
    wait 0.1.
    return nodeLex.

}




Declare function MatchOrbit_Node
{
    set testNode to node(time:seconds,0,0,0).
    set nodeLex to lexicon().
    nodeLex:add("n0",testNode).
    if target:orbit:semiMajorAxis>ship:orbit:semiMajorAxis
    {
         nodeLex:add("step",20).
         set testNode:eta to eta:apoapsis+1.
    }else
    {
        nodeLex:add("step",-20).
        set testNode:eta to eta:periapsis+1.
    }
    
    set nodeLex to tuneNode_matchVelocity(nodeLex).
   
    print nodeLex.
    
}




Declare function Rendezvous {
    
   // MatchInclination().
   // createCloseApp_Node().
   // exeNode().
   // MatchOrbit_node().
   // exeNode().
    dock().
   
}

Declare function Dock {
    lock steering to target:position.
    Print "hello".

}

Declare function ExeNode {
    set nd to nextnode.
    Clearscreen.
    
    //calculate ship's max acceleration
    set burn_duration to nd:deltav:mag/maxAcc.
    print "Crude Estimated burn duration: " + round(burn_duration) + "s".
    print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).
    sas off.
    lock np to nd:deltav. //points to node, don't care about the roll direction.
    lock steering to np.
    wait until vang(np, ship:facing:vector) < 0.5.
    kuniverse:timewarp:warpto(time:seconds+nd:eta-40-burn_duration).
    wait until vang(np, ship:facing:vector) < 0.5.
    wait until nd:eta <= (burn_duration/2).
    set tset to 0.
    lock throttle to tset.
    set done to False.
    set dv0 to nd:deltav.
    until done
    {
        set tset to min(nd:deltav:mag/maxAcc, 1).
        if nd:deltaV:mag<5
        {
            lock steering to dv0.
        }
        if vdot(dv0, nd:deltav) < 0
        {
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }
    }
    unlock throttle.
    remove nd.
    Sas On.
}