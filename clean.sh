#!/bin/sh
# Given catalinabase
if [ -z "$1" ]
  then
    echo "No argument supplied. Please provide a teamengine deployment. For example, under tomcat/wepapps"
    exit
else
	echo "cleaning deployment in $1"
	if [ -d $1 ]; then
		
		cd  $1/WEB-INF/lib
		echo 'removing derby jar from WEB-INF/lib'
		rm derby*.jar
		echo ""
		echo "These are the testng tests installed. If find repeated tests, then remove the minor version"	
		echo "For example: rm $1/WEB-INF/lib/TheFileName"
		echo ""
		ls -l ets-*

		echo "make sure all the status are passed"
		cd $1
		cd ../../
		cd TE_BASE
		cd scripts

		search="<status>Beta<\/status>"

		find ./ -name config.xml |
		while read configFile
		do 
			##echo $configFile
			grep "$search" $configFile &> /dev/null
  			if [ $? -ne 0 ]; then
    			echo "Search string not found in $configFile!"
				
			else
				echo "replacing in $configFile"
				sed -i'.orig' 's/<status>Beta<\/status>/<status>Final<\/status>/' $configFile
			fi	
		done	
		


	fi	

fi
