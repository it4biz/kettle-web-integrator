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



<%@page import="java.util.ArrayList"%>
<%@page import="java.io.StringWriter"%>
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
     , org.pentaho.di.trans.step.StepInterface
     , javax.xml.bind.*
     , org.it4biz.web.kettle.*"%>

<%@page contentType="application/xml; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
    List<Object[]> capturedRows;
    RowMetaInterface rowStructure;
    String contextWeb;
    String xmlResult;

    public void runTransformation(String filename) {

        try {

            // load transformation definition file
            TransMeta transMeta = new TransMeta(filename, (Repository) null);

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
        xmlResult = "";
        KettleEnvironment.init();
        String webRootPath = application.getRealPath("/").replace('\\', '/');
        contextWeb = request.getContextPath();
        runTransformation(webRootPath + "kettle/system/listEndpoints.ktr");
    } catch (KettleException e) {
        e.printStackTrace();
        return;
    }

    String xml = "<transforms>"
            + "<transform directory=\"/MyTransformations/Kickstarter\" id=\"7\" name=\"Kickstarter\">"
            + "<params>"
            + "<param name=\"term\" type=\"String\" />"
            + "</params>"
            + "<fields>"
            + "<field name=\"projectId\" />"
            + "</fields>"
            + "</transform>"
            + "</transforms>";
    
    Transforms transforms = new Transforms();
    Transform transf =  new Transform();
    transf.setName("Kickstarter");
    transf.setDirectory("/MyTransformations/Kickstarter");
    transf.setId(7);
    transf.setParams(new ArrayList<Param>());
    transf.getParams().add(new Param());
    transf.getParams().get(0).setName("term");
    transf.getParams().get(0).setType("String");
    transf.setFields(new ArrayList<Field>());
    transf.getFields().add(new Field());
    transf.getFields().get(0).setName("projectid");
    
    transforms.setTransform(new ArrayList<Transform>());
    transforms.getTransform().add(transf);
    
    StringWriter sw = new StringWriter();
    JAXBContext context = JAXBContext.newInstance(Transforms.class);
    Marshaller jaxbMarshaller = context.createMarshaller();
    jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
    jaxbMarshaller.marshal(transforms, sw);
    xmlResult = sw.toString();
    System.out.println(xmlResult);
%>    

 <%= xmlResult %>