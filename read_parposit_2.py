#!/usr/bin/env python
"""
read flexpart particle position file and output to csv

usage:

  ./read_partposit.py in_file out_file num_species


e.g.:

  ./read_partposit.py partposit_20180713090000 partposit_20180713090000.csv 3
"""
import struct
import sys

if len(sys.argv) != 4:
  sys.stderr.write('usage : read_partposit.py in_file out_file num_species\n')
  sys.exit()

file_in = sys.argv[1]
file_out = sys.argv[2]
num_species = int(sys.argv[3])

line_cols = 11 + num_species

fh_in = open(file_in, 'rb')
fh_out = open(file_out, 'w')

b = fh_in.read(4)
time_step = struct.unpack('<i', b)[0]

while True:
  fh_in.read(12)
  line = []
  for i in range(1):
    b = fh_in.read(4)
    v = struct.unpack('<i', b)[0]
    line.append(v)
  for i in range(3):
    b = fh_in.read(4)
    v = struct.unpack('<f', b)[0]
    line.append(v)
  for i in range(1):
    b = fh_in.read(4)
    v = struct.unpack('<i', b)[0]
    line.append(v)
  for i in range(6 + num_species):
    b = fh_in.read(4)
    v = struct.unpack('<f', b)[0]
    line.append(v)
  if line[0] < -999:
    break
  out_cols = ['{0}'.format(line[i]) for i in range(line_cols)]
  out_line = ','.join(out_cols)
  fh_out.write('{0}\n'.format(out_line))

fh_in.close()
fh_out.close()
