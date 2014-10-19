#!/usr/bin/perl
#
# script to do a random order probe of a hexagonal grid
# generates g-code
#### Parameters:
#$xOffset = -4;   $yOffset = 7;  # switch position relative to extruder tip
$xOffset = 0;   $yOffset = 0;  # switch position relative to extruder tip
$dx=15;#7.5;  # space between samples on grid
$z0=13.33;  # start probe from this height
$radMax = 70.1;  # No probes more than this far from center
####

$deg2rad = 3.14159/180;
$dy=sin(60*$deg2rad) * $dx;
$r2 = $radMax * $radMax;

## generate arrays of probe points
local $i;
$x[0] = $y[0] = 0;
$n = 1;
for ($i=1;$i*$dx<$radMax;$i++) {
    $x[$n] = $i * $dx;    $y[$n++]=0;
    $x[$n] =-$i * $dx;    $y[$n++]=0;
}
local $j = 1;
$yj = $dy;
while ($yj < $radMax) {
    local $di = 1;
    if ($j % 2) {
	$di = 0.5;
    } else {
	$y[$n] = $yj;	$x[$n++] = 0;
	$y[$n] =-$yj;	$x[$n++] = 0;
    }

    &quadScan();

    $j++;
    $yj = $dy * $j;
}
## diagnostic dump
for ($i=0; $i<= $#x; $i++) { printf(";%.2f\t%.2f\n",$x[$i],$y[$i]); }

### lets probe each point 3X to check for repeatability
local $n = $#x + 1;
for ($j=0; $j < 2; $j++) {
  for ($i=0; $i < $n; $i++) {
    $x[$#x+1] = $x[$i];
    $y[$#y+1] = $y[$i];
  }
}

print "G21 ; set units to millimeters
M107
G28 ; home all axes
G4 P55 ; pause
G28 ; home again
G1 F9999 ; go fast
G90 ; use absolute coordinates
";

#$initialPause = 3000;  # long pause to set up first sensor

#$zprobe = "G1 X%.1f Y%.1f Z$z0 ; slight offset to be moving same way before all probes
#G1 X%.2f Y%.2f F777 ; move to probe position and slow down
#G4 P%d  ; pause (ms)
#G30 ; z-probe
#G1 F9999
#G1 Z$z0
#;G4 P9
#;G30
#;G1 F9999
#;G1 Z$z0
#;G4 P9
#;G30
#;G1 F9999
#;G1 Z$z0 ; back up off plate, probe complete
#";

local $reHome = 22;
$n = $#x + 1;
while($n > 0) {
    local $i = int(rand($n));
    $xx = $x[$i] - $xOffset;
    $yy = $y[$i] - $yOffset;
    &printProbe();
    $n--;
    $x[$i] = $x[$n];  # clobber selected probe location
    $y[$i] = $y[$n];
    #$initialPause = 9;  # shorter pause for subsequent probes

    if ($reHome-- < 0) {
	$reHome=20;
	print "G28 ; re-home, to try and combat drift?
G4 P99
G28
G1 F9999
G1 Z33
";
    }
}

print "G28 ; done, home\n";

##################

sub printProbe() {
    #printf($zprobe,$xx+2,$yy+2,$xx,$yy,$initialPause);
    print "G1 X$xx Y$yy Z$z0 ; move to above probe position
G4 P99  ; pause (ms)
G30 ; z-probe
G1 F3333 ; speed up
G1 Z$z0 ; return to above probe spot
";

}

sub quadScan() {
    local $i=0;
    while(1) {
	local $xi = $dx * ($i + $di);
	local $d2 = $xi * $xi + $yj * $yj;
	return if ($d2 > $r2);

	$x[$n] = $xi;  $y[$n++]= $yj;
	$x[$n] =-$xi;  $y[$n++]= $yj;
	$x[$n] = $xi;  $y[$n++]=-$yj;
	$x[$n] =-$xi;  $y[$n++]=-$yj;

	$i++;
    }
}
