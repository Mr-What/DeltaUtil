% Given a set of measurements (N,3) of a surface,
% compute coefficients for a parabolic fit, and plot
%   c  -- fit coefs
%   ax -- axis for fit sample points surface
%   z  -- parabolic points on this surface
function [c,ax,z] = plotParabolicFit(meas)
c = parabolicFit(meas);
% distance from origin of all measurements
r = sqrt(meas(:,1) .* meas(:,1) + meas(:,2) .* meas(:,2));
r5 = floor(max(r)/5)*5+5;  % r, rounded up to to neareast 5mm
ax = [-r5:5:r5];
n = length(ax);
z = zeros(n);
for i=1:n
   x = ax(i);
   for j=1:n
      y = ax(j);
      if (norm([x y]) <= r5)
         z(j,i) = parabola(c,x,y);
      end
   end
end
meshc(ax,ax,z);
hold on;
plot3(meas(:,1),meas(:,2),meas(:,3),'.');
cmd = sprintf('M668 A%.4f B%.6f C%.6f D%.8f E%.8f F%.8f',c);
disp(cmd)
title(cmd)
end

function c = parabolicFit(meas)
A = ones(size(meas,1),6);
A(:,2:3) = meas(:,1:2);
A(:,4) = meas(:,1) .* meas(:,2);
A(:,5) = meas(:,1) .* meas(:,1);
A(:,6) = meas(:,2) .* meas(:,2);
c = inv(A' * A) * A' * meas(:,3);
end

function z = parabola(c,x,y)
z = c(1) + c(2)*x + c(3)*y + c(4)*x*y + c(5)*x*x + c(6)*y*y;
end
