// Self driving Rover.
// For now, declare distance and Direction, later it will be geoCoordinates. 
Parameter Mode to "W".
Parameter MaxSpeed to 20.
Parameter TargetLocation to LatLng(2,164).
set NorthPole to LatLng(0,0).

set TargetSpeed to MaxSpeed.
set spot to list(list(0,0),List(0,0),list(0,0),list(0,0),list(0,0),List(0,0),List(0,0)).
set seekHdg to 0.
set ShipHDG to 0.
set TargetHDG to 270.
//set testlist to list (1,2,3,4,5).
set spotDistance to list(15, 30, 40, 60, 90,120, 160, 200).
set scoreweight to list(0.3, 0.3,  0.3, 0.25, 0.2,  0.2,  0.15, 0.1). //list(.4, .4,  .3, .3, .2,  .2,  .1, .1).
Lock east to vCrs(up:vector,north:vector).
Lock frontHDGV to vxcl(up:vector,ship:facing:vector).
Lock ShipPitch to round(90-vang(up:vector,ship:facing:vector),3).
Lock shipBank to Round(90-vang(up:vector,ship:facing:rightvector),3).
set evaluatedPower to 0.

// Pid LOOPS


set powerPID to pidLoop(0.3,0.1,.05,-1,1).
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
        wait 0.1.
       
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
        if vdot(frontHDGV,east)>0
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
            Set TargetSpeed to .1*MaxSpeed.
        }else
        {
            set TargetSpeed to MaxSpeed.
        }
        
        lock wheelsteering to shipHDG+seekHDG.
        
      
        
    }

  //                   cell:getmodule("ProcessController"):doAction("Start/Stop Fuel Cell",True).
Declare Function SeekTarget
    {
        
    }