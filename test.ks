run "r2.ks".
run "_orbit.ks".
gear off.
// This is the small program to run the script. 

//print a_Time.
until hasnode=false{
    remove nextnode.
}
adjust_apoapsis(200000).
exenode().
adjust_Periapsis(199000).
exenode().
//exenode().

