#!/bin/bash

usagestr="usage: ./check_job_status.sh [-v <0/1>] <dirname> <njobs>"

verbose=""

while getopts "v:" opt; do
  case $opt in
    v)
      verbose=$OPTARG
      echo $verbose
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
  #shift $((OPTIND-1))
done
basedir=${@:$OPTIND:1}
njobs=${@:$OPTIND+1:1}

cd $basedir

for i in $(seq 1 $njobs); do 
  d=(*_$i); 
  nmatches=$(ls $d 2>/dev/null | wc -w)
  if [ 0 -lt $nmatches ]; then
    jobid=${d%_$i}; 
    stage0time=$(grep -o "Real = .*" $d/larStage0.out 2>/dev/null | cut -f2- -d"=")
    stage1time=$(grep -o "Real = .*" $d/larStage1.out 2>/dev/null | cut -f2- -d"=")
    stage0stat=$(cat $d/larStage0.stat 2>/dev/null)
    stage1stat=$(cat $d/larStage1.stat 2>/dev/null)
    host=$(cat $d/hostname.txt 2>/dev/null)
    #echo $i $jobid $(cat $d/larStage0.stat) $(cat $d/larStage1.stat) $(cat $d/hostname.txt) $stage0time $stage1time; 
    echo $i $jobid $stage0stat $stage1stat $host $stage0time $stage1time; 
    if [ -n "$verbose" ]; then
      tail -n 20 $d/larStage"$verbose".out
    fi
  else
    echo "$i not found"
  fi #filenames
done
