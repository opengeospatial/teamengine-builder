Introduction
------------

This repository provides easy to use scripts to install, from scratch and configure `TEAM Engine <https://github.com/opengeospatial/teamengine>`_ in Windows and Unix Machines

Prerequisites
-------------
The machine where TEAM Engine will be installed requires:


- **Java 8**: Download Java JDK (Java Development Kit) 8, from `here <http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html>`_.
- **Maven 2**: It has been tested with Maven 2.2.1 and **Maven 3.2.2**: Download Maven version 3.2.2 from `here <http://apache.mesi.com.ar/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.zip>`_.
- **Git 1.8**: Download Git-SCM version 1.8 or newer  `here <http://git-scm.com/download/win>`_.
- **Apache Tomcat 7**: It has been tested with Tomcat version 7.0.52, can be download from `here <http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.52/bin/>`_.


Download and run TE builder
---------------------------

Download te-build helper scripts::

	git clone https://github.com/opengeospatial/teamengine-builder.git

Go to the directory::

	cd teamengine-builder

Change permissions to allow to execute build-te.sh ::

	chmod 744 build_te.sh 

Run te-build::

	./build_te.sh -a 4.1.0b -t /home/ubuntu/apache-tomcat-7.0.52	

Start tomcat and you should see teamengine at htpp://localhost:8080/teamengine or similar configuration


Installation of the tests
-------------------------

Assume:

- $catalina_base is a variable with the path to catalina_base
- $war is the name of the war. For example *teamengine*
- $TE_BASE is the location of TE_BASE

Do the following:

#. Identify a file in csv format that has all the tests. For example: production-releases/201601.csv
#. Identify where TE_BASE is located. For example: $catalina_base/TE_BASE
#. Identify where the deployed war is located. For example: $catalina_base/webapps/$war 

run ./install-all-tests.sh::

   ./install-all-tests.sh $TE_BASE $catalina_base/webapps/$war production-releases/201601.csv

Go again to htpp://localhost:8080/teamengine, you should see all the tests.   


Jar cleanup
-----------

There might be the case that  that jars are repeated in the web installation. Do the following:

#. go to WEB-INF/lib  
#. run find-repeated-jars.sh

It will suggest a command to remove repeated jars.
   


