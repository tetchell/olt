#!/usr/bin/env python

# Accept an input file, a relative path, and an optional file extension.
# For each file matching the optional extension, add the contents of the input file at the start of the file

import os, sys

def prepend(file, to_prepend):
    with open(file, 'r+') as f:
        content = f.read()
        f.seek(0,0)
        f.write(to_prepend + '\n' + content)

if len(sys.argv) < 3:
    print('Usage: prepender.py $inputfile $targetpath [$extension]')
    exit(1)

inputfile = sys.argv[1]
targetpath= sys.argv[2]
extension = sys.argv[3]

to_prepend = ''
with open(inputfile, 'r') as f:
    to_prepend= f.read()

if to_prepend == None or len(to_prepend) == 0:
    print('Error reading input file ' + inputfile + ', or file is empty')
    exit(1)

print('Prepending contents of ' + inputfile + ' to all ' + extension + ' files in ' + targetpath)

for root, dirs, files in os.walk(targetpath):
    for file in files:
        if file.endswith('.' + extension):
            abspath=os.path.join(root, file)
            print(abspath)
            # Comment below line out for a dry-run
            prepend(abspath, to_prepend) 
