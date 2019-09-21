// Test the maneuverability of the ship on the ground.
run "_global.ks".
run "_hover.ks".
run "_hud.ks".
run "_land.ks".
run "_userInput.ks".   // Must be Second Last.

if status="Landed"
{
    set shipHeight to alt:radar-1.
} else
{
    set shipHeight to 0.
}
clearscreen.
if maxThrust<1
{
    stage.
}

lights off.
//lock steering to up:vector.
lock steering to heading (360,90).
until false

{
    userInput().
    AltControl().
    PitchControl().
   
   // BasicInfo().
   if alt:radar>20
   {
       Gear Off.
   } else if ALt:radar <15
   {
       Gear on. 
   } 
    
    wait 0.01.
}

softland(shipHeight).
