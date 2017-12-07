#!/bin/bash

usagestr="usage: ./check_job_status.sh [-v <0/1>] [-e <0/1>] [-p] [-a] <dirname>"

verbose=""
eventsverbose=""
eventspass=""
eventsall=""

while getopts "v:e:pa" opt; do
  case $opt in
    v)
      verbose=$OPTARG
      ;;
    e)
      eventsverbose=$OPTARG
      ;;
    p)
      eventspass="1"
      ;;
    a)
      eventsall="1"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo $usagestr >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo $usagestr >&2
      exit 1
      ;;
  esac
done
basedir=${@:$OPTIND:1}

cd $basedir

# figure out how many job outputs are in the outdirectory
njobsfound=0
allfns=$(ls)
for fn in $(ls); do
  thisjob=$(echo $fn | grep '[0-9]\{1,\}_[0-9]\{1,\}' | cut -f2- -d"_")
  thisjob=${thisjob// /}
  if [ -n "$thisjob" ]; then
    if [ $thisjob -gt $njobsfound ]; then
        njobsfound=$thisjob;
    fi
  fi
done

#do the printing
stage0evttotal=0
stage1evttotal=0
for i in $(seq 0 $njobsfound); do 
  d=(*_$i); 
  nmatches=$(ls $d 2>/dev/null | wc -w)
  #ds=*_$i
  #nmatches=$(echo $ds | wc -w)
  if [ 0 -lt $nmatches ]; then
    #d=""
    #jobid=0
    #for d2 in $ds; do
    #  jobid2=${d2%_$i}
    #  if [ $jobid2 -gt $jobid ]; then
    #    jobid=$jobid2
    #    d=$d2;
    #  fi
    #done
    #echo $jobid $d
    stage0time=$(grep -o "Real = .*" $d/larStage0.out 2>/dev/null | cut -f2- -d"=")
    stage1time=$(grep -o "Real = .*" $d/larStage1.out 2>/dev/null | cut -f2- -d"=")
    stage0stat=$(cat $d/larStage0.stat 2>/dev/null)
    stage1stat=$(cat $d/larStage1.stat 2>/dev/null)
    host=$(cat $d/hostname.txt 2>/dev/null)
    eventsstr=""
    if [ -n "$eventsverbose" ]; then
      eventsstr=$(grep -o "Events total.*" $d/larStage"$eventsverbose".out 2>/dev/null)
    elif [ -n "$eventspass" ]; then
      eventsstr0=$(grep -o 'Events total = [0-9]* passed = [0-9]*' $d/larStage0.out 2>/dev/null | cut -f3- -d"=")
      eventsstr1=$(grep -o 'Events total = [0-9]* passed = [0-9]*' $d/larStage1.out 2>/dev/null | cut -f3- -d"=")
      eventsstr=$eventsstr0$eventsstr1
      stage0evttotal=$(( stage0evttotal + eventsstr0 ))
      stage1evttotal=$(( stage1evttotal + eventsstr1 ))
    elif [ -n "$eventsall" ]; then
      eventsstr0=$(grep -o 'Events total = [0-9]*' $d/larStage0.out 2>/dev/null | cut -f2- -d"=")
      eventsstr1=$(grep -o 'Events total = [0-9]*' $d/larStage1.out 2>/dev/null | cut -f2- -d"=")
      eventsstr=$eventsstr0$eventsstr1
      stage0evttotal=$(( stage0evttotal + eventsstr0 ))
      stage1evttotal=$(( stage1evttotal + eventsstr1 ))
    fi
    #echo $i $jobid $(cat $d/larStage0.stat) $(cat $d/larStage1.stat) $(cat $d/hostname.txt) $stage0time $stage1time; 
    echo $i $jobid $stage0stat $stage1stat $host $stage0time $stage1time $eventsstr
    if [ -n "$verbose" ]; then
      tail -n 20 $d/larStage"$verbose".out
    fi
  else
    echo "$i not found"
  fi #filenames
done

if [ -n "$eventspass" ] || [ -n "$eventsall" ]; then
  echo "Stage 0 total events: $stage0evttotal"
  echo "Stage 1 total events: $stage1evttotal"
fi
