# Kettle Web Integrator

Welcome to Kettle Web integrator Project.

Kettle Web Integrator - An easy and open way to integrate your web app with Kettle Pentaho Data Integration by IT4biz Global.

### Kettle / PDI

Pentaho Data Integration (PDI, also called Kettle) is the component of Pentaho responsible for the Extract, Transform and Load (ETL) processes. Though ETL tools are most frequently used in data warehouses environments, PDI can also be used for other purposes:
* Migrating data between applications or databases
* Exporting data from databases to flat files
* Loading data massively into databases
* Data cleansing
* Integrating applications
 
PDI is easy to use. Every process is created with a graphical tool where you specify what to do without writing code to indicate how to do it; because of this, you could say that PDI is metadata oriented.

PDI can be used as a standalone application, or it can be used as part of the larger Pentaho Suite. As an ETL tool, it is the most popular open source tool available. PDI supports a vast array of input and output formats, including text files, data sheets, and commercial and free database engines. Moreover, the transformation capabilities of PDI allow you to manipulate data with very few limitations.

Source: <BR>
http://wiki.pentaho.com/display/EAI/Pentaho+Data+Integration+(Kettle)+Tutorial<BR>

### Spoon

Kettle is an acronym for "Kettle E.T.T.L. Environment." Kettle is designed to help you with your ETTL needs, which include the Extraction, Transformation, Transportation and Loading of data.

Spoon is a graphical user interface that allows you to design transformations and jobs that can be run with the Kettle tools — Pan and Kitchen. Pan is a data transformation engine that performs a multitude of functions such as reading, manipulating, and writing data to and from various data sources. Kitchen is a program that executes jobs designed by Spoon in XML or in a database repository. Jobs are usually scheduled in batch mode to be run automatically at regular intervals.

Note: For a complete description of Pan or Kitchen, see the Pan and Kitchen user guides.

Transformations and Jobs can describe themselves using an XML file or can be put in a Kettle database repository. Pan or Kitchen can then read the data to execute the steps described in the transformation or to run the job. In summary, Pentaho Data Integration makes data warehouses easier to build, update, and maintain.

Source: <BR>
http://wiki.pentaho.com/display/EAI/.01+Introduction+to+Spoon<BR>

### Origin of Kettle (PDI - Pentaho Data Integration)

In this video you will have the opportunity to learn about the Origin of Kettle (PDI - Pentaho Data Integration) told by Kettle creator Mr. Matt Casters at Pentaho Day 2014 in May, 16, 2014 in FEA/USP (School of Economics, Business and Accounting of the University of São Paulo).

In May, 16, 2014 Kettle was already a 11 years project. It started on March, 2003.

Link to the video:<BR>
http://iptv.usp.br/portal/video.action?idItem=23309<BR>
http://blog.professorcoruja.com/2015/10/origin-of-kettle-pdi-pentaho-data.html<BR>

Slides:<BR>
https://github.com/it4biz/kettle-web-integrator/tree/master/samples/matt-casters<BR>


### Usage

	* Move your transformations file to kettle-web-integrator/kettle/transformations

	* Move your jobs file to kette-web-integrator/kettle/jobs

	* Access the url http://localhost:<portOfContainer>/kettle-web-integrator/


### Installing on Apache Tomcat 8.0.27

* Download kettle-web-integrator.war from https://sourceforge.net/projects/kettle-web-integrator/files/0.2/kettle-web-integrator.war/download
* Download Apache Tomcat 8.0.27 from http://apache.rediris.es/tomcat/tomcat-8/v8.0.27/bin/apache-tomcat-8.0.27.tar.gz
* Copy kettle-web-integrator.war to apache-tomcat-8.0.27/webapps
* Find catalina.sh at apache-tomcat-8.0.27/bin
* Run Catalina.sh in Apache Tomcat 8.0.27 using the command line: sh catalina.sh start

Apache Tomcat 8.0.27 Linux Command Line Output:

```
Caios-MacBook-Pro:bin caiomsouza$ sh catalina.sh start
Using CATALINA_BASE:   /Users/caiomsouza/Desktop/apache-tomcat-8.0.27
Using CATALINA_HOME:   /Users/caiomsouza/Desktop/apache-tomcat-8.0.27
Using CATALINA_TMPDIR: /Users/caiomsouza/Desktop/apache-tomcat-8.0.27/temp
Using JRE_HOME:        /Library/Java/JavaVirtualMachines/jdk1.7.0_67.jdk/Contents/Home
Using CLASSPATH:       /Users/caiomsouza/Desktop/apache-tomcat-8.0.27/bin/bootstrap.jar:/Users/caiomsouza/Desktop/Ariadna/apache-tomcat-8.0.27/bin/tomcat-juli.jar
Tomcat started.
```

### Development

* Open the project in netbeans IDE and set the jars available in data-integration/lib/.

### Tested Environment
* Mac OS X El Capitan 10.11 Beta (15A278b)
* pdi-ce-6.0.0.0-353
* NetBeans 8.0.1
* jdk1.7.0_80
* Apache Tomcat 8.0.27


### Support
* If you need support, please contact us creating a issue here (https://github.com/it4biz/kettle-web-integrator/issues).

###Python Code to integrate:

```
# Import python libs
from lxml import html
import requests

# Call a PDI Transformation using Kettle Web Integrator  
url = "http://localhost:8080/kettle-web-integrator/runTransformation.jsp?endpointPath=transformations%2Fuser_defined_java_class_concatenate_firstname_lastname.ktr&stepOutput=Json+output"
pdi_resultset = requests.get(url)

# Print the resultset
pdi_resultset.text

# print the resultset in Json format
pdi_resultset.json()

```

### Python Notebook - Kettle Web Integrator

We create a python notebook to help you understand better the integration with python.

Folder:<BR>
kettle-web-integrator/samples/kettle-web-integrator-python-notebook<BR>

File:<BR>
Kettle Web Integrator - iPython Notebook.ipynb<BR>

Link:<BR>
https://github.com/it4biz/kettle-web-integrator/blob/master/samples/kettle-web-integrator-python-notebook/Kettle%20Web%20Integrator%20-%20iPython%20Notebook.ipynb

### Project on SourceForge
https://sourceforge.net/projects/kettle-web-integrator/
