#!/bin/bash 
# This script advices on jars with different version in a  directory. Provides a command to remove those jars.
# The script can be change to delete the files as well
# For example: if a directory contains jersey-client-1.18.1.jar jersey-client-1.17.1.jar
# it will advise to remove jersey-client-1.17.1.jar

list_of_files_to_remove=""
flag='false'

## echo "Possible repeated files:"

for PREFIX in `ls *.jar|sed 's/-[0-9\.a-zA-Z]*\.jar//g'|uniq -d`; do 
  echo "   " $PREFIX 

#now do a reverse sorted listing with the jar name and remove the 
#top line so that non latest versions are returned 

  for FILE in `ls -r ${PREFIX}*|sed '1d'`; do 
    ##echo "$FILE"
    list_of_files_to_remove="$list_of_files_to_remove $FILE"
    ##rm -f $FILE 
    flag = "true"
   done 
   

done 
if [ "$flag" = "true" ]; then
	echo "issue the following command to remove jars with old versions"
	echo "sudo rm -r $list_of_files_to_remove" 
else
	echo "No repeated jars were found."
fi
