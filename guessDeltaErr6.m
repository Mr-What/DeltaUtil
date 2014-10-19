% Given a set of measurements on the bed surface, guess
% the tower endstop and Delta radius errors that are most
% likely to have produced these measurements.
%
%     [radiusErr, towerErr] = guessDeltaErr6(DeltaParams,bedMeasurements)
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
%      radius(3) -- Marlin DELTA_RADIUS, which is radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
%       RodLen   -- length between center of pivots on diagonal rods
%
% RETURN:  values added to DELTA_RADIUS1,2,3
%          and tower offset(M666 X Y Z)
%          settings which fit measurements
function [radiusErr, towerErr] = guessDeltaErr6(DP0,meas)

% initial data plot
figure(2);
hold off;
[c,ax,pFit] = plotParabolicFit(meas);
grid on;hold on;
plot3(meas(:,1),meas(:,2),meas(:,3),'+');
title('Parabolic fit to measurements, + is measurements, . are fit points');
pause(0.1); % forces plot to display, so we can review it while computing

DP.RodLen = DP0.RodLen;
DP.radius = DP0.radius;
DP.bed.xyz = meas;
twr=meas;
for i=1:size(meas,1),twr(i,:)=cart2delta(DP0,meas(i,:));end
DP.bed.twr=twr;  % comands given at actual bed level

DP.verbose = 0;
[dErr,nEval,status,err] = SimplexMinimize(...
              @(p) deltaGuessErr(p,DP),...
   	      [0 0 0 0 0 0], 0.1+[0 0 0 0 0 0], 0.005+[0 0 0 0 0 0], 999)
radiusErr = dErr(1:3);
towerErr  = dErr(4:6);

% plot delta parameter fit
%errZ = deltaErrZ(dErr,GuessParams);
errZ = deltaErrZ([dErr(4:6),dErr(1:3),0],DP);
fm = meas; fm(:,3) = fm(:,3)+errZ;
plot3(fm(:,1),fm(:,2),fm(:,3),'r.');
#legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
xlabel('X(mm)');ylabel('Y(mm)');zlabel('mm');
hold off

figure(3);
hold off;
c = plotParabolicFit(fm);
grid on;hold on;
plot3(fm(:,1),fm(:,2),fm(:,3),'+');
hold off;
title('Parabolic Fit to simulated measured points');
xlabel('X');ylabel('Y');

figure(1);
hold off
plot3(fm(:,1),fm(:,2),fm(:,3)*1000,'rx');
#plotParabolicFit(fm);
grid on;hold on;
plot3(meas(:,1),meas(:,2),meas(:,3)*1000,'+');
legend('Fit','Measured');
xlabel('X(mm)');ylabel('Y(mm)');zlabel('Z(um)');
hold off

end

% Error metric for minimization
function err = deltaGuessErr(p,DP)
%err = deltaErrZ(p,DP);
err = deltaErrZ([p(4:6),p(1:3),0],DP);
err = mean(err .* err);
disp(sqrt(err))
end

%% retrieve whole error vector
%function errZ = deltaErrZ(p,GP)
%DP = struct('RodLen',GP.RodLen,...
%            'radius',GP.radius+p(1:3));
%err = 0;
%n = size(GP.meas,1);
%errZ = zeros(n,1);
%for i=1:n
%  d0 = cart2delta(GP,[GP.meas(i,1),GP.meas(i,2),0]);
%  de = d0 + p(4:6);  % delta positions with position offset error
%  dz = delta2cart(DP,[de(1),de(2),de(3)]);
%  errZ(i) = dz(3) - GP.meas(i,3);
%end
%end
