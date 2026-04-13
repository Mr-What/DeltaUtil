% Given a set of measurements on the bed surface,
% made with the given tilted delta parameters,
% guess the delta_radius (R) which is most likely to have 
% caused this distortion.
%
% probe data is (n,3) where columns are:
%     commanded X,  commanded Y,  probed Z
%
% PP        -- probed parameters.  Parameters used for the probe
% PP.probe  -- probe data
% [IGP]     -- initial guess parameters, if not same as PP
%
% RETURN:  revised parameter set
function tp = deltaRefineR(PP,IGP)
    global callCount;
    callCount = 0;
    
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
        @(p) tetraFitErr(p, PP, gp, @setTetraRadius),...
   	initialGuess, initialStep, smallBox, maxIterations)
    tp = gp.p;  % re-compute full kinematic params
    tp.delta_radius = [0,0,0] + fit;
    tp = getTetraParams(tp);  % re-compute kinematic params

    % plot delta parameter fit
    [err,errZ] = tetraFitErr(fit,PP,gp,@setTetraRadius);
    %errZ = tetraRadiusErrZ(fit,PP,gp);
    figure(1); plotProbeFit(PP.probe, errZ); hold off
end

% set printer parameters from simplex search vector
function gp = setTetraRadius(p,igp)
    gp = igp.p;
    gp.delta_radius = [0,0,0] + p;
    gp = getTetraParams(gp);  % re-build kinematic params
end
