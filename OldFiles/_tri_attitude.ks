

// Locks for ship attitude and directions.

lock east to vcrs(up:vector,north:Vector).
lock frontHDGV to vxcl(up:vector,facing:vector).
lock bank to vang(up:vector,facing:rightVector)-90.
lock pitch to 90-vang(up:vector,facing:vector).

// **** ShipTarget lexicon and ShipAtt lexicon are inherited from the '_tri_control'. This will need fixing, 




Declare Function update_Att
{
    set shipATT:bank to bank.
    set shipATT:pitch to pitch.
    set shipATT:HDG to hdg().
}

Declare Function HDG
	{
        if vang(frontHDGV,east)<90 
		{
			set ShipHDG to  vang(frontHDGV,north:vector).
		}else
		{
			set shipHDG to  360-vang(frontHDGV,north:vector).
        }
        return shipHDG.
    }
