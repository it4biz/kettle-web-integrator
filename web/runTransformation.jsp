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
     , org.it4biz.web.kettle.*
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
     , org.pentaho.di.trans.step.StepInterface
     , com.google.gson.Gson"%>

<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%!
    List<Object[]> capturedRows;
    RowMetaInterface rowStructure;
    String jsonResult;
    Metadata[] metadata;
    List<String> resultsetCda;
    List<String> resultsetVisualCue;

    public void runTransformation(String filename, String endpointLabel, boolean showOnlyColumns, HttpServletRequest request) {
       
        try {

            // load transformation definition file
            TransMeta transMeta = new TransMeta(filename, (Repository) null);

            //set parameters values
            String[] declaredParameters = transMeta.listParameters();
            for (int i = 0; i < declaredParameters.length; i++) {
                String parameterName = declaredParameters[i];
                String defaultValue = transMeta.getParameterDefault(parameterName);
                String parameterValue = request.getParameter(parameterName) == null ? defaultValue : request.getParameter(parameterName);

                // assign the value to the parameter on the transformation
                transMeta.setParameterValue(parameterName, parameterValue);

            }
            
            if (showOnlyColumns) {
                transMeta.setParameterValue("endpointPath", endpointLabel);
            }

            Trans transformation = new Trans(transMeta);

            // adjust the log level
            transformation.setLogLevel(LogLevel.MINIMAL);

            // starting the transformation, which will execute asynchronously
            transformation.prepareExecution(new String[0]);

            // find the "output" step
            StepInterface step = transformation.getStepInterface(request.getParameter("stepOutput"), 0);

            //parserResultset
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

                        metadata = new Metadata[rowMeta.size()];
                        resultsetCda = new LinkedList<String>();
                        resultsetVisualCue = new LinkedList<String>();

                        for (int i = 0; i < rowMeta.size(); i++) {
                            metadata[i] = new Metadata();
                            metadata[i].setColIndex(i);
                            metadata[i].setColName(rowMeta.getFieldNames()[i]);
                            metadata[i].setColType(rowMeta.getFieldNamesAndTypes(0)[i].replace("(", "").replace(")", "").toString().trim());
                        }

                    }
                    try {

                        boolean firstColumnResultset = true;
                        String rowResultCda = new String();
                        String rowResultVisualCue = new String();

                        rowResultCda = "";
                        rowResultVisualCue = "";
                        for (int i = 0; i < rowMeta.size(); i++) {
                            Gson gson = new Gson();
                            String fieldName = rowMeta.getFieldNames()[i];
                            String value = rowMeta.getString(row, i);

                            if (firstColumnResultset) {
                                firstColumnResultset = false;

                                rowResultCda = gson.toJson(value);
                                rowResultVisualCue = gson.toJson(fieldName) + ":" + gson.toJson(value);
                            } else {
                                rowResultCda += "," + gson.toJson(value);
                                rowResultVisualCue += "," + gson.toJson(fieldName) + ":" + gson.toJson(value);
                            }

                        }
                        resultsetCda.add(rowResultCda);
                        resultsetVisualCue.add(rowResultVisualCue);

                        // keep the row 
                        capturedRows.add(row);

                    } catch (KettleValueException e) {
                        e.printStackTrace();
                    }
                }
            };
            step.addRowListener(rowAdapter);

            System.out.println("\nStarting transformation");
            transformation.startThreads();

            // waiting for the transformation to finish
            transformation.waitUntilFinished();

            //System.out.print("resultset "+resultsetToJson(resultset));
            // retrieve the result object, which captures the success of the transformation
            Result result = transformation.getResult();

            // report on the outcome of the transformation
            String resultRun = "Trans " + endpointLabel + " executed " + (result.getNrErrors() == 0 ? "successfully" : "with " + result.getNrErrors() + " errors");

            String outputType = request.getParameter("output_type");

            if (metadata != null) {
                //System.out.print("metadata: "+MetadataToJson(metadata));
                if (outputType.equals("cda")) {
                    jsonResult = "{\"status\": \"" + resultRun + "\", \"metadata\":[" + MetadataToJson(metadata) + "], \"resultset\":[" + resultsetToCDAJson(resultsetCda) + "]}";
                } else if (outputType.equals("visualcue")) {
                    jsonResult = "{\"data\":[" + resultsetToVisualCueJson(resultsetVisualCue) + "]}";
                }
            } else {
                if (outputType.equals("cda")) {
                    jsonResult = "{\"status\": \"" + resultRun + "\", \"metadata\":[], \"resultset\":[]}";
                } else if (outputType.equals("visualcue")) {
                    jsonResult = "{\"data\":[]}";
                }
            }

            //System.out.print(jsonResult);
        } catch (Exception e) {
            // something went wrong, just log and return
            e.printStackTrace();
        }

    }

    static public String MetadataToJson(Metadata[] metadata) {
        String json = "";
        Boolean firstRow = true;
        for (Metadata item : metadata) {
            if (firstRow) {
                firstRow = false;
                json += "{\"colIndex\":" + item.getColIndex() + ","
                        + "\"colType\":\"" + item.getColType() + "\","
                        + "\"colName\":\"" + item.getColName() + "\"}";
            } else {
                json += ",{\"colIndex\":" + item.getColIndex() + ","
                        + "\"colType\":\"" + item.getColType() + "\","
                        + "\"colName\":\"" + item.getColName() + "\"}";
            }
        }
        return json;
    }

    static public String resultsetToCDAJson(List<String> resultset) {
        String json = "[]";
        Boolean firstRow = true;
        for (String item : resultset) {
            if (firstRow) {
                firstRow = false;
                json = "[" + item + "]";
            } else {
                json += ",[" + item + "]";
            }
        }
        return json;
    }

    static public String resultsetToVisualCueJson(List<String> resultset) {
        String json = "[]";
        Boolean firstRow = true;
        for (String item : resultset) {

            if (firstRow) {
                firstRow = false;
                json = "{" + item + "}";
            } else {
                json += ",{" + item + "}";
            }
        }
        //System.out.print(json);
        return json;

    }
%>

<%
    //clear cache
    jsonResult = "";
    //init Kettle
    try {
        boolean showOnlyColumns = Boolean.parseBoolean(request.getParameter("showOnlyColumns"));
        //Boolean showOnlyColumns = showOnlyColumnsTemp.equals("true") ? true : false;
 
        String directory = request.getParameter("directory");
        String webRootPath = application.getRealPath("/").replace('\\', '/');
        String endpointPath = webRootPath+request.getParameter("endpointPath");
        
        String endpointPathReal = showOnlyColumns == false ? endpointPath : webRootPath + "kettle/system/getColumns.ktr";
        
        KettleEnvironment.init();
        //System.out.println("endpointPathReal "+endpointPathReal);
        //System.out.println("endpointPath "+endpointPath);
        runTransformation(endpointPathReal, request.getParameter("endpointPath"), showOnlyColumns, request);
    } catch (KettleException e) {
        e.printStackTrace();
        return;
    }
%>    

<%= jsonResult%>