
parameter filemode to "add".
Parameter Filename to "bridge1.json".
parameter useAsFunction to false.


// for editing the file " really bad practice"
local pointer to 0.
local selected to false.

// Edit List, loaded at start to help with confustion.

if (exists(filename))
    {
        set editList to readjson(filename).
    }

declare function addWaypoint
    {
    set waypoint to lexicon().
    waypoint:add("pos",ship:geoposition).
    waypoint:add("info","Info"+waypoints:length).
    waypoint:add("alt",200).
    waypoint:add("Speed",60).
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
  //  parameter currentFix to 0.
    Parameter filename to "Bridge1.json".
    
    Local wayPointList to readjson(filename).
    if abs(waypointList[currentFix]:pos:bearing)>90 and waypointList[currentFix]:pos:distance<(50+alt:radar)
    {
        
        if currentFix+1<waypointList:length
        {
            set currentfix to currentfix+1.
        }
        else if currentFix=waypointlist:length-1
        {
            set currentFix to 0.
        }
        
    }
    return waypointList.

}

declare function editFLT
{
    
    print "File [ "+ exists(filename) +" ] :  "+ filename + "  " at (0,1).
    print "    NO of fix : "+editList:length at (0,3).
    Print " Press 'D' to Select  " at (0,5).
    print " Press 'W' to Move up. " at (0,6).
    print " Press 'S' to Move down. " at (0,7).
    print " press 'A' to un-Select. " at (0,8).
    Print " Press 'Z' to Save. : "at (0,9).
    print " Waypoint List : " +(editList:length+1) at (0,12).
    ListWaypoints(editList).
    editInput().
}
declare function editInput
{
    
     if terminal:input:haschar 
    {
         print "  " at (0,14+pointer).
        set ch to terminal:input:getChar().
        Terminal:input:clear.
        if ch = "w"
        {
            set pointer to max(0,pointer -1).
            if selected=true
            {
               set temp to editList[pointer+1].
               editList:remove(pointer+1).
               editList:insert(pointer,temp).
               print " ** Unsaved Changes ** " at (0,2).
              // print "AA".
            }
           
        }
        if ch = "s"
        {
            set pointer to min(editlist:length-1,pointer +1).
            if selected=true
            {
               set temp to editList[pointer-1].
               editList:remove(pointer-1).
               editList:insert(pointer,temp).
               print " ** Unsaved Changes ** " at (0,2).
              // print "AA".
            }
        }
        if ch = "d"
        {
            set selected to true.
        }
        if ch = "a"
        {
         //   print editList.
            set selected to false.
        }
        if ch = "z"
        {
           print " **  Saved Changes  ** " at (0,2).
            writejson(editList,Filename).
        }
            if selected=true{
                print "*>" at (0,14+pointer).
            }else{
                print "*" at (0,14+pointer).
            }    
    }
   

    

}


declare function addInput
{

    if terminal:input:haschar 
    {
        clearscreen.
        set ch to terminal:input:getChar().
        Terminal:input:clear.
        if ch = "n"
        {
            if exists("bridge1.json")
            {
                set waypoints to readjson("bridge1.json").

            }
            else {
                Print " No file " at (20,0).
            }
           
        }
        if ch = "a"
        {
            waypoints:add( addwaypoint()).
            PRINT " Unsaved File " at (0,2).
        }
        if ch = "x"
        {
            waypoints:remove(closestPoint).
             PRINT " Unsaved File " at (0,2).
           
        }
        if ch = "z"
        {
            if waypoints:length>0
            {
                writejson(waypoints,filename).
                PRINT "              " at (0,2).
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

declare function addFLT{
    print "File [ "+ exists(filename) +" ] :  "+ filename + "  " at (0,1).
    Print " Press 'N' to Load file " at (0,5).
    print " Press 'A' to add current position as a waypoint. " at (0,6).
    print " Press 'X' to remove closest waypoint. " at (0,7).
    print " press 'Z' to save. " at (0,8).
    print " Waypoint List : " +waypoints:length at (0,12).
    ListWaypoints(waypoints).
    addInput().
    
}
clearscreen.    
set waypoints to list().


// variabls to keep track of waypoints.
set closestPoint to 0.
set closedDistance to 0.
until useAsFunction  = true
{
    if filemode="add"{
        addFLT().
    }else if filemode="edit"
    {

        editFLT().
        
       
    }
    
    wait 0.
}

declare function ListWaypoints
{
    local parameter showwaypoints.
    set count to 0.
    set closestPoint to 0.
    set closedDistance to 0.
    if showwaypoints:length>0
    {
        set closedDistance to showwaypoints[count]:pos:distance.
    }
    until count=showwaypoints:length{
        
        print "  Dis: " + round(showwaypoints[count]:pos:distance)+"  " at (2,14+count).
        print "bng: " + round(showwaypoints[count]:pos:bearing)+"  " at (16,14+count).
        print "  <info> " + showwaypoints[count]:info+"  " at (25,14+count).
        if showwaypoints[count]:pos:distance<closedDistance
        {
            set closedDistance to showwaypoints[count]:pos:distance.
            set closestPoint to count.
        }
        set count to count+1.
        
    }
}