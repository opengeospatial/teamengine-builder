#!/bin/sh
# Builds a test from the test directory.
# Two arguments are required:
# TE_BASE directory
# TEAM Engine deployment directory
# example: ./build_simple_one.sh $TE_BASE tomcat/webapps/teamengine

if [ -z "$1" ]; then
  echo "[FAIL] Require a directory where TE_BASE is located, as the fist argument."
  echo "$moreInfo"
  exit 0
else
  if [ ! -d "$1" ]; then
    echo "[FAIL] Argument 1 '$1' is not a directory. The TE_BASE directory is required."
    echo "$moreInfo"
    exit 0
  fi  
fi

if [ -z "$2" ]; then
  echo "[FAIL] Require a directory where TEAM Engine has been deployed as a war file, as the second argument."
  echo "$moreInfo"
  exit 0
else
  if [ ! -d "$2" ]; then
    echo "[FAIL] Argument 2 '$2' is not a directory."
    echo "       A directory where TEAM Engine has been deployed as a war file, is required."
    echo "$moreInfo"
    exit 0
  fi  
fi

if [ -z "$3" ]; then
  echo "[INFO] Third argument (-DskipTests) was provided - packaging and testing"
  echo "$moreInfo"
else
  if [ "$3" = "-DskipTests" ]; then
    echo "[INFO] Tests will be skipped when packaging using -DskipTests"
    SKIP="-DskipTests"
  fi  
fi

TE_BASE=$1
TE=$2




dir=$(pwd)
test_name=$(basename $dir)
folder=~/te-build
catalina_base=$folder/catalina_base
#TE_BASE=$catalina_base/TE_BASE
#webapps_lib=$catalina_base/webapps/teamengine/WEB-INF/lib
webapps_lib=$TE/WEB-INF/lib
logfile=log-te-build-test.txt
if [ -f $logfile ]; then
  rm $logfile 1> /dev/null 2>&1;
fi 

echo "[INFO] Packaging via MAVEN with this command:' mvn $SKIP package'"
mvn $SKIP package > $logfile 2>&1 
grep "BUILD SUCCESS" $logfile &> /dev/null
if [ $? -ne 0 ]; then
  echo "[FAIL] Packaging of $dir via MAVEN failed." 
  echo "       Details in $logfile."
  exit 0
  
else
  echo "[INFO] Packaging of $dir via MAVEN was OK"
fi 


cd target

zip_ctl_file=$(ls *ctl.zip | grep -m 1 "ctl")
# get file that has the jars
if ls *deps.zip 1> /dev/null 2>&1; then
    zip_dep_file=$(ls *deps.zip | grep -m 1 "deps")
fi



if [ -n "$zip_ctl_file" ]; then  
   echo '[INFO] Installing' $zip_ctl_file 'at'  $TE_BASE/scripts
   unzip -q -o $zip_ctl_file -d $TE_BASE/scripts
   
   if [ -n "$zip_dep_file" ]; then
       echo '[INFO] Installing' $zip_dep_file 'at'  $webapps_lib
       unzip -q -o $zip_dep_file -d $webapps_lib
   fi   
else
   echo '[FAIL] zip file not found: ' $zip_ctl_file
   exit 0
fi

echo "[SUCCESS] - Built test '$test_name' in $TE_BASE".
if [ -f $logfile ]; then
  rm $logfile 
fi

