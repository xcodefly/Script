// basic logging file to see how inclinate and lat lng works.

set currentLat to round(ship:GeoCoordinates:lat).
set currentLNG to round(ship:geocoordinates:lng).


until light
{
    if ship:geocoordinates:lat<>curretLat or ship:geocoordinates:lng<>curretlng
    {
        set currentLat to round(ship:GeoCoordinates:lat).
        set currentLng to round(ship:geocoordinates:lng).
        log "a" to "mylog.csv".
        wait 1.
    }
}