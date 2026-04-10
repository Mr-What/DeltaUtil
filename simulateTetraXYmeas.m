%  generate simulated test print measurements for a tilted_delta (tetra) printer
%
%  tp -- tetra printer params, with errors
%  p0 -- ideal printer params
%  pm -- ideal print measurements, with standard naming conventions  
function xy = simulateTetraXYmeas(tp, p0, pm)
    fn = fieldnames(pm);
    nField = length(fn);
    xy = struct();
    for m = 1:length(fn)
        nam = fn{m};
        if length(nam) != 4, continue; end
        if (nam(1) != 'p'), continue; end
        if (nam(4) != 'o') && (nam(4) != 'i'), continue; end
        p = pm.(nam);
        xyz1 = simTetraCartErr([p(1,:),0], tp.k, p0.k);
        xyz2 = simTetraCartErr([p(2,:),0], tp.k, p0.k);
        d = xyz1 - xyz2;
        d = norm(d(1:2));
        xy.(nam(2:4)) = d;
    end
end

% return the actual effector location when commanded to
% location xyz0 using tilted_delta (tetra) kinematic parameters tp,
% when actual, ideal, kinematic parameters were p0
function xyz = simTetraCartErr(xyz0,tp,p0)
%disp([tp.base(3,2), p0.base(3,2)]);
    tet = cart2tetra(tp,xyz0); % commanded stepper locations
    tetTrue = commandedTowerPositions(tp, tet, p0); % adjust for stepper mismatch
    %disp(tet-tetTrue)
    xyz = tetra2cart(p0, tetTrue);  % simulated/actual effector position
    %disp([xyz0;xyz])
end

