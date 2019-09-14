@ECHO OFF

setlocal enabledelayedexpansion

set current_dir=%CD%
REM echo off


echo.
echo.
echo -------------------------------------
echo.

if "%1" == "-h" set res=%1
if "%1" == "-help" set res=%1
if DEFINED res (

call :printHelp

GOTO END
) 
::---------------------------------------------------------------

:loop
set param=%~1

if DEFINED param (

		if "%1"=="-a" (

			set te_tag=%~2
			shift
			
		) else if "%1"=="-b" (

			set base_folder=%2
			shift
		
		) else if "%1"=="-t" (

			set tomcat_base=%2
			shift
			
		) else if "%1"=="-w" (

			set war=%2
			shift
			
		)  else if "%1"=="-g" (

			set te_git_url=%2
			shift
			
		) else if "%1"=="-s" (

			set start=%2
			shift

		) else if "%1"=="-d" (

			set dev=%2
			shift
			
		) else if "%1"=="-f" (

			set folder_site=%2
			shift
			
		) else if "%1"=="-cb" (

			set catalinabasefolder=%2
			shift
		)


shift
GOTO :loop

) 

REM -- Checking pre-conditions for java, git, maven, tomcat is installed or not.

	if "!JAVA_HOME!" == "" (
		echo.
		echo "[FAIL] JAVA not found. Please install Git."
		echo.
		GOTO END
	)
	
	set "git_status=false"
	for /f "tokens=*" %%g in ( 'call git --version' ) do  echo %%g | findstr /lic:"git" >nul && set "git_status=true"
	if "!git_status!" == "false" (
		echo.
		echo "[FAIL] Git not found. Please install Git."
		echo.
		GOTO END
	)
	
	set "mvn_status=false"
	for /f "tokens=*" %%g in ( 'call mvn -version' ) do  echo %%g | findstr /lic:"maven" >nul && set "mvn_status=true"
	if "!mvn_status!" == "false" (
		echo.
		echo "[FAIL] Maven not found. Please install Maven."
		echo.
		GOTO END
	)
REM -- END Pre-conditions ---	

if DEFINED catalinabasefolder (

	 if exist !catalinabasefolder! (
	 
		echo "[INFO] Using catalinabasefolder: " !catalinabasefolder!
		
	) else if DEFINED tomcat_base (

		if exist "!tomcat_base!\bin\catalina.bat" (
			call :realpath !tomcat_base!
			set tomcat_base=!tomcat_base!
			echo "[INFO] Using tomcat:!tomcat_base! " 
		) else (
			echo "[FAIL] Please provide a correct tomcat location, e.g. C:\apache-tomcat-8.0.26" 
			echo.
			echo.
			call :printHelp
			 GOTO END
			)
			
    ) else  (
		echo.
		echo.
		echo "[FAIL] Please provide a correct tomcat installation or CATALINA_BASE folder"
		echo ""
		echo.
	   call :printHelp
	   GOTO END
	  )
)
  
if DEFINED dev (
	  echo "[INFO] Running in development mode. The local source to be used is "!dev!
	  SET te_git_url=
	  SET te_tag=
	  
	) else if DEFINED te_git_url (

		  echo "[INFO] Using git url: " !te_git_url!
		  ) else (

		  echo  "[INFO] The git url  was not provided,  so 'https://github.com/opengeospatial/teamengine.git' will be used"
		  SET te_git_url=https://github.com/opengeospatial/teamengine.git
	  ) 
	  
	 if DEFINED te_tag (
		echo "[INFO] Building " !te_tag!
		) else (
		echo "[INFO] Did not provide a tag to build 'te_tag', so building master"
		SET "te_tag=master"
	  )    
)
:: If a a specific tag or branch is not given then the master will be built

if DEFINED base_folder (

	  if EXIST !base_folder! (
		call :realpath !base_folder!
		SET base_folder=!base_folder!
		echo "[INFO] Building in a fresh base folder: " !base_folder!
		) else (
		 echo "[FAIL] Base folder doesn't exist" !base_folder!
		 GOTO END
		  )  
	) else (
	  echo "[INFO] Base folder was not provided, so it will attempt to build in the user's directory 'C:\te-build'"
	  if NOT EXIST "C:\te-build" (
	   mkdir C:\te-build
	  )  
 SET "base_folder=C:\te-build" 
)

