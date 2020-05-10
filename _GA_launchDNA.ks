// functions file which contains the 
LAZYGLOBAL OFF.
declare function AccentGene  // Function that create basic gene to target Accent altitude.
{
    local Parameter targetAlt to 80.
    local accentDNA to list().
    local count to 0.
    until count=targetAlt{
        local dna to lexicon().     // Heading, pitch, throttle
        dna:add("heading",90).
        dna:add("Pitch",90-count).
        dna:add("throttle",1).
        accentDNA:add(dna).
        set count to count +1.
        
        
    }
    return accentDNA.
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

