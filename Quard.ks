// This scrip it used to find to fly the Quard Copter without any stabilization.

// Find the engine at all for corners.

run "_quard_control.ks".
run "_quard_HUD.ks".
run "_quard_Input.ks".


lock east to vcrs(up:vector,north:Vector).
lock frontHDGV to vxcl(up:vector,facing:vector).

lock bank to vang(up:vector,facing:rightVector)-90.
lock pitch to 90-vang(up:vector,facing:vector).

clearscreen.
set shipATT to lexicon().
set shipTarget to lexicon().
gear off.
shipTarget:add("RPM",100).
shipTarget:add("ALT",altitude+0.5).
shipTarget:add("Pitch",0).
shipTarget:add("Bank",0).
shipTarget:add("HDG",HDG).

shipAtt:add("Pitch",0).
shipAtt:add("Bank",0).
shipAtt:add("HDG",0).





// Basic takeoff using.

// Main Loop
Until gear
{
    quard_Basic(shipAtt,shipTarget).
    userInput_Basic(shipTarget).
    hud_Basic(shipATT,shipTarget).


    
    update_att().
    wait 0.04.
}

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