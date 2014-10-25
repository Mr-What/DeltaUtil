% convert cartesian coords to delta-bot displacements, with tilted towers
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
%       radius(3)-- Marlin DELTA_RADIUS, for each tower, at bed level.
%                   Radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
%       RodLen   -- length between center of pivots on diagonal rods
%       tilt(3)  -- angle from printbed to each tower, usually <= 90
%                   Assumed towers tilt exactly toward center.
%                   to be used for real calibration, we'd need another tilt,
%                   for amount of spiral tilt along circle
function delta = cart2deltaT(DeltaParams,cart)

radius0 = DeltaParams.radius;

s = 0.8660254037844386; % sind(60)
c = 0.5;                % cosd(60)
r2 = DeltaParams.RodLen * DeltaParams.RodLen;

tp0 = [[-s,-c]*radius(1);...         % tower positions at bed level
       [ s,-c]*radius(2);...
       0,radius(3)];

sa = sind(DeltaParams.tilt);
tz1 = cart(3) ./ sa;  % displacement along tower at cartesian point level
rz = radius0 - cart(3) ./ tand(tilt); % delta radius, at point Z level

tpz = [[-s,-c]*rz(1);...
       [ s,-c]*rz(2);...
       [ 0, 1]*rz(3)];  %  tower positions at cart. point Z level

dv = tpz - [1;1;1] * cart(1:2); % offset from tower at Z level to cart point in XY
d2 = sum (dv .* dv, 2)';  % square of dist from tower, in XY
d  = sqrt(d2);  % dist from tower to point, in XY plane

delta = tz1 + d .* cosd(DeltaParams.tilt) + ...
     sqrt(r2 - (d2 .* (sa .* sa)));
end
