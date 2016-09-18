@echo OFF


REM Builds a test from the test directory.
REM Two arguments are required:
REM TE_BASE directory
REM TEAM Engine deployment directory


setlocal enabledelayedexpansion

set TE_BASE=%1

	if NOT DEFINED TE_BASE (
		echo.
		echo [FAIL] Require a directory where TE_BASE is located, as the fist argument.
		echo.
		GOTO END
	) else if NOT EXIST "!TE_BASE!" (
		echo.
		echo [FAIL] Argument 1 '!TE_BASE!' is not a directory. The TE_BASE directory is required.
		echo.
		GOTO END	
	)

set TE=%2
	
	if NOT DEFINED TE (
		echo.
		echo [FAIL] Require a directory where TEAM Engine has been deployed as a war file, as the second argument.
		echo.
		GOTO END
	) else if NOT EXIST "!TE!" (
		echo.
		echo [FAIL] Argument 2 '!TE!' is not a directory.
		echo        A directory where TEAM Engine has been deployed as a war file, is required.
		echo.
		GOTO END	
	)

set status=%3
	
	if DEFINED status (
	
		if "!status!" == "true" (
			echo [INFO] Tests will be skipped when packaging using -DskipTests
			SET "SKIP=-DskipTests"
		) else (
			echo [WARNING] Third argument was provided, but is not 'true'. Tests will run when building"
		)
	) else (
		echo.
		echo [INFO] 3rd argument was not provided. Tests will not be skipped.
		echo.	
	)

	SET dir=%CD%
	echo "Build_test script current directory "!dir!
	FOR /f "tokens=1*delims=\/" %%i IN ("!url!") DO SET test_name=%%~nxj

	REM folder=~/te-build
	REM catalina_base=$folder/catalina_base
	REM TE_BASE=$catalina_base/TE_BASE
	REM webapps_lib=$catalina_base/webapps/teamengine/WEB-INF/lib
	SET webapps_lib=!TE!\WEB-INF\lib
	SET logfile=log-te-build-test.txt
	SET "errorlog=error-log.txt"

	if EXIST "!logfile!" (
			del /f /s /q !logfile!
	)

	if EXIST "!errorlog!" (
			del /f /s /q !errorlog!
	)
	
	
	:: Execute Maven Command to build the test and check whether it was success or fail.
	echo "[INFO] Building via MAVEN with this command:' mvn clean install !SKIP! '"
	call mvn clean install !SKIP! >!logfile!
	FINDSTR /L /C:"BUILD SUCCESS" !logfile! >nul 2>&1
	If %errorlevel% NEQ 0 (
		echo "[FAIL] Building of !dir! via MAVEN failed." 
		echo "       Details in !logfile!." 
		echo "!test_name!" >>!errorlog!
		GOTO END
	  
	) else (
		echo "[INFO] Building of !dir! via MAVEN was OK"
	)
	
	cd target
	
	for /f "delims=" %%i in ('dir /s/b *ctl.zip 2^>NUL') do set zip_ctl_file=%%i
	for /f "delims=" %%i in ('dir /s/b *dep.zip 2^>NUL') do set zip_deps_file=%%i
	if DEFINED zip_ctl_file (
		echo "DEPS File Name: " !zip_ctl_file!
		echo '[INFO] Installing' !zip_ctl_file! 'at'  !TE_BASE!\scripts
		PUSHD !TE_BASE!\scripts
		jar xf !zip_ctl_file!		
		POPD
		
		if DEFINED zip_deps_file (
			
			echo '[INFO] Installing' !zip_dep_file! 'at'  !webapps_lib!
			PUSHD !webapps_lib!
			jar xf !zip_deps_file!
			POPD
		)
		
	) else (
			echo '[FAIL] zip file not found: ' !zip_ctl_file!
			GOTO END
	)
	
	
	
GOTO END

:printHelp

  echo "Builds a test from the test directory."
  echo "Usage build_test.sh TE_BASE TEAM_ENGINE SKIP_TESTS"
  echo ""
  echo "where:"
  echo ""
  echo "  TE_BASE           is the  TE_BASE directory"
  echo "  TEAM_ENGINE       is the  TEAM_ENGINE directory"
  echo "  SKIP_TESTS        true or false to skip tests while building mvn"
  echo ""
  echo "More information: https://github.com/opengeospatial/teamengine-builder/"

GOTO END

:END
