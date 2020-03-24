set lgt to gui(200). 
set lgt:x to -100. 
set lgt:y to 200. 
set rtl to lgt:addlabel("LT"). 
set rtl:style:align to "left". 
set rtl:style:richtext to true. 
set rta to lgt:addlabel("LG"). 
set rta:style:align to "left". 
set rta:style:richtext to true. 
lgt:show().
set lgswitch to true. 
declare function updateGUI
{ 
    set rtl:text to "<size=14>Lt: "+round(ship:latitude,4)+"</size>". 
    set rta:text to "<size=14>Lg: "+round(ship:longitude,4)+"</size>". 
} 
