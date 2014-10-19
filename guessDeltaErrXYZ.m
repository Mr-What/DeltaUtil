% Given a set of measurements of the print bed level and
% a standard test print, guess the individual tower radii,
% delta rod length, endstop offsets, and printer spread that was most
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
% DeltaParams(DP) struct must contain:
%      radius(3) -- Marlin DELTA_RADIUS, which is radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
%      RodLen    -- length between center of pivots on diagonal rods
%      XYcal     -- test print definitions, from loadXYcalDef()
%      meas      -- measurements of test print, from loadXYcalMeas(XYcal,...)
%      bed       -- bed measurements, adjusted for probe offset
%
% RETURN:  values to SUBTRACT from :
%             towerZErr -- endstop offsets
%             radiusErr -- DELTA_RADIUS1,2,3 settings
%             diagErr   -- diagonal rod length (RodLen)
%    also...
%             spread    -- estimate of printer spread (mm)
function [towerZErr, radiusErr, diagErr, spread] = guessDeltaErrXYZ(DP)
global DeltaErr
DP.verbose=1;  % set desired diagnostic verbosity

DeltaErr.traj = [0 0 0];  % log error trajectory for diagnostic plot
DeltaErr.n = 0;

% had problems with deviations from measured RodLen.  try to limit this.
if (~isfield(DP,'measuredRodLen'))
  DP.measuredRodLen = 217.95;  % aaron's initial Kossel-mini delta
end

% initial data plot
figure(2);
hold off;
[c,ax,pFit] = plotParabolicFit(DP.bed.xyz);
grid on;hold on;
plot3(DP.bed.xyz(:,1),DP.bed.xyz(:,2),DP.bed.xyz(:,3),'+');
title('Parabolic fit to measurements, + is measurements, . are fit points');
pause(0.1); % forces plot to display, so we can review it while computing

%seed = [0,0,0,DP.radius-109.5,DP.RodLen-217.95,.1];

step = [1 1 1  1 1 1  1 0.3]*0.1; % initial step
randStep = step/4;  % *2
%seed = [0 0 0  0 0 0  0  .1];
% hack to try and double check a good-looking minima
seed = [-.27 .16 .06  1.4 -1.4 -.5 -.1 .1];
seed = seed + (rand(1,8)+rand(1,8)-1) .* randStep;  % randomize seed to test convergence
[dErr,nEval,status,err] = SimplexMinimize(...
      @(p) deltaGuessErrXYZ(p,DP),seed,step,step/20,999)
towerZErr = dErr(1:3);
radiusErr = dErr(4:6);
diagErr   = dErr(7);
spread    = dErr(8);

% plot delta parameter fit
errZ = deltaErrZ(dErr,DP);
fm = DP.bed.xyz; fm(:,3) = fm(:,3)+errZ;
plot3(fm(:,1),fm(:,2),fm(:,3),'r.');
xlabel('X(mm)');ylabel('Y(mm)');zlabel('mm');
hold off

figure(3);
hold off;
c = plotParabolicFit(fm);
grid on;hold on;
plot3(fm(:,1),fm(:,2),fm(:,3),'+');
hold off;
title('Parabolic Fit to simulated points');
xlabel('X');ylabel('Y');

figure(1);
hold off
plot3(fm(:,1),fm(:,2),fm(:,3)*1000,'rx');
%plotParabolicFit(fm);
grid on;hold on;
plot3(fm(:,1),fm(:,2),DP.bed.xyz(:,3)*1000,'+');
legend('Fit','Measured');
xlabel('X(mm)');ylabel('Y(mm)');zlabel('Z(um)');
hold off

% need to add some sort of XY distortion plot
errXY0   = deltaErrXY([0 0 0 0 0 0 0 dErr(8)],DP);
disp(sprintf('Initial XY RMSE : %.3f',sqrt(mean(errXY0 .^ 2))));
errXYfit = deltaErrXY(dErr,DP);
disp(sprintf('    fit XY RMSE : %.3f',sqrt(mean(errXYfit .^ 2))));

figure(4);
hold off;
plot(DeltaErr.traj(:,1),'LineWidth',3); grid on; hold on
plot(DeltaErr.traj(:,2),'r','LineWidth',2);
plot(DeltaErr.traj(:,3),'g');
legend('XY RMSE','Z RMSE','Diag Rod err');
hold off

end

% Error metric for minimization
function err = deltaGuessErrXYZ(p,DP)
global DeltaErr
DeltaErr.n = DeltaErr.n + 1;

err = deltaErrXY(p,DP);
errXY = mean(err .* err);

err = deltaErrZ(p,DP);
errZ = mean(err .* err);

% tends to get overfit.  make sure RodLen estimate is close to measurement
%errR = abs((DP.RodLen+p(7))/DP.measuredRodLen - 1)+1;
errR = abs(DP.RodLen+p(7) - DP.measuredRodLen);

DeltaErr.traj(DeltaErr.n,:) = [sqrt([errXY,errZ]),errR];
if (mod(DeltaErr.n,25)==0)
  fprintf(1,"%4d %6.3f %6.3f %5.2f\n",DeltaErr.n,...
	  DeltaErr.traj(DeltaErr.n,:));
end

maxRodLenDeviation = 1;  % penalize rod len if more than 1mm from measurement
errR = max([0,errR - maxRodLenDeviation])+1;

% may want to weight one type of error over another
err = (errXY^2) * errZ * (errR^.5);
end
