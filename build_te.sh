#!/bin/sh

if [ "$1" == "-h" -o "$1" == "--help" ]; then

  echo ""
  echo "Usage build_te -t tomcat [-options] "
  echo ""
  echo "where:"
  echo "  tomcat                    is the path to tomcat, e.g. /home/ubuntu/apache-tomcat-7.0.52"
  echo ""
  echo "where pptions include:"
  echo "  -g (or --git-url)         URL to a git repository (local or external) for the  TEAM Engine source"
  echo "                            for example: https://github.com/opengeospatial/teamengine.git"
  echo "  -a (or --tag-or-branch)   to build a specific tag or branch"
  echo "  -b (or --base-folder)     local path where teamengine will be build from scratch."
  echo "                            If not given ~/te-build will be used."
  echo "  -w (or --war)             local path where teamengine will be build from scratch."
  echo "                            If not given teamengine will be used"
  echo "  -s (or --start)           if provided it will attempt to stop a tomcat a process and start it again
  echo " Example:"
  echo "    ./build_te.sh -t /Applications/apache-tomcat-7.0.57 -a 4.1.0b -w super-testing-server"
  echo ""
  echo "more information about TEAM Engine at https://github.com/opengeospatial/teamengine/  "
exit 0

fi 

while [ "$1" != "" ]; do
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
      start="true"
      shift
      ;;

      
      
      
  esac
  shift
done    

# If a a specific tag or branch is not given then the master will be built

if [ $te_tag ];
then
  echo "Building " $te_tag
else
  echo "Did not provide te_tag, it should be the first parameter, building master"
  te_tag="master"
fi    

if [ $base_folder ];
then   
  if [ -d $base_folder ]; then
    echo "Building in base folder: " $base_folder. "Note that the folder will be re-created"

    else
      echo "Base folder was not found. For example, provide a base folder like this: -b ~/te-build"
      exit
  fi 
else
  echo "Since the base folder was not provided it will be build in the user's directory '~/te-build'"
 

  if [ ! -d  ~/te-build ]; then
   mkdir -p ~/te-build
  fi  
  base_folder=~/te-build  


fi
echo "Using Base folder: $base_folder" 

if [ $tomcat_base -a -d $tomcat_base ];
then
  echo "Using tomcat: " $tomcat_base
else
  echo "Please provide a correct tomcat location, e.g. /home/ubuntu/apache-tomcat-7.0.52"
  exit
fi   

if [ $war ];
then
  echo "Using war name: " $war
else
  echo "Since the war name was not provide, 'teamengine' will be used"
  war=teamengine
fi   

if [ $te_git_url ];
then
    echo "Using git url name: " $te_git_url
else
    echo  "Since the git url  was not provide, 'https://github.com/opengeospatial/teamengine.git' will be used"
    te_git_url=https://github.com/opengeospatial/teamengine.git
fi  

dir=$(pwd)



 

folder_to_build=$base_folder

## location of tomcat
tomcat=$tomcat_base

## optional: contains body, header and footer for the welcome page
folder_site=$dir/site

## Contains example of a user: ogctest, ogctest
user_temp_folder=$dir/users

## no need to change anything else hereafter

##----------------------------------------------------------##

# Define more variables
catalina_base=$folder_to_build/catalina_base 
war_name=$war
#repo_te=$folder_to_build/build





##  clean 
if [ -d $folder_to_build ]; 
then
  echo "backing up $folder_to_build "
  mv -f $folder_to_build $folder_to_build.bak
  rm -rf $folder_to_build
fi  

mkdir $folder_to_build
echo "dir created " $folder_to_build



## download TE 
echo "downloading and installing TE"
cd $folder_to_build
git clone $te_git_url


cd $folder_to_build/teamengine 
tags=$(git tag)

if echo "$tags" | grep -q "$te_tag"; then
    echo "Tag $te_tag found, trying a branch";
else
  echo "Tag $te_tag not found";
  echo "looking for branches"
  branches=$(git branch -a)
  if echo "$branches" | grep -q "$te_tag"; then
    echo "found branch"
   else 
    echo "Branch $te_tag not found";
      exit
   fi   
fi




git checkout $te_tag
echo "TE branch is: " $te_tag
echo "Building using Maven in quite mode (1-2 min)"
mvn -q package -DskipTests=true

echo "----- TE has been downloaded and built successfully"
echo " "


cd $folder_to_build

echo "clean, create and populate catalina base" 
rm -rf $catalina_base
mkdir -p $catalina_base
cd $catalina_base
mkdir bin logs temp webapps work lib

## copy from tomcat bin and base files
cp $tomcat/bin/catalina.sh bin/
cp -r $tomcat/conf $catalina_base

echo "copying war: $war_name in $catalina_base/webapps/"
## move tomcat to catalina_base

#echo "updating war file with custom source" - not working
#jar -uvf $folder_to_build/teamengine/teamengine-web/target/teamengine.war $folder_site

echo "moving war to catalina_base"

cp $folder_to_build/teamengine/teamengine-web/target/teamengine.war $catalina_base/webapps/$war_name.war

echo "unzipping  common libs in $catalina_base/lib "
unzip -q -o $folder_to_build/teamengine/teamengine-web/target/teamengine-common-libs.zip -d $catalina_base/lib

echo "building TE_BASE"

mkdir -p $catalina_base/TE_BASE
export TE_BASE=$catalina_base/TE_BASE 

## get the file that has base zip and copy it to TE_BASE
cd $folder_to_build/teamengine/teamengine-console/target/
base_zip=$(ls *base.zip | grep -m 1 "base")
unzip -q -o $folder_to_build/teamengine/teamengine-console/target/$base_zip -d $TE_BASE

echo "copying sample of users"
cp -rf $user_temp_folder/ $TE_BASE/users

echo "updating $TE_BASE/resources/site" 
# The folder_site contains body, header and footer to customize TE.
if [ -d "$folder_site" ];then

  rm -r $TE_BASE/resources/site
  cp -rf $folder_site $TE_BASE/resources/site
  
 else
  echo "the following folder for site was not found: '$folder_site'. site was not updated"
fi


echo 'creating setenv with environmental variables'
cd $catalina_base/bin
touch setenv.sh
cat <<EOF >setenv.sh
#!/bin/sh
## path to tomcat installation to use
export CATALINA_HOME=$tomcat

## path to server instance to use
export CATALINA_BASE=$catalina_base
export CATALINA_OPTS='-server -Xmx1024m -XX:MaxPermSize=128m -DTE_BASE=$TE_BASE'
EOF

chmod 777 *.sh




echo "catalina_base was built at" $catalina_base 
echo 'to start run: '$catalina_base'/bin/catalina.sh start'  
echo 'to stop run: '$catalina_base'/bin/catalina.sh stop'  


## If you want the script to start catalina, remove (or comment) the exit command with caution. It will stop any tomcat process and will start catalina_base where teamengine.war was installed.

if $start ; then
  ## Stops TE if running
  pid=$(ps axuw | grep tomcat | grep -v grep |  awk '{print $2}')
  if [ "${pid}" ]; then
    eval "kill ${pid}"
  fi

  sleep 3


  #starts teamengine
  $catalina_base/bin/catalina.sh start   
fi

