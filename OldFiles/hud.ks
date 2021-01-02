clearscreen.
Declare function HUD{
    
    Print "Speed : "+ Round(airspeed) +" " at (1,1).
    Print "  Alt : "+ Round(altitude) + " " at (1,2).
    if alt:radar<500
    {
        print "(RA: "+ Round(alt:radar,1)+") " at (15,2).
    } else
    {
        print "              " at (15,2).
    }
    
}