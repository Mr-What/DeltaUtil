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
    callCount = 0;

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
    smallBox = [0,0,0,0]+0.004;
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraRadiusEndstop),...
   	initialGuess, initialStep, smallBox, maxIterations)

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,@setTetraRadiusEndstop);
    pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(PP.probe,errZ); hold off;

    % return refined tetra (tilted) parameter set
    tp = gp.p;
    tp.position_endstops = fit(1:3);
    tp.delta_radius = [0,0,0] + fit(4);
    tp = getTetraParams(tp);  % re-construct kinematic params
end

% --- copy parameters from search vector over to kinetic param struct
function gp = setTetraRadiusEndstop(p,igp)
    gp = igp.p;
    gp.delta_radius = [0,0,0] + p(4);
    gp.position_endstops = p(1:3);
    gp = getTetraParams(gp);  % re-build kinematic params
end

% -------- compute error vector for delta_radius and endstops
%function [errZ,bad] = tetraRadiusEndstopErrZ(p,pp,igp)
%    err = 0;
%    n = size(pp.probe,1);
%    errZ = zeros(n,1);
%    bad = int32(errZ);
%    dEndstop = pp.p.endstop_distance - p(1:3);
%    gp = igp.p;
%    gp.delta_radius = [0,0,0] + p(4);
%    gp = getTetraParams(gp);  % re-build kinematic params
%    for i=1:n
%        % call getProbePositions to pre-compute this:
%        %d0 = cart2tetra(pp.k,pp.probe(i,:));  % commanded position
%        %if !isreal(d0)
%        %    bad(i)=1;
%        %    d0 = abs(d0);
%        %end
%
%        % insert endstop error to commanded stepper positions
%        de = pp.pos(i,:) + dEndstop;
%
%        % get effector location if servos were commanded as found above
%        % but using the refined guess parameters.
%        % Ideally dz==0 if the guessed parameters were correct
%        dz = tetra2cart(gp.k,de); % effector loc if endstops were at guess
%        if !isreal(dz)
%            bad(i) = 1;
%        end
%        errZ(i) = real(dz(3));
%    end
%end
