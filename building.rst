Building in OGC server
-------------------------

1. Select the tag or branch you want to build:
	e.g. 4.1

2. Update a file that contains the versions of the tests that you want to install. For example a file name **tests-to-build.csv**:

	Repository,Tag
	https://github.com/opengeospatial/ets-csw202.git,1.11
	https://github.com/opengeospatial/ets-gml32.git,1.20
	https://github.com/opengeospatial/ets-kml22.git,2.2-r11
	https://github.com/opengeospatial/ets-sos10.git,1.13
	https://github.com/opengeospatial/ets-sos20.git,1.9
	https://github.com/opengeospatial/ets-sps10.git,1.6
	https://github.com/opengeospatial/ets-sps20.git,1.9
	https://github.com/opengeospatial/ets-sfs11.git,1.5
	https://github.com/opengeospatial/ets-sfs12.git,1.4
	https://github.com/opengeospatial/ets-wcs10.git,1.10
	https://github.com/opengeospatial/ets-wcs11.git,1.4
	https://github.com/opengeospatial/ets-wcs20.git,1.7
	https://github.com/opengeospatial/ets-wfs10.git,1.8
	https://github.com/opengeospatial/ets-wfs11.git,1.22
	https://github.com/opengeospatial/ets-wfs11.git,1.4
	https://github.com/opengeospatial/ets-wfs20.git,2.0-r18
	https://github.com/opengeospatial/ets-wms11.git,1.9
	https://github.com/opengeospatial/ets-wms13.git,1.11

3. Get the tomcat path. For example:

	/home/ubuntu/apache-tomcat-7.0.52

4. Stop tomcat

5. Run the builder command, providing tomcat as an argument. e.g:

	./build_te.sh -t /Applications/apache-tomcat-7.0.57

6. Start tomcat and check that teamengine is running correctly. For example:

	http://localhost:8080/teamengine/ 

5. Stop tomcat

6. Get the path for TE_BASE for example: te-build/catalina_base/TE_BASE

7. Get the path for TEAM ENGINE, for example: te-build/catalina_bsdsds

7. Install the tests, running::
	
	./install-all-tests.sh $TE_BASE $TEAMENGINE tests-to-build.csv


	





