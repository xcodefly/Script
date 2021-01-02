Declare Function userInput
	{
	if terminal:input:haschar 
        {
            set ch to terminal:input:getChar().
            
            Terminal:input:clear.
            if  abs(shipHDG-TargetHDG)>5
            {
                set hdgstep to 5.
            }else 
            {
                set hdgstep to 1.
            }
            if ch = "a"
            {
                set TargetHdg to TargetHdg - hdgstep.
                if TargetHdg<0
                {
                    Set TargetHdg to TargetHdg+360.
                }
            }
            if ch = "d"
            {
                
                set TargetHdg to TargetHdg + hdgstep.
                if TargetHdg>360
                {
                    Set TargetHdg to TargetHdg-360.
                }
            }
            if ch = "s"
            {
                
                set targetSpeed to Max(-5,targetSpeed-1).
            }
            if ch = "w"
            {
                
                set TargetSpeed to Min(30,targetSPeed+1).
            }
            if ch = "n"
            {
                set targetAlt to targetAlt-1.
                set targetRadar to targetRadar-1.
            }
            if ch = "h"
            {
                set targetAlt to targetAlt+1.
                set targetRadar to targetRadar+1.
              }
            if CH = "j"
            {
                set slipSpeed to slipSpeed-1.
            
            }
            if ch = "l"
            {
                set slipSpeed to slipSpeed+1.
            }
            if ch = "t"
            {
                set targetALT to ALtitude.
                set targetRadar to alt:radar.
                set Hovermode to MOD((hovermode+1),2).
            }

            if ch = "b"
            {
                
                toggle Brakes.
                clearscreen.
                set targetHDG to shipHDG.
            }

            if ch="u"
            {
                toggle lights.
                clearscreen.
            }


        }

	}
