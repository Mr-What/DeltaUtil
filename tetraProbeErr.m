% Given a set of measurements on the bed surface,
%   and associated probe parameters, pp,
% compute the error metric given the error function and
% guess parameters, gp
function err = tetraProbeErr(p, pp, gp, ferr)
    [err0,bad] = ferr(p,pp,gp);
    nBad = sum(bad);
    e = err0(find(bad==0));
    err = mean(e .* e) * (1+nBad);  % add penalty for number of bad probes
    if (nBad > 0)
        badProbe = find(bad>0)'
        badProbe = pp.probe(badProbe',:)
    end
    disp([sqrt(err)*1000,p]);
end
