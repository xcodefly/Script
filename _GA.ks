// the following functions are used to tune the GA.
set candidatePool to List().
set candidateDistance to list().

Declare function CreateGENE
{

    Parameter poolsize to 30.
    set xx to 0.
    until xx>poolsize
    {
        candidateDNA:add(random()*10-5).
        set xx to xx+1.
    }
    return (CandidateDNA).
}

Declare function EvaluateGENE
{
    local xx to 0.
    until xx>30
    {
        print candidateList[xx].
    }

}

Declare function Eval_closed_App
{
    local count to 0.
    until count>candidatePool:length-1
    {
        add candidatePool[count].
        set dvector to positionat(ship,)  
        //print Round(candidatePool[count]:eta)+","+Round(candidatePool[count]:deltaV:mag,1).
        remove candidatePool[count].
        set count to count +1.
    }


    
}


Declare function createCandidate{
   
    set settime to round(time:seconds).
    parameter poolsize to 30.
    Local count to 0.
    until count>poolsize
    {
        set utime to settime+random()*100.
        set testnode to node(utime,round(Random(),2),round(Random(),2),round(Random()*10,1)).
        candidatePool:add(testnode).
        set count to count +1.
    }
    print candidatePool:length.
    
}

Declare Function PrintCandidate
{
    local count to 0.
    Print " Time  -   Radial   - Normal - Prograde ".

    until count>candidatePool:length-1
    {
        add candidatePool[count].
        print Round(candidatePool[count]:eta)+","+Round(candidatePool[count]:deltaV:mag,1).
        remove candidatePool[count].
        set count to count +1.
    }
}
