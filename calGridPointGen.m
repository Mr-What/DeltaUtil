% generate calibration points, standard pattern, for calGrid, pattern B
wr=5;
spc=35;

spcX=spc/2;
spcY=spc*sind(60);
hr=wr/cosd(30);

id='ABCDEFGHIJKLMNOPQRS';

cntr = [0,0;spc,0;spc/2,spcY;-spc/2,spcY;-spc,0;-spc/2,-spcY;spc/2,-spcY;...
	2*spc,0;1.5*spc,spcY;spc,2*spcY;0,2*spcY;-spc,2*spcY;...
	-1.5*spc,spcY;-2*spc,0;-1.5*spc,-spcY;-spc,-2*spcY;0,-2*spcY;...
	spc,-2*spcY;1.5*spc,-spcY];

hold off;plot(cntr(:,1),cntr(:,2),'.r'); hold on; grid on; axis equal
for i=1:length(id); text(cntr(i,1),cntr(i,2),id(i));end
%hold off

yNodes = [1,9,11,13,15,17,19];% nodes with flat in +-Y

for i=1:length(id)
  a0 = 0;
  if (length(find(i==yNodes))>0), a0 = 30; end
  for j=1:6
    a = a0 + (j-1)*60;
    p = cntr(i,:) + wr*[cosd(a),sind(a)];
    disp(sprintf('%c%d %8.3f  %8.3f',id(i),j,p));
    plot(p(1),p(2),'.');
  end
end

hold off
