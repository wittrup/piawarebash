#!/usr/bin/python2.7
from __future__ import print_function
from io import open
import argparse
import re


pattern = r'([-\d.]+)%s([\d.]+)%s([\d.]+)%s([\d.]+)' % (('\t',) * 3)
parser = argparse.ArgumentParser()
parser.add_argument(dest='filename')
parser.add_argument('--delim', type=str, default='\t', help="delimiter to seperate output")
args = parser.parse_args()

with open(args.filename, encoding='utf-8') as fobj: # Use "with" so the file will automatically be closed
    text = fobj.read()

gains = {}
matches = re.findall(pattern, text)
for match in matches:
    match = list(map(float, match))
    gains[match[0]] = [match[i+1] + v for i,v in enumerate(gains[match[0]])] if match[0] in gains else match[1:]
for k in sorted(gains):
    print(str(k), args.delim.join(map(str, gains[k])), sep=args.delim)
