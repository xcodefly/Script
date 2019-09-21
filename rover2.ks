// Self driving Rover.
// For now, declare distance and Direction, later it will be geoCoordinates. 
Parameter Mode to "W".
Parameter MaxSpeed to 20.
Parameter TargetLocation to LatLng(2,164).
if Mode = "W"{
    set StartAngle to -60.
    set sweepAngle to 15.
} else if Mode = "N"
{
      set StartAngle to -45.
    set sweepAngle to 10.
}

set TargetSpeed to MaxSpeed.
set spot to list(list(0,0),List(0,0),list(0,0),list(0,0),list(0,0),List(0,0),List(0,0)).
set seekHdg to 0.
set ShipHDG to 0.
set TargetHDG to 270.
//set testlist to list (1,2,3,4,5).
set spotDistance to list(15, 30, 40, 60, 90,120, 160, 200).
set scoreweight to list(.3, .3,  .3, .25, .2,  .2,  .15, .1). //list(.4, .4,  .3, .3, .2,  .2,  .1, .1).
Lock east to vCrs(up:vector,north:vector).
Lock frontHDGV to vxcl(up:vector,ship:facing:vector).
Lock ShipPitch to round(90-vang(up:vector,ship:facing:vector),3).
Lock shipBank to Round(90-vang(up:vector,ship:facing:rightvector),3).
set evaluatedPower to 0.

// Pid LOOPS


set powerPID to pidLoop(.3,.1,.05,-1,1).
set BatteryCapacity to 0.
Set BatteryAmount to 0.
// Locks

Lock wheelThrottle to evaluatedPower.
set Cell to ship:partsTagged("Cell").


// Detecting ElectricCharge and FuelCell Array from list of resources.
List Resources in ShipRes.
set BatteryIndex to 0.
Set CellIndex to 0.
Set Counter to 0.

// Varaibles for Seeking Function
Set PreviousTrack to TargetLocation:heading.
Set PathCost to List(10,10,10,10,10,10,10,10,10).


// Listing resources in shipRes variables.
for Res in ShipRes
    {   
        if res:name = "ElectricCharge"
        {
            set BatteryIndex to Counter.
        }
        if Res:Name = "_FuelCell"
        {
            set CellIndex to Counter.
        }
        Set Counter to Counter+1.
    }

Lock BatteryAmount   to     ShipRes[BatteryIndex]:Amount.
Lock BatteryCapacity to     ShipRes[BatteryIndex]:Capacity.
Lock BatteryCharge to Round(BatteryAmount/BatteryCapacity*100).
//Brakes Off.
RCS off.
//brakes off.
Clearscreen.
until RCS
    {
        
        EvaluateSpot().
        HeadingControl(). // Must go below Evaluatedspeed so rover slowdonw during turn.
        BatteryStat().
    //     set EvaluatedSpeed to targetSpeed*evaluateSpot().
       // CLEARSCREEN.
        if TargetLocation:distance<100{
            set EvaluatedSpeed to 0.
            Brakes on.
            RCS on.
        }
            set powerPID:setpoint to EvaluatedSpeed.
            Lock evaluatedPower to powerPID:update(time:seconds,vdot(ship:velocity:surface,ship:facing:vector)).
            Print "            " at (16,0).
            print "      Heading : " + Round(shiphdg) + " | " + ROUND(HDGerror,2) +"  " at (0,0).
            print "        Pitch : " + Round(ShipPitch,1)+ "   " at (0,1).
            print "         Bank : " + Round(shipBank,1)+"  "at (0,2).
            Print "                " at (16,3).
            Print " Eval   Speed : " + EvaluatedSpeed + "|"+TargetSpeed at (0,3).
            Print "      Battery : " + BatteryCharge at (0,4).  
         //   Print "  Active Cell : " + shipRes[CellIndex]:amount+"/"+shipRes[CellIndex]:Capacity.
            Seektarget().
            Print "Direct Distance: "+Round(TargetLocation:distance)+"   " at (0,6).
            Print "Target Bearing : "+Round(TargetLocation:bearing)+ "   " at (0,7).
            Print "       Alt Diff: " + Round(TargetLocation:terrainheight-ship:Altitude) +"   " at (0,8).
        //    print PathCost at (0,10).
        wait .1.
       
    }
    ClearScreen.
   
    RCS OFF.
    brakes on.

