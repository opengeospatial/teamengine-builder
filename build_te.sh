#!/bin/sh



echo "" 
dir=$(pwd)

realpath(){
  thedir=$1
  cd $thedir
  pwd

}

printHelp(){

  echo "---------"
  echo "Usage build_te [-t tomcat or -cb catalinabasefolder] [-options] "
  echo ""
  echo "There are two main ways to build."
  echo "1. From scratch, Tomcat and catalina_base are not setup"
  echo "2. catalina_base is already setup"
  echo ""
  echo "For the first case. -t parameter needs to be passed as argument." 
  echo "For the second case -cb needs to passed as argument."
  echo "It is mandatory to use one or the other."
  echo ""
  echo "where:"
  echo "  tomcat                    Is the path to tomcat, e.g. /home/ubuntu/apache-tomcat-7.0.52"
  echo "  catalinabasefolder        Is the path to the CATALINA_BASE directory. It should contain "
  echo "                            webapps and lib folders, amongst others."
  echo ""
  echo "where options include:"
  echo "  -g (or --git-url)         URL to a git repository (local or external) for the  TEAM Engine source"
  echo "                            For example: https://github.com/opengeospatial/teamengine.git"
  echo "                            If not provided, then this URL will be used:"
  echo "                            https://github.com/opengeospatial/teamengine.git"
  echo ""
  echo "  -a (or --tag-or-branch)   To build a specific tag or branch."
  echo "                            If not provided, then master will be used."
  echo ""
  echo "  -b (or --base-folder)     Local path where teamengine will be build from scratch."
  echo "                            If not given, then  ~/te-build will be used."
  echo ""
  echo "  -w (or --war)             War name"
  echo "                            If not given, then 'teamengine' will be used."
  echo ""
  echo "  -s (or --start)           If 'true', then the build will attempt to stop" 
  echo "                            a tomcat a process and will start again tomcat."
  echo ""
  echo "  -d (or --dev)             Local directory to build from to run in development mode." 
  echo "                            It will build from the source at the given path. No 'git pull' is issued."
  echo "                            If the parameters -g and -a are also provided, then they will not be used"
  echo ""
  echo "  -f (or -folder_site)      If given, it will build with the provided site folder, if not it will"
  echo "                            use a folder 'site' located in the same directory of this script"
  echo "                            The site folder customizes the look and feel, welcome page, etc."
  echo ""
  echo " Examples:"
  echo "    ./build_te.sh -t /Applications/apache-tomcat-7.0.57 "
  echo "    ./build_te.sh -t /Applications/apache-tomcat-7.0.57 -a 4.1.0b -w /temp/te"
  echo "    ./build_te.sh -t /Applications/apache-tomcat-7.0.57 "
  echo "    ./build_te.sh -t /Applications/apache-tomcat-7.0.57 -d /Users/mike/git/teamengine/ -s true"
  echo "" 
  echo "more information about TEAM Engine at https://github.com/opengeospatial/teamengine/  "
  echo "more information about this builder at https://github.com/opengeospatial/teamengine-builder/ "
  echo "----------" 
exit 0

}

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  printHelp

fi 


while [ "$1" ]; do
  key="$1"

  case $key in
      -a|--tag-or-branch)
      te_tag="$2"
      shift
      ;;
      -b|--base-folder)
      base_folder="$2"
      shift
      ;;
      -t|--tomcat)
      tomcat_base="$2"
      shift
      ;;
      -w|--war)
      war="$2"
      shift
      ;;
      -g|--git-url)
      te_git_url="$2"
      shift
      ;;
      -s|--start)
      start="$2"
      shift
      ;;
      -d|--dev)
      dev="$2"
      shift
      ;;
      -f|--folder_site)
      folder_site="$2"
      shift
      ;;
      -cb|--catalina_base)
      catalinabasefolder="$2"
      shift
      ;;

      
      
      
  esac
  shift
done  

#--------- Check pre-condtions for the java, git, maven, tomcat.


if echo $(java -version 2>&1) | grep -q -v "java"; then
	echo ""
	echo "[ERROR] Java not found. Please install JAVA."
	echo ""
	exit 0
fi

if echo $(mvn -version 2>&1) | grep -q -v "maven"; then
	echo ""
	echo "[ERROR] Maven not found. Please install Maven."
	echo ""
	exit 0
fi

if echo $(git -version 2>&1) | grep -q -v "git"; then
	echo ""
	echo "[ERROR] Git not found. Please install git."
	echo ""
	exit 0
fi

#--- End of pre-conditions. -----

if [ $catalinabasefolder ];
then
  if [ -d $catalinabasefolder ];
  then 
    echo "[INFO] Using catalinabasefolder: " $catalinabasefolder
  fi  