echo "[INFO] Using Base folder: !base_folder!" 

	if DEFINED war (
	  echo "[INFO] Using war name: " !war!
	) else (
			echo "[INFO] War name was not provide, so 'teamengine' will be used"
			SET "war=teamengine"
		)

	if DEFINED start (
		if "!start!" == "true" (
		echo "[INFO] tomcat will start after installing !start!"
		) else (
			SET "start=false"
		)
	)

:: optional: contains body, header and footer for the welcome page
	if DEFINED folder_site (

	  echo "[INFO] The folder to be used to create custom site content is : " !folder_site!
	  call :realpath !folder_site!
	  SET folder_site=!folder_site!
	) else (
	  SET "folder_site=!current_dir!\site"
	::  folder_site=realpath $folder_site/
	  echo "[INFO] The folder site was not provided, so folder_site will be used: " !folder_site!
	)


	
	SET folder_to_build=!base_folder!

	:: location of tomcat
	SET tomcat=!tomcat_base!

	:: Contains example of a user: ogctest, ogctest
	SET user_temp_folder=!current_dir!\users

	:: no need to change anything else hereafter

::----------------------------------------------------------##

	:: Define more variables

	SET war_name=!war!

	:: ----------------------------------------------------------
	:: clean 
	echo "[INFO] - cleaning - removing folder to build "!folder_to_build!
	
	if EXIST !folder_to_build! (
	  xcopy !folder_to_build! "!folder_to_build!.bak" /s /h /q /i /y
	  pushd !folder_to_build!
	  SET "STATUS="
	  REM Check if the files or dir are exists in the dir !folder_to_build!
	  for /f %%A in ('dir /b !folder_to_build!\*.*') do set "STATUS=exists"
	  if "!STATUS!" == "exists" (
	  
		  for /f "Tokens=*" %%A in ('dir /B /S /A:-D^|FIND /V "%~nx0"') do del /q "%%A"
		 rem cd !folder_to_build!
		  
		   for /f "Tokens=*" %%A in ('dir /B /A:D') do rd /q /s "%%A"
		)  
		
	 popd
	)
	
::------------------------------------------------------------	

::-----------------------------------------------
::	Install TeamEngine depend on dev
::-----------------------------------------------

	echo "[INFO] Installing TEAM Engine "
	cd /d !folder_to_build!
	:: if dev is not given
	if NOT DEFINED dev (
	  
		REM rd /s /q teamengine
		REM download TE 
		REM  git clone !te_git_url! teamengine
		REM for /f "delims=" %%i in ('git clone !te_git_url! teamengine') do set git_message=%%i
		git clone !te_git_url! teamengine
		
		  If !errorlevel! NEQ 0 (
			
			set err="[FAIL] - Repository doesn't exist: !te_git_url!"
			echo "!err!"
			GOTO END
		  )
			
			cd /d !folder_to_build!\teamengine 

		if "!te_tag!"=="master" (
			echo "[INFO] Checking out: master branch "
	  
		) else (
  
			git tag >tag.txt
						
			FIND /I "!te_tag!" tag.txt>Nul && ( 
				Echo "Found TAGS..."
				set tags=true
			) || (
				Echo "Did not find TAGS...."
				set tags=false
				)
			  del tag.txt	
			
			If  "!tags!"=="true" (
				set "found=tag"				
			) else (
				
					echo "Tag !te_tag! not found, so looking for branches"
				  
					git branch -a >branch.txt
										
					FIND /I "!te_tag!" branch.txt>Nul && ( 
						set branch=true
					) || (
						set branch=false
						)
					del branch.txt
					If "!branch!"=="true" (
						SET "found=branch"
						
					) else ( 
						echo "[FAIL] Branch or Tag !te_tag! not found";
						
						GOTO END
						) 
			)
			echo "[INFO] Checking out: !te_tag! !found!"

		)
 
		git checkout !te_tag!
  
		echo "[INFO] Building using Maven in quiet mode (1-2 min)"
		call mvn -q clean install -DskipTests=true
		
	) else (
			echo "[INFO] Running development mode - building from local folder"
			if EXIST teamengine (
			rd /s /q teamengine
			)
			if EXIST !dev! (
				if NOT EXIST !folder_to_build!\teamengine (
					echo "!folder_to_build!\teamengine"	
					echo "Directory created successfuly"
					mkdir "!folder_to_build!\teamengine" 
				) 
				echo "[INFO] Copying from  !dev! to !folder_to_build!"
				
				xcopy !dev! "!folder_to_build!\teamengine" /s /h /q
				cd /d !folder_to_build!\teamengine
				
				echo "[INFO] Building using Maven in quiet mode (1-2 min)"
				call mvn -q clean install -DskipTests=true
		
			) else (
					echo "[FAIL] !dev! doesn't seems to be a local folder. It should for example C:\repo\directory.."  
					rem exit
					GOTO END
				) 
		)

	echo "[INFO] TE has been installed and built successfully"
	echo.
	
	
