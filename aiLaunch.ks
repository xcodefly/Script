// This file manage all the candidate for the flight. 
@Lazyglobal off.


// Reset a file with a true parameter, and write new file. 
local parameter fileFlag to false.
local parameter fileName to "AI_Launch.json".

runpath ("_GALKO.ks").
runpath ("GAFlight.ks").

// create a json file that has all the candidates.
Local generation to 0.
local generationMax to 500.
Local agentNumber to 0.
local aiFile to Lexicon().
local poolsize to 25.
local AIagentList to list().
local AIagent to lexicon().
declare function easyLog{
    local x to 0.
   
    local scoreStr to "Gen"+generation+",".
    until x=aiFile:aiAgentlist:length{
       set scorestr to scorestr+aiAgentList[x]:score+",".
        set x to x+1.
    }
    log scorestr to "test1.csv".
}
declare function updateAIfile
{
    deletepath(filename).
    set aiFile:agentNumber to agentNumber.
    set aiFile:generation to generation.
    writeJson(aiFile,filename).
    

}
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
                        set aiFile:agentNumber to 0.
                        set agentNumber to 0.

                        aiAgentlist:clear().
                        set AIagentList to new_Generation(poolsize).  // First parameter is pool size, seconds parameter dna Length.
                        set aiFile:aiagentlist to aiagentlist.

                        writeJson(aiFile,filename).
                        print " New file agents : "+aifile:aiagentlist:length.
                    }
                }
            }
        
        
        local function openAIfile{
            if exists(filename){
                set aiFile to readjson(filename).
                
                set AIagentList to aifile:AIagentList.
                if poolsize<>aiagentlist:length or fileFlag = true
                {
                    Print " file reset because no of Agents or file flag.".
                    resetAIFile(true).
                }
                set generation      to aiFile:generation.
                set agentNumber   to aifile:agentNumber.
                print " file exists, No of Agents in this file: " + aiagentlist:length.

            }else
            {
                newAIfile().
            }
         }
        local function newAIFile
            {
                aiFile:add("Generation",Generation).
                aiFile:add("agentNumber",agentNumber).
                // Create a new list of agents to be added to the file and then add it to aiFile.

                set AIagentList to new_Generation(poolsize).  // First parameter is pool size, seconds parameter dna Length.
                aiFile:add("AIagentList",AIagentList).

                writeJson(aiFile,filename).
                Print " New File Created ".
            }
    
    }

clearscreen.
checkAIfile().
testAgentList().
declare function testAgentList
{
    until generation = generationMax
    {

    
        until agentNumber=AIagentList:length
        {
            agentHUD(agentNumber).
           
            set AIagentList[agentNumber]:score to Launch_Agent(AIagentList[agentnumber]).
            
            set agentNumber to agentNumber+1.
            updateAIfile().
            kuniverse:reverttolaunch().
           
            
            
            
        }
        set AIagentList to sort_Candidate(aiAgentlist).
        easylog().
        set aiAgentList to next_generation(aiAgentlist).
        set aiAgentlist to mutate_Candidate(aiAgentList).
        set agentNumber to 0.
        set generation to generation +1.
        updateAIfile().
        
      // kuniverse:reverttolaunch().
        
    }
    print " End of File".
}

declare function agentHUD{
    local parameter agentNO.
    print " Current Generation : " + generation +  "  " at (0,1).
    print "      Current Agent : " + AgentNO +"  " at (0,2).
}
// go o first candidate and do a launch and record the score.
// go throught the full list.
// once end of list, evolve dna.
// go to the top of the list and start again. 
// create list of candidate.

