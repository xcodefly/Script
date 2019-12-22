// This scrip it used to find to fly the Quard Copter without any stabilization.

// Find the engine at all for corners.

run "_quard_control.ks".
run "_quard_HUD.ks".
run "_quard_Input.ks".


clearscreen.
set shipATT to lexicon().
set shipControl to lexicon().
gear off.
shipControl:add("RPM",100).





// Basic takeoff using.

// Main Loop
Until gear
{
    set shipControl to quard_ALT(shipControl,80).
    quard_HUD(shipATT,shipControl).
    set shipControl to userInput(shipControl).
    wait 0.01.
}