echo ----------------------------------------------------------------------------
echo    Building CATALINA_BASE
echo ----------------------------------------------------------------------------	
	
	if NOT DEFINED catalinabasefolder (
			  echo "[INFO] Now building catalina_base "
			  cd /d !folder_to_build!
			  
			  SET "catalina_base=!folder_to_build!\catalina_base" 

			  if EXIST !catalina_base! (
				
				pushd !catalina_base!
				for /f "Tokens=*" %%A in ('dir /B /S /A:-D^|FIND /V "%~nx0"') do del /q "%%A"
				popd
				rd /q !catalina_base!
				REM del X /f /s /q !catalina_base!
				REM rd X /s /q !catalina_base!
			  ) 
			  mkdir !catalina_base!
			  echo "[INFO] clean, create and populate catalina base in !catalina_base!" 

			  cd /d !catalina_base!
			  mkdir bin logs temp webapps work lib conf
			  
			  REM copy from tomcat bin and base files
			  xcopy !tomcat!\bin\catalina.bat bin\ /s /h /q
			 
			  xcopy !tomcat!\conf conf\ /s /h /q
			  
		) else (
			  SET "catalina_base=!catalinabasefolder!"
			)
		
:: ----------------------------------------------------------------------------
::  Setup TE_BASE and copy war and common lib to CATALINA_BASE
:: ----------------------------------------------------------------------------		
		
		echo "[INFO] copying war: !war_name! in !catalina_base!\webapps\"
		REM move tomcat to catalina_base

		
		rem del /f /s /q !catalina_base!\webapps
		rem  rd /s /q !catalina_base!\webapps
		rem  md !catalina_base!\webapps
		pushd !catalina_base!\webapps
		REM   Delete files and sub directories
		SET "STATUS="
		REM Check if the files or dir are exists in the dir !folder_to_build!
		for /f %%A in ('dir /b !catalina_base!\webapps\*.*') do set "STATUS=exists"
		  if "!STATUS!" == "exists" (
			
			for /f "Tokens=*" %%A in ('dir /B /S /A:-D^|FIND /V "%~nx0"') do del /q "%%A"
			for /f "Tokens=*" %%A in ('dir /B /A:D') do rd /s /q "%%A"
		)
		popd
		
		copy "!folder_to_build!\teamengine\teamengine-web\target\teamengine.war" "!catalina_base!\webapps\!war_name!.war"
		
		echo "[INFO] unzipping  common libs in !catalina_base!\lib "


	pushd !catalina_base!\lib
	
	jar xf !folder_to_build!\teamengine\teamengine-web\target\teamengine-common-libs.zip
	
	popd

		echo "[INFO] building TE_BASE"

		cd /d !catalina_base!
		
		if EXIST !catalina_base!\TE_BASE (
		rd /s /q !catalina_base!\TE_BASE
		)
		mkdir !catalina_base!\TE_BASE
		SET "TE_BASE=!catalina_base!\TE_BASE"

		REM  get the file that has base zip and copy it to TE_BASE
		cd /d !folder_to_build!\teamengine\teamengine-console\target

		FOR %%f IN (!folder_to_build!\teamengine\teamengine-console\target\*base.zip) DO SET "base_zip=%%~nxf"
	
		pushd !TE_BASE!
	
		jar xf !folder_to_build!\teamengine\teamengine-console\target\!base_zip!
	
		popd

		echo "[INFO] copying sample of users"
		
		xcopy !user_temp_folder! !TE_BASE!\users /s /q /y

		echo "[INFO] updating !TE_BASE!\resources\site" 
		REM The folder_site contains body, header and footer to customize TE.
		
		if EXIST !folder_site! (  
			del !TE_BASE!\resources\site /q
			rd !TE_BASE!\resources\site /s /q
			md !TE_BASE!\resources\site

			xcopy !folder_site! !TE_BASE!\resources\site /s /h /q
  
		) else (
				echo "[WARNING] the following folder for site was not found: '!folder_site!'. Site was not updated with custom information"
			)

		if DEFINED catalinabasefolder (
		
		REM ------ Update current TE_BASE path into setenv.bat file -------------
			move !catalina_base!\bin\setenv.bat !catalina_base!\bin\setenv.bat.old
			
			type !catalina_base!\bin\setenv.bat.old | findstr /v \-DTE_BASE >> !catalina_base!\bin\setenv.bat
			
			echo SET CATALINA_OPTS=-server -Xmx1024m -XX:MaxPermSize=128m -DTE_BASE=!TE_BASE! >> !catalina_base!\bin\setenv.bat
			del  !catalina_base!\bin\setenv.bat.old
		  echo "[SUCCESS] TE build successfully"
		  echo "[INFO] Now start tomcat depending on your configuration"
		  GOTO END
		)
		
		
		echo '[INFO] creating setenv with environmental variables'
		cd !catalina_base!\bin

		 (
		echo rem !/bin/sh
		echo rem path to java jdk
		echo set JAVA_HOME=!JAVA_HOME!
		echo rem This file creates requeried environmental variables 
		echo rem to properly run teamengine in tomcat
		echo.
		echo rem path to tomcat 
		echo SET CATALINA_HOME=!tomcat!
		echo.
		echo rem path to server instance 
		echo SET CATALINA_BASE=!catalina_base!
		echo.
		echo rem catalina options
		echo SET CATALINA_OPTS=-server -Xmx1024m -XX:MaxPermSize=128m -DTE_BASE=!TE_BASE!
		 
		 ) >setenv.bat


		echo "[SUCCESS] TE build successfully"
		echo "[INFO] TE_BASE is !TE_BASE!"
		echo "[INFO] catalina_base was built at !catalina_base!"
		echo "[INFO] to start run !catalina_base!/bin/catalina.bat start"  
		echo "[INFO] to stop run !catalina_base!/bin/catalina.bat stop"  


