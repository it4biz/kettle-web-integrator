# Kettle Web Integrator

Welcome to Kettle Web integrator Project.

Kettle Web Integrator - An easy and open way to integrate your web app with Kettle Pentaho Data Integration.

### Usage

	* Move your transformations file to kettle-web-integrator/kettle/transformations

	* Move your jobs file to kette-web-integrator/kettle/jobs

	* Access the url http://localhost:<portOfContainer>/kettle-web-integrator/index.jsp


### Installation

* Move kettle-web-integrator.war in a container Java.

### Development

* Open the project in netbeans IDE and set the jars available in data-integration/lib/.

### Tested Environment
* Mac OS X El Capitan 10.11 Beta (15A278b)
* pdi-ce-6.0.0.0-353
* NetBeans 8.0.1
* jdk1.7.0_80


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

