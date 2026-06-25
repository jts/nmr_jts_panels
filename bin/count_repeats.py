#! /usr/bin/env python

import sys
from collections import defaultdict

major_map = {
    "LINE": "LINE",
    "SINE": "SINE",
    "Simple_repeat": "Simple",
    "Low_complexity": "Simple",
    "Satellite": "Satellite",
    "LTR": "LTR",
    "DNA": "DNA",
    "rRNA": "rRNA"
}

bases = defaultdict(int)

for line in sys.stdin:
    (chrom, start, end, classification, _, strand) = line.rstrip().split()
    major = "Other"
    for (i,o) in major_map.items():
        if i in classification:
            major = o

    bases[major] += (int(end) - int(start))
    #print(f"{major}\t{classification}")

print("feature\tmegabases")
for (k,b) in bases.items():
    print(f"{k}\t{b/1000000:.1f}")
