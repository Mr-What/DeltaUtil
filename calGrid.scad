// calibration pattern B?
hr=5/cos(30);
spc=35;

spcX=spc/2;
spcY=spc*sin(60);

module marker(rot=0) { rotate([0,0,rot?30:0]) cylinder(r=hr,h=3.5,$fn=6); }

module calGrid() {
  marker(0);
  for (a=[ 0:60:359]) rotate([0,0,a]) translate([  spc ,0,0]) marker(1);
  for (a=[30:60:359]) rotate([0,0,a]) translate([2*spcY,0,0]) marker(1);
  for (a=[ 0:60:359]) rotate([0,0,a]) translate([2*spc ,0,0]) marker(1);
  %for (a=[ 0:60:359]) rotate([0,0,a]) translate([3*spc ,0,0]) marker(1);

  for (a=[-60:60:66]) rotate([0,0,a])
    translate([0,0,.5]) cube([4*spc,3,1],center=true);

  for (a=[30:60:359]) rotate([0,0,a])
    translate([2*spcY,0,.5]) cube([3,2*spc,1],center=true);


  // These are all radius 2.64575131106459*spc
  for (a=[-1,1]) for (b=[-1,1])
    %translate([2.5*spc*a,spcY*b,0]) marker(0);

  for (a=[-1,1]) for (b=[-1,1])
    %translate([2*spc*a,2*spcY*b,0]) marker(0);

  for (a=[-1,1]) for (b=[-1,1])
    %translate([0.5*spc*a,3*spcY*b,0]) marker(0);
}

%translate([0,0,-1]) cylinder(r=70/cos(30),h=1,$fn=60);

//projection(cut=true) translate([0,0,-0.1])
  calGrid();