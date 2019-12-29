// All the inputs are accpted here.

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
