// Autopilot for airshow. 

// Rate calculaiton for turn, pitch and roll for controlling the roll.
    


        Lock ShipFront to ship:facing:vector.
        Lock East to vcrs(up:vector,North:vector).
        Lock hdgVector to vxcl(up:vector,ship:facing:vector).
        // Record time for calculating rates.
        set PreviousTime to time:seconds.


    // PIDs used to control the surface. (No yaw control for now)

        set AileronPID to pidLoop(.186,0.0011,.0052,-0.5,0.5).
        set RollPID to pidloop(0.4,0,2,-3,3).  //(0.135,0,.24,-3,3).
        
        Set elevatorPitchPID to PIDLoop(.15,0.05,.02,-1,1). // -2,5 are relative to facing vector
        Set elevatorVSPID to PIDLoop(.04,0.03,0.018,-1,1). // -2,5 are relative to facing vector  ///(.065,0.06,0.033,-1,1) values produce occilation at higher speed
        Set throttlePID to PIDloop(0.18,0.0075,0.10,0.02,1).  //(.065,0.004,0.28,0.02,1).
        Set elevatorALTPID to PIDLoop(.30,0,0.045,-100,100).

        
        
    // Main part of this plane is to use control surface to control the attitude and no gyro. Idea came from QuadCopter whis is very stable and make more sense. Using reaction wheel feels like cheating. 
        set shipPitch to 0.
        Set ShipRoll to 0.
        Set ShipHDG to 0.
        set TargetHDG to 0.
        set TargetAlt to 100.
        
        set LnavMode to list(0,0,0).
        set VnavMode to list(0,0,0).
        set PreviousHDG to 0.
        set rollrate to 0.
        
	// AP Display offset , didn't implement 
       
        set apDisplayOffset to 4.

	// Autopilot Control
        set apPointer to 2.
        set TargetHDG to 0.
        set AP to true.
        set AT to true.
        set TargetSpeed to 100.
        set TargetThrottle to 0.
        set TargetPitch to 2.
        Set TargetVS to 0.
        set seekHDG to 0.
        set altStep to 50.


	// Landing and Approach variables
        Set GS to False. // GlideSlop Toggle
		set vR to 60.    // Speed below which Pitch control doen't work for takeoff. Unless flying. 
        Set GlidePathAngle to 4.
        Set FlareAlt to 40.         // 40 for most planes
        Set TouchdownPitch to 4.    // Default is 8.
	// Position Constants for Runways
		set RunwayHDG to 0.
        // Add to touchdown spots of the runway in list. Order doesn't matter. LIST(Lat1, Lng1, Lat2, Lng2), 
		set RunwayLocations to List(    List(-0.0501105286831176,-74.5054501611489,-0.048626302038742,-74.7247883048936)    ,
									    List(-0.048626302038742,-74.7247883048936,-0.0501105286831176,-74.5054501611489)     ).
		
	
    Clearscreen.
        // PID
            // Heading PID
           
		
		
    // Other Quick tweek variables
        
		
    //	DisplayStatic().
        apModeDisplay().
        APControlDisplay().
        updateLnavmode().
        updateVnavMode().
        set RollPID:setPoint to 0.
        set elevatorALTPID:setpoint to 0.
        SET PreviousTime TO TIME:SECONDS. WAIT 0.01.
    Until gear and Lights
        {
        
        //    AttitudeUpdate().
            DisplayFunction().
            apModeDisplay().
          //  PowerControl().
            PitchControl().
            RollControl().
            userinput().
            wait 0.01.
        }

	Declare Function PitchControl
		{
			if ship:airspeed>vr or status = "Flying"
			{
				if VnavMode[0]=1
				{
					set elevatorPitchPID:setpoint to targetPitch.
					set ship:control:pitch to elevatorPitchPID:update(time:seconds,shipPitch). 
				}else if VnavMode[1]=1
				{
					set elevatorVSPID:setpoint to targetVS.
					set ship:control:pitch to elevatorVSPID:update(time:seconds,VerticalSpeed).
				}else if VnavMode[2]=1
				{
					set targetVS to -ElevatorAltPID:update(time:seconds,TargetAlt-Altitude).
					set elevatorVSPID:setpoint to TargetVS.
					set ship:control:pitch to elevatorVSPID:update(time:seconds,VerticalSpeed).
				}
				
				if LnavMode[2]=1
				{
				//	Print " CLose Fix Distance : "+ Round(CloseFix:Distance) + "  "  at (4,22).
				//	Print "      a  Target Alt : "+ Round(Sin(4)*CloseFix:distance)+ " " at (4,23).
					
					{
					    Set VNavAlt to Sin(GlidePathAngle)*CloseFix:distance.
						If VnavAlt<Altitude
						{
							Set GS to True.
                             Gear ON.
                            
						}
				          
                        if GS = true and Alt:radar>FlareAlt
                        {
							set TargetAlt to VnavAlt.
							set targetVS to -ElevatorAltPID:update(time:seconds,TargetAlt-Altitude).
                     		set elevatorVSPID:setpoint to TargetVS.
							set ship:control:pitch to elevatorVSPID:update(time:seconds,VerticalSpeed).
						}
                        IF Alt:radar<400{
                         //   AG3 on.
                        }
                       
                       	if Alt:Radar<FlareAlt
                        {
                            Set TargetSpeed to 0.
                            FlareMode().      
                        }
					}
				}
			}
		}

	
    Declare Function DisplayFunction
		{
			Print "                                  " at (1,7).
			if vnavMode[0]=1
			{
				Print "   Pitch : "+ Round(shipPitch,1)	+ "  " at ( 1,7).
				Print "["+TargetPitch+"]" at (16,7).
			} else if vnavmode[1]=1 or VnavMode[2]=1
			{
				Print "      VS : "+ Round(verticalspeed,1)	+ "  " at ( 1,7).
				Print "["+Round(TargetVS,1)+"]" at (16,7).
			}
			Print "             " at (12,8).
			Print "Altitude : " + Round(altitude) at (1,8).
			if vnavmode[2]=1
			{
				print "["+Round(targetALT)+"]" at (16,8).
			}
			else
			{
				print "<"+Round(targetALT)+">" at (16,8).
			}
			
			Print "         " at (12,9).
			Print " Heading : " + Round(shipHdg) at (1,9).
			
		
			Print "          " at (12,10).
			Print "Airspeed : "+Round(airspeed)  at (1,10).
			print "         " at (12,11).
			Print "Throttle : " at (1,11).
			if lnavMode[0]=1
			{
				print "["+TargetHDG+"]  " at (16,9).
			}else
			{
				print "       " at (15,9).
			}

			if AT = true{
				print "["+TargetSpeed+"]" at (16,10).
				Print Round(TargetThrottle*100) at (12,11).
				Print "%[AT]" at (15,11).
				
			}else{
				Print Round(TargetThrottle*100) at (12,11).
				Print "%" at (15,11).
			}
		}
		
	Declare Function APModeDisplay{
			
			Print "  Auto Throttle <x> : " + AT + "  " at (1,0).
			Print "   Auto Pilot   <z> : " + AP + "  " at (1,1).
			Print "PIT" at (5,3).
			Print " VS" at (5,4).
			Print "ALT" at (5,5).

			Print "HDG" at (13,3).
			Print "NAV" at (13,4).
			Print "APP" at (13,5).
		}

	Declare Function APControlDisplay{
			Print " " at (10,3+apPointer-1).
			Print "-" at (10,3+apPointer).
			Print " " at (10,3+apPointer+1).
		}

	Declare Function updateLnavMode{
			set counter to 0.
			until counter>2 
			{
				if LnavMode[counter]=1
				{
					Print "[" at (12,3+counter).
					Print "]" at (16,3+counter).
				}else
				{
					Print " " at (12,3+counter).
					Print " " at (16,3+counter).
				}
			
				set counter to counter + 1.
			}
		}
	Declare Function updateVnavMode
        {
			set counter to 2.
			until counter>2
			{
				if VnavMode[counter]=1
				{
					Print "[" at (4,3+counter).
		    		Print "]" at (8,3+counter).
					
				}else
				{
					Print " " at (4,3+counter).
					Print " " at (8,3+counter).
				}
				set counter to counter + 1.
			}
		}

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
					if ch = "s"
					{
						if vnavmode[0]=1
						{
							set targetPitch to round(TargetPitch,1) +.1.
						}else if vnavmode[1]=1
						{
							set TargetVS to Round(TargetVS)+1.
						}
					}
					if ch = "w"
					{
						if vnavmode[0]=1
						{
							set targetPitch to round(TargetPitch,1) -0.1.
						}else if vnavmode[1]=1
						{
							set TargetVS to Round(TargetVS)-1.
						}
					}
					if ch = "q"
					{   
                         if alt:radar<30
                        {
                            set altStep to 1.
                            set targetALT to round(TargetAlt).
                        }else if alt:radar>1000
                        {
                            set altStep to 100.
                            set targetALT to round(targetALT/100)*100.
                        }else {
                            set altStep to 20.
                            set targetALT to round(targetALT/10)*10.
                       
                        }
						set targetAlt to targetAlt-altStep.
					}
					if ch = "e"
                    {
                         if alt:radar<50
                        {
                            set altStep to 1.
                            set targetALT to round(TargetAlt).
                        }
                        else if alt:radar>1000
                        {
                            set altStep to 100.
                            set targetALT to round(targetALT/100)*100.
                        }else {
                            set altStep to 20.
                            set targetALT to round(targetALT/10)*10.
                        }
						set targetAlt to targetAlt+altStep.
					}
					
					if ch = "h"
					{
						if AT = true{
							set TargetSpeed to TargetSpeed+1.
						}
						else
						{
							set TargetThrottle to Min(1,TargetThrottle + .05).
						}
					}
					if ch = "n"
					{
						if AT = true{
							set TargetSpeed to Max(0, TargetSpeed-1).
						}
						else
						{
							set TargetThrottle to Max(0,TargetThrottle - .05).
						}
					}
					
					if ch = "x"
					{
						if AP = true{
							if AT = false
							{
								Set AT to True.
                                set TargetSpeed to Round(airspeed).

							} else
							{
								Set AT to False.
								set SHIP:CONTROL:MAINTHROTTLE to 0.
							}
							apModeDisplay().
						}
					}
					if CH = "j"
					{
						Set GS to False.
						set counter to 0.
						
						if AP = true
						{
							until counter>2
							{
								if counter=apPointer
								{
									SET VnavMode[Counter] TO 1.
								}
								else
								{
									SET VnavMode[Counter] to 0.
								}
								if apPointer=2
								{
									set TargetAlt to Round(Altitude).
								}
									set counter to counter +1.
								
							}
							set targetVS to round(verticalSpeed).
							Set TargetPitch to Round(ShipPitch,1).
							updateVnavMode().
						}
					}
					if ch = "l"
					{
						if apPointer = 0
						{
							set TargetHDG to round(shipHDG).
						} else if apPointer = 1
						{
							SelectApproach().
						}
						set counter to 0.
						if AP = true
						{
							until counter>2
							{
								if counter=apPointer
								{
									set LnavMode[Counter] to 1.
								}
								else
								{
									set LnavMode[Counter] to 0.
								}
								set counter to counter +1.
							}
							updateLnavMode().
						}
										
					}
					if ch = "i"
					{
						set apPointer to Max(0,(apPointer -1)).
						APControlDisplay().
					}
					if ch = "k"
					{
						set apPointer to Min(2,(apPointer + 1)).
						APControlDisplay().
					}
					if ch = "z"
					{
						if AP = false
						{
							set AP to true.
							set targetHDG to round(ShipHDG).
							Set VnavMode[0] to 1.
							set LnavMode[0] to 1.
							updateLnavMode().
							UpdateVnavMode().
						} 
						else
						{
							set AP to False.
							Set AT to False.
							set counter to 0.
							until counter >2
							{
								set lnavMode[counter] to 0.
								set vnavMode[Counter] to 0.
								set counter to counter +1.
							}
							apModeDisplay().
							updateLnavMode().
							UpdateVnavMode().
							set SHIP:CONTROL:NEUTRALIZE to true.
							
						}
					}
				}
		}

	Declare Function SelectApproach
		{
			set RunwayCounter to RunwayLocations:length.
			
			
			set ClosestAirportIndex to 0.
			set ClosestAirport to LatLng(RunwayLocations[ClosestAirportIndex][0],RunwayLocations[ClosestAirportIndex][1]).
			Set Counter to 1.
			set TestAirportLocation to LatLng(0,0).
			Until Counter=RunwayLocations:length
			{
				
				set TestAirportLocation to LatLng(RunwayLocations[Counter][0],RunwayLocations[Counter][1]).
				if Round(TestAirportLocation:Distance)<Round(ClosestAirport:Distance)
				{
					set ClosestAirportIndex to Counter.
				}
				set Counter to Counter+1.

			}
		//	Print "Closest Index : " + ClosestAirportIndex at (4,19).
			set Closefix to LatLng(RunwayLocations[ClosestAirportIndex][0],RunwayLocations[ClosestAirportIndex][1]).
			set FarFix to LatLng(RunwayLocations[ClosestAirportIndex][2],RunwayLocations[ClosestAirportIndex][3]).
			set TargetFix to LatLng((RunwayLocations[ClosestAirportIndex][2]+RunwayLocations[ClosestAirportIndex][0])/2,(RunwayLocations[ClosestAirportIndex][1]+RunwayLocations[ClosestAirportIndex][3])/2).
			if FarFix:distance<CloseFix:distance
			{
				set Closefix to LatLng(RunwayLocations[ClosestAirportIndex][2],RunwayLocations[ClosestAirportIndex][3]).
				set FarFix to LatLng(RunwayLocations[ClosestAirportIndex][0],RunwayLocations[ClosestAirportIndex][1]).
			}
		//	Print " Seek Direction : "+(CloseFix:Bearing - FarFix:bearing) at (4,19).
			set RunwayVector to FarFix:position-CloseFix:Position.
			
			if vang(RunwayVector,east)<90 
				{
					set RunwayHDG to  vang(RunwayVector,north:vector).
				}
			else
				{
					set RunwayHDG to  360-vang(RunwayVector,north:vector).
				}
			Print "     Runway HDG : "+ Round(RunwayHDG) + "  " at (1,15).
			set LandingElevation to Round(Kerbin:Altitudeof(CloseFix:Position)).

		}
	
	
    Declare Function GOAround
        {
            if Alt:radar>15
            {
                Set VnavMode[0] to 1.
                Set VnavMode[1] to 0.
                Set VnavMode[2] to 0.
                Set LnavMode[0] to 1.
                Set LNavMode[1] to 0.
                Set LnavMode[2] to 0.
                Set GS to False.
                UpdateLnavMode().
                UpdateVnavMode().
                Set TargetHDG to Round(RunwayHDG).
                Set TargetPitch to 10.
                set TargetSpeed to 110.
                Gear Off.
                AG1 ON.
                
            }
        }
    
    Declare Function FlareMode
        {
            set targetVS to -(Alt:radar/15)+TouchDownPitch.
            set elevatorVSPID:setpoint to TargetVS.
            set ship:control:pitch to elevatorVSPID:update(time:seconds,VerticalSpeed).
            if Alt:radar<5
            {
                Brakes ON.
            }
        }
       
