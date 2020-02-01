
// This scrip it used to find to fly the Quard Copter without any stabilization.

// Find the engine at all for corners.

run "_tri_control.ks".
run "_tri_hud.ks".
run "_tri_Input.ks".


// initiate the lexicon so that the values can be used in all the function. Later, it will need to be passed on as the program gets more complex. 


clearscreen.
set shipATT to lexicon().
set shipTarget to lexicon().
gear off.
shipTarget:add("RPM",100).
shipTarget:add("ALT",altitude+5).
shipTarget:add("Pitch",0).
shipTarget:add("Bank",0).
shipTarget:add("HDG",0).
shipTarget:add("Mode",0).

shipAtt:add("Pitch",0).
shipAtt:add("Bank",0).
shipAtt:add("HDG",0).
shipAtt:add("yaw",0).
shipAtt:add("speed",0).

set modeList to List("Raw Control","Speed        ").



// Basic takeoff using.

// Main Loop
Until gear
{
    if (shipTarget:Mode=0)
    {
        tri_0(shipAtt,shipTarget).
    }else if (shipTarget:Mode=1)
    {
        tri_1(shipAtt,shipTarget).
    }
    update_Att().
    userInput_Basic(shipTarget).

    print " MODE : " + shipTarget:mode at (1,12).
    
    
    wait 0.01.
}

