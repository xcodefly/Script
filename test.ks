run "r2.ks".
gear off.
// This is the small program to run the script. 

set a_Time to setTimeLexicon().
//print a_Time.
until hasnode=false{
    remove nextnode.
}
AdjustClosedApproach().
//exenode().

