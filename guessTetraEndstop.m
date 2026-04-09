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
    global callCount;
    callCount = 0;

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
    initialGuess = gp.p.position_endstops  % cariage axis pos, mm along rail from z=0
    initialStep = [1,1,1];
    smallBox = [0,0,0]+0.004;
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp, @setTetraEndstop),...
   	      initialGuess, initialStep, smallBox, maxIterations)

    % plot delta parameter fit
    [err,errZ] = tetraFitErr(fit,PP,gp,@setTetraEndstop);
    figure(1); plotProbeFit(PP.probe, errZ); hold off;

    tp = gp.p;  % re-compute full parameters for fit
    tp.position_endstops = fit;
    tp = getTetraParams(tp);
end

% ---------- copy parameter vector into fields of parameter structure
function gp = setTetraEndstop(p,igp)
    gp = igp.p;
    gp.position_endstops = p;
    gp = getTetraParams(gp);  % re-build kinetic parameters
end
