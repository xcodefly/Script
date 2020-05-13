// functions file which contains the 
@LAZYGLOBAL OFF.

// use keyword candidate to help with the different files.

// Function that create basic gene to target Accent altitude.
local mutationRate to 0.25.
local dropoff to 0.35.
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
        local parameter listsize is 1,dnaLenght is 80.
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
        until x>generation:length*dropoff{
            // remove the old generation 
            local parentA to generation[generation:length-x-1].
         //   local parentA to generation[0].
            local parentBindex to min(generation:length-1,generation:length-1-Round((random()-0.3)*generation:length*.25)).
            print "Parent B Index : "+parentBIndex.
            local parentB to generation[parentBindex].
         //   local parentB to generation[generation:length-1].
            set generation[x] to child_candidate(ParentA,ParentB).
          //  print generation:length.
            set x to x+1.
            wait 0.
        }
        return Generation.
    }

declare function child_Candidate
{
    Local parameter p1,p2.
    local xx to 0.
    until xx=p1:DNA:length{
        if random()<mutationRate{
            set p1:dna[xx]:throttle to p2:dna[xx]:throttle.
            set xx to xx+1.
        }
    }
   

    return P1.
}
// This function will slowly evolve the given gene profile. each geen will have
declare function mutate_Candidate
    {
        // need a better function but for now it is just chaning the values like a hill climb.
        local parameter generation.
        local parameter evolvePoint to Round(generation[0]:dna:length*mutationRate).
        local x to 0.
        until x=generation:length
        {
           
            if random()>.3
            {
                local y to 0.
                 until y=generation[x]:dna:length
                {
                    if random()>mutationRate and evolvePoint > 0
                    {
                        set generation[x]:dna[y]:throttle to min(1,generation[x]:dna[y]:throttle+(random()-0.5)*0.2). 
                        set evolvePoint to evolvePoint -1.
                    }
                    set y to y+1.
                }
            }
           
            set x to x +1.
                
        }
        return generation.
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

