run "r2.ks".
run "_orbit.ks".
Run "_targetPlus.ks".

gear off.
// This is the small program to run the script. 
clearscreen.
//print a_Time.
until hasnode=false{
    remove nextnode.
}
//adjust_apoapsis(200000).
//exenode().
//adjust_Periapsis(199000).
//exenode().
//exenode().
//print " Target periapsis : " + Round(target_periapsis_eta()).
Periapsis_closedApp_Burn().


