run "r2.ks".
run "_orbit.ks".
Run "_targetPlus.ks".

gear off.

clearscreen.
until hasnode=false{
    remove nextnode.
}
 set a to  target_Inclination_fx().
 print a.
//matchOrbit().




