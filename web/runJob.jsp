<%-- 

/*! ******************************************************************************
*
* Kettle Web Integrator
*
* Copyright (C) 2007-2015 by IT4biz : http://www.it4bizglobal.com
*
*******************************************************************************
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
******************************************************************************/


--%>


<%@page import="org.pentaho.di.job.JobMeta"%>
<%@
page language="java"
     import="java.net.URLEncoder
     , java.util.LinkedList
     , java.util.List
     , org.apache.commons.lang.StringUtils
     , org.pentaho.di.core.KettleEnvironment
     , org.pentaho.di.core.Result
     , org.pentaho.di.core.exception.KettleException
     , org.pentaho.di.core.exception.KettleStepException
     , org.pentaho.di.core.exception.KettleValueException
     , org.pentaho.di.core.logging.LogLevel
     , org.pentaho.di.core.row.RowMetaInterface
     , org.pentaho.di.repository.Repository
     , org.pentaho.di.trans.Trans
     , org.pentaho.di.trans.TransMeta
     , org.pentaho.di.job.Job
     , org.pentaho.di.job.JobMeta
     , org.pentaho.di.trans.step.RowAdapter
     , org.pentaho.di.trans.step.StepInterface"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <body>
        <%!
            List<Object[]> capturedRows;
            RowMetaInterface rowStructure;
            String resultRun;
            public void runTransformation(String filename, String endpointPathLabel) {

                try {

                    // load job definition file
                    JobMeta jobMeta = new JobMeta(filename, (Repository) null);

                    Job job = new Job(null, jobMeta);

                    // adjust the log level
                    job.setLogLevel(LogLevel.MINIMAL);

                    System.out.println("\nStarting job");

                    // starting the job
                    job.start();

                    // waiting for the job to finish
                    job.waitUntilFinished();

                    // retrieve the result object, which captures the success of the transformation
                    Result result = job.getResult();

                    // report on the outcome of the transformation
                    resultRun = "\nJob " + endpointPathLabel + " executed " + (result.getNrErrors() == 0 ? "successfully" : "with " + result.getNrErrors() + " errors");
                    
                } catch (Exception e) {
                    // something went wrong, just log and return
                    e.printStackTrace();
                }

            }
        %>

        <%
            //init Kettle
            try {
                String webRootPath = application.getRealPath("/").replace('\\', '/');
                String directory = request.getParameter("directory");
                String endpointPath = request.getParameter("endpointPath");

                KettleEnvironment.init();
                
                runTransformation(webRootPath+directory+"/jobs/"+endpointPath, endpointPath);
            } catch (KettleException e) {
                e.printStackTrace();
                return;
            }
        %>    

        <%= resultRun %>
    </body>
</html>
