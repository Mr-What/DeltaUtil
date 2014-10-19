//projection(cut=true)  // to make annotated 2D drawing
union() {

  for (a=[0,120,240]) rotate([0,0,a]) {
    // tip 39+62/2 = 70 mm from exact center
    translate([0, 39,0]) cube([8,62,4],center=true);
    hull() {  // support brace
      translate([0,30,1]) scale([1,15,1]) cylinder(r1=1.5,r2=.2,h=3,$fn=4);
      translate([0,63,1])                 cylinder(r1=1.5,r2=.2,h=3,$fn=4);
    }
    // outer edge aligned with center of tip of bar towards tower,
    // exactly 35mm from center
    translate([0,-32,0]) {
      cube([60,6,4],center=true);
      for (b=[-1,1]) 
        translate([28*b,8,0]) cube([4,15,4],center=true);
    }

    // more stuff to test Z scale
    // corners exactly 60 from center, on outside, 5mm above rest.
    translate([0,65,0]) rotate([0,0,30]) cylinder(r=4/cos(30),h=2+5,$fn=6);
  }

  // more XY-square parts to test straight lines/squareness
  for(a=[-1,1]) {
    translate([52*a, 10  ,0]) cube([ 6,60,4],center=true);
    translate([52*a,  0  ,1]) hull() { // support brace
      translate([0,37,0]) cylinder(r1=1.5,r2=.2,h=3,$fn=4);
      translate([0,-7,0]) scale([1,9,1]) cylinder(r1=1.5,r2=.2,h=3,$fn=4);
    }
    translate([43*a,-18  ,0]) cube([16, 4,4],center=true);
    translate([34*a, 37.5,0]) cube([35, 5,4],center=true);
  }
  translate([ 0  , 37  ,1]) hull() { // more braces
    for (a=[-1,1]) translate([ 52*a,0,0])
      cylinder(r1=1.5,r2=.3,h=3,$fn=4);
  }

  difference() {
    //cube([20/cos(30),20,4],center=true);
    cube([20,20,4],center=true);
    translate([0,0,-3]) cylinder(h=6,r=5/cos(30),$fn=6);  // 1cm wide hex, marks center
  }

  // more z-scale tests
  translate([0,5+4,12/2]) cube([8,8,12],center=true);

  // This little post ensures that slic3r puts drawing centered correctly,
  // without manual 15.768 mm offset.
  // I also had problems with re-melt when printing one tall spire.
  // this will force the head to move on each layer and give things more time
  // to cool
  translate([0,-70+4,5]) cube([8,8,14],center=true);
  for(a=[-1,1]) hull() {
    translate([22*a,-31,-2]) cylinder(r1=1.5,r2=.2,h=4.5,$fn=4);
    translate([  0 ,-68,-2]) cylinder(r1=1.5,r2=.2,h=9,$fn=6);
  }
}

%translate([0,0,-1]) rotate([0,0,30]) cylinder(h=2,r=70,$fn=6);
