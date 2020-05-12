// functions file which contains the 
@LAZYGLOBAL OFF.

// Function that create basic gene to target Accent altitude.
declare function newDNA  
    {
        local Parameter geneLength to 3.
        local accentGene to list().
        local count to 0.
        until count=geneLength
        {
            local gene to lexicon().     // Heading, pitch, throttle
            gene:add("heading",90).
            gene:add("Pitch",90-count).
            gene:add("throttle",round(random(),2)).
            accentGene:add(gene).
            set count to count +1.
        }
        return accentGene.
    }



declare function newCandidate
    {
        // this profile which holds the other helpful paramteers
        local accentCandidate is Lexicon().
        accentCandidate:add("DNA",newDNA).
        accentCandidate:add("score",0).
        return accentCandidate.
    }



// This function will slowly evolve the given gene profile. each geen will have
declare function evolveCandidateDNA
    {
        // need a better function but for now it is just chaning the values like a hill climb.
        local parameter eDNA.
        local parameter evolvePoint to 10.
        local count to 0.
        until count=edna:length
        {
            if random()>0.05 and evolvePoint >0
            {
                set eDNA[count]:throttle to eDNA[count]:throttle+(random()-0.5)*0.05. 
                set evolvePoint to evolvePoint -1.
            }
        }
        return eDNA.
    }

declare function rankedCandidate
    {
        local parameter candidateList, candidate.
        local count to 0.
        until count>candidatelist:length
        {
            if candidate:score>candidateList[count]:score{
                set count to count+1.
            }else 
            {
                break.
            }
        }
        candidateList:insert(count,candidate).

        return candidateList.


    }

declare function scoreGene
    {

        // need to know how good the orbit was. 
        // amount of fuel left. 
        local parameter startfuel,endfuel.
        return startfuel/endFuel*100.

    }


declare function printCandidate{
    local Parameter printList.
    local count to 0.
    clearscreen.
    until count=printlist:length
    {
        print printlist[count].
        set count to count +1.
    }
}

