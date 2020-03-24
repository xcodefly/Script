// First file to write lexicon.

// Aerobatic lexicon





//moveList:add(attitude).
set movelist to list().
            // pitch, bank,speed,alti,time

moveList:add(setmove(1,1,100,1000,0)).
moveList:add(setmove(2,2,200,1000,0)).

set pullVertical to setMove(90,0,0,0,20).

//movelist:add(setAttitude(2,2,200,2000)).

Function setMove
{
    Parameter pitch, bank,speed,alti,time.
    set att  to lexicon().
    att:add("Pitch",pitch).
    att:add("Bank",bank).
    att:add("Speed",speed).
    att:add("alti",alti).
    att:add("time",time).
   
   
    Return att.
}
//writeJson(moveList,"output1.json").
set x to readJson("output1.json").
print x:length.
print x[1].

print pullVertical.

//  WRITEJSON(moveList, "output1.json").

//  set xx to readJson("output1.json").
