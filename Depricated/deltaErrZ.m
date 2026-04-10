% Given a set of measurements of a standard test print,
% and estimates of :
%     - tower endstop offset errors guess
%     - tower axis radius errors
%     - delta rod-length error
% Compute the error of each bed probe measurement
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
%
% Guess Parameters struct (GP) must contain:
%      radius(3) -- Marlin DELTA_RADIUS, which is radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
%      RodLen    -- length between center of pivots on diagonal rods
%      bed.xyz   -- bed probe measurements
%      bed.twr   -- tower commands used to obtain bed.xyz (using orig params)

function errZ = deltaErrZ(p,GP)
  DP = struct('RodLen',GP.RodLen+p(7),...
              'radius',GP.radius+p(4:6));
  n = size(GP.bed.twr,1);
  errZ = zeros(n,1);
  for i=1:n
    t = GP.bed.twr(i,:); % commanded tower positions at bed
    t = t + p(1:3);  % delta tower positions with endstop offset error
    dz = delta2cart(DP,t);
    errZ(i) = dz(3); % dist from bed, assuming guess delta parameters
  end
end
