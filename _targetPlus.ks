// File contain functions that will help get more information about the target ex. Mean Anomaly, eta to periapsis, etc. 
Declare function Target_anomalyAt
{
    parameter checkTime.
    Return target_v.
}

Declare function target_periapsis_eta
{
    set v to target:orbit:trueanomaly.
    set e to target:orbit:eccentricity.
    set E_v to arccos((e+cos(v))/(1+e*cos(v))).
    if v<180
        {
            set M to (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
        
        }
        else 
        {
            set M to 360 - (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
        }
        set t_periapsis to target:orbit:period/360*(360-M).
        return t_periapsis.

}

declare function target_positionAt
{
    Parameter testTime.
    Local shipV to velocityat(ship,testtime+time:seconds):orbit:normalized.
    local shipP to positionAt(ship,testtime+time:seconds).
    Local TargetP to positionat(target,testtime+time:seconds).
    set targetPosition to targetP-shipP.
    set targetDistance to 0.
    if vdot(shipV,targetPosition)<0
    {
        set targetDistance to targetPosition:mag*-1.

    }else
    {
         set targetDistance to targetPosition:mag.
    }
 //   Print round(targetDistance).
    Return targetDistance.
    

}

declare function target_orbit_info{
    
    Local v to target:orbit:trueanomaly.
    Local e to target:orbit:eccentricity.
    Local E_v to arccos((e+cos(v))/(1+e*cos(v))).
    if v<180
    {
        set M to (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
    }
    else 
    {
        set M to 360 - (E_v*Constant:degToRad-e*Sin(E_v))*constant:radToDeg.
    }
    set t_periapsis to target:orbit:period/360*(360-M).
    set t_apoapsis to t_periapsis-target:orbit:period/2.
    if t_apoapsis<0
    {
        set t_apoapsis to t_apoapsis+target:orbit:period.
    }
    
    set Target_Info to lexicon().
    target_Info:add("ETA_periapsis",t_periapsis).
    target_info:add("ETA_apoapsis",t_apoapsis).
    target_info:add("MeanAnomaly",M).

    return target_info.
}

Declare function target_Inclination_Match{
    // Find the angle between two orbits
    // take the normal of the orbi and crsproduct it 

        Local Target_node to lexicon().
        Local ship_normal to vcrs(ship:velocity:orbit,ship:position-body:position):normalized.
        Local target_normal to vcrs(target:velocity:orbit,target:position-body:position):normalized.
        Local dAngle to vang(ship_normal,target_normal).
        //   print "Orbit Angle : "+Round(angle,2) +"  " at (0,1).
        Local ANDN to vcrs(ship_normal,target_normal).
        local ship_position_5 to positionat(ship,time:seconds-0.5).
        if vang(ship:position-body:position,andn)<vang(ship_position_5-body:position,andn)
        {
            set ascNode to vang(ship:position-body:position,andn).
            set desNode to ascNode+180.
        }else
        {
            set ascNode to 360-vang(ship:position-body:position,andn).
            set desNode to ascNode-180.
        }
        target_node:add("ascNode",ascNode).
        target_node:add("desNode",desNode).
        target_node:add("dAngle",dAngle).
        // Finding Time to asc_anomaly
        local Asc_true_anomaly to mod(ascNode+ship:orbit:trueAnomaly,360).
        target_node:add("eta_asc_node",Round(etatrueAnomaly(Asc_true_anomaly),1)).
        target_node:add("eta_des_Node",Round(etatrueAnomaly(Asc_true_anomaly+180),1)).
        // check where to add the node
        // adjust inclination at slower speed.
        // Asc Node TrueAnomaly will be ascNode+trueAnomaly.
        inclinationNode(target_node,ship_normal).
        return target_node.
    // Find true anomaly to the target
    // Find time to That using eccentrcity anomaly and then mean anomaly.

}

function etaTrueAnomaly{
    Local Parameter setAnomaly.
    Local ecc_anomaly to EccAnomaly(setAnomaly).
    Local mean_anomaly to MeanAnomaly(setAnomaly).
    local eta_anomaly to etaMeanAnomaly(setAnomaly).
    return eta_anomaly.
}


function EccAnomaly {
    Local parameter v_anomaly.    //True anomaly
    set  ec to ship:orbit:eccentricity.   //eccentricity
    local   ecc_anomaly is  sqrt((1-ec)/(1+ec))	* tan(v_anomaly/2).                    // tan(E/2)
    return 2 * arctan(ecc_anomaly).
}

function MeanAnomaly
{
    Local Parameter ecc_anomaly.
    Local ec to Ship:orbit:eccentricity . 
    return ecc_anomaly - ec*sin(ecc_anomaly) * Constant:RadToDeg.
}

Declare Function etaMeanAnomaly{
    Local Parameter M.
    Local u to sqrt(constant:G*Body:mass/ship:orbit:semiMajorAxis^3).
    Return M*constant:degToRad/u+eta:periapsis.
}

Function inclinationNode
{
    local Parameter inc_node.
    local Parameter normal.
    Local adj_node to node(time:seconds,0,0,0).
    if velocityat(ship,inc_node:eta_asc_node):orbit:mag<velocityAt(ship,inc_node:eta_des_node):orbit:mag
    {
        set dV to -2*velocityAt(ship,time:seconds+inc_node:eta_asc_node):orbit:mag*sin(inc_node:dAngle/2).
        set nodeTime to time:seconds+inc_node:eta_asc_node.
    }else
    {
        set dV to 2*velocityAt(ship,time:seconds+inc_node:eta_asc_node):orbit:mag*sin(inc_node:dAngle/2).
        set nodeTime to time:seconds+inc_node:eta_des_node.
    }
    Local adj_node to node(nodeTime,0,dV,0).
    add adj_node.
}

