% Given a set of measurements of a standard test print,
% and estimates of :
%     - tower endstop offset errors guess
%     - tower axis radius errors
%     - delta rod-length error
%     - print spread
% Compute the error of each given test object measurement
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
%   p -- error vector:
%        (1:3) -- tower offset error 
%        (4:6) -- tower radius error
%        (7)   -- delta rod-length error
%        (8)   -- print spread
%
% Guess Parameters struct (GP) must contain:
%      radius(3) -- Marlin DELTA_RADIUS, which is radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
%      RodLen    -- length between center of pivots on diagonal rods
%      XYcal     -- test print definitions, from loadXYcalDef()
%      meas      -- measurements of test print, from loadXYcalMeas(XYcal,...)

function err = deltaErrXY(p,GP)
  DP = struct('RodLen',GP.RodLen+p(7),...
              'radius',GP.radius+p(4:6));
  n = length(GP.meas.dist);
  errD = zeros(n,1);
  spread = p(8);
  for i=1:n
    iPair = GP.meas.idx(i);  % index of point pair measured
    pIdx = GP.XYcal.pairs.idx(iPair,:);  % indices of two points measured
    ta = GP.XYcal.points.twr(pIdx(1),:); % tower commands, point a
    tb = GP.XYcal.points.twr(pIdx(2),:); % tower commands, point b
    ta = ta + p(1:3);  % add endstop error estimate
    tb = tb + p(1:3);
    a = delta2cart(DP,ta); % recover position with err
    b = delta2cart(DP,tb);
    d = norm(a-b); % simulated expected measurement, ideal

    % adjust simulted measurement by print spread, to match physical
    if (GP.XYcal.pairs.inside(iPair))
      d = d - 2*spread;
    else
      d = d + 2*spread;
    end
    err(i) = d - GP.meas.dist(i);
  end
end
