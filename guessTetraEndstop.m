% Given a set of measurements on the bed surface, guess
% the tower endstop errors that are most
% likely to have caused this distortion.
%
% DP are full tilted delta parameters as returned by getTetraParams()
% probe is (n,3) where columns are bed probe returns:
%       Commanded X, commanded Y, Z-probe 
function tp = guessTetraEndstop(DP,probe)

% initial data plot
figure(2);
hold off;
[c,ax,pFit] = plotParabolicFit(probe);
grid on;hold on;
plot3(probe(:,1),probe(:,2),probe(:,3),'+');
title('Parabolic fit to measurements, + is measurements, . are fit points');
pause(0.1);

GuessParams = getTetraParams(DP.p);  % re-compute from cfg params
GuessParams.probe = probe;
GuessParams.verbose = 0;
initialGuess = DP.p.endstop_distance  % cariage axis pos, mm along rail from z=0
initialStep = [1,1,1];
smallBox = [0,0,0]+0.004;
maxIterations=444;
[fit,nEval,status,err] = SimplexMinimize(...
              @(p) tetraGuessEndstopErr(p,GuessParams),...
   	      initialGuess, initialStep, smallBox, maxIterations)

% plot delta parameter fit
errZ = tetraEndstopErrZ(fit,GuessParams);
plot3(probe(:,1),probe(:,2),errZ+probe(:,3),'r.');
#legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
xlabel('X');ylabel('Y');
hold off

figure(3);
hold off;
fm = probe; fm(:,3) = fm(:,3)+errZ;
c = plotParabolicFit(fm);
grid on;hold on;
plot3(fm(:,1),fm(:,2),fm(:,3),'+');
hold off;
title('Parabolic Fit to simulated points');
xlabel('X');ylabel('Y');

figure(1);
hold off
plot3(probe(:,1),probe(:,2),probe(:,3),'+');
grid on;hold on;
plot3(probe(:,1),probe(:,2),errZ+probe(:,3),'rx');
legend('Measured','Fitted Points');
xlabel('X');ylabel('Y');
hold off

tp = GuessParams.p;
tp.endstop_distance = fit
tp = getTetraParams(tp);  % re-construct kinematic params
end

%-- ============================================ Error metric for minimization
function err = tetraGuessEndstopErr(p,DP)
    [err0,bad] = tetraEndstopErrZ(p,DP);
    nBad = sum(bad);
    e = err0(find(bad==0));
    err = mean(e .* e) * (1+nBad);  % add penalty for number of bad probes
    if (nBad > 0)
        badProbe = find(bad>0)'
        badProbe = DP.probe(badProbe',:)
    end
    disp([sqrt(err)*1000,p]);
end

% retrieve whole error vector
function [errZ,bad] = tetraEndstopErrZ(p,DP)
    err = 0;
    n = size(DP.probe,1);
    errZ = zeros(n,1);
    bad = int32(errZ);
    for i=1:n
        d0 = cart2tetra(DP.k,DP.probe(i,:));  % commanded position

        % insert endstop error to positions
        if !isreal(d0)
            bad(i)=1;
            d0 = abs(d0);
        end
        de = d0 + DP.p.endstop_distance-p;
        
        dz = tetra2cart(DP.k,de); % effector loc if endstops were at guess
        if !isreal(dz)
            bad(i) = 1;
        end
        errZ(i) = real(dz(3));
    end
end
