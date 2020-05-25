// All the global varables start with "_" to make it easy to remember.

Lock MaxAcc to  ship:availableThrust/ship:mass.
Lock East to vCRS (up:vector,north:vector).
Lock localG to constant:g * body:mass / body:radius^2.  
Lock MaxLandingAcc to MaxAcc-LocalG.
clearscreen.






