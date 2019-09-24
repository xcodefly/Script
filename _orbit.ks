// The function in this library are used for orbit adjustments for the ship.
// Fx. setOrbit (Parameter AP, Pe, )
Clearscreen.

Declare function setOrbit{
    Parameter setApoapsis.
    Parameter setPeriapsis.
    // SemiMajor Axis of orbit is (setApoapsis + setPeriapsis)/2
    set setSemiMajAxis to (setApoapsis+setPeriapsis)/2.

    set currentApoapsis to ship:apoapsis.
    set currentPeriapsis to ship:Periapsis.
    set currentSemiMajAxis to (currentApoapsis+currentPeriapsis)/2.


    Print "  Target Semi Major Axis : " + Round(setSemiMajAxis) +"   " at (0,2).
    Print " Current Semi Major Axis : " + Round(CurrentSemiMajAxis) +"   " at (0,3).
    



}


setOrbit (120000,110000).