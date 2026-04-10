% Given a set of measurements on the bed surface, guess
% the tower endstop and DELTA_RADIUS errors that are most
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
%       RodLen   -- length between center of pivots on diagonal rods
%
% RETURN:  values to SUBTRACT from DELTA_RADIUS and tower offset(M666 X Y Z)
%          settings to calibrate print bed
function [deltaErr, towerErr] = guessDeltaErr4(DP,meas)

% initial data plot
figure(2);
hold off;
[c,ax,pFit] = plotParabolicFit(meas);
grid on;hold on;
plot3(meas(:,1),meas(:,2),meas(:,3),'+');
title('Parabolic fit to measurements, + is measurements, . are fit points');
pause(0.1);

GuessParams.RodLen = DP.RodLen;
if (isfield(DP,'RADIUS'))
  GuessParams.radius = DP.RADIUS+[0,0,0];
else
  GuessParams.radius = mean(DP.radius)+[0,0,0]
end
GuessParams.bed.xyz = meas;
twr=meas;
for i=1:size(meas,1),twr(i,:)=cart2delta(GuessParams,[meas(i,1:2),0]);end
GuessParams.bed.twr=twr;
GuessParams.verbose = 0;
[dErr,nEval,status,err] = SimplexMinimize(...
              @(p) deltaGuessErr(p,GuessParams),...
   	      [0 0 0 0], 0.1+[0 0 0 0], 0.005+[0 0 0 0], 300)
deltaErr = dErr(1);
towerErr =-dErr(2:4);

% plot delta parameter fit
%errZ = deltaErrZ(dErr,GuessParams);
errZ = deltaErrZ([dErr(2:4),dErr(1)+[0 0 0],0],GuessParams);
plot3(meas(:,1),meas(:,2),(errZ+meas(:,3)),'r.');
#legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
xlabel('X(mm)');ylabel('Y(mm)');zlabel('mm');
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
plot3(meas(:,1),meas(:,2),(errZ+meas(:,3))*1000,'rx');
#plotParabolicFit(fm);
grid on;hold on;
plot3(meas(:,1),meas(:,2),meas(:,3)*1000,'+');
legend('Fit','Measured');
xlabel('X(mm)');ylabel('Y(mm)');zlabel('Z(um)');
hold off

end

% Error metric for minimization
function err = deltaGuessErr(p,DP)
err = deltaErrZ([p(2:4),p(1)+[0 0 0],0],DP);
err = mean(err .* err);
disp(sqrt(err))
end

% use standard, "complete" parameter vector version of deltaErrZ
% retrieve whole error vector
%function errZ = deltaErrZ(p,GP)
%DP = struct('RodLen',GP.RodLen,...
%            'RADIUS',GP.RADIUS+p(1));
%err = 0;
%n = size(GP.meas,1);
%errZ = zeros(n,1);
%for i=1:n
%  d0 = cart2delta(GP,[GP.meas(i,1),GP.meas(i,2),0]);
%  de = d0 + p(2:4);  % delta positions with position offset error
%  dz = delta2cart(DP,de);
%  errZ(i) = dz(3) - GP.meas(i,3);
%end
%end
