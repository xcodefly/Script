// All the inputs are accpted here.

Declare Function userInput
{
    Local Parameter inputControl.
    if terminal:input:haschar 
    {
        set ch to terminal:input:getChar().
        Terminal:input:clear.
        if ch = "h"
        {
            set inputControl:alt to  inputControl:alt+1.
        }else if ch = "n"
        {
            set inputControl:alt to  inputControl:alt-1.
        }
        else if ch = "a"
        {
            set inputControl:bank to  inputControl:bank-1.
        } 
        else if ch = "d"
        {
            set inputControl:bank to  inputControl:bank+1.
        }else if ch = "w"
        {
            set inputControl:pitch to  inputControl:pitch-1.
        } 
        else if ch = "s"
        {
            set inputControl:pitch to  inputControl:pitch+1.
        }else if ch = "q"
        {
            set inputControl:HDG to  inputControl:HDG-1.
            if inputControl:HDG<0
            {
                set inputControl:HDG to inputControl:HDG +360.
            }
        } 
        else if ch = "e"
        {
            set inputControl:HDG to  inputControl:HDG+1.
             if inputControl:HDG>359
            {
                set inputControl:HDG to inputControl:HDG -360.
            }
        }
    }
}
