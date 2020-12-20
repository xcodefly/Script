// This file is to create atmospheric autopilot. 

// Objective - Straight and Level flight
//
CLEARSCREEN.

set OldHdg to 0.
set oldTime to time:seconds.
set dTurn to 0.
set ship_Pitch to 0.
set turnrate to 0.
set pInput to 0.
set targetSpeed to 300.
set p_control to 0.
set targetAlt to ship:altitude.
set targetVS to 1.
lock hdgVec to vxcl(up:vector,ship:facing:vector).
lock east to vcrs(up:vector,north:vector).
lock hdg to CompassHDG().

// Vertial and Horizontal modes
set vModeList to list(" PITCH","    VS","   ALT","   IAS").
set vmode to 1.
set vModeValue to List(3,0,0,0).
set nModeList to List("Roll"," HDG"," Nav"," App").
set nnode to 0.
set setThrottle to 0.
set cursor to 0.
// Auto Pilot 

set autoPilot to True.
set autoThrottle to True.

//SET altPID to pidLoop()
set vMax to 15.
set vMin to -15.

if availableThrust<1
{
    stage.
}

// PID controllers to control 
SET speedControl to pidLoop(0.088,0.007,0.011,0,1).
set pitchControl to pidLoop(0.045,0.01,0.053,-1,1).
set rollcontrol to PidLoop(0.1,0.01,0.05,-0.5,0.5).


lock throttle to setThrottle.

Declare function hud
{
    Parameter Offset to 5.
    set Space to 7.
    Print "     AutoPilot Master [Z] : "+autoPilot +"  " at (0,0).
    Print "        Auto Throttle [X] : "+autoThrottle + " ["+Round(setThrottle*100)+"]    " at (0,1). 
      
    Print "_______________________________________" at (0,2).
    Print "   " + vmodeList[vmode]+" : "+VmodeValue[vmode] + "   "  at (0,3).
    print " " + nModeList[nmode] + "  " at (20,3).

   // Printing HUD modes
    set x to 0.
    until x=vmodeList:length
    {
        print vmodeList[x] at (0+Space,offset+x).
        set x to x+1.
    }
    set space to 19.
   set x to 0.
    until x=NmodeList:length
    {
        print NmodeList[x] at (0+Space,offset+x).
        set x to x+1.
    }
    Print "  {Use I,J,K,L to change Mode}  " at (0,offset+x+1).

    set x to 0.
    until x=vmodeList:length
    {
        if x=cursor
            {
                Print "=" at (15,offset+X).
            } else
            {
                Print " " at (15,offset+X).
            }
        if x=vMode
            {
               Print " <" at (13,offset+X).
            } else
            {
                Print "  " at (13,offset+X).
            }
        

       set x to x+1. 
    }

    

 //   print " AP : " + 
   
    
}

Declare function shipAttitude
{
    if round(time:seconds,2)>Round(oldTime,2)
    {
        set dHDG to hdg-oldHDG.
        set oldHDG to hdg.
        set dT to time:seconds-oldTime.
        set oldTime to time:seconds.
        set turnrate to dHDG/dT.
        set oldHDG to hdg.
        set oldTime to time:seconds.
        
    }
    set ship_pitch to -(vang(ship:facing:vector,up:vector)-90).
 //   Return dTurn.
}

Declare function throttle_Control
{
    if autothrottle=true
    {
        set speedControl:setpoint to targetSpeed.
        set setThrottle to speedControl:update(time:seconds,airspeed).
    }
}

Declare function Roll_Control
{

}

Declare function Pitch_Control
{
    // all vertical controls are done using pitch control. 
    set pitchControl:setPoint to vModeValue[vmode].
    if vMode=0
    {
        set pInput to pitchControl:update(time:seconds,ship_pitch).
    }
    else if vMode=1
    {
        set pInput to pitchControl:update(time:seconds,verticalSpeed).
      
    }
    else if vMode=2
    {
        
        set pInput to pitchControl:update(time:seconds,Altitude)/3.
    }
    set ship:control:pitch to pInput.
}

until Gear and Lights
{
    hud().
    shipAttitude().
    if autoPilot=True
    {
        throttle_control().
        Pitch_control().
        Roll_control().
    }
    
    input().
    wait 0.01.

}
set pInput to 0.

Declare function CompassHDG{
    if vang(hdgVec,east)<90
    {
        set cHDG to vang(hdgVec,north:vector).
    }else
    {
        set cHDG to 360 -  vang(hdgVec,north:vector).
    }
    return cHDG.
}
Declare function input{
    if terminal:input:haschar 
				{
					set ch to terminal:input:getChar().
					Terminal:input:clear.
					if ch="I"
                    {
                        set cursor to max(0,cursor-1).
                    }
                    if ch="K"
                    {
                        set cursor to Min(vModeList:length-1,cursor+1).
                    }
                    if CH="J"
                    {
                        set Vmode to cursor.
                    }
                    if CH="J"
                    {
                        set Nmode to Cursor.
                        vModeChange().
                    }

                    if ch = "h"
                    {
                        if autoThrottle=False
                        {
                            set setThrottle to min(1,round(setThrottle,2)+0.01).
                        }
                        else 
                        {
                            set targetSpeed to targetSpeed+1.
                            set autoThrottle to targetSpeed.
                        }
                        
                    }
                    if ch="n"
                    {
                        if autoThrottle=False
                        {
                            set setThrottle to min(1,round(setThrottle,2)-0.01).
                        }
                        else 
                        {
                            set targetSpeed to targetSpeed-1.
                            set autoThrottle to targetSpeed.
                        }
                      
                    }
                    if ch="e"
                    {
                        set targetAlt to targetAlt+10.
                    }
                    if ch="q"
                    {
                        set targetAlt to targetAlt-10.
                    }
                    if ch="w"or ch="s"
                    {
                       vModeupdate(ch).
                    }
                // Autothrottle and PIlot    
                    if ch="Z"
                    {
                        if autoPilot=True{
                            set autopilot to false.     
                        }else
                        {
                            set autopilot to true.
                        }
                    }
                    if ch="X"
                    {
                        if autoThrottle=false{
                            set autoThrottle to targetSpeed.
                                 
                        }else
                        {
                            set autoThrottle to False.
                        }
                    }
					
                }
}

declare function vModeUpdate
{
    Local Parameter ch.
    if vmode = 0
    {
        if ch="s"
        {
            set vmodeValue[0] to round(vmodeValue[0],1)+0.1.
        }
        else if ch="w"
        {
            set vmodeValue[0] to round(vmodeValue[0],1)-0.1.
        }
       
    }else if vmode = 1
    {
        if ch="s"
        {
            set vmodeValue[1] to round(vmodeValue[1],1)+1.
        }
        else if ch="w"
        {
            set vmodeValue[1] to round(vmodeValue[1],1)-1.
        }
       
    }else if vmode = 2
    {
        if ch="s"
        {
            set vmodeValue[2] to round(vmodeValue[2])+10.
        }
        else if ch="w"
        {
            set vmodeValue[2] to round(vmodeValue[2])-10.
        }
       
    }

}

Declare function vModeChange
{
    set vmodeValue[0] to round(ship_pitch,1). 
    set vmodeValue[1] to round(verticalSpeed).
    set vmodeValue[2] to round(ship:altitude/10)*10.
    
}