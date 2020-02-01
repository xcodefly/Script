// Print HUD.

Declare function hud_0
{
    Local Parameter hudATT.
    local Parameter hudControl.
    local parameter elist.
   
    Print " ALT  : "+round(ship:altitude)+" [ "+Round(hudControl:alt)+ " ]   " at (0,0).
    print " RPM  : "+Round(hudControl:rpm)+"   " at (0,1).
  
    print " Pitch : "+round(hudATT:pitch,1)+ +" [ "+Round(hudControl:Pitch)+ " ]    " at (0,2).
    print "  Bank : "+round(hudATT:bank,1)+" [ "+Round(hudControl:bank)+ " ]    " at (0,3).
    print "   HDG : "+round(hudATT:HDG) +" [ "+Round(hudControl:HDG)+ " ]    "at (0,4).

    // Print the current RPM for engines.
    Print " Left Front : Right Front " at  (0,7).
    print Round( eList[0]:getmodule("ModuleRoboticServoRotor"):getfield("rpm Limit"))+"   " at (3,8).
    print " :    "+Round( eList[1]:getmodule("ModuleRoboticServoRotor"):getfield("rpm Limit"))+"   " at (11,8).
    print Round( eList[2]:getmodule("ModuleRoboticServoRotor"):getfield("rpm Limit"))+"   " at (10,9).
}

declare function hud_1
{
    Local Parameter hudATT.
    local Parameter hudControl.
    local parameter elist.
    local parameter _mode to "aa".
    local parameter _mode_YD to false.
clearscreen.
    Print "           TRI - Control  " at (0,1).
    print "      MODE (T) : " + _mode at (0,2).
    print "    YawDam (T) : " + _mode_YD at (0,3).
     print "  Slip : "+round(hudATT:yaw,1)+" [ "+Round(hudControl:bank)+ " ]    " at (0,4).
}