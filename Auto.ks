    // AutoFligh for Airplanes.
    
    // Code need lot of polish, lost of tricks to do continous circuits. 
    // Control Inputs: (Active Focuse Window, kOS Window for all Controls)
        // A, D to increase or decrease heading. only if square bracket is visible. 
        // S and W, adjust Pitch or VS when in Pitch or VS mode
        // Q and E, change selected alt. ** ALT Capture doesn't work for now. 

        // Autopilot is control by I,K (up,down) and J,K. Present position is indicated by '-', J and K will select the approprate mode. 
        // H,N if AT - ON, increase and decrease - set speed.
        // H,N if AT - Not On, acts as throttle +-(5%)
        // ** Nav only turns one way, need to look into the code. 
        // ** descent will not start unless within few degrees on final course. NEED more room or slow down..

        // Takeoff - Manual or  AP - ON, AT - OFF, user H/N to adjust power.
        // Approach, (1) Activate NAV. (2) Activate APP. ** will make it better later.  
        // Laning, target speed is when pitch contorl is between .25 to .5 up so it doen't float for every and go in overshoot. 
        // After Landing, disconnect AT-'X' if plane rolls back.
    
    // Test Airplane - Mallard ( AppSpeed - 80), Stearwing A300 (App speed - 95), StratuLaunch( Elevator Eff - 50%,Tail Fin - 50%, Engine Revers-AG6(Default is AG0) AppSpeed - 80 ), Thunderbird(Elevator and Aileron -40%,Brake-75% AppSpeed - 85, TouchdownPitch - 4, *** During Flare AT-OFF, Press N-0% Thrust. )
    
    
    // Two main modes Vnav and Lnav. 
    // Lnav - HDG, NAV and App mode. app mode will use TargetAlt to descent the plane for now. 
    // Vnav - Pitch, VS and Alt.
    // Control Functions - Rollcontrol for Lnav, Pitch control for Vnav.
    // ** Once in App mode, target Alt is used to descent. * NEED TO UPDATE TO SOMETHING BETTER.
    // Flare alt can be adjsuted by a varaible (Landing and Approach Varables) 
    // ** userinput, updateLnavmode and Updatevnavmode need to rewritten in a better flow.
    // ** GoAround Conditions for stable approach, need to test how and where. 
        //GoAround, Pitch 10 Degree, speed 110 and Cleanup the plane.*
    // Attutide Update, calculate heading and pitch.
    // ** Powercontrol better logic on ground. 
    // Select approach, look for the closest runway and then looks for the closest end and caclulate runway orientation. when you select NAV.

    
    // Main part of this plane is to use control surface to control the attitude and no gyro. Idea came from QuadCopter whis is very stable and make more sense. Using reaction wheel feels like cheating. 
        set shipPitch to 0.
        Set ShipRoll to 0.
        Set ShipHDG to 0.
        set TargetHDG to 0.
        set TargetAlt to 100.
        Lock ShipFront to ship:facing:vector.
        Lock East to vcrs(up:vector,North:vector).
        Lock hdgVector to vxcl(up:vector,ship:facing:vector).
        set LnavMode to list(0,0,0).
        set VnavMode to list(0,0,0).
        set PreviousHDG to 0.
        set PreviousTime to time:seconds.
        set rollrate to 0.
        
	// AP Display offset , didn't implement 
       
        set apDisplayOffset to 4.

	// Autopilot Control
        set apPointer to 0.
        set TargetHDG to 0.
        set AP to False.
        set AT to False.
        set TargetSpeed to 100.
        set TargetThrottle to 0.
        set TargetPitch to 0.
        Set TargetVS to 0.
        set seekHDG to 0.
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
            set AileronPID to pidLoop(.0186,0.0011,.0042,-.5,.5).
            set RollPID to pidloop(0.135,0,.24,-3,3).
            set Turnrate to 0.
            set DesiredTurnRate to 0.
        
            // Pitch PID
            Set elevatorPitchPID to PIDLoop(.25,0.05,.12,-1,1). // -2,5 are relative to facing vector
            Set elevatorVSPID to PIDLoop(.073,0.06,0.022,-1,1). // -2,5 are relative to facing vector
            Set throttlePID to PIDloop(.065,0.004,0.28,0.02,1).
            Set NavPID to pidLoop(4.5,0,3.5,-45,45).
            Set NavPID:setPoint to 0.
            Set elevatorALTPID to PIDLoop(.13,0,0.04,-20,20).
		
		
    // Other Quick tweek variables
        
		
    //	DisplayStatic().
        apModeDisplay().
        APControlDisplay().
        updateLnavmode().
        updateVnavMode().
        set RollPID:setPoint to 0.
        set elevatorALTPID:setpoint to 0.
    Until gear and Lights
        {
        
            AttitudeUpdate().
            DisplayFunction().
            apModeDisplay().
            PowerControl().
            PitchControl().
            RollControl().
            userinput().
            wait 0.04.
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

	Declare Function RollControl
		{
			
			set TurnRate to (shipHDG-PreviousHDG)/(Time:seconds-PreviousTime).
			set PreviousTime to Time:seconds.
			Set PreviousHDG to shipHDG.
			if LnavMode[0]=1
			{
				
			//	set seekHDG to ArcSin(Round(Sin(TargetHDG-ShipHDG),3)).
				set rollPID:setPoint to 0.
				set SeekHDG to TargetHDG-ShipHDG.
				if SeekHDG >180
				{
					Set SeekHDG to SeekHDG-360.
				} else if SeekHDG<-180
				{
					set SeekHDG to SeekHDG +360.
				}
				set DesiredTurnRate to rollPID:update(time:seconds,-SeekHDG).
				set AileronPID:setPoint to DesiredTurnRate.
				set Ship:control:roll to AileronPID:update(time:seconds,TurnRate).
				
			} 
			else if LnavMode[1]=1 or LnavMode[2]=1
			{
				
				set SeekBearing to RunwayHDG-(shipHDG+targetFix:bearing).
				set NavHDG to  NavPID:update(time:seconds,-SeekBearing).
				set SeekHDG to RunwayHDG-NavHDG.
				set rollPID:setPoint to SeekHDG.
				set DesiredTurnRate to rollPID:update(time:seconds,ShipHDG).
				set AileronPID:setPoint to DesiredTurnRate.
				set Ship:control:roll to AileronPID:update(time:seconds,TurnRate).
                print "        SeekHDG : " + Round(SeekHDG) + "    " at (1,16).
			    print " Target Bearing : " + Round(SeekBearing,1) + "    " at (1,17).
				if TargetFix:distance<CloseFix:distance
				{
					GoAround().
                }
		    }
        }
	Declare Function PowerControl{
			if AT=1 
			{
                if Status="Flying"
                {
                    set throttlePID:setPoint to TargetSpeed.
			    	set TargetThrottle to ThrottlePID:Update(time:seconds,airspeed).
			    	set ship:control:mainthrottle to TargetThrottle.
                } else if Status="Landed"
                {
                    AG6 ON.
                    set ship:control:mainthrottle to .4.
                }
				
			}
			else 
			{
				set ship:control:mainthrottle to  TargetThrottle.
			} 
		}
    Declare Function AttitudeUpdate
		{
			if vang(hdgVector,east)<90 
				{
					set ShipHDG to  vang(hdgVector,north:vector).
				}
			else
				{
					set shipHDG to  360-vang(hdgVector,north:vector).
				}
			lock shipPitch to -(vang(up:vector,ship:facing:vector)-90).
			lock shipRoll to (vang(up:vector,facing:rightvector)-90).
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
			set counter to 0.
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
						set targetAlt to Round(targetAlt/10)*10-10.
					}
					if ch = "e"
					{
						set targetAlt to Round(targetAlt/10)*10+10.
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
       
