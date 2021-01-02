// This will sync the orbits of satelitte and space they appropriately.


// launch to LKO.
// Match its apoapsis or Periapsis (for circiualr orbit, i doesn't matter)

//create a node at the apoapsis and find the time 

@LAZYGLOBAL OFF.
clearscreen.
local mn to node(time:seconds+eta:apoapsis,0,0,0).
gear off.
if hasnode=false
{
    add mn.
}else
{
    remove nextnode.
    add mn.
}

declare function satAngle{
    local parameter targetSat to target.
    local parameter noOfSat to 3.

    local angleTrail to 360/noOfSat.

    
    // calculate your postion after node
    local shipPos to positionat(ship,time:seconds+eta:apoapsis+mn:orbit:period).
  //  local bodyPOS to positionat(body,time:seconds+eta:apoapsis+mn:orbit:period).
    local targetPos to positionat(target,time:seconds+eta:apoapsis+mn:Orbit:period).
    print " Next Angle : " + round(vang(shipPOS-body:position, targetPOS-body:position ),1) +"    " at (0,0).
    wait 0.
}
until gear
{
satAngle().
}
runpath ("exenode.ks").
