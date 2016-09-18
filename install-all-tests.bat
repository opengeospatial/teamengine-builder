@echo OFF

setlocal enabledelayedexpansion

set pwdd=%CD%
set logfile=log.txt


set TE_BASE=%1

	if NOT DEFINED TE_BASE (
		echo.
		echo [FAIL] Require a directory where TE_BASE is located, as the fist argument.
		echo.
		call :printHelp
		GOTO END
	) else if NOT EXIST "!TE_BASE!" (
		echo.
		echo [FAIL] Argument 1 '!TE_BASE!' is not a directory. The TE_BASE directory is required.
		echo.
		call :printHelp
		GOTO END	
	)

set TE=%2
	
	if NOT DEFINED TE (
		echo.
		echo [FAIL] Require a directory where TEAM Engine has been deployed as a war file, as the second argument.
		echo.
		call :printHelp
		GOTO END
	) else if NOT EXIST "!TE!" (
		echo.
		echo [FAIL] Argument 2 '!TE!' is not a directory.
		echo        A directory where TEAM Engine has been deployed as a war file, is required.
		echo.
		call :printHelp
		GOTO END	
	)

set CSV=%3
	
	if NOT DEFINED CSV (
		echo.
		echo [FAIL] Require a CSV file that provides a git url and revision of the tests, as third argument.
		echo.
		call :printHelp
		GOTO END
	) else if NOT EXIST "!CSV!" (
		echo.
		echo [FAIL] Argument 3 '!CSV!' is not a file. A CSV  file that provides a git url and revision number.
		echo.
		call :printHelp
		GOTO END	
	)
	
set TEMP_DIR=%4
	
	if NOT DEFINED TEMP_DIR (
		echo.
		echo [FAIL] Require temporary directory to build tests.
		echo.
		call :printHelp
		GOTO END
	) else if NOT EXIST "!TEMP_DIR!" (
		echo.
		echo [FAIL] Argument 4 '!TEMP_DIR!' is not a directory.
		echo.
		call :printHelp
		GOTO END	
	)

set status=%5
	
	if DEFINED status (
	
		if "!status!" == "true" (
			echo [INFO] Tests will be skipped when packaging using -DskipTests
			SET "SKIP=true"
		) else (
			echo [WARNING] Fifth argument was provided, but it is not 'true'. 
			echo           Tests will run when building mvn 
		)
	) else (
		echo.
		echo [INFO] 5th argument was not provided. Tests will not be skipped.
		echo.	
	)	
	
echo.
echo [INFO] The provided TE_BASE directory, TEAMEngine directory and CSV file appeared to be fine.

:: continue is everything is fine	

echo '[INFO] Removing all tests from TE_BASE'

			if EXIST "!TE_BASE!\scripts\" (	
				pushd !TE_BASE!\scripts\
				for /f "Tokens=*" %%A in ('dir /B /S /A:-D^|FIND /V "%~nx0"') do del /q "%%A"
				popd
				REM rd /q !TE_BASE!\scripts\
			) else (
				echo [WARNING] the following directory was not found: '!TE_BASE!\scripts\'.
			)

	SET failures=0
	SET "fail_message="
	for /f "usebackq tokens=1-2 delims=," %%a in ("!CSV!") do (
		
		echo.
		echo.
		SET url=%%a
		SET tag=%%b
		SET res=false
		if NOT "!url!" == "Repository"  SET res=true
		if "!res!" == "true" (
			
			echo '[INFO] Found ' !url! !tag!
			cd !pwdd!
			
			if DEFINED url (
			
				echo '[INFO] Processing ' !url! !tag!
				echo "TEMP: " !TEMP_DIR!
				
				REM Delete all the data from the temp directory.
				if EXIST "!TEMP_DIR!" (	
					pushd !TEMP_DIR!
					for /f "Tokens=*" %%A in ('dir /B /S /A:-D^|FIND /V "%~nx0"') do del /s /q "%%A" >NUL 2>&1
					for /f "Tokens=*" %%A in ('dir /B /A:D') do rd /s /q "%%A" >NUL 2>&1
					popd
				)
				
				pushd !TEMP_DIR!
				
				call git clone !url! 2>nul
			
				If !errorlevel! NEQ 0 (
					SET "err=[ERROR] - Repository doesn't exist: !url!"
					echo !err! >>!logfile!
					echo "!err!"	
					GOTO END
				)
				
				REM Get the test name
				FOR /f "tokens=1*delims=\/" %%i IN ("!url!") DO SET basename=%%~nxj
				SET "ets_name=!basename:.="!^&REM #
				echo "[URL]:  " !ets_name!
				
				cd !ets_name!
				REM get all the tag list into array.
				for /F "delims=" %%f in ('call git tag') do (
				SET /a output_cnt+=1
				SET "output[!output_cnt!]=%%f"
				)
				
				SET NL=^ & echo.
				SET "tag_status=false"
				REM Check tag is exist or not.
				for /L %%n in (1 1 !output_cnt!) DO if "!tag!" == "!output[%%n]!" SET "tag_status=true"
				
					If  "!tag_status!"=="true" (
							
							echo "[INFO] !tag! of !ets_name! exists. Checking it out."
							
							REM Checkout the test to specified tag.
							call git checkout !tag! 2>NUL
							
							REM Call another batch script 'build_test.bat' to build the test.
							call !pwdd!\build_test.bat !TE_BASE! !TE! !SKIP! >log_build_test.txt
							
							REM Check the log file if the test is successfully build or not
							>nul find "FAIL" log_build_test.txt && ( 
							SET "fail_message=!fail_message!!NL! !ets_name! !tag!"
		         			set /A failures+=1
							echo "After Check...."
							)
									
					) else (
						
							echo "[ERROR] TAG NOT FOUND tag:'!tag! 'it was not build"
							echo "[ERROR] TAG NOT FOUND tag:'!tag! 'it was not build" >>!logfile!
					)
			)
		)
	)
	
	If !failures! GTR 0 (
		echo "Total failures: "!failures!
		echo !fail_message!
		echo.
	)
	
	
echo "------------- End -----------"
GOTO END
:printHelp

  echo.
  echo Usage install-all-tests.sh TE_BASE TEAM_ENGINE CSV_FILE DIR_TO_BUILD  SKIP_TESTS
  echo.
  echo where:
  echo.
  echo   TE_BASE        		is the  TE_BASE directory
  echo   TEAM_ENGINE    		is the  TEAM_ENGINE directory
  echo   CSV_FILE       		is a CSV  file that provides per test a git url and revision number 
  echo   DIR_TO_BUILD   		temporary directory to build tests
  echo   SKIP_TESTS  			true or false to skip tests while building mvn
  echo.
  echo More information: https://github.com/opengeospatial/teamengine-builder/
  
  GOTO END


:END