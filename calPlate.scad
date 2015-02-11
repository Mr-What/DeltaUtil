// idea for calibration probe plate.
// needle probe will find minima of holes, which will be positions with known
// XYZ location.  The actuator positions yielding these locations can be analysed
// to estimate the actual kinematic parameters of the robot.

holeDepth=3;

module calHole() {
  hull() {
    cylinder(r=0.001,h=1,$fn=6);
    translate([0,0,1]) cylinder(r=2,h=5,$fn=48);
  }
}

module calPlate(plateR, plateH, holeSep) {
dy=sin(60) * holeSep;
yjmax = floor(plateR/holeSep);
rMax = plateR - holeSep/2;
r2 = rMax*rMax;
  difference() {
    cylinder(r=plateR, h=plateH,$fn=200);

    translate([0,0,plateH-2]) {
      calHole();

      // holes on x axis
      for(x=[holeSep:holeSep:rMax]) for(a=[-1,1])
         translate([x*a,0,0]) calHole();

      // holes on y axis 
      for(y=[2*dy:2*dy:rMax])
        for(a=[-1,1])
          translate([0,y*a,0]) calHole();

      for(y=[dy:2*dy:rMax]) for(x=[holeSep/2:holeSep:rMax]) if (x*x+y*y<r2)
        for(a=[-1,1]) for (b=[-1,1])
          translate([x*a,y*b,0]) calHole();

      for(y=[2*dy:2*dy:rMax]) for(x=[holeSep:holeSep:rMax]) if(x*x+y*y<r2)
        for(a=[-1,1]) for (b=[-1,1])
          translate([x*a,y*b,0])  calHole();


    }
  }
}

calPlate(80,25.4/4,20,25.4/8,3);
