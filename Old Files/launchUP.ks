set oldThrust to 0.
set autoSteer to Heading(90,90).
set aThrottle to 0.
Lock steering to autoSteer.
Lock throttle to aThrottle.

set tPID to pidloop(0.1,0.02,0.02,0.6,1).


Declare Function AutoStage
{
	if availablethrust < 1 or availablethrust<oldThrust*.95
	{
		SET athrottle to 0.
		wait 0.1.
		stage.
		Print "Staging..".
		wait 0.1.
		set oldThrust to availablethrust.
	}
}
set tPID:setpoint to 270.
until gear
{
  //  autostage().
    set athrottle to tPID:update(time:seconds,airspeed).
    wait 0.01.
}