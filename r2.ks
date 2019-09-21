// Rendezvous.
// Match Inclination
// Add MunouverNode to get closed approach.
// Match the orbit
// Rendezvous

set setTime to time:seonds.
// Locking Common Variables
Lock MaxAcc to Ship:maxThrust/Ship:mass.
set closedApp_time to fx_CloseApp_time().
Clearscreen.
Declare function Hud
    {
        Print "       Close Approach in : " + Round() + "  " at (0,0).
        Print " Close Appraoch Distance : " + Round() +"  " at (0,1).
    }

Declare function MatchInclination {}

Declare function HolmerTransfer
{
    

}
Declare function Rendezvous {}
Declare Function fx_closedApp_Time
{   
    
}
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
        if nd:deltaV:mag<1
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