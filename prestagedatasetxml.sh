#!/bin/bash

xmlfn=$1
line=$(grep "<inputdef>.*</inputdef>" $xmlfn)
ndefs=$(echo $line | wc -w)
if [ "$ndefs" -eq "0" ]; then
  echo "Error: No single-line inputdef found in: $xmlfn"
  exit 1;
fi
if [ "$ndefs" -gt "1" ]; then
  echo "Error: Too many inputdef's found in $xmlfn"
  exit 1;
fi
line=${line#*>}
inputdef=${line%</*}

echo $inputdef

samweb prestage-dataset --defname=$inputdef
