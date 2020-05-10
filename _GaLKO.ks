// functions file which contains the 
LAZYGLOBAL OFF.


declare function AccentGene  // Function that create basic gene to target Accent altitude.
    {
        local Parameter targetAlt to 80.
        local accentDNA to list().
        local count to 0.
        until count=targetAlt
        {
            local dna to lexicon().     // Heading, pitch, throttle
            dna:add("heading",90).
            dna:add("Pitch",90-count).
            dna:add("throttle",round(random(),2)).
            accentDNA:add(dna).
            set count to count +1.
        }
        return accentDNA.
    }
// This function will slowly evolve the given gene profile. each geen will have
declare function EvolveGene  
    {
        local parameter eDNA.
        local parameter evolvePoint to 10.
        local count to 0.
        until count=edna:length
        {
            if random()>0.05
            {
                eDNA[count]:throttle to eDNA[count]:throttle+(random()-0.5)*0.05. 
            }
        }
        return eDNA.
    }

declare function rankGeneList
{
    local parameter dnaList to list()
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

