%  generate simulated bed probe data for a tilted_delta (tetra) printer

v = [-100:5:100];  % sample grid

% p0 is ideal parameters
p0=struct();  % clear any old values
p0.delta_radius = [160,160,160];
p0.delta_angles = [210,330,90];
p0.arm_lengths = [287,287,287];
p0.tilt_radial = [13,13,13];
p0.tilt_tangential = [0,0,0];
p0.endstop_distance = [500,500,500];
p0 = getTetraParams(p0)

tp = p0.p;  % test recovery from purtutbed parameters
tp.endstop_distance = p0.p.endstop_distance + [-1,3,2];
tp.delta_radius = tp.delta_radius - 3;
tp = getTetraParams(tp)

n = length(v);
x = repmat(v,n,1);
y=x';
z = getSimulatedTetraProbeData(x, y, 9, tp, p0, file='probeBadRadiusEndstops.mat');
