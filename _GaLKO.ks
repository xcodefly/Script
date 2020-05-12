// functions file which contains the 
@LAZYGLOBAL OFF.

// use keyword candidate to help with the different files.

// Function that create basic gene to target Accent altitude.
local mutationRate to 0.1.
local dropoff to 0.3.
declare function new_DNA  
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




declare function new_Candidate
    {
        // this profile which holds the other helpful paramteers
        local parameter dnalength to 10.
        local Candidate is Lexicon().
        Candidate:add("DNA",new_DNA(dnalength)).
        Candidate:add("score",0).
        return Candidate.
    }

declare function new_Generation{
        local parameter listsize is 1,dnaLenght is 5.
        local newList to list().
        until newList:length=listsize
        {   
            newlist:add(new_Candidate(dnaLenght)).
        }
        return newList.
    }

declare function next_Generation
    {
        local parameter generation.
        local lowestScore to generation[0]:score.
        local bestscore to generation[generation:length-1]:score.
        
        local x to 0.
        until x=generation:length{
            // remove the old generation 
            
            set x to x+1.
            wait 0.
        }
        return Generation.
    }

declare function child_generation
{

}
// This function will slowly evolve the given gene profile. each geen will have
declare function mutate_Candidate_DNA
    {
        // need a better function but for now it is just chaning the values like a hill climb.
        local parameter eDNA.
        local parameter evolvePoint to 5.
        local count to 0.
        until count=edna:length
        {
            if random()>mutationRate and evolvePoint > 0
            {
                set eDNA[count]:throttle to eDNA[count]:throttle+(random()-0.5)*0.05. 
                set evolvePoint to evolvePoint -1.
            }
        }
        return eDNA.
    }



declare function sort_Candidate
    {

         

        // the score will be given here.
        local parameter aList.
        local x to 0.
        until x=alist:length{
            local y to x.
            until y=0
            {
                if alist[y]:score<alist[y-1]:score
                {
                    local temp to alist[y].
                    set alist[y] to alist[y-1].
                    set alist[y-1] to temp.
                }
                set y to y-1.
            }
            set x to x+1.
        }
        return alist.

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