else
  if [ $tomcat_base ];
  then
    if [ -f $tomcat_base/bin/catalina.sh ]; then
    tomcat_base=$(realpath $tomcat_base)
    echo "[INFO] Using tomcat: " $tomcat_base


    else
        echo "[FAIL] Please provide a correct tomcat location, e.g. /home/ubuntu/apache-tomcat-7.0.52." 
        printHelp
    fi
  else
    echo "[FAIL] Please provide a correct tomcat installation or CATALINA_BASE folder"
    echo ""
    printHelp
      
  fi
fi   


if [ $dev ]; then
  echo "[INFO] Running in development mode. The local source to be used is "$dev
  te_git_url=""
  te_tag=""

else

  if [ $te_git_url ];
  then
      echo "[INFO] Using git url: " $te_git_url
  else

      echo  "[INFO] The git url  was not provided,  so 'https://github.com/opengeospatial/teamengine.git' will be used"
      te_git_url=https://github.com/opengeospatial/teamengine.git
  fi  

  if [ $te_tag ];
  then
    echo "[INFO] Building " $te_tag
  else
    echo "[INFO] Did not provide a tag to build 'te_tag', so building master"
    te_tag="master"
  fi    

  
fi  


# If a a specific tag or branch is not given then the master will be built



if [ $base_folder ];
then   
  if [ -d $base_folder ]; then
    base_folder=$(realpath $base_folder)
    echo "[INFO] Building in a fresh base folder: " $base_folder
  else
     echo "[FAIL] Base folder doesn't exist" $base_folder
     exit 0
        
  fi 

else
  echo "[INFO] Base folder was not provided, so it will attempt to build in the user's directory '~/te-build'"
  if [ ! -d  ~/te-build ]; then
   mkdir -p ~/te-build
  fi  
  base_folder=~/te-build  


fi
echo "[INFO] Using Base folder: $base_folder" 


if [ $war ];
then
  echo "[INFO] Using war name: " $war
else
  echo "[INFO] War name was not provide, so 'teamengine' will be used"
  war=teamengine
fi   



if $start ; then
    if [ "$start" = "true" ]; then
    echo "[INFO] tomcat will start after installing $start"
    fi
else
  $start="false"    
fi    


## optional: contains body, header and footer for the welcome page
if [ $folder_site ];
then
  echo "[INFO] The folder to be used to create custom site content is : " $folder_site 
  folder_site=$(realpath $folder_site)
else

  folder_site=$dir/site
##  folder_site=realpath $folder_site/
  echo "[INFO] The folder site was not provided, so $folder_site will be used: " 
fi

 

folder_to_build=$base_folder

## location of tomcat
tomcat=$tomcat_base

## Contains example of a user: ogctest, ogctest
user_temp_folder=$dir/users

## no need to change anything else hereafter

##----------------------------------------------------------##

# Define more variables

war_name=$war
#repo_te=$folder_to_build/build




