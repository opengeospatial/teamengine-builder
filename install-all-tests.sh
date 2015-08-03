#!/bin/sh

# Installs the tests in a TE_BASE directory



#folder=~/te-build
#catalina_base=$folder/catalina_base
#TE_BASE=$catalina_base/TE_BASE

fail_message="\n--------------FAILURES-------------------"
failures=0

printHelp(){

  echo ""
  echo "Usage install-all-tests.sh TE_BASE TEAM_ENGINE CSV_FILE DIR_TO_BUILD  SKIP_TESTS"
  echo ""
  echo "where:"
  echo ""
  echo "  TE_BASE        		is the  TE_BASE directory"
  echo "  TEAM_ENGINE    		is the  TEAM_ENGINE directory"
  echo "  CSV_FILE       		is a CSV  file that provides per test a git url and revision number" 
  echo "  DIR_TO_BUILD   		temporary directory to build tests "
  echo "  SKIP_TESTS  			true or false to skip tests while building mvn"
  echo ""
  echo "More information: https://github.com/opengeospatial/teamengine-builder/"

}


if [ -z "$1" ]; then
	echo "[FAIL] Require a directory where TE_BASE is located, as the fist argument."
	printHelp
	exit 0
else
	if [ ! -d "$1" ]; then
		echo "[FAIL] Argument 1 '$1' is not a directory. The TE_BASE directory is required."
		printHelp
		exit 0
	fi	
fi

if [ -z "$2" ]; then
  echo "[FAIL] Require a directory where TEAM Engine has been deployed as a war file, as the second argument."
  printHelp
  exit 0
else
  if [ ! -d "$2" ]; then
    echo "[FAIL] Argument 2 '$2' is not a directory."
    echo "       A directory where TEAM Engine has been deployed as a war file, is required."
   printHelp
    exit 0
  fi  
fi

if [ -z "$3" ]; then
	echo "[FAIL] Require a CSV file that provides a git url and revision of the tests, as third argument."
	printHelp
	exit 0
else
	if [ ! -f "$3" ]; then
		echo "[FAIL] Argument 3 '$3' is not a file. A CSV  file that provides a" 
		printHelp
		exit 0
	fi		
fi	

if [ ! -d "$4" ]; then
	echo "[FAIL] Argument 4 '$4' is not a directory."
	printHelp
	exit 0
fi


if [ "$5" ]; then
  if [ "$5" = "true" ]; then
    echo "[INFO] Tests will be skipped when packaging using -DskipTests"
    SKIP="true"
  else
    echo "[WARNING] Fifth argument was provided, but it is not 'true'." 
    echo "          Tests will run when building mvn "
  fi  
else
   echo "[INFO] 5th argument was not provided. Tests will not be skipped."
fi


pwdd=$(pwd)

TE_BASE=$1
TE=$2
ETS_FILE=$3
temp=$4


logfile=log.txt
echo ""

echo "[INFO] The provided TE_BASE directory, TEAMEngine directory and CSV file appeared to be fine."
# continue is everything is fine	

echo '[INFO] Removing all tests from TE_BASE'
rm -rf $TE_BASE/scripts/* 1> /dev/null 2>&1;

OLDIFS=$IFS
IFS=","


csvfile=$ETS_FILE
{
	# skip the first line
	echo "[INFO] Reading $ETS_FILE"
	read
	
	while read url tag
	do
		if [ ! "$url" = "Repository" ] && [ ! "$url" = "" ]; then
			echo '[INFO] Found ' $url $tag
			cd $pwdd
			if [ "$url" ]; then
				
				echo '[INFO] Processing ' $url $tag

				if [ -d  $temp ];
				then
					rm -rf $temp/* 1> /dev/null 2>&1;
				fi	
				
				cd $temp
				
				
				mss=$(git clone -q $url)

				
				if echo "$mss" | grep "fatal" ;
					then
						err="[ERROR] - repository doesn't exist: $url"
						echo "$err" >> $logfile
						echo "$err"
						exit 0

				fi	
				ets_name=$(basename "$url" .git)
				cd $ets_name
				tags=$(git tag)

				
				if echo "$tags" | grep -q "$tag"; 
				then
					echo "[INFO] $tag of $ets_name exists. Checking it out."
					git checkout $tag 1> /dev/null 2>&1;
		         install_mss=$($pwdd/build_test.sh $TE_BASE $TE $SKIP)
		         echo $install_mss
		         if echo "$install_mss" | grep "[FAIL]" ;
		         then
		         	fail_message=$fail_message"\n"$ets_name" "$tag
		         	failures=$(($failures + 1 ))
		         	

		         fi 	
		        
				else
					echo "[ERROR] TAG NOT FOUND tag:'$tag 'it was not build"
					echo "[ERROR] TAG NOT FOUND tag:'$tag 'it was not build" >> $logfile
				fi	
			fi
		fi
	done
} < $csvfile		 
IFS=$OLDIFS

if [ "$failures" -gt 0 ]; then
	echo "Total failures: "$failures
	echo $fail_message
	echo ""
fi

