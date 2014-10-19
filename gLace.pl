#!/usr/bin/perl -w
# generate g-code to command a spiral

$outerRadius = 73;  # mm, outer most spiral radius
$loopWidth = 10;    # width of each loop, mm
$feedRate = 0.1;    # mm of feed for each mm of travel
$stepDeg = 30;      # degrees around circle for each line segment

print STDERR "
Usage: $0 [outerRadius=$outerRadius [loopWidth=$loopWidth [feedRate=$feedRate [stepDeg=$stepDeg]]]] > spiral.gcode
   outerRadius -- mm, outer most spiral radius
   loopWidth   -- width of each loop, mm
   feedRate    -- mm of feed for each mm of travel
   stepDeg     -- degrees around circle for each line segment
";
$outerRadius = $ARGV[0] if ($#ARGV >= 0);
$loopWidth   = $ARGV[1] if ($#ARGV >= 1);
$feedRate    = $ARGV[2] if ($#ARGV >= 2);
$stepDeg     = $ARGV[3] if ($#ARGV >= 3);

print "G21 ; set units to mm
G28 ; home
G90 ; use absolute coords
G1 F20000 ; go fast
G1 X0 Y0 Z14 ; move away from the probe retractor plate
G92 E0
;M82 ; use absolute distances for extrusion
M83 ; use relative distances for extrusion\n";

$pi = 3.14159264359;
print "G1 F4444 ; set print speed\n";
&printSpokes(0.1,$outerRadius-2,$stepDeg/4,$feedRate);
#&printRaster(0.2,$outerRadius-3,    3     ,$feedRate);
&printSpiral(0.3,$outerRadius  ,$loopWidth,$feedRate*3,$stepDeg);

print "G1 X0 Y0 Z88
G28 ; home
M84     ; disable motors
;M104 S0 ; extruder heater off\n";

##############################################################

sub printSpiral() {
    local ($z0,$ro,$lw,$fr,$sd) = @_; # height,radius,loopWidth,feedRate,step in degrees

    local $r = $ro;
    print "G1 X0 Y$r Z$z0 ; start spiral in\n";
    local $n = int(360 * ($r / $lw) / $sd); # number of steps to trace
    for(local $i=1; $i <= $n; $i++) {
	local $r0 = $r;
	$r -= $lw * $sd / 360;
	local $dPath = ($r0+$r)*$pi*$sd/360;  # aprox path len
	local $e = $dPath * $fr;
	local $a = $i*$sd * $pi / 180;
	local $x = $r * sin($a);
	local $y = $r * cos($a);
	printf("G1 X%.3f Y%.3f E%.3f\n",$x,$y,$e);
    }

    print "G1 X0 Y0 E.1; spiral back out\n";
    $r=$lw/4;
    $n -= int(90/$sd);
    for($i=1; $i <= $n; $i++) {
	local $r0 = $r;
	$r += $lw * $sd / 360;
	local $dPath = ($r0+$r)*$pi*$sd/360;  # aprox path len
	local $e = $dPath * $fr;
	local $a = -($i*$sd+180)* $pi / 180;
	local $x = $r * sin($a);
	local $y = $r * cos($a);
	printf("G1 X%.3f Y%.3f E%.3f\n",$x,$y,$e);
    }
    print "G1 Z55 ; end of spiral\n";
}

sub printSpokes() {
    local ($z0,$ro,$sd,$fr) = @_;  # height, radius, step(deg), feedrate

    print "G1 X$ro Y0 Z$z0 ; start spokes\n";
    local $i=0;
    local $ir = 2;  # inner radius
    local $e = $ro * $fr;
    while ($i < 359) {
	local $a = $i * $pi / 180;
	printf("G1 X%.3f Y%.3f\n", $ro*cos($a), $ro*sin($a));
	$i += $sd/2;
	$a = $i * $pi / 180;
	printf("G1 X%.3f Y%.3f E%.3f\n", $ir*cos($a), $ir*sin($a), $e);
	$i += $sd/2;
	$a = $i * $pi / 180;
	printf("G1 X%.3f Y%.3f E%.3f\n", $ro*cos($a), $ro*sin($a), $e);
	$i += $sd;
    }

    print "G1 Z15 ; spokes complete\n";
}

sub printRaster() {
    local ($z0,$ro,$rw,$fr) = @_;  # height, radius, rasterWidth, feedrate

    print "G1 X0 Y$ro Z$z0 ; start raster\n";
    local $y = $ro - $rw;
    while ($y > -$ro + 1.1*$rw) {
	local $x = sqrt($ro*$ro - $y*$y);
	printf("G1 X-%.3f Y%.3f\n", $x, $y);
	local $e = 2*$x * $fr;
	printf("G1 X%.3f Y%.3f E%.3f\n", $x, $y, $e);
	$y -= $rw;
	$x = sqrt($ro*$ro - $y*$y);
	printf("G1 X%.3f Y%.3f\n", $x, $y);
	$e = 2*$x * $fr;
	printf("G1 X-%.3f Y%.3f E%.3f\n", $x, $y, $e);
	$y -= $rw;
    }
    print "G1 Z15 ; raster complete\n";
}
