// This is just the check the sorting algorith.


declare function sortList
{
    parameter xlist to list().
    local x to 0.
   // print xlist:length.
    until x=xlist:length-1
    {
        if xlist[x]<=xlist[x+1]
        {
            set x to x+1.
          //  print x.
        }
       
        else
        {
            set a to xlist[x].
            set xlist[x] to xlist[x+1].
            set xlist[x+1] to a.
            set x to 0.
        }
       // clearscreen.
      //  print xlist.
       // print x.
       // wait 1.
    }
    print " Done: ".
    return xlist.
}

set tlist to list(4,33,2,113,64,23,84,134,654,133,68,865,3).
clearscreen.
//print tlist.
set tlist to sortlist(tlist).
print " New list".
print  tlist.
