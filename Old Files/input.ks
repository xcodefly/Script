// all the input functions required to control the ship.

 Declare Function UserInput
		{
            
			if terminal:input:haschar 
				{
					set ch to terminal:input:getChar().
					Terminal:input:clear.
					if ch = "a"
					{
						set TargetHdg to TargetHdg - 1.
						if TargetHdg<0
						{
							Set TargetHdg to TargetHdg+360.
						}
					}
					if ch = "d"
					{
						set TargetHdg to TargetHdg + 1.
						if TargetHdg>360
						{
							Set TargetHdg to TargetHdg-360.
						}
					}
                    if ch = "w"
					{
						set desiredSpeed to desiredSpeed + 1.
						
					}
                     if ch = "s"
					{
						set desiredSpeed to desiredSpeed-1.
                    }
                    if ch = "h"
					{
                       
                        set desiredAlt to desiredAlt+1.
                    }
                     if ch = "n"
					{
					    
                     
                        set desiredAlt to desiredAlt-1.
                     
						
					}
                     if ch = "j"
					{
						set desiredSlip to desiredSlip - 1.
						
					}
                     if ch = "l"
					{
						set desiredSlip to desiredSlip + 1.
						
					}
                    if ch = "r"
					{
					//	set flightmode flightmode+1.
                        if flightMode=0
                        {
                            set flightmode to 1.
                            set desiredAlt to round(alt:radar).
                        } else if flightmode=1
                        {
                            set flightmode to 0.
                            set desiredALT to round(Altitude).
                        }
						
					}
                }
        }