// Spot array for 8 spots 
// evaluatespot(pitchDetal,rollDelta)
Declare Function evaluateSpot{
    set step to 0.
    set score to 0.
    set groundslope to Round(arctan(ship:body:geopositionof(ship:position+cos(shipHDG)*north:vector+sin(shipHDG)*east):terrainheight-ship:geoposition:terrainheight),2).
    for x in spot{
       set x[0] to round(ship:body:geopositionof(ship:position+cos(shipHDG)*spotDistance[step]*north:vector+sin(shipHDG)*spotDistance[step]*east):terrainheight-ship:geoposition:terrainheight-spotdistance[step]*tan(Groundslope),1).
        set step to step+1.
        set score to score + Min(3,abs(scoreweight[step]*x[0])).
       
        }
        set score to Min(7,Score).
        set score to log10(score +1).
        
        Lock EvaluatedSpeed to Max(3.5,(1-Round(score,2))*targetSpeed).
        set eBrakeAlt to round(ship:body:geopositionof(ship:position+cos(shipHDG)*20*north:vector+sin(shipHDG)*20*east):terrainheight-ship:geoposition:terrainheight-20*tan(Groundslope),1).
        if groundslope<-8 or abs(shipBank)>8
        {
            set EvaluatedSpeed to Min(4,evaluatedSpeed).
        }else if Groundslope<-5 or Abs(shipBank)>5
        {
            set EvaluatedSpeed to Min(10,evaluatedSpeed).
        }

        if abs(eBrakeAlt)>5 or groundslope<-25
        {
         //   set EvaluatedSpeed to 0.
           // Brakes on.
          //  Print " ****** Emergency Stop ****** ".
        } 
  
    } 

