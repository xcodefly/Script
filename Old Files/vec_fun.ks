// temp file to draw vectors.
Function vv
{
    clearvecdraws().
    vecdraw(ship:position,targetV,red,"Target",1,true).
    vecdraw(ship:position,dv,green,"DeltaV",1,true).
    vecdraw(dv,targetV,blue,"desired",1,true).
    vecdraw(target:position,target:facing:vector,White,"target Port",1,true).
   
}