run "_global.ks".
run "_hud.ks".
run "_land.ks".
run "_deorbit.ks".

clearscreen.

    DeorbitRetro().
    info_land(4).
    clearvecdraws().
    HoverSlam().
    Softland().
    wait 0.01.

