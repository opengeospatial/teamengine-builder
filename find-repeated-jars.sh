#!/bin/bash 
# This script advices on jars with different version in a  directory. Provides a command to remove those jars.
# The script can be change to delete the files as well
# For example: if a directory contains jersey-client-1.18.1.jar jersey-client-1.17.1.jar
# it will advise to remove jersey-client-1.17.1.jar

list_of_files_to_remove=""
flag='false'
echo ""
echo "Files to Delete"
echo ""

## echo "Possible repeated files:"

for PREFIX in `ls *.jar|sed 's/-[0-9\.a-zA-Z]*\.jar//g'|uniq -d`; do 
# echo "   Prefix:  " $PREFIX 


## Check filename contains the string "pending"

for FILE in `ls -r ${PREFIX}*`; do 

	if echo $FILE | grep -q "pending";then
		list_of_files_to_remove="$list_of_files_to_remove $FILE"

		#rm -f $FILE		
	fi
   done



#now do a reverse sorted listing with the jar name and remove the older one
# 
#Get the latest version jar file 		
#This command only works in ubuntu>> sorted_file=$(ls -r ${PREFIX}* | sort -t- -k2 -V -r | head -1)

sorted_file=$(ls -r ${PREFIX}* | grep -v "pending" | sed 's/^[0-9]\./0&/; s/\.\([0-9]\)$/.0\1/; s/\.\([0-9]\)\./.0\1./g;' | sort -r | sed 's/^0// ; s/\.0/./g' | head -1)



#list the files with PREFIX



  for FILE in `ls -r ${PREFIX}*`; do 

	#Delete the older version files	
	if [ "$sorted_file" != "$FILE" ] && echo $FILE | grep -v "pending";
	then
		echo " "$FILE
		#rm -f $FILE
		list_of_files_to_remove="$list_of_files_to_remove $FILE"
	fi

    flag= "true"
   done 
   
echo "---------------------------------------"
done 
if [ "$flag"="true" ]; then
	echo "issue the following command to remove jars with old versions"
	echo "sudo rm -r $list_of_files_to_remove" 
else
	echo "No repeated jars were found."
fi
