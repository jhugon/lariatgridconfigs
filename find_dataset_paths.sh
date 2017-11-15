#!/bin/bash

samweb list-definition-files $1 >> filenames.txt
while read in; do 
  #echo $in; 
  pathname=$(samweb locate-file $in); 
  pathname=$(echo $pathname | sed "s/^.*:\(.*\)(.*)$/\1/"); 
  fullpath=$pathname/$in
  echo $fullpath
  echo $fullpath >> fullpathnames.txt
done < filenames.txt