REM If you want the script to start catalina, remove (or comment) the exit command with caution. It will stop any tomcat process and will start catalina_base where teamengine.war was installed.

	if "!start!"=="true" (
		echo "[INFO] starting tomcat but first - check running tomcat processes.."

		netstat -na | find "LISTENING" | find /C /I ":8080">Nul && ( 
						Echo "Tomcat is running....."
						!catalina_base!\bin\catalina.bat stop 
						timeout /t 6
					) || (
						Echo "Tomcat is not running...."
						
						)
		
  echo "[INFO] ... starting tomcat ... "  
  !catalina_base!\bin\catalina.bat start   
)
		
		
		
::----------------------------------------------------------------
GOTO END

::-----------Get RealPath----------------- 
:realpath
set curr_dir=%1
cd !curr_dir!
set "%1=!curr_dir!"
GOTO END

:printHelp

  echo "---------"
  echo "Usage build_te [-t tomcat or -cb catalinabasefolder] [-options] "
  echo ""
  echo "There are two main ways to build."
  echo.
  echo "1. From scratch, Tomcat and catalina_base are not setup"
  echo "2. catalina_base is already setup"
  echo.
  echo ""
  echo "For the first case. -t parameter needs to be passed as argument." 
  echo "For the second case -cb needs to passed as argument."
  echo "It is mandatory to use one or the other."
  echo.
  echo.
  echo ""
  echo "where:"
  echo "  tomcat                    Is the path to tomcat, e.g. C:\apache-tomcat-7.0.52"
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
  echo "    build_te.bat -t C:\apache-tomcat-7.0.57 "
  echo "    build_te.bat -t C:\apache-tomcat-7.0.57 -a 4.1.0b -w /temp/te"
  echo "    build_te.bat -t C:\apache-tomcat-7.0.57 "
  echo "    build_te.bat -t C:\apache-tomcat-7.0.57 -d C:\teamengine\ -s true"
  echo "" 
  echo "more information about TEAM Engine at https://github.com/opengeospatial/teamengine/  "
  echo "more information about this builder at https://github.com/opengeospatial/teamengine-builder/ "
  echo "----------" 

GOTO END

:END

