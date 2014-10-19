% Given a set of measurements on the bed surface, guess
% the tower endstop errors that are most
% likely to have caused this distortion.
%
% Assumes delta bed coordinates are:
%
%      +Y                       3(RAMPS-Z)
%       ^                          X
%       |  Card coords            / \          Tower name/number
%       |                        /   \
%       +-->+X       (RAMPS-X)1 +-----+ 2 (RAMPS-Y)
%
%
% DeltaParams struct must contain:
%       RADIUS   -- Marlin DELTA_RADIUS, which is radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
% XOR   radius(3) -- independant radii
%       RodLen   -- length between center of pivots on diagonal rods
%
% RETURN:  values to SUBTRACT from tower offset(M666 X Y Z)
%          settings to level print bed
function towerErr = guessDeltaEndstopErr(DP,meas)

% initial data plot
figure(2);
hold off;
[c,ax,pFit] = plotParabolicFit(meas);
grid on;hold on;
plot3(meas(:,1),meas(:,2),meas(:,3),'+');
title('Parabolic fit to measurements, + is measurements, . are fit points');
pause(0.1);

GuessParams = DP;
GuessParams.meas = meas;
GuessParams.verbose = 0;
[dErr,nEval,status,err] = SimplexMinimize(...
              @(p) deltaGuessEndstopErr(p,GuessParams),...
   	      [0 0 0], 0.1+[0 0 0], 0.005+[0 0 0], 300)
towerErr =-dErr;

% plot delta parameter fit
errZ = deltaEndstopErrZ(dErr,GuessParams);
plot3(meas(:,1),meas(:,2),errZ+meas(:,3),'r.');
#legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
xlabel('X');ylabel('Y');
hold off

figure(3);
hold off;
fm = meas; fm(:,3) = fm(:,3)+errZ;
c = plotParabolicFit(fm);
grid on;hold on;
plot3(fm(:,1),fm(:,2),fm(:,3),'+');
hold off;
title('Parabolic Fit to simulated points');
xlabel('X');ylabel('Y');

figure(1);
hold off
plot3(meas(:,1),meas(:,2),meas(:,3),'+');
grid on;hold on;
plot3(meas(:,1),meas(:,2),errZ+meas(:,3),'rx');
legend('Measured','Fitted Points');
xlabel('X');ylabel('Y');
hold off

end

% Error metric for minimization
function err = deltaGuessEndstopErr(p,DP)
err = deltaEndstopErrZ(p,DP);
err = mean(err .* err);
disp(sqrt(err))
end

% retrieve whole error vector
function errZ = deltaEndstopErrZ(p,DP)
err = 0;
n = size(DP.meas,1);
errZ = zeros(n,1);
for i=1:n
  d0 = cart2delta(DP,DP.meas(i,1),DP.meas(i,2),0);
  de = d0 + p;  % delta positions with position offset error
  dz = delta2cart(DP,de(1),de(2),de(3));
  errZ(i) = dz(3) - DP.meas(i,3);
end
end
