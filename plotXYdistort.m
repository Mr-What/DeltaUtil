% Given a grid of cartesian measurements, xyz, which are supposed
% to be on a grid defined by axis x, plot a magnified view of the distortions
function plotXYdistort(x,xyz,scale)
  if (nargin < 3), scale=1; end
  hold off;
  n = length(x);
  r2max = max(abs(x));
  r2max = r2max * r2max;
  firstPlot=1;
  for i=1:n
    for j=1:n
      if (x(i)*x(i) + x(j)*x(j) < r2max)
        ex = xyz(i,j,1) - x(i);
        ey = xyz(i,j,2) - x(j);
        plot(x(i)+[0,ex*scale], x(j)+[0,ey*scale]);
	if (firstPlot), firstPlot=0; hold on; end
	plot(x(i),x(j),'or','MarkerSize',2);
      end
    end
  end
  grid on;axis equal
end
