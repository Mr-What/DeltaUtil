% Given a set of measurements on the bed surface,
% made with the given tilted delta parameters,
% guess the delta_radius which is most likely to have 
% caused this distortion.
%
% probe data is (n,3) where columns are:
%     commanded X,  commanded Y,  probed Z
%
% [IGP]  -- initial guess delta config, if not same as PP
%
% RETURN:  revised parameter set
function tp = guessTetraRadius(PP,IGP)

% retrieve full parameter set for initial guess
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
    initialGuess = mean(gp.p.delta_radius);
    initialStep = 1;
    smallBox = 0.002;
    maxIterations = 222;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraProbeErr(p, PP, gp, @tetraRadiusErrZ),...
   	initialGuess, initialStep, smallBox, maxIterations)
    tp = gp.p;  % re-compute full kinematic params
    tp.delta_radius = [0,0,0] + fit;
    tp = getTetraParams(tp);  % re-compute kinematic params

    % plot delta parameter fit
    errZ = tetraRadiusErrZ(fit,PP,gp);
    figure(1); plotProbeFit(PP.probe, errZ); hold off
end

%-- ============================================ Error metric for minimization

% retrieve whole error vector
function [errZ,bad] = tetraRadiusErrZ(p,PP, igp)
    err = 0;
    tp = igp.p;
    tp.delta_radius = [0,0,0] + p;
    tp = getTetraParams(tp);  % re-compute kinematic parameters
    n = size(PP.probe,1);
    errZ = zeros(n,1);
    bad = int32(errZ);
    for i=1:n
        %d0 = cart2tetra(DP.k,DP.probe(i,:)); % commanded servo pos
        %if !isreal(d0)
        %    bad(i)=1;
        %    d0 = abs(d0);
        %end
        dz = tetra2cart(tp.k, PP.pos(i,:)); % cart from guess parameters
        if !isreal(dz)
            bad(i)=1;
            dz = real(dz);
        end
        errZ(i) = dz(3);
    end
end
