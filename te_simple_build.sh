#!/bin/bash

# wget http://apache.cs.utah.edu/tomcat/tomcat-7/v7.0.61/bin/apache-tomcat-7.0.61.zip
dir=$(pwd)
# unzip apache-tomcat-7.0.61.zip

dir_to_build=$dir/te-build-demo
./build_te.sh -t $dir/apache-tomcat-7.0.61 -b $dir_to_build

## Warning: catalina_base and teamengine folder are created by build_te.sh.

CATALINA_BASE=$dir_to_build/catalina_base
TE_BASE=$CATALINA_BASE/TE_BASE/
TE=$CATALINA_BASE/webapps/teamengine

##start tomcat required to build teamengine folder
$CATALINA_BASE/bin/catalina.sh start
sleep 5
$CATALINA_BASE/bin/catalina.sh stop


CSV_FILE=tests_to_build.csv
./install-all-tests.sh $TE_BASE $TE $CSV_FILE

echo "Full installations of TEAM Engine and tests have been completed"

echo "CATALINA_BASE $CATALINA_BASE"
echo "TE_BASE $TE_BASE"
echo "TE $TE"
echo ""

echo "to start tomcat run: $CATALINA_BASE/bin/catalina.sh start"  
echo "to stop tomcat run: $CATALINA_BASE'/bin/catalina.sh stop" 
echo ""
echo "More information: https://github.com/opengeospatial/teamengine-builder/"