##  clean 
echo "[INFO] - cleaning - removing folder to build "$folder_to_build
if [ -d $folder_to_build ]; 
then
  cp -f $folder_to_build $folder_to_build.bak
  rm -rf $folder_to_build/*
  
fi  




echo "[INFO] Installing TEAM Engine "
cd $folder_to_build
# if dev is not given
if [ ! $dev ] ; then
  rm -rf teamengine
  ## download TE 
  git clone $te_git_url teamengine
  mss=$(git clone $te_git_url teamengine)

  if echo "$mss" | grep "fatal" ;
  then
    err="[FAIL] - Repository doesn't exist: $te_git_url"
    echo "$err"
    exit 0

  fi  

  cd $folder_to_build/teamengine 

  if [ "$te_tag" = "master" ];then
    echo "[INFO] Checking out: master branch "
  
  else
    tags=$(git tag)

    if echo "$tags" | grep -q "$te_tag"; then
        found="tag"
    else
      echo "Tag $te_tag not found, so looking for branches"
      branches=$(git branch -a)
      if echo "$branches" | grep -q "$te_tag"; then
        found="branch"
       else 
        echo "[FAIL] Branch or Tag $te_tag not found";
          exit
       fi   
    fi
    echo "[INFO] Checking out: $te_tag $found"

   fi 
 
  git checkout $te_tag 
  
  echo "[INFO] Building using Maven in quite mode (1-2 min)"
  mvn -q clean install -DskipTests=true
  

else
  echo "[INFO] Running development mode - building from local folder"
  if [ -d $dev ]; then
    if [ ! -d $folder_to_build/teamengine ]; then  
      mkdir $folder_to_build/teamengine 
    fi  
    echo "[INFO] Copying from  $dev to $folder_to_build"
    ##cp -rf $dev $folder_to_build/teamengine
    cp -rf $dev/* $folder_to_build/teamengine
    cd $folder_to_build/teamengine
    mvn -q clean install -DskipTests=true
    
  else
    echo "[FAIL] $dev doesn't seems to be a local folder. It should for example /users/home/.."  
    exit
    
  fi  
fi  


echo "[SUCCESS] TE has been installed and built successfully"
echo " "

if [ ! $catalinabasefolder ];
then
  echo "[INFO] Now building catalina_base "
  cd $folder_to_build
  catalina_base=$folder_to_build/catalina_base 

  if [ -d $catalina_base ]; then
    rm -rf $catalina_base
  fi  

  mkdir -p $catalina_base
  echo "[INFO] clean, create and populate catalina base in $catalina_base" 

  cd $catalina_base
  mkdir bin logs temp webapps work lib

  ## copy from tomcat bin and base files
  cp $tomcat/bin/catalina.sh bin/
  cp -r $tomcat/conf $catalina_base
else
  catalina_base=$catalinabasefolder 
fi

echo "[INFO] copying war: $war_name in $catalina_base/webapps/"
## move tomcat to catalina_base

#echo "updating war file with custom source" - not working
#jar -uvf $folder_to_build/teamengine/teamengine-web/target/teamengine.war $folder_site

rm -rf $catalina_base/webapps/*
mkdir -p $catalina_base/webapps
cp $folder_to_build/teamengine/teamengine-web/target/teamengine.war $catalina_base/webapps/$war_name.war

echo "[INFO] unzipping  common libs in $catalina_base/lib "
unzip -q -o $folder_to_build/teamengine/teamengine-web/target/teamengine-common-libs.zip -d $catalina_base/lib

echo "[INFO] building TE_BASE"

cd $catalina_base
rm -rf TE_BASE
mkdir -p $catalina_base/TE_BASE
export TE_BASE=$catalina_base/TE_BASE 

## get the file that has base zip and copy it to TE_BASE
cd $folder_to_build/teamengine/teamengine-console/target/
base_zip=$(ls *base.zip | grep -m 1 "base")
unzip -q -o $folder_to_build/teamengine/teamengine-console/target/$base_zip -d $TE_BASE

echo "[INFO] copying sample of users"
cp -rf $user_temp_folder/ $TE_BASE/users

echo "[INFO] updating $TE_BASE/resources/site" 
# The folder_site contains body, header and footer to customize TE.
if [ -d "$folder_site" ];then

  rm -r $TE_BASE/resources/site/*
  cp -rf $folder_site/* $TE_BASE/resources/site
  
 else
  echo "[WARNING] the following folder for site was not found: '$folder_site'. Site was not updated with custom information"
fi

if [ $catalinabasefolder ]; then
  echo "[SUCCESS] TE build successfully"
  echo "[INFO] Now start tomcat depending on your configuration"
  exit 0
fi

echo '[INFO] creating setenv with environmental variables'
cd $catalina_base/bin
touch setenv.sh
cat <<EOF >setenv.sh
#!/bin/sh
## This file creates requeried environmental variables 
## to properly run teamengine in tomcat

## path to tomcat 
export CATALINA_HOME=$tomcat

## path to server instance 
export CATALINA_BASE=$catalina_base

## catalina options
export CATALINA_OPTS='-server -Xmx1024m -XX:MaxPermSize=128m -DTE_BASE=$TE_BASE -Dderby.system.home=$catalina_base/derby_data'
EOF

chmod 777 *.sh
echo "[SUCCESS] TE build successfully"
echo "[INFO] TE_BASE is $TE_BASE"
echo "[INFO] catalina_base was built at $catalina_base"
echo "[INFO] to start run $catalina_base/bin/catalina.sh start"  
echo "[INFO] to stop run $catalina_base/bin/catalina.sh stop"  


## If you want the script to start catalina, remove (or comment) the exit command with caution. It will stop any tomcat process and will start catalina_base where teamengine.war was installed.


if [ "$start" = "true" ]; then
  echo "[INFO] starting tomcat but first - check running tomcat processes.."
  # gets the first process found "
#  pid=$(ps axuw | grep tomcat | grep -v grep |  awk 'END{print $2'})
  pid=$(ps axuw | grep tomcat | grep -v grep)
  echo "pid is $pid"
  pidn=$(ps axuw | grep tomcat | grep -v grep | wc -l)
  echo " "
  echo "[INFO] number or processes: $pidn"
  if [ $pidn -gt 1 ]; then
    pidlast=$(ps axuw | grep tomcat | grep -v grep | awk 'END{print $2'})
    kill -9 $pidlast
    echo "[INFO] process $pidlast was terminated"
    sleep 4

  else
    echo "[INFO] Tomcat processes not found"
  fi  
  


  echo "[INFO] ... starting tomcat ... "  
  $catalina_base/bin/catalina.sh start   
fi



