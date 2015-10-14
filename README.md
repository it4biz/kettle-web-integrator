# Kettle Web Integrator
Kettle Web Integrator - An easy and open way to integrate your web app with Kettle Pentaho Data Integration.

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


