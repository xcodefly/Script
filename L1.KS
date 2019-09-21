// This program listen if any incomeing message for kOS script. 
clearscreen.

until False
{   
    set len to ship:messages:Length.
    if len=1
    {
        lock steering to dir. 
        Print " Dir Recieved " at (0,1).
    }else
    {
        Print " Listning.    " at (0,1).
        wait 1.
        Print " Listning..   " at (0,1).
        wait 1.
        Print " Listning...  " at (0,1).
        wait 1.
        Print " Listning.... " at (0,1).
       
    }
    clearscreen.
    wait 0.3.
    
}