Declare Function BatteryStat{
    
        if BatteryCharge<60
        {
            if shipRes[CellIndex]:Amount<1
            {
                cell[0]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
        }
        if BatteryCharge<50
        {
            if shipRes[CellIndex]:Amount<2
            {
                cell[1]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
        }
        if BatteryCharge<40
        {
            if shipRes[CellIndex]:Amount<3
            {
                cell[2]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
        }
        if BatteryCharge<30
        {
            if shipRes[CellIndex]:Amount<4
            {
                cell[3]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
        }
        if BatteryCharge>85
        {
            if shipRes[CellIndex]:Amount=4
            {
                if shipRes[CellIndex]:Amount
                cell[3]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
            if shipRes[CellIndex]:Amount=3
            {
                if shipRes[CellIndex]:Amount
                cell[2]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
            if shipRes[CellIndex]:Amount=2
            {
                if shipRes[CellIndex]:Amount
                cell[1]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
            if shipRes[CellIndex]:Amount=1
            {
                if shipRes[CellIndex]:Amount
                cell[0]:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
            }
        }
    }

Declare Function HeadingControl{
     if vang(frontHDGV,east)<90
        {
            Lock ShipHDG to  vang(frontHDGV,north:vector).
        }else
        {
            Lock shipHDG to  360-vang(frontHDGV,north:vector).
        }
        lOCK SeekHDG to Max(-1,Min(1,(targetHDG-shipHDG)))*(5/(Groundspeed+.1)).
        // Order is important to the Rover doesn't turn too aggresively at higher speeed.
        // SeekHDG is slowing the rover and then SeekHDG is tweeked make shallow turn. 

        set HDGerror to ArcSin(Round(Sin(TargetHDG-ShipHDG),3)).
        if abs(HDGerror)>20
        {
            Set TargetSpeed to .2*MaxSpeed.
        }else
        {
            set TargetSpeed to MaxSpeed.
        }
        
        lock wheelsteering to shipHDG+seekHDG.
        if abs(shipPitch)>18 or Abs(shipBank)>18
        {
            set RightCorner to ship:body:geopositionof(ship:position+cos(shipHDG+20)*30*north:vector+sin(shipHDG+20)*30*east).
            Set LeftCorner to ship:body:geopositionof(ship:position+cos(shipHDG-20)*30*north:vector+sin(shipHDG-20)*30*east).
            
            set RightCornerHeight to round(RightCorner:terrainheight-ship:geoposition:terrainheight-20*tan(Groundslope),1).
            set LeftCornerHeight to round(LeftCorner:terrainheight-ship:geoposition:terrainheight-20*tan(Groundslope),1).
            set shipSpotHeight to ship:geoposition:Terrainheight.
            set corneraverageheight to (RightCornerHeight+LeftCornerHeight)/2.
            if shipSpotHeight<corneraverageheight
            {
                lock wheelsteering to shipHdg+(RightCornerHeight-LeftCornerHeight)/5.
                set EvaluatedSpeed to 2.   
            }else if shipSpotHeight>corneraverageheight
            {
                lock wheelsteering to shipHdg+(LeftCornerHeight-RightCornerHeight)/5.
                set EvaluatedSpeed to 2.
            }
        }
      
        
    }

  //                   cell:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
Declare Function SeekTarget
    {
        // Devide target distance in 10 parts
        set TargetBearing to TargetLocation:Bearing. 
        set TargetDistance to TargetLocation:distance.

        set ScanSector  to 750. 
        set resStep     to 25. // Distance Rover can potential Monitor.
        
        if ScanSector/3<TargetDistance
        {
            set ScanSector to Round(TargetDistance/3).
        }
        
    
        
      
        // Front Scan Angles are 0,-10,10,-20,20,-30,30,-40,40 (Total 9 paths.)
        set ScanAngle to StartAngle.
        set displayCounter to 0.
        // Clearing Gosting. 
        set x to 0.
        set res to ScanSector / resStep.
        set DistanceStack to list(0,0,0,0,0,0,0,0,0).
        set AltStack to list(0,0,0,0,0,0,0,0,0).
        set AngleStack to list(0,0,0,0,0,0,0,0,0).
        
        Until x>8
        {
            set SlopeCost to 0.
            Set AltCost to 0.
            set EvaluateAngle to ScanAngle-targetBearing.
            set EvaluateTrack to shipHDG+ScanAngle.
            set TargetSlope to ArcTan((TargetLocation:terrainheight-ship:Altitude)/TargetLocation:distance).
            set CostStep to 1.
            clearvecdraws().
            Vecdraw(TargetLocation:position,Up:Vector*10,Red,"Target",1,true).
            set PreviousAltCost to 0.
            // Altitude Penalties.
            Until CostStep>ResStep
            {
                set AltStepCost to ((ResStep-CostStep)/ResStep)*(ship:body:geopositionof(ship:position+cos(EvaluateTrack)*Res*CostStep*north:vector+sin(EvaluateTrack)*Res*CostStep*east):terrainheight-ship:geoposition:terrainheight-Res*CostStep*tan(TargetSlope)).

                if abs(AltStepCost<PreviousAltCost)
                {
                    set PreviousAltCost to AltStepCost. // Position Matters
                    set AltstepCost to AltstepCost*1.5.
                }
                else{
                    set PreviousAltCost to AltStepCOst.
                }
                set Altcost to AltCost + Abs(AltStepCost).
                set CostStep to CostStep+1.
               
            }
            set AltStack[x] to round(Altcost).
            
            Set CostStep to 1.
            Until CostStep>resStep
                {
                    set spotC to  ship:body:geopositionof(ship:position+cos(EvaluateTrack)*res*CostStep*north:vector+sin(EvaluateTrack)*res*CostStep*east).
                    
                    set nspot to spotC:body:geopositionof(spotc:position+north:vector).
                    set espot to spotc:body:geopositionof(spotC:position+east).
                    set slopeV to vcrs(spotC:position-nspot:position,spotC:position-espot:position).
                    set SpotSlopeCost to ((ResStep-CostStep)/ResStep)*vang(slopeV,up:vector).
                    set SlopeCost to slopeCost +SpotSlopeCost^2.
                    set CostStep to CostStep+1.
                    Vecdraw(spotC:position,up:vector,Yellow,"*",1,True).
                
                }
                set AngleStack[x] to round(SlopeCost).
            
            set DistanceCost to Scansector+(ship:body:geopositionof(ship:position + cos(EvaluateTrack)*ScanSector*north:vector +sin(EvaluateTrack)*ScanSector*east):position-TargetLocation:position):mag.
           
           
            set DistanceStack[x] to round(DistanceCost).
            


            // Old HUD
            //    Print "Cos:"+PathCost[x]+"   " at (0,X + 10).
             //   Print "DIS:"+Round(DistanceCOst)+"   "at (10,x+10).
             //   Print "Alt:"  +Round(AltCost)+"   " at (20,x+10).
              //  Print " Sl:"+ Round(.3*SlopeCost)+"   " at (28,x+10).
               // Print "Ang:"+Round(EvaluateTrack)+"   " at (40,x + 10).
         //   Print " Cost Ratio: " +Round( (1-(PathCost[4]/PathCost[x]))*100,2)+"%      " at (0,10+x).
          //  Print " Distance : " +Round( (((DistanceCost-TargetDistance)/TargetLocation:distance))*100,2)+"%      " at (18,10+x). 
            


            set x to x+1.
            set ScanAngle to ScanAngle+sweepAngle.
            
        }
        // Normalizing Stack.
        
        
        // Finding MinAlt and Angle

        set MinAngleCost to AngleStack[0].
        set MaxAngleCost to AngleStack[0].
        Set MinAltCost to AltStack[0].
        set MaxAltCost to altstack[0].
        set loopstep to 1.
        until LoopStep=8
        {   
            if AngleStack[LoopStep]<MinAngleCost
            {
                set MinAngleCost to angleStack[loopStep].

            } else if AngleStack[LoopStep]>MaxAngleCost
            {
                set MaxAngleCost to angleStack[loopStep].

            } 

            if AltStack[LoopStep]<MinAltCost
            {
                set MinAltCost to AltStack[loopStep].

            }else if AltStack[LoopStep]>MaxAltCost
            {
                set MaxAltCost to AltStack[loopStep].

            }



            Set LoopStep to Loopstep+1.
        }
        
        set loopStep to 0.
        Until loopStep=9
        {
            Set PathCost[LoopStep] to Round(DistanceStack[loopStep]/(TargetDistance/2),2)+    Round(1+(anglestack[loopStep]-MinangleCost)/(MaxAngleCost-MinangleCost),2)  + Round(.5+(Altstack[loopStep]-MinAltCost)/(MaxAltCost-MinAltCost),2).
            
            
            Print "Stacks : C " + pathcost[loopStep] +", D "+ round(DistanceStack[loopStep]/(TargetDistance/2),2)+", Ang "+ Round(1+(anglestack[loopStep]-MinangleCost)/(MaxAngleCost-MinangleCost),2)+", Alt "+Round(.5+(Altstack[loopStep]-MinAltCost)/(MaxAltCost-MinAltCost),2)+" /"+ScanSector+"      " at (0,10+loopStep).
            set Loopstep to loopstep+1.
        }
        
        
        
        //Finding the best


    
        set bestScore to Pathcost[0].
        set BestIndex to 0.
        Set CostStep to 1.
        
        // Edge Detection
        set RightCorner to ship:body:geopositionof(ship:position+cos(shipHDG+20)*30*north:vector+sin(shipHDG+20)*30*east).
        Set LeftCorner to ship:body:geopositionof(ship:position+cos(shipHDG-20)*30*north:vector+sin(shipHDG-20)*30*east).
        
        set RightCornerHeight to round(RightCorner:terrainheight-ship:geoposition:terrainheight-20*tan(Groundslope),1).
        set LeftCornerHeight to round(LeftCorner:terrainheight-ship:geoposition:terrainheight-20*tan(Groundslope),1).
        
        Vecdraw(RightCorner:position,up:Vector*(RightCornerHeight+5),RED,"Right Corner",1,True).
        Vecdraw(LeftCorner:position,up:Vector*(LeftCornerHeight+5),RED,"Left Corner",1,True).
        
        
        if LeftCornerHeight<-5
        {
                set PathCost[3] to PathCost[3]*2.
                set PathCost[5] to PathCost[5]*.1.
              //  brakes on.
        }
        if RightCornerHeight<-5
        {
                set PathCost[3] to PathCost[3]*.1.
                set PathCost[5] to PathCost[5]*2.
               // brakes on.
        }
        until CostStep=8
        {
            if PathCost[CostStep]<bestScore
            {
                Set BestIndex to CostStep.
                set bestScore to pathCost[CostStep].
            }
            set CostStep to CostStep+1.
        }

        set targetHDG to ShipHDG+(-40+10*(BestIndex)).
        Print Round(targetHDG)+" Index:"+BestIndex+ "  " at (5,20).
        Print Round(LeftCornerHeight,1)+":Corner:"+Round(RightCornerHeight,1)+"   " at (30,0).

    }