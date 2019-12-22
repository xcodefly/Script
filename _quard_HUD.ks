// Print HUD.

Declare function quard_HUD
{
    Local Parameter hudATT.
    local Parameter hudControl.
    Print " RPM : "+hudControl:rpm+ "   " at (0,0).
}