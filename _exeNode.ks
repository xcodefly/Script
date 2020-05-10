
// The file contains the following functions -- Code was copied from internet, works well, made some small tweeks but it was great.


// exeNextNode  - This will execute the next node in the orbit.

Declare function exeNextNode{
    Local nextND to nextNode.
    Local max_acc to ship:maxthrust/ship:mass.
    Local burn_duration to nextND:deltav:mag/max_acc.
    local StageFuel to 0.
    resourceMonitor().

    clearscreen.
    
    Print " Next Node in : " +round(nextND:eta)+"   " at (0,6).
    print " Estimated Burn : " + round(burn_duration) +"'s  " at (0,7).
    SAS off.
    

    
    Local dv0 to nextND:deltav.
     //points to node, don't care about the roll direction.
    lock steering to prograde.
    lock steering to dv0.

 // ***     steering not locking to this vector. 
  //  vecdraw(ship:position,dv0*5,white,"Burn Vector",1,true).

    until vang(dv0, ship:facing:vector) < 0.5 
    {
        Print " Next Node in : " +round(nextND:eta)+"   " at (0,6).
        print " Estimated Burn : " + round(burn_duration) +"'s  " at (0,7).
        if nextNd:eta<30{
            break.
        }

    } 
    kuniverse:timewarp:warpto(time:seconds+nextND:eta-60-burn_duration).


    //the ship is facing the right direction, let's wait for our burn time
    wait until nextND:eta <= (burn_duration/2).

    
    local tset to 0.
    lock throttle to tset.

    local done to False.
    //initial deltav
    
    
   
    
    until done = true
    {
        burnNodeInfo().
        //recalculate current max_acceleration, as it changes while we burn through fuel
        if stage:liquidfuel<0.1 
        {
            QuickStage().
            local max_acc to max(0.1,ship:maxthrust/ship:mass).
            resourceMonitor().
            
        }
        else
        {
            local max_acc to max(0.1,ship:maxthrust/ship:mass).
        }
        if max_acc>0
        {
            set tset to min(nextND:deltav:mag/max_acc, 1).
        }
        
     
        //throttle is 100% until there is less than 1 second of time left to burn
        //when there is less than 1 second - decrease the throttle linearly
        

        //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
        //this check is done via checking the dot product of those 2 vectors
        if vdot(dv0, NextND:deltav) < 0
            {
                lock throttle to 0.
                break.
            }

        //we have very little left to burn, less then 0.1m/s
        if nextND:deltav:mag < 0.1
        {
            //we burn slowly until our node vector starts to drift significantly from initial vector
            //this usually means we are on point
            wait until vdot(dv0, nextND:deltav) < 0.5.
            lock throttle to 0.
             set done to True.
        }
    }
       
        SAS On.
        //we no longer need the maneuver node
        remove nextND.
        //set throttle to 0 just in case.
        SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.



    declare function resourceMonitor
    {
        for item in stage:resources{
            if item:name ="LiquidFuel"
            {
                set StageFuel to item.
            }

        }
    } 

    Declare function burnNodeInfo
        {
        Print " Executing Node : " at (0,1).
        print "     Stage Fuel : " + Round(stageFuel:amount/stageFuel:capacity*100)+" %   " at (0,2).
        print "        Max Acc : " + round(max_acc)+" " at (0,3).
        print "     Available Thrust : " +round(availablethrust)+" " at (0,4).
        print "deltaV remaning : " + round(nextND:deltaV:mag)+"  " at (0,5). 

    }

}

// Function to display status of burn node. 

