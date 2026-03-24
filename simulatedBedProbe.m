% given ideal tilted_delta kinematic parameters, k0,
% and estimated parameters, ke
% compute the z ordinate found by probe.
%    I will assume that they use inverse kinematic equation to probe in Z
%    not arbitrary moving servos down
function z = simulatedBedProbe(x0,y0,z0,ke,k0)
    dz = -1;
    zA = z0;
    xyzA = actualCart([x0,y0,zA],ke,k0);
    if (xyzA(3) < 0)
        disp('WARNING: initial bed probe height already below bed!');
        dz = -dz;
    end
    zB = zA + dz;
    xyzB = actualCart([x0,y0,zB],ke,k0);
    while (xyzA(3) * xyzB(3) > 0)
        zA=zB; xyzA=xyzB;
        zB = zA + dz;
        xyzB = actualCart([x0,y0,zB],ke,k0);
    end
    % found neighbors of zero crossing
    %disp('Crossing bounded by : ');
    %disp([zA,xyzA]);
    %disp([zB,xyzB]);%keyboard

    % interval half to refine bed level crossing location
    while (abs(zA-zB) > 0.0003)
        zC = (zA + zB)/2;
        xyzC = actualCart([x0,y0,zC],ke,k0);
        if (xyzC(3) * xyzA(3) <= 0)
            xyzB=xyzC; zB=zC;
        else
            xyzA=xyzC; zA=zC;
        end
    end
    z = (zA + zB) / 2;
end

function xyz = actualCart(xyz0,ke,k0)
    ds = ke.endstop - k0.endstop;  % servo reporting error
    tet = cart2tetra(ke,xyz0);
    if !isreal(tet)
        xyz = xyz0;
        xyz(2)=0;
        return
    end
    tet = tet - k0.endstop + ke.endstop;  % add endstop error
    xyz = tetra2cart(k0,tet);
    %disp([xyz0(3),xyz]);
end
