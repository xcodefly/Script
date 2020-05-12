// This file manage all the candidate for the flight. 
@Lazyglobal off.


// Reset a file with a true parameter, and write new file. 
local parameter resetfile to false.
local parameter fileName to "LaunchCandidate.json".

runpath ("_GALKO.ks").
runpath ("GAFlight.ks").

// create a json file that has all the candidates.
Local generation to 1.
Local testCandidate to 1.
local aiFile to Lexicon().
local poolsize to 30.
declare function createFile
    {
        aiFile:add("Generation",generation).
        aiFile:add("testCandidate",testCandidate).
        aiFile:add("aiGeneList",geneList).
            
    }

clearscreen.


// create list of candidate.

if exists(filename)
{
  //  readjson()
}
else {
// writejson with the new aitest.
}