run "r2.ks".
run "_orbit.ks".
Run "_targetPlus.ks".

gear off.

clearscreen.
until hasnode=false{
    remove nextnode.
}
 //set aa to  target_Inclination_Match().
 //print aa.
 //exenode().
//matchOrbit().
matchArgumentOfPeriapsis().




