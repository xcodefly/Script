// Calculate Ground Slope.

Parameter TargetLoc to LatLng(2,165).
Lock east to vcrs(up:vector,north:Vector).
Lock FacingLevel to vxcl(up:vector,ship:facing:Vector).
set shipHDG to 0.
set NextHDG to 0.   
Clearscreen.
clearvecdraws().
// Common Variables for the program. 
Set MaxSpeed to 5.
Lock targetBearing to Round(TargetLoc:Bearing,2).
Lock targetDistance to (Round(targetLoc:distance)).
lock shipVelocity to vdot(ship:velocity:surface,ship:facing:vector).
set pathQue to Queue().

Set PathStep to 30 .

set PathTarget to ship:geoposition.


if vdot(FacingLevel,east)>0
{
    Lock ShipHDG to  vang(FacingLevel,north:vector).
}
else
{
    Lock shipHDG to  360-vang(FacingLevel,north:vector).
}




Lock L1 to Ship:body:geopositionof(ship:position + 10*ship:facing:vector - 5*ship:Facing:rightvector).
Lock R1 to Ship:body:geopositionof(ship:position + 10*ship:facing:vector + 5*ship:Facing:rightvector).
Lock F1 to ship:body:geopositionof(Ship:position + 5*ship:facing:vector).


Set LastTrack to List(f1,ShipHDG).


// Main Loop
RCS off.
Until RCS
{
    EvaluatePath().
    HDGControl().
    ShipAttitude(). // Must be the last function before any inputs to correct any unusual attitude. 
   
    HUD().
   
    

    // Disabled autodrive.
    
      lock wheelThrottle to Max(-1,Min(1,(TargetSpeed-shipVelocity) )).
    Wait .01.
}
Declare Function HDGControl
    {
        Print "  "  at (30,8).
        
        Lock SeekHDG to Round(PathTarget:bearing,1).    
        if PathTarget:distance<10 and pathQue:length>1 or abs(seekHDG)>60
        {
             
            Print "**" at  (30,8). 
            set Current to PathQue:pop.
          
            set PathTarget to Current[0][0].
            Lock nexthdg to Next[0][1].
            lights off.
        }
    

        Print "Distance : " + Round(PathTarget:distance) + "  "at (25,7).
        Print " Bearing : " + round(PathTarget:Bearing) + "  "at (25,8).  
     //   vecdraw(PathTarget:position,UP:Vector,Yellow,"Target",1,True).
        
        if abs(SeekHDG)>3
        {
            Set TargetSpeed to Min(Maxspeed,Max(3,MaxSpeed/Abs(seekHDG)*7+.2)).
        }else
         {
             set TargetSpeed to MaxSpeed.
         }
        lock wheelsteering to shipHDG +Max(-1,Min(1,SeekHDG/2.5))*(4/Ship:Groundspeed).

    }
Declare Function EvaluatePath
    {
      //   Clearvecdraws(). 
        
        if pathQue:length<1or Lights
        {
        //    clearvecdraws().
            
            set BestTrack to AddSector(LastTrack).
            pathQue:push(List(BestTrack)).
            set LastTrack to BestTrack.
            Vecdraw(LastTrack[0]:position,up:vector*5,Red,"*",1,True).
           Print " Best Track : " + LastTrack[1] at (20,15).
           
        }
       
      //  Vecdraw(targetLoc:position,up:vector*5,Red,"Target",1,True).
      //  vecdraw(L1:Position,up:vector,Red,"Left",1,true).
      // Vecdraw(R1:position,up:vector,Red,"Right",1,true).
    
    

    }
// Must be just befor any corrective Shipinputs to correct for unusual attitude. 

Declare Function ShipAttitude
    {
    
        Set ShipPitch   to Round(90-Vang(ship:facing:vector,up:vector)).
        Set ShipBank    to Round(Vang(ship:facing:rightVector,Up:vector)-90).
        Set BankCorrection to 0.
        // Calculating slope and Direction of slope.
        Set SlopeV      to vcrs(l1:position-ship:geoposition:position,R1:Position-Ship:geoposition:Position).
        Set SlopeAng    to vang(up:vector,SlopeV).
        Set SlopeDir    to vDot(north:vector,vxcl(up:vector,SlopeV)).


        if Abs(shipBank)>18
        {
            
            if shipPitch > 0
            {
                set BankCorrection to - shipBank/Abs(ShipBank)*.8*abs(shipBank).
            }
            else{
                set BankCorrection to shipBank/Abs(ShipBank)*.08*abs(shipBank).
            }

         //   vecdraw(ship:position+10*ship:facing:vector,ship:facing:rightvector * BankCorrection , Blue, "F", 1, true).
            
        }   
    }
