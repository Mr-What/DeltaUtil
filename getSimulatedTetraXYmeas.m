%  generate simulated test print measurements for a tilted_delta (tetra) printer
%
%  tp -- tetra printer params, with errors
%  p0 -- ideal printer params
%  pm -- ideal print measurements, with standard naming conventions  
function xy = getSimulatedTetraXYmeas(tp, p0, pm)
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
        xy.(nam(2:4)) = norm(d(1:2));
    end
end
