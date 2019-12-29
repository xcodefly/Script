// This return the list of engines in Clockwise for Quard.

declare function Engine_ClockWise
{
    clearvecdraws().
    Local engList to ship:partsnamed("rotor.02s").
    
    print engList.
    set sortedList to List(0,0,0).
    for e in englist{
      
        if (e:tag="front right")
        {
            set sortedList[1] to e.

        }
        else if (e:tag="front left")
        {
            set sortedList[0] to e.

        }
        else  if (e:tag="back")
        {
            set sortedList[2] to e.

        }
        else
        {
            Print "Missing Engines".
            Wait 1.
        }
    }
    
   
    print sortedList.
    
    return sortedList.
}

