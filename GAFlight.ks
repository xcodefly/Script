// The file to have all the launch function for GA.

@lazyglobal off.
// Accent
// Monitor
// Circulize.
parameter tApoapsis to 70000.



Declare function AccentHUD
    {   local parameter displayDNA,x.
        print "  index NO : " + x at (0,5).
        print "   Heading : " +displayDNA[x]:heading at (0,6).
        print "     pitch : " +displayDNA[x]:pitch at (0,7).
        print "  Throttle : "+ round(displayDNA[x]:throttle,3) at (0,8).
        print "DNA length : "+displayDNA:length at (0,9).
    }

declare function checkStatus
{
    parameter lapstime.
    local flightstatus to false.
    if ship:apoapsis>tApoapsis 
    {
        set flightstatus to true.
    }
    
    if lapstime>5
    {
        set kuniverse:timewarp:mode to "Physics".
        set kuniverse:timewarp:rate to 4.
        if ( status="prelaunch" or status="landed" or verticalspeed<1)
        {
            set flightstatus to true.
        }
        
        
    }
    return flightstatus.
}
declare function Launch_Agent
{
    Local parameter Candidate.
    local dna to candidate:dna.
    local res to ship:resources.
    local shipFuel to 0.
   
    
  
    for res in ship:resources
    {
        if res:name="LiquidFuel"
        {
            set shipFuel to res.
            break.
        }
    }
    // clearscreen.
    local startFuel to shipFuel:amount.
    Accent_GA(dna).
    local altScore to altitude_Score().
    Monitor_GA().
    Circulize_GA().
    // evaluate score. 
    local endfuel to shipFuel:amount.

    local fScore to  fuel_score(startfuel,endfuel).
    return round(fscore*altScore,4).
    
}
declare function calc_Score{
    return fuelscore().

}
declare function fuel_Score{
    parameter startfuel,endfuel.
    return endfuel/startfuel.

}
declare function orbit_Score{

}
declare function altitude_Score{
    Return (ship:altitude/tApoapsis).
    
}
Declare function Accent_GA{  // function to create the automatic launch profile. 
    // have different alitutde for each 1000 feet step. and then follow that heading.   
        
       
        Local parameter dna.
        local nextStage to false.
        Local starttime to time:seconds.
        local pointer to Round(altitude/1000).
        sas off.
        if maxthrust <1
        {
            stage.    
            wait 1.    
        }
        until nextstage
        {
            set throttle to dna[pointer]:throttle.
            set steering to heading(DNA[pointer]:heading,DNA[pointer]:pitch).
            set pointer to Round(altitude/1000).

            set nextstage to checkStatus(round(time:seconds-starttime)).
            accentHUD(DNA,pointer).
         
            wait 0.
        
        }
        set throttle to 0.
        unlock steering.
        sas on.
    }
//Monitor mode
declare function Monitor_GA
    {

    }

// circulization mode.   
declare function Circulize_GA
    {

    }




