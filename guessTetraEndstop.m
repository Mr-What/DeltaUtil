% Given a set of measurements on the bed surface, guess
% the tower endstop errors that are most
% likely to have caused this distortion.
%
% PP are full tilted delta probe parameters as returned by getTetraParams(),
%    which were being used when the included probe results were measured.
%    These (n,3) probe commands when probe was triggered are included
%    along with the parameters.
% [IGP] -- optional Initial Guess Parameters to seed the search.  Default == PP.
%            We may want to implement a piecewise approach to finding
%            parameters, so that the initial guess may not be the
%            parameters used when the probe was measured.
%
%    probe is (n,3) where columns are bed probe returns:
%       Commanded X, commanded Y, Z-probe 
function tp = guessTetraEndstop(PP,IGP)

    if nargin < 2
        gp = getTetraParams(PP.p);
    else
        gp = getTetraParams(IGP);
    end

    if !isfield(PP,'pos')
        PP = getProbePositions(PP.p,PP.probe);  % append stepper positions
    end

    figure(2); [c,ax,pFit] = plotInitialProbe(PP.probe);  % initial data plot
    
    gp.verbose = 0;
    initialGuess = gp.p.endstop_distance  % cariage axis pos, mm along rail from z=0
    initialStep = [1,1,1];
    smallBox = [0,0,0]+0.004;
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraProbeErr(p,PP,gp, @tetraEndstopErrZ),...
   	      initialGuess, initialStep, smallBox, maxIterations)

    % plot delta parameter fit
    errZ = tetraEndstopErrZ(fit,PP,gp);
    figure(1); plotProbeFit(PP.probe, errZ); hold off;

    tp = gp.p;  % re-compute full parameters for fit
    tp.endstop_distance = fit;
    tp = getTetraParams(tp);
end

%-- ============================================ Error metric for minimization
function [errZ,bad] = tetraEndstopErrZ(p,pp,igp)
    err = 0;
    n = size(pp.probe,1);
    errZ = zeros(n,1);
    bad = int32(errZ);
    de = pp.p.endstop_distance - p;  % difference in endstops
    for i=1:n
        %d0 = cart2tetra(DP.k,DP.probe(i,:));  % commanded position
        %
        % insert endstop error to positions
        %if !isreal(d0)
        %    bad(i)=1;
        %    d0 = abs(d0);
        %end
        pos = pp.pos(i,:) + de;
        
        dz = tetra2cart(igp.k, pos); % effector loc if endstops were at guess
        if !isreal(dz)
            bad(i) = 1;
        end
        errZ(i) = real(dz(3));
    end
end
