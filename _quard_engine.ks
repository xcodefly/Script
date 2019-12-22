// This return the list of engines in Clockwise for Quard.

declare function Engine_ClockWise
{
    clearvecdraws().
    Local engList to ship:partsnamed("rotor.01s").
    
   
    set sortedList to List(0,0,0,0).
    for e in englist{
      
        if (e:tag="right front")
        {
            set sortedList[0] to e.

        }else  if (e:tag="right back")
        {
            set sortedList[1] to e.

        }else if (e:tag="left back")
        {
            set sortedList[2] to e.

        }else if (e:tag="left front")
        {
            set sortedList[3] to e.

        }
        else{
            Print "Missing Engines".
            Wait 1.
        }
    }
    
   

    
    return sortedList.
}

