#!/bin/bash

jobsub_q --hold -G lariat --user=jhugon > heldjobs.txt
#while read in; do echo $in; command="jobsub_release --jobid=$in"; $command; done < heldjobs.txt 
