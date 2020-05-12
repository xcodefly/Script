// This file manage all the candidate for the flight. 
@Lazyglobal off.


// Reset a file with a true parameter, and write new file. 
local parameter fileFlag to false.
local parameter fileName to "AI_Launch.json".

runpath ("_GALKO.ks").
runpath ("GAFlight.ks").

// create a json file that has all the candidates.
Local generation to 0.
Local testCandidate to 0.
local aiFile to Lexicon().
local poolsize to 5.
local AIagentList to list().
local AIagent to lexicon().


declare function checkAIfile
    {
        // open file has set of small functions that can be used to manage file.
        // reset file, create file, open file,
        openAIfile().
        local function resetAIfile
            {
                local parameter localflag to false.
                if localFlag=true{
                    if exists(filename)
                    {
                        deletepath(filename).
                        print " file deleted".
                        set aiFile:generation to 0.
                        set aiFile:candidate to 0.
                        aiAgentlist:clear().
                        set AIagentList to newCandidateList(poolsize).  // First parameter is pool size, seconds parameter dna Length.
                        set aiFile:aiagentlist to aiagentlist.

                        writeJson(aiFile,filename).
                        print " New file agents : "+aifile:aiagentlist:length.
                    }
                }
            }
        
      
        local function openAIfile{
            if exists(filename){
                set aiFile to readjson(filename).
                set generation      to aiFile:generation.
                set testCandidate   to aifile:testCandidate.
                set AIagentList     to aifile:AIagentList.
                if poolsize<>aiagentlist:length or fileFlag = true
                {
                    Print " file reset because no of Agents or file flag.".
                    resetAIFile(true).
                    
                   
                  
                }
                print " file exists, No of Agents in this file: " + aiagentlist:length.

            }else
            {
                newAIfile().
            }
         }
        local function newAIFile
            {
                aiFile:add("Generation",Generation).
                aiFile:add("TestCandidate",testCandidate).
                // Create a new list of agents to be added to the file and then add it to aiFile.

                set AIagentList to newCandidateList(poolsize).  // First parameter is pool size, seconds parameter dna Length.
                aiFile:add("AIagentList",AIagentList).

                writeJson(aiFile,filename).
                Print " New File Created ".
            }
       
       
      
            
    
    }

clearscreen.
checkAIfile().

// go o first candidate and do a launch and record the score.
// go throught the full list.
// once end of list, evolve dna.
// go to the top of the list and start again. 
// create list of candidate.

