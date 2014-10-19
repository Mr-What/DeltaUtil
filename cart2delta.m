% convert cartesian coords to delta-bot displacements.
% Assumes delta bed coordinates are:
%
%      +Y                       3(RAMPS-Z)
%       ^                          X
%       |  Cart coords            / \          Tower name/number
%       |                        /   \
%       +-->+X       (RAMPS-X)1 +-----+ 2 (RAMPS-Y)
%
%
% DeltaParams struct must contain:
%       RADIUS   -- Marlin DELTA_RADIUS, which is radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
%       radius(3)-- instead of one RADIUS for all towers,
%                   provide individual radius for each tower 
%       RodLen   -- length between center of pivots on diagonal rods
function delta = cart2delta(DeltaParams,cart)

if (isfield(DeltaParams,'RADIUS'))
   radius = DeltaParams.RADIUS + [0 0 0];  # assumes equal radius
else
   radius = DeltaParams.radius;
end
s = 0.8660254037844386; % sind(60)
c = 0.5;                % cosd(60)
r2 = DeltaParams.RodLen * DeltaParams.RodLen;

tp = [[-s,-c]*radius(1);...         % tower positions
      [ s,-c]*radius(2);...
      0,radius(3)];

d = tp - [1;1;1] * cart(1:2);  % offset from tower XY to cart XY
d = sum(d .* d,2)';  % square of this distance
delta = sqrt(r2 - d) + cart(3);
end
