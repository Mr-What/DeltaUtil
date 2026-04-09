% adjust tower positions for any stepper calibration err
%      semi-hand optimized since this code is inside minimization search
%
%   pk   -- kinetic parameter set used to compute tower stepper position
%   pos  -- tower stepper positions
%   gk   -- candidate guess (or true) kinetic parameters
%
% return : pos adjusted for mis-match in stepper parameters
%              non-physical location, but real, if there is an error
function tet = commandedTowerPositions(pk, pos, gk)
    de = gk.endstop - pk.endstop;
    endstopsMatch = sum(abs(de)) < 0.00001;
    scaleMatch =    sum(abs(pk.mmPerRot - gk.mmPerRot)) < 0.000001;
    if scaleMatch
        if endstopsMatch
            tet = pos;  % matching stepper calibration, no change
        else % correct for mis-matched endstop locations only
            tet = [pos(:,1) - de(1), ...
                   pos(:,2) - de(2), ...
                   pos(:,3) - de(3)];
        end
    else % scales mis-matcghed.  usually belt stretch
        nRot1 = (pk.endstop(1) - pos(:,1)) / pk.mmPerRot(1); 
        nRot2 = (pk.endstop(2) - pos(:,2)) / pk.mmPerRot(2); 
        nRot3 = (pk.endstop(3) - pos(:,3)) / pk.mmPerRot(3);
        tet = [gk.endstop(1) - (nRot1 * gk.mmPerRot(1));...
               gk.endstop(2) - (nRot2 * gk.mmPerRot(2));...
               gk.endstop(3) - (nRot3 * gk.mmPerRot(3))];
    end
end
