#!/usr/bin/perl -w
# compute the IDEAL calibration distance between all identified calibration
# point pairs
($#ARGV == 1) or die "
Usage $0 calPoints.dat calPairs.dat > calDist.dat\n\n";

&loadCalPoints($ARGV[0]);
&loadCalPairs( $ARGV[1]);

for (local $i=0; $i <= $#CalPair; $i++) {
    local $na = $CalPair[$i][0];
    local $nb = $CalPair[$i][1];
    local @a = @{ $CalPoint{$na} };
    local @b = @{ $CalPoint{$nb} };
    print STDERR "$na($a[0],$a[1]) $nb($b[0],$b[1])\n";
    local $dx = $a[0]-$b[0];
    local $dy = $a[1]-$b[1];
    local $d = sqrt($dx*$dx + $dy*$dy);
    printf "$na $nb %g\n",0.01*int($d*100+0.5);
}
    
sub loadCalPoints() {
    local ($calPointsFN) = @_;

    $_ = `cat $calPointsFN`;
    local @lines = split /\n/;
    foreach (@lines) {
	chomp;
	s/\s+/ /g;
	s/ $//;
	s/^ //;
	local ($nam,$x,$y) = split / /;
	$CalPoint{$nam} = [$x,$y];
	print STDERR "$nam $x $y\n";
    }
}

sub loadCalPairs() {
    local ($calPairsFN) = @_;

    $_ = `cat $calPairsFN`;
    local @lines = split /\n/;
    local $i=0;
    foreach (@lines) {
	chomp;
	s/\s+/ /g;
	s/ $//;
	s/^ //;
	s/ i//;  # don't care about inner/outer for ideal dist
	if (m/.. ../) {
          local ($a,$b) = split / /;
	  $CalPair[$i++] = [$a,$b];
	  print STDERR "$a $b\n";
	} else { print STDERR "Bad Line : $_\n"; }
    }
    printf STDERR "%d pairs.\n",$#CalPair+1;
}
