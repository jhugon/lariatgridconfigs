#!/bin/bash

for f in $1/*.out; do
    echo 
    basename $f
    grep Nodename $f
    tail -n 3 $f
done
