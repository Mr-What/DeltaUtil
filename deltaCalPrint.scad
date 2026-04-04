// calibration print.  Take measurements
HEX_RAD = 5/cos(30);
PATTERN_RAD = 60;//80;
HEX_HEIGHT = 3;

testHex(0,0,"Z");  // zero, origin

// note tower names as labels next
for(a=[0:2]) testHex(cos(a*120-150)*PATTERN_RAD,sin(a*120-150)*PATTERN_RAD, chr(ord("A")+a));

// sides
for(a=[0:2]) testHex(cos(a*120+30)*PATTERN_RAD,sin(a*120+30)*PATTERN_RAD, chr(ord("a")+a));

module testHex(x,y,txt,rot=0) translate([x,y]) difference() {
    rotate(rot) hull() { // bevil to avoid top layer "ears", hard to measure
        cylinder(r=HEX_RAD,h=HEX_HEIGHT-.5,$fn=6);
        translate([0,0,HEX_HEIGHT-.1]) cylinder(r=HEX_RAD-.5, h=.1, $fn=6);
    }
    translate([0,0,HEX_HEIGHT-1]) linear_extrude(1.1)
        text(txt,size=HEX_RAD,halign="center",valign="center");
}