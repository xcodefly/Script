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
            set inputControl:rpm to  inputControl:rpm+10.
        }else if ch = "n"
        {
            set inputControl:rpm to  inputControl:rpm-10.
        }   
    }
}
