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

<%!
    int year = (new java.util.Date()).getYear() + 1900;
    List<Object[]> capturedRows;
    RowMetaInterface rowStructure;
    String listTableFormatted = "";
    String contextWeb;
    String listTableTemplate
            = "<tr>"
            + "<td>${short_filename}</td>"
            + "<td>"
            + "<form target='_blank' action='${type_file}' method='get'>"
            + "${parameters}"
            + "<input type='hidden' id='endpointPath' name='endpointPath' value='${endpoint_path}'>"
            + "<hr>"
            + "<div class='form-group'>"
            + "<label for='stepOutput'>Step output name (insert the name of step that you want show data)</label>"
            + "<input type='text' class='form-control' id='stepOutput' name='stepOutput' value='OUTPUT'>"
            + "</div>"
            + "<div class='checkbox'>"
            + "<label>"
            + "<input type='checkbox' value='true' name='showOnlyColumns'id='showOnlyColumns'> Show only columns?"
            + "</label>"
            + "</div>"
            + "<div class='radio'>"
            + "    <label>"
            + "     <input type='radio' name='output_type' id='output_type1' value='cda' checked>"
            + "     CDA Output"
            + "   </label>"
            + "</div>"
            + "<div class='radio'>"
            + "   <label>"
            + "     <input type='radio' name='output_type'  id='output_type2' value='visualcue'>"
            + "     VisualCue Output"
            + "   </label>"
            + " </div>"
            + " </div>"
            + "<button type='submit' class='btn btn-default btn-lg pull-right'>"
            + "<span class='glyphicon glyphicon-play' aria-hidden='true'></span> run"
            + "</button>"
            + "</form>"
            + "</td>"
            + "</tr>";

    public void runTransformation(String filename) {

        try {

            // load transformation definition file
            TransMeta transMeta = new TransMeta(filename, (Repository) null);

            //if endpointTypeList = null, will list all transformations and jobs
            //if endpointTypeList = ktr, will list only transformations
            //if endpointTypeList = kjb, will list only jobs
            //transMeta.setParameterValue("endpointTypeList", endpointTypeList);
            
            // crate a transformation object
            Trans transformation = new Trans(transMeta);

            // set log level to avoid noise on the log
            transformation.setLogLevel(LogLevel.MINIMAL);

            // preparing the executing initializes all steps
            transformation.prepareExecution(new String[0]);
   
            // find the "output" step
            StepInterface step = transformation.getStepInterface("OUTPUT", 0);

            // attach adapter receiving row events
            RowAdapter rowAdapter = new RowAdapter() {

                private boolean firstRow = true;

                public void rowWrittenEvent(RowMetaInterface rowMeta, Object[] row) throws KettleStepException {

                    if (firstRow) {
                        firstRow = false;
                        // a space to keep the captured rows
                        capturedRows = new LinkedList<Object[]>();
                        // keep the row structure for future reference
                        rowStructure = rowMeta;
                        // print a header before the first row
                        //System.out.println(StringUtils.join(rowMeta.getFieldNames(), "\t"));
                    }
                    try {

                        TransMeta transMeta;
                        JobMeta jobMeta;
                        String typeFile;
                        String parameters = "";
                        String parameterTemplate = "<div class='form-group'>"
                                + "<label for='input${parameter_name}'>Parameter Name: ${parameter_name} <BR> Parameter Description: ${parameter_description}</label>"
                                + "<BR>Default Value: <input type='text' class='form-control' id='${parameter_name}' name='${parameter_name}' value='${parameter_default_value}'>"
                                + "</div>";

                        //verify if is transformation or job
                        if (rowMeta.getString(row, 3).equals("transformation")) {
                            typeFile = "Transformation";
                            transMeta = new TransMeta(rowMeta.getString(row, 0), (Repository) null);
                            String[] declaredParameters = transMeta.listParameters();

                            for (int i = 0; i < declaredParameters.length; i++) {
                                String parameterName = declaredParameters[i];
                                String description = transMeta.getParameterDescription(parameterName) == null ? "" : " (" + transMeta.getParameterDescription(parameterName) + ")";
                                String defaultValue = transMeta.getParameterDefault(parameterName) == null ? "" : transMeta.getParameterDefault(parameterName);
                                //System.out.println("template: \n"+transMeta.getParameterDescription(parameterName)+"\n"+transMeta.getParameterDefault(parameterName));
                                String separator = i > 0 ? "<hr>" : "";
                                parameters += parameterTemplate.replace("${parameter_name}", parameterName)
                                        .replace("${parameter_description}", description)
                                        .replace("${parameter_default_value}", defaultValue);
                            }
                        } else {
                            typeFile = "Job";
                            jobMeta = new JobMeta(rowMeta.getString(row, 0), null);
                            String[] declaredParameters = jobMeta.listParameters();

                            for (int i = 0; i < declaredParameters.length; i++) {
                                String parameterName = declaredParameters[i];
                                String description = jobMeta.getParameterDescription(parameterName) == null ? "" : " (" + jobMeta.getParameterDescription(parameterName) + ")";
                                String defaultValue = jobMeta.getParameterDefault(parameterName) == null ? "" : jobMeta.getParameterDefault(parameterName);
                                //System.out.println("template: \n"+transMeta.getParameterDescription(parameterName)+"\n"+transMeta.getParameterDefault(parameterName));
                                //String separator = i > 0 ? "<hr>" : "";
                                parameters += parameterTemplate.replace("${parameter_name}", parameterName)
                                        .replace("${parameter_description}", description)
                                        .replace("${parameter_default_value}", defaultValue);
                            }
                            //parameters += "<hr>";
                        }
                        String fileName = rowMeta.getString(row, 4);
                        String kettleFolder = rowMeta.getString(row, 5);
                        String endpointPath = fileName.replace(kettleFolder, "");
                        listTableFormatted += listTableTemplate.replace("${short_filename}", rowMeta.getString(row, 1))
                                .replace("${parameters}", parameters)
                                .replace("${endpoint_path}", endpointPath)
                                .replace("${type_file_show_columns}", contextWeb + "/showColumns" + typeFile + ".jsp")
                                .replace("${type_file}", contextWeb + "/run" + typeFile + ".jsp");
                        // keep the row 
                        capturedRows.add(row);

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            };
            step.addRowListener(rowAdapter);

            // after the transformation is prepared for execution it is started by calling startThreads()
            transformation.startThreads();

            // waiting for the transformation to finish
            // The row adapter will receive notification of any rows written by the "output" step
            transformation.waitUntilFinished();
        } catch (Exception e) {
            // something went wrong, just log and return
            e.printStackTrace();
        }

    }
%>

<%
    //init Kettle
    try {
        listTableFormatted = "";
        KettleEnvironment.init();
        String webRootPath = application.getRealPath("/").replace('\\', '/');
        contextWeb = request.getContextPath();
        runTransformation(webRootPath + "kettle/system/listEndpoints.ktr");
    } catch (KettleException e) {
        e.printStackTrace();
        return;
    }
%>    

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Kettle Web integrator</title>

        <!-- bootstrap CSS -->
        <link rel="stylesheet" href="libs/bootstrap/css/bootstrap.min.css">
    </head>
    <body>
        <div class="container-fluid">
            <div class="page-header">
                <h1>List Endpoints <small>Kettle Web integrator</small></h1>
            </div>
            <p>
                <a href="/kettle-web-integrator/metadataTransformations.jsp" target="no_blank">Click here, to view this page as a XML |</a> 
                    <small><a href="/kettle-web-integrator/metadataTransformations.jsp?endpointTypeList=ktr" target="no_blank">Only transformations |</a></small>
                    <small><a href="/kettle-web-integrator/metadataTransformations.jsp?endpointTypeList=kjb" target="no_blank">Only jobs.</a></small>
            </p>
            
            
            


            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Endpoint</th>
                        <th>Parameters</th>
                    </tr>
                </thead>
                <tbody>
                    <%= listTableFormatted%>
                </tbody>
            </table>

            <div id="footer" class="pull-right">



                <p>Copyright &copy; 2007-<%=String.valueOf(year)%> by IT4biz Global</p>

                <p>
                    <a target="no_blank" href="http://www.it4biz.com.br">Powered by 
                        <img height="40px" src="http://www.it4biz.com.br/extras/logo-it4biz-wordpress.png"></a>
                </p>
            </div>
        </div>
    </body>
    <!-- bootstrap api js -->
    <script src="libs/bootstrap/js/bootstrap.min.js"></script>
</html>