Declare Function HUD{
        Print "   HDG : " + Round(SHipHDG) + " ["+SeekHDG+ "] "+"Nxt HDG : " +round(NextHDG)   +"  "  at (3,0).
        Print " Pitch : " + ShipPitch   +"  "       at (3,1).
        Print "  Bank : " + ShipBank    +"  ]"  + BankCorrection +"]   " at (18,1).
        Print " Speed : " +round(shipVelocity,0)+"["+Round(TargetSpeed)+"]  " at (3,2).
        //Target Info - Line 5
        Print "----- Target -----" at (0,5).
        Print " Bearing : " + Round(TargetBearing) + "   " at (0,6).
        Print " Distance: " + targetDistance + "  " at(0,7).


        // Score HUD  - Line 5
        Print "----- Score -----" at (25,5).
        Print " Path Q  : " + pathQue:length + " "at (25,6).
        
      //  Print "Distance : " + Round(Next[0][0]:distance) at (25,7).
      //  Print "     HDG : " + round(next[0][1]) at (25,8).
    

    }



Declare Function addSector
    {
        Parameter anchorSpot.
        set AnchorTrk to AnchorSpot[1].
        set AnchorGeo to AnchorSpot[0].
        set anchorDistance to (AnchorGeo:position - TargetLoc:Position):Mag.
        Set counter         to 0.
        set ScanStep to 37.
        Set ScanRes to 3.
        set ScoreList to List().
        set DistanceList to List().
        set SlopeList to List().
        set GeoList to List().  
        set EvalTrackList to List().
        set EvalSpot to List(List()).
        // EvalSpot is (GeoPosition,Distance,,Score)
        Until counter = ScanStep
        {
           // clearvecdraws().
            set EvalTrK to AnchorTrk + ScanRes*(Counter-(ScanStep-1)/2).
            set EvalTrk to Mod(evalTrk+720,360).
            set geoCandidate to  Ship:body:geopositionof(AnchorGeo:position + PathStep*Cos(EvalTrk)*North:Vector + PathStep*Sin(EvalTrK)*east).
            set PathAdvance to anchorDistance - (geoCandidate:position - TargetLoc:Position):Mag.
           
            //  Slope Penalty - it the slope changes aggresively.
            set leftSpot  to  Ship:body:geopositionof(GeoCandidate:position - 10*Cos(EvalTrk+90)*North:Vector - 10*Sin(EvalTrK+90)*east).
            set RightSpot to  Ship:body:geopositionof(GeoCandidate:position + 10*Cos(EvalTrk+90)*North:Vector + 10*Sin(EvalTrK+90)*east).
            set FrontSpot to Ship:body:geopositionof(GeoCandidate:position + 10*Cos(EvalTrk)*North:Vector + 10*Sin(EvalTrK)*east).
            set LeftSlopeV to leftspot:position-GeoCandidate:position.
            set RightSlopeV to rightspot:position-GeoCandidate:position.
            set CenterSlopeV to FrontSpot:position-GeoCandidate:position.
            set ROllSlopeV to RightSlopeV-LeftSlopeV.
            
            set slopeV to vang(UP:vector,Vcrs(LeftSlopeV,CenterSlopeV))^1.2+vang(UP:vector,Vcrs(RightSlopeV,CenterSlopeV))^1.2+vang(ship:facing:rightVector,RightSLopeV-leftSlopeV)/10.
            // trun dampning. 
            set slopeV to slopeV + abs(ScanRes*(Counter-(ScanStep-1)/2))/10.
            
           
           
           
           
        //   vecdraw(geoCandidate:position,up:vector,green,"candidiate",1,true).
         //   vecdraw(leftspot:position,up:vector,white,"left",1,true).
         //   vecdraw(RightSpot:position,up:vector,red,"right",1,true).
         //   Print " EvalTrack   "+ Evaltrk at (1,25+Counter).
         //   Print " Anc track " + anchorTrk at (15,25+Counter).
        //   Print " Slope v " + (-SlopeV) at (25,30+Counter).
            ScoreList:add(PathAdvance-SlopeV).
            // can be removed if I an tune with extra loop.
            DistanceList:add(PathAdvance).
            SlopeList:add(slopeV).
            geoList:add(geoCandidate).
            EvalTrackList:add(EvalTrk).
            set Counter to Counter+1.
          // wait 2.
        }
        // Normalizing slope
        set Counter to 0.
        set MaxSlope to Slopelist[0].
       
        // Insert all values in List.
        set Counter to 0.
        Until Counter = ScanStep
        {
            ScoreList:add(DistanceList[counter]*2+slopeList[Counter]).
            set counter to counter+1.
        }
        set Counter to 0.
        set bestIndex to 0.
        Set bestscore to ScoreList[0].
        Until Counter = ScanStep
        {
            if scorelist[Counter]>BestScore
            {
                set BestIndex to Counter.
                Set BestScore to scorelist[Counter].
                
            }
            Print " Score "+round(ScoreList[counter],1) at (2,15+Counter).
            set Counter to Counter+1.
          //  wait 0.1.
        }



        Set BestCandidate to List(geolist[bestIndex],EvalTrackList[bestindex]).
      

        Return BestCandidate.
    }