#!/bin/bash 
# This script advices on jars with different version in a  directory. Provides a command to remove those jars.
# The script can be change to delete the files as well
# For example: if a directory contains jersey-client-1.18.1.jar jersey-client-1.17.1.jar
# it will advise to remove jersey-client-1.17.1.jar

list_of_files_to_remove=""

for PREFIX in `ls *.jar| sed 's/^\(.*\)-.*$/\1/'|uniq`; do 

prefix_file_count=$( ls -r ${PREFIX}* | wc -l )

if [ "$prefix_file_count" -gt "1" ]; then

	sorted_file=""
	for FILE in `ls -r ${PREFIX}* | sed 's/^[0-9]\./0&/; s/\.\([0-9]\)$/.0\1/; s/\.\([0-9]\)\./.0\1./; s/\.\([0-9]\+-\)/.0\1/g; s/\.\([0-9]\)\./.0\1./g;'`; do

		file_prefix=$( echo ${FILE} | sed 's/^\(.*\)-.*$/\1/' )

		echo "File Prefix: <$file_prefix>"
		skip_file=""
		if [[ ${PREFIX} != ${file_prefix} ]]; then
			    skip_file=${FILE}
			    echo "Skipped File: <$skip_file>" 	
			    break
			fi
	done

	if [[ -n "$skip_file" ]]; then
	echo "test......................."
	sorted_file=$( ls -r ${PREFIX}* | grep -v "${skip_file}" | sed 's/^[0-9]\./0&/; s/\.\([0-9]\)$/.0\1/; s/\.\([0-9]\)\./.0\1./; s/\.\([0-9]\+-\)/.0\1/g; s/\.\([0-9]\)\./.0\1./g;' | sort -r | sed 's/^0// ; s/\.0/./g' | head -1 )
	for deleteFile in `ls -r ${PREFIX}* | grep -v "${sorted_file}" | grep -v "${skip_file}" | sed 's/^[0-9]\./0&/; s/\.\([0-9]\)$/.0\1/; s/\.\([0-9]\)\./.0\1./; s/\.\([0-9]\+-\)/.0\1/g; s/\.\([0-9]\)\./.0\1./g;'`; do

		list_of_files_to_remove="$list_of_files_to_remove $deleteFile"
	done
	
	else 
	sorted_file=$( ls -r ${PREFIX}* | sed 's/^[0-9]\./0&/; s/\.\([0-9]\)$/.0\1/; s/\.\([0-9]\)\./.0\1./; s/\.\([0-9]\+-\)/.0\1/g; s/\.\([0-9]\)\./.0\1./g;' | sort -r | sed 's/^0// ; s/\.0/./g' | head -1 )
	for deleteFile in `ls -r ${PREFIX}* | grep -v "${sorted_file}" | sed 's/^[0-9]\./0&/; s/\.\([0-9]\)$/.0\1/; s/\.\([0-9]\)\./.0\1./; s/\.\([0-9]\+-\)/.0\1/g; s/\.\([0-9]\)\./.0\1./g;'`; do
		list_of_files_to_remove="$list_of_files_to_remove $deleteFile"
	done
	fi

else 

sorted_file=$( ls -r ${PREFIX}* )

fi

echo ""
done

echo ""
echo "######################################"
echo ""
echo "rm -rf $list_of_files_to_remove"
echo ""
