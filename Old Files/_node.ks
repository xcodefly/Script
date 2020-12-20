// new create node will be calcuated here. 

// adjust the apoapsis and periapsis.




Declare function sortNode
    {
    Parameter testCandidate to List().
    Local x to 0.
    until x=testCandidate:length
    {
        Local y to x.
        until y=0
        {
            if testCandidate[y]["error"]<testCandidate[y-1]["error"]
            {
                set temp to testCandidate[y].
                set testCandidate[y] to testCandidate[y-1].
                set testCandidate[y-1] to temp.
            }
            set y to y-1.
        }
        set x to x+1.
    }
    
    return testCandidate.
}

Declare function evaluateOrbit
    {
    parameter nodeList to List().
    parameter targetApoapsis to 0.
    parameter targetPeriapsis to 0.
    set testDna to 0.
  
    Local x to 0.
    until x=nodeList:length{
        set testMnv to node(time:seconds+eta:periapsis,0,0,nodeList[x]["Dna"]).
        add testMnv.
        
        set apoapsisError to testMnv:orbit:apoapsis-targetApoapsis.
        remove testMnv.
        set nodeList[x]["abserror"] to apoapsisError.
        set nodeList[x]["error"] to abs(apoapsisError).
        set x to x+1.
    }
    return nodeList.
    
}


declare function PrintNode  
    {
    Parameter tNode TO list()..
    local x to 0.
    until x=tnode:length
    {
        print " Node : "+(x+1) at (0,x+3).
        print " DNA : "+Round(tnode[x]["dna"],1) at (15,x+3).
        print " error : " +Round(tnode[x]["error"],1) at (35,x+3).
        set x to x+1.
    }
}

declare Function GaNode
    {
    Local candidateList to List().
    parameter poolsize to 20.
  
    until candidateList:length>poolsize-1
    {
        candidateList:add(lexicon("DNA",random()*tunePrograde-tunePrograde/2,"error",100,"absError",100)).
    }
   // print candidatelist.
    return candidateList.

}

declare Function evolveNode
    {
    parameter candidateList to list().
    Local x to 0.
    set listLength to candidateList:length.
    set errorSum to 0.
    set absErrorSum to 0.
    until X=listLength
    {
        set errorSum to CandidateList[x]["error"]+errorSum.
        set absErrorSum to candidateList[x]["absError"]+absErrorSum.
        set x to x+1.
    }
    if abs(absErrorSum)=abs(errorSum)
    {
        set tunePrograde to tunePrograde*3.
    }
    else 
    {
        set tunePrograde to tunePrograde*0.5.
    }
    print " tunePrograde : "+round(tunePrograde)+ "  " at (0,0).
    print " error Sum : "+round(errorSum,1)+ " ABS error Sum : "+round(absErrorSum,1) +"  "at (0,25).
    set x to 0.
    until X=listLength
    {
        set CandidateList[listLength-x-1]["dna"] to (CandidateList[x]["dna"]).
        set x to x+1.
    }

    Local Y to 0..
    until Y = candidateList:length
    {
        set dnaMod to (random()-1/2)*tunePrograde.
        set CandidateList[Y]["dna"] to dnaMod+CandidateList[Y]["dna"].
        set Y to Y+1.
    }

    return candidateList.
    
}