// All the inputs are accpted here.
Declare function userInput_JoyStick
{
    Local Parameter inputControl.
    set inputControl:HDG to inputControl:HDG+SHIP:CONTROL:pilotyaw.
    set inputControl:Bank to inputControl:Bank+SHIP:CONTROL:pilotroll.
    set inputControl:Pitch to inputControl:Pitch+SHIP:CONTROL:pilotPitch.
    set inputControl:Alt to inputControl:Alt+SHIP:CONTROL:pilotmainthrottle-0.5.
    set inputControl:Alt to Max(inputControl:alt,ship:Altitude-5).
    if inputControl:HDG<0
    {
                set inputControl:HDG to inputControl:HDG +360.
    }else if (inputControl:hdg>360)
    {
        set inputControl:HDG to inputControl:Hdg-360.
    }
    

   // print "input :"+SHIP:CONTROL:pilotyaw at (0,15).
}


Declare function userInput_Raw
{
    Local Parameter inputControl.
    set inputControl:HDG to inputControl:HDG+SHIP:CONTROL:pilotyaw*3.
    set inputControl:Bank to SHIP:CONTROL:pilotroll*15.
    set inputControl:Pitch to SHIP:CONTROL:pilotPitch*15.
    set inputControl:Alt to ship:altitude+(ship:control:Pilotmainthrottle-0.2)*15.
  //  set inputControl:Alt to Max(inputControl:alt,ship:Altitude-5).
    if inputControl:HDG<0
    {
                set inputControl:HDG to inputControl:HDG +360.
    }else if (inputControl:hdg>360)
    {
        set inputControl:HDG to inputControl:Hdg-360.
    }
    

    print "Alt :"+ship:control:PilotMainthrottle*5 at (0,15).
}
Declare Function userInput_Basic
{
    Local Parameter inputControl.
    if terminal:input:haschar 
    {
        set ch to terminal:input:getChar().
        Terminal:input:clear.
        if ch = "e"
        {
            set inputControl:alt to  inputControl:alt+1.
        }else if ch = "q"
        {
            set inputControl:alt to  inputControl:alt-1.
        }
        else if ch = "j"
        {
            set inputControl:bank to  max(-25,inputControl:bank-1).
        } 
        else if ch = "l"
        {
            set inputControl:bank to  min(25,inputControl:bank+1).

        }else if ch = "w"
        {
            set inputControl:pitch to  Max(-25,inputControl:pitch-1).
        } 
        else if ch = "s"
        {
            set inputControl:pitch to  min(25,inputControl:pitch+1).
        }else if ch = "a"
        {
            set inputControl:HDG to  inputControl:HDG-1.
            if inputControl:HDG<0
            {
                set inputControl:HDG to inputControl:HDG +360.
            }
        } 
        else if ch = "d"
        {
            set inputControl:HDG to  inputControl:HDG+1.
             if inputControl:HDG>359
            {
                set inputControl:HDG to inputControl:HDG -360.
            }
        }
    }
}
