// this file is used to sort the elements of a list.

Declare function sortAsc
{
    parameter testList to list().
    local x to 0.
  
    until x=testList:length
    {
        set y to x.
        until y=0
        {
            if testList[y]<testList[y-1]
            {
                set temp to testList[y].
                set testList[y] to testList[y-1].
                set testList[y-1] to temp.
            }
            set y to y-1.
        }
        Print " Sortinng "+x+ " / " + testList:length at (0,0).
        set x to x+1.
    }


    return testList.

}

clearscreen.
set ls to list().
until ls:length =50
{
    ls:add(Round(random()*500)).
}
//print ls.
set ls to sortAsc(ls).
print ls.
