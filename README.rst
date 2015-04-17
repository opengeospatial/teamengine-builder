Introduction
-------------

This repository provides easy to use scripts to install, from scratch and configure `TEAM Engine <https://github.com/opengeospatial/teamengine>`_ in an Ubuntu machine in the Amazon Cloud. 


Setup Amazon Instance
------------------------

Login to Amazon

Launch Instance::

	https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#LaunchInstanceWizard:

Select a free tier eligible::

	Ubuntu Server 14.04 LTS (HVM), SSD Volume Type		

Review and Launch

Update security Settings. Security Group should have::

	SSH (22)
	HTTP (80)

Connect via ssh (via terminal or configure putty)


Install required software
-----------------------------	
	
Update::
	
	sudo apt-get update        
	sudo apt-get upgrade 	

Install Java JDK::

	sudo apt-get install openjdk-7-jdk

Configure JAVA_HOME::

	export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
	export PATH=$JAVA_HOME/bin:$PATH


Install git::

	sudo apt-get install git

Install maven::		

	sudo apt-get install maven


Download tomcat::

	wget http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.52/bin/apache-tomcat-7.0.52.zip

Unzip::

	unzip apache-tomcat-7.0.52.zip 


Configure port 8080	
----------------------

Open port 80 and redirect 8080::

	sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

Download and run TE builder
----------------------------------------

Download te-build helper scripts::

	git clone https://github.com/opengeospatial/teamengine-builder.git

Go to the directory::

	cd teamengine-builder

Change permissions to allow to execute build-te.sh ::

	chmod 744 build_te.sh 

Run te-build::

	./build_te.sh -a 4.1.0b -t /home/ubuntu/apache-tomcat-7.0.52	




Optional if not building in Ubuntu
------------------------------------
Update the file with the location of tomcat, where the software will be build etc..::

		nano build_te.sh 


Check that in setven all paths have setup correctly::

		nano setenv.sh

