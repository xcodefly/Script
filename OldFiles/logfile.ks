// basic logging file to see how inclinate and lat lng works.

set currentLat to round(ship:GeoPosition:lat).
set currentLNG to round(ship:GeoPosition:lng).
clearscreen.
set step to 0.
set startLng to currentLng-1.
until currentLNG=startLNG
{
    if round(ship:geoPosition:lng)<>currentLng
    {
        set currentLat to round(ship:GeoPosition:lat).
        set currentLng to round(ship:GeoPosition:lng).
        log currentLAT +","+CurrentLNG to "mylog.csv".
        set step to step+1.
        print " No of logs "+step at (0,1).
        
    }
    print " Ship's positoin " + round(ship:geoPosition:lat,1)+" / "+ round(ship:geoPosition:lng,1)+"      " at (0,0).
    wait 0.01.
}