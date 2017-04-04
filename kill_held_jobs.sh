#!/bin/bash

jobsub_q --hold -G lariat --user=jhugon > heldjobs.txt
while read in; do
  if [[ $in == *"@"* ]]; then
    echo $in; 
    jobid=$(sed 's/ .\+//' <<< $in)
    #echo $jobid
    command="jobsub_rm --jobid=$jobid"; 
    echo $command
    $command; 
  fi
done < heldjobs.txt 
