% Given a set of measurements on the bed surface,
%   [optional] test print measurements,
%   and associated probe parameters, pp,
% compute the error metric for guess parameters, gp
%
% Provide function fSetParams to set selected
% parameters in gp for the given parameter vector to evaluate
function [err,errZ,badZ,errXY,badXY] = tetraFitErr(p, pp, igp, fSetParams)
    gp = fSetParams(p,igp);  % copy parameter vector to standard param struct
    [err,errZ,badZ] = tetraProbeErr(pp.k, pp.pos, gp.k);
    if isfield(pp,'measXY')
        [mse,errXY,badXY] = tetraPrintErr(pp.k, pp.measXY, gp.k);
        err = err * mse;
    else
        errXY=1;
        badXY=0;
    end
    %fprintf(2,'\n');
    global callCount;
    callCount = callCount+1;
    fprintf(1,'%4d %.6g \t',callCount, err); disp(p);
end

% pos is commanded tower location at probe trigger
function [err, errZ, bad] = tetraProbeErr(pk, pos, gk)
    err = 0;
    n = size(pos,1);

    % update tower positions for differences in stepper calibration, if any.
    tet = commandedTowerPositions(pk, pos, gk);

    m = 1;
    errZ = zeros(n,1);
    bad = int32(errZ);
    for j=1:n
        dz = tetra2cart(gk, tet(j,:));  % guess at actual effector position
        if !isreal(dz)
            bad(j) = 1;
        end
        errZ(j) = real(dz(3));
    end
    nBad = sum(bad);

    if nBad > 0
        err = errZ(bad == 0);
        err = sqrt(mean(err .* err)) * (nBad+1);  % penalty of out of envelope probe
    else
        err = sqrt(mean(errZ .* errZ));
    end
    %fprintf(2,'Bed Probe RMSE=%.6g',err);
end

% pk - parameters used for print
% pm - measurements of print
% gk - guess at better parameters to use for print.
function [err, errXY, bad] = tetraPrintErr(pk, pm, gk)
    % update tower positions for differences in stepper calibration, if any.
    twr1 = commandedTowerPositions(pk, pm.twr(:,1:3), gk);
    twr2 = commandedTowerPositions(pk, pm.twr(:,4:6), gk);
    
    err = 0;
    n = size(pm.twr,1);
    m = 1;
    errXY = zeros(n,1);
    bad = int32(zeros(n,1));
    for j=1:n
        xyz1 = tetra2cart(gk, twr1(j,:));  % guess at actual effector position
        xyz2 = tetra2cart(gk, twr2(j,:));  % guess at actual effector position
        if (isreal(xyz1) && isreal(xyz2))
            simulatedDistance = norm(xyz1(1:2) - xyz2(1:2));
            measuredDistance = pm.dist(j);
            errXY(j) = measuredDistance - simulatedDistance;
        else
            bad(j)=1;
        end
    end
    nBad = sum(bad);%keyboard
    if nBad > 0
        err = errXY(find(bad == 0));
        err = mean(err .* err) ^ (nBad+1);  % penalty for out of envelope probe
    else
        %err = mean(errXY .* errXY); % more weight than bed probe errors
        err = sqrt(mean(errXY .* errXY));
    end
    %fprintf(2,'\tXY measurement MSE=%.6g',err);
    %hold off; plot(errXY,'x'); grid on; ginput(1)
end
