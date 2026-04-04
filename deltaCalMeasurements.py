#!/usr/bin/python3
"""
deltaCalMeasurements.py : Provide parameters for your deltaCalPrint,
and print out ideal measurement points.

Usage: ./deltaCalMeasurements.py <hexWidth> <patternRadius>
"""

import sys
import math

def usage():
    print(f"Usage: {sys.argv[0]} <hexWidth> <patternRadius>")
    sys.exit(1)

def edgeCenters(x,y,r):
    c = math.cos(math.radians(30)) * r
    s = math.sin(math.radians(30)) * r
    return [[x+c, y+s],
            [x  , y+r],
            [x-c, y+s],
            [x-c, y-s],
            [x  , y-r],
            [x+c, y-s]]

def printEdgeCenters(label,a):
    print(f"{label}=[[{a[0][0]:.3f}, {a[0][1]:.3f}], [{a[1][0]:.3f}, {a[1][1]:.3f}], [{a[2][0]:.3f}, {a[2][1]:.3f}], [{a[3][0]:.3f}, {a[3][1]:.3f}], [{a[4][0]:.3f}, {a[4][1]:.3f}], [{a[5][0]:.3f}, {a[5][1]:.3f}]];")

# euclidean distance
def ed(a,b) :
    x = a[0]-b[0]
    y = a[1]-b[1]
    return math.sqrt(x*x + y*y)

def printMeasurement(label,a,b):
    print(f"{label}={ed(a,b):.1f}; \tp{label}=[{a[0]:.3f},{a[1]:.3f}; {b[0]:.3f},{b[1]:.3f}];")

def main():
    if len(sys.argv) != 3:
        usage()

    try:
        hexWidth = float(sys.argv[1])
        patternRadius = float(sys.argv[2])
    except ValueError:
        usage()

    rHex = hexWidth/2;
    print(f"% commanded deltaCalPrint measurement points")
    print(f"hexWidth={hexWidth}; patternRadius={patternRadius};")
    pr = patternRadius;
    cr = math.cos(math.radians(30)) * pr;
    sr = math.sin(math.radians(30)) * pr;
    
    Z = edgeCenters(  0,  0,rHex); printEdgeCenters("Z",Z)
    a = edgeCenters( cr, sr,rHex); printEdgeCenters("a",a)
    C = edgeCenters(  0, pr,rHex); printEdgeCenters("C",C)
    b = edgeCenters(-cr, sr,rHex); printEdgeCenters("b",b)
    A = edgeCenters(-cr,-sr,rHex); printEdgeCenters("A",A)
    c = edgeCenters(  0,-pr,rHex); printEdgeCenters("c",c)
    B = edgeCenters( cr,-sr,rHex); printEdgeCenters("B",b)

    # spokes
    printMeasurement("aZi",a[3],Z[0])
    printMeasurement("aZo",a[0],Z[3])
    printMeasurement("CZi",C[4],Z[1])
    printMeasurement("CZo",C[1],Z[4])
    printMeasurement("bZi",b[5],Z[2])
    printMeasurement("bZo",b[2],Z[5])
    printMeasurement("AZi",A[0],Z[3])
    printMeasurement("AZo",A[3],Z[0])
    printMeasurement("cZi",c[1],Z[4])
    printMeasurement("cZo",c[4],Z[1])
    printMeasurement("BZi",B[2],Z[5])
    printMeasurement("BZo",B[5],Z[2])

    #diameters
    printMeasurement("Aai",A[0],a[3])
    printMeasurement("Aao",A[3],a[0])
    printMeasurement("Bbi",B[2],b[5])
    printMeasurement("Bbo",B[5],b[2])
    printMeasurement("Cci",C[4],c[1])
    printMeasurement("Cco",C[1],c[4])

    # borders
    printMeasurement("Abi",A[1],b[4])
    printMeasurement("Abo",A[4],b[1])
    printMeasurement("Aci",A[5],c[2])
    printMeasurement("Aco",A[2],c[5])
    printMeasurement("Bci",B[3],c[0])
    printMeasurement("Bco",B[0],c[3])
    printMeasurement("Bai",B[1],a[4])
    printMeasurement("Bao",B[4],a[1])
    printMeasurement("Cai",C[5],a[2])
    printMeasurement("Cao",C[2],a[5])
    printMeasurement("Cbi",C[3],b[0])
    printMeasurement("Cbo",C[0],b[3])

if __name__ == "__main__":
    main()
