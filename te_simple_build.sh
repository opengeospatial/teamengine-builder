#!/bin/bash

start=$SECONDS

realpath(){
  thedir=$1
  cd $thedir
  pwd

}


rm -rf apache-tomcat-7.0.62.zip
wget http://apache.mirrors.pair.com/tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62.zip
unzip -oq apache-tomcat-7.0.62.zip
dir_to_build=te-build

./build_te.sh --tomcat apache-tomcat-7.0.62 --base-folder $dir_to_build --tag-or-branch 4.1-beta2  

## Warning: catalina_base and teamengine folder are created by build_te.sh.
dir_to_build=$(realpath $dir_to_build)

CATALINA_BASE=$dir_to_build/catalina_base
TE_BASE=$CATALINA_BASE/TE_BASE/
TE=$CATALINA_BASE/webapps/teamengine
CSV_FILE=tests_to_build.csv

##start tomcat required to build teamengine folder
$CATALINA_BASE/bin/catalina.sh start
sleep 5
$CATALINA_BASE/bin/catalina.sh stop


./install-all-tests.sh $TE_BASE $TE $CSV_FILE

duration=$(( SECONDS - start ))
echo "[INFO] Full installations of TEAM Engine and tests have been completed"
echo "[INFO] Time to build in seconds: $duration"

echo "[INFO] CATALINA_BASE: $CATALINA_BASE"
echo "[INFO] TE_BASE: $TE_BASE"
echo "[INFO] TE: $TE"
echo ""

echo "[INFO] to start tomcat run: $CATALINA_BASE/bin/catalina.sh start"  
echo "[INFO] to stop tomcat run: $CATALINA_BASE'/bin/catalina.sh stop" 
echo ""
echo "[INFO] More information: https://github.com/opengeospatial/teamengine-builder/"

