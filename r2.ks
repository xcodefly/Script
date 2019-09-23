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
Declare function AdjustClosedApproach
{
    // Add a node.
    set testNode to node(time:seconds,0,0,0).
    set nodeLex to lexicon().
    nodeLex:add("n0",testNode).
    if target:orbit:semiMajorAxis>ship:orbit:semiMajorAxis
    {
         nodeLex:add("step",10).
    }else
    {
        nodeLex:add("step",-10).
    }
    
    set nodeLex to tuneNode(nodeLex).
    print nodeLex.
    return nodeLex:n0.
}

declare function selectNode
{
    
}
declare function tuneNode
{
    parameter nodeLex.
    set testNode to nodeLex:n0.
    add testNode.
    set dis_Now to (positionat(ship,time:seconds+testNode:eta)-positionat(target,time:seconds+testNode:eta+testNode:orbit:period)):mag.
    until dis_Now<1000 or Abs(nodeLex:step)<0.5
    {
        set testNode:prograde to testNode:prograde+nodeLex:step.
        set dis_next to (positionat(ship,time:seconds+testNode:eta)-positionat(target,time:seconds+testNode:eta+testNode:orbit:period)):mag.
        if dis_next<dis_now
        {
            set dis_now to dis_Next.
        } else
        {
            set testNode:prograde to testNode:prograde-nodeLex:step.
            set nodeLex:step to -nodeLex:step/1.3.
        }
        
        print round(dis_Now)+"     " at (0,1).
        print round(dis_next)+"     " at (0,2).
       
        print round(nodeLex:step,5)+ "     " at (0,3).
        wait 0.
    }
    wait 0.1.
    return nodeLex.
    
}

declare function testPosition{
    
    return deltaP.
}


declare function setTimeLexicon
{
    set testTime to lexicon().
    testTime:add("seek",eta:periapsis+Time:seconds).
    testTime:add("step",ship:orbit:period).
    testTime:add("orbit",1).
    testTime:add("distance",target_distance(testtime:seek)).
    testTime:add("count",0).
    return testTime.
}



Declare function target_distance
{
    Parameter t.
    Return (positionat(ship,t)-positionat(target,t)):mag .
}
Declare function TrimTime
{
    Local parameter testTime. 
    if  target_distance(testTime:seek+testTime:step)<testTime:distance
    {
        set testTime:seek to testTime:seek+testTime:step.
        set testtime:distance to target_Distance(testTime:seek).
    }
    else 
    {
        set testTime:step to -testTime:step/2.
    }
    if testTime:seek<time:seconds
    {
        set testtime:orbit to testtime:orbit+1.
        Set testtime:seek to time:seconds+eta:periapsis+testTime:orbit*ship:orbit:period.
        Print "Next Orbit".
        wait 1.

    }
    set testtime:count to  testtime:count+1.
    
    //wait 0.1.
    Return testTime.
}

Declare function ClosedAppTime
{
    parameter testTime.
    
    until abs(testTime:step)<5
    {
        set testTime to trimTime(testTime).
    }
   return testTime.
}
Declare function Rendezvous {}

Declare function Dock {}

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

    //now we need to wait until the burn vector and ship's facing are aligned
    wait until vang(np, ship:facing:vector) < 0.5.

    //the ship is facing the right direction, let's wait for our burn time
    wait until nd:eta <= (burn_duration/2).

    

    set tset to 0.
    lock throttle to tset.

    set done to False.
    //initial deltav
    set dv0 to nd:deltav.
    until done
    {
        //recalculate current max_acceleration, as it changes while we burn through fuel
        set maxAcc to ship:maxthrust/ship:mass.

        //throttle is 100% until there is less than 1 second of time left to burn
        //when there is less than 1 second - decrease the throttle linearly
        set tset to min(nd:deltav:mag/maxAcc, 1).
        if nd:deltaV:mag<5
        {
            lock steering to dv0.
        }
        //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
        //this check is done via checking the dot product of those 2 vectors
        if vdot(dv0, nd:deltav) < 0
        {
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }


      
    }
    unlock throttle.
    

    //we no longer need the maneuver node
    remove nd.
    Sas On.
    //set throttle to 0 just in case.
    
}