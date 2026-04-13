% Given a set of measurements of the bed surface,
% and an optional set of calibration print measurements, guess
% a parameter set more likely to explain these distortions.
%
%    PP    -- Full parameters used for the probe, ammended with probe
%             and carriage position data, returned by getProbePositions()
%             and optionally a set of calibration print measurements,
%             and their expected values.
%             We usually store this data as .m code that
%             defines all the measurements, which can be
%             loaded by loadAsStruct(fileName.m)
%
%    [IGP] -- Configuation parameters, for the initial guess.
%             Default is same as PP, but in some cases, where
%             partial optimizations are performed in sequence from
%             a single set of probe data, some of the parameters
%             used in this optimization may not be the same as ones
%             used for the original probe(s).
%-
function tp = guessTetraRadiusEndstop(PP,IGP)
    global callCount;
    callCount = 0;  % tetraFitErr() will count number of calls in SimplexMinimize

    % ----- initial data plot
    figure(2); [c,ax,pFit] = plotInitialProbe(PP.probe);

    if nargin < 2
        gp = getTetraParams(PP.p);
    else
        gp = getTetraParams(IGP);
    end
    gp.verbose = 0;

    initialGuess = [gp.p.position_endstops, mean(gp.p.delta_radius)];
    initialStep = [1,1,1,1];
    smallBox = [0,0,0,0]+0.04;
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraRadiusEndstop),...
   	initialGuess, initialStep, smallBox, maxIterations)

    % check results with random perturbation?
    %%initialGuess = fit + (rand(1,4)-.5) * .2;
    %finalStep = fit - initialGuess
    %finalStepLen = norm(finalStep)
    %randStep = (finalStep/finalStepLen) + (rand(1,4)-.5) * .1;
    %randStep = finalStepLen*.05 * randStep/norm(randStep)
    %initialGuess = fit + randStep
    initialGuess = fit + 0.04 * (rand(1,4)-.5) .* (initialGuess - fit)
    callCount=0;  % tetraFitErr will count number of calls in SimplexMinimize
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraRadiusEndstop),...
   	initialGuess, initialStep*.1, smallBox*.1, maxIterations)
    
    % return refined tetra (tilted) parameter set
    tp = setTetraRadiusEndstop(fit,gp);

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,@setTetraRadiusEndstop);
    pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(PP.probe,errZ); hold off;
end

% --- copy parameters from search vector over to kinetic param struct
function gp = setTetraRadiusEndstop(p,igp)
    gp = igp.p;
    gp.delta_radius = [0,0,0] + p(4);
    gp.position_endstops = p(1:3);
    gp = getTetraParams(gp);  % re-build kinematic params
end
