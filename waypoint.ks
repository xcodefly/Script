Parameter Filename to "bridge1.json".
declare function addWaypoint
    {
    set waypoint to lexicon().
    waypoint:add("pos",ship:geoposition).
    waypoint:add("info","Info"+waypoints:length).
    waypoint:add("alt",90).
    waypoint:add("inBound",90).
    waypoint:add("outBound",270).
    waypoint:add("vMode","pitch").
    waypoint:add("vModeValue",0).  
    waypoint:add("lMode","bank").
    waypoint:add("lModeValue",0).
    return waypoint.
}
set vMode to list("pitch","VS","ALT","IAS").
set lMode to list("bank","HDG","WayPoint","ILS","ARC").
declare function exeFlt
    {
    Parameter filename.

}

declare function editFlt
    {
    Parameter filename.
}

declare function createFlt
    {
    Parameter filename.

}

declare function NavInput
{

    if terminal:input:haschar 
    {
        set ch to terminal:input:getChar().
        Terminal:input:clear.
        if ch = "n"
        {
            if exists("bridge1.json")
            {
                set waypoints to readjson("bridge1.json").

            }
            else {
                Print " No file " at (0,10).
            }
        }
        if ch = "a"
        {
            waypoints:add( addwaypoint()).
        }
        if ch = "x"
        {
            waypoints:remove(closestPoint).
            clearscreen.
        }
        if ch = "z"
        {
            if waypoints:length>0
            {
                writejson(waypoints,filename).
            }
            else
            {
                Print " Empty list " at (0,15).
                SET V0 TO GETVOICE(1). // Gets a reference to the zero-th voice in the chip.
                V0:PLAY( NOTE(400, 0.1) ).
                wait 1.
                clearscreen.
            }
            
        }
        
    }
}

declare function info_display{
    print "File [ "+ exists(filename) +" ] :  "+ filename + "  " at (0,1).
    set temp to readjson(filename).
    if (temp:length<>waypoints:length and waypoints:length>0)
    {
        print " ..  unsaved file .." at (0,2).
    }
    else 
    {
        Print "                    " at (0,2).
    }
    print "    NO of fix : "+temp:length at (0,3).
    Print " Press 'N' to open file " at (0,5).
    print " Press 'A' to add current position as a waypoint. " at (0,6).
    print " Press 'X' to remove closest waypoint. " at (0,7).
    print " press 'Z' to save file. " at (0,8).
    print " Waypoint List : " +waypoints:length at (0,12).
    ListWaypoints().
    
}
clearscreen.    
set waypoints to list().


// variabls to keep track of waypoints.
set closestPoint to 0.
set closedDistance to 0.
until false
{
    info_display().
    NavInput().
    wait 0.
}
declare function ListWaypoints
{
    set count to 0.
    set closestPoint to 0.
    set closedDistance to 0.
    if waypoints:length>0
    {
        set closedDistance to waypoints[count]:pos:distance.
    }
    until count=waypoints:length{
        
        print " Dis: " + round(waypoints[count]:pos:distance)+"  " at (0,14+count).
        print " HDG: " + round(waypoints[count]:pos:heading)+"  " at (10,14+count).
        print " <info> " + waypoints[count]:info+"  " at (18,14+count).
        if waypoints[count]:pos:distance<closedDistance
        {
            set closedDistance to waypoints[count]:pos:distance.
            set closestPoint to count.
        }
        set count to count+1.
        
    }
}