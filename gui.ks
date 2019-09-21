declare function guiOrbit
{
    set gui to gui(300).
    set myLat to gui:addlabel.
    set myLat:text to "Lat : "+ Round(ship:latitude).
    set myLng to gui:addLabel.
    set myLng:text to "Lng : "+ round(ship:longitude).
    set tick to time:seconds.
    gui:show().
    return tick.

}
guiOrbit().