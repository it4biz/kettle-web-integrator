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

force dowloand the file
<%response.setHeader("Content-Disposition", "attachment; filename=listTransformations.xml");%>
--%>

<%@page contentType="application/xml; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@
page language="java"
     import="java.net.URLEncoder
     , java.util.LinkedList
     , java.util.List
     , java.util.ArrayList
     , java.io.StringWriter
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


<%!
    List<Object[]> capturedRows;
    RowMetaInterface rowStructure;
    String webRootPath;
    String directory;
    String contextWeb;
    String xmlResult;
    int countTransf = 0;
    int countFields = 0;
    Transforms transforms;
    Transform transf;
    StringWriter sw;
    JAXBContext context;
    Marshaller jaxbMarshaller;

    public void getTransformationMetadata(String filename, String endpointTypeList) {
        transforms = new Transforms();
        transforms.setTransform(new ArrayList<Transform>());

        try {

            // load transformation definition file
            TransMeta transMeta = new TransMeta(filename, (Repository) null);
            
            //if endpointTypeList = null, will list all transformations and jobs
            //if endpointTypeList = ktr, will list only transformations
            //if endpointTypeList = kjb, will list only jobs
            transMeta.setParameterValue("endpointTypeList", endpointTypeList);
            
            //if directory = null, by default will get data from folder kettle
            transMeta.setParameterValue("directory", directory);
            
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
                        transf = new Transform();
                        transf.setParams(new ArrayList<Param>());
                        transf.setFields(new ArrayList<Field>());
                        //verify if is transformation or job
                        if (rowMeta.getString(row, 3).equals("transformation")) {
                            typeFile = "Transformation";
                            transMeta = new TransMeta(rowMeta.getString(row, 0), (Repository) null);
                            String[] declaredParameters = transMeta.listParameters();

                            for (int i = 0; i < declaredParameters.length; i++) {
                                String parameterName = declaredParameters[i];
                                String description = transMeta.getParameterDescription(parameterName) == null ? "" : transMeta.getParameterDescription(parameterName);
                                String defaultValue = transMeta.getParameterDefault(parameterName) == null ? "" : transMeta.getParameterDefault(parameterName);
                                //System.out.println("template: \n"+transMeta.getParameterDescription(parameterName)+"\n"+transMeta.getParameterDefault(parameterName));

                                transf.getParams().add(new Param());
                                transf.getParams().get(i).setName(parameterName);
                                transf.getParams().get(i).setType(description);
                            }
                        } else {
                            typeFile = "Job";
                            jobMeta = new JobMeta(rowMeta.getString(row, 0), null);
                            String[] declaredParameters = jobMeta.listParameters();

                            for (int i = 0; i < declaredParameters.length; i++) {
                                String parameterName = declaredParameters[i];
                                String description = jobMeta.getParameterDescription(parameterName) == null ? "" : jobMeta.getParameterDescription(parameterName);
                                String defaultValue = jobMeta.getParameterDefault(parameterName) == null ? "" : jobMeta.getParameterDefault(parameterName);

                                transf.getParams().add(new Param());
                                transf.getParams().get(i).setName(parameterName);
                                transf.getParams().get(i).setType(description);
                            }
                        }

                        String endpointPathReal = webRootPath + "kettle/system/getColumns.ktr";    
                        
                        String fileName = rowMeta.getString(row, 1);
                        String endpointPath = directory+"/transformations/"+fileName;
                        //System.out.println(endpointPath);
                        String kettleFolder = rowMeta.getString(row, 2);
                 
                        runTransformation(endpointPathReal, endpointPath);

                        transf.setName(fileName);
                        transf.setDirectory(kettleFolder);
                        transf.setId(countTransf);
                        countTransf++;

                        transforms.getTransform().add(transf);

                        StringWriter sw = new StringWriter();
                        JAXBContext context = JAXBContext.newInstance(Transforms.class);
                        Marshaller jaxbMarshaller = context.createMarshaller();
                        jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
                        jaxbMarshaller.marshal(transforms, sw);
                        xmlResult = sw.toString();
                        
                        //System.out.println(xmlResult);
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

    //function to get fields and types from a transformation    
    public void runTransformation(String filename, String endpointPath) {
        countFields = 0;
        try {

            // load transformation definition file
            TransMeta transMeta = new TransMeta(filename, (Repository) null);
            
            transMeta.setParameterValue("endpointPath", endpointPath);
            
            Trans transformation = new Trans(transMeta);

            // adjust the log level
            transformation.setLogLevel(LogLevel.MINIMAL);

            // starting the transformation, which will execute asynchronously
            transformation.prepareExecution(new String[0]);

            // find the "output" step
            StepInterface step = transformation.getStepInterface("OUTPUT", 0);

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

                    }
                    try {
                            
                        boolean firstColumnResultset = true;
                        
                        for (int i = 0; i < rowMeta.size(); i++) {
                            if (firstColumnResultset) {
                                firstColumnResultset = false;
                                transf.getFields().add(new Field());
                                transf.getFields().get(countFields).setName(rowMeta.getString(row, i).toString().trim());
                            } else {
                                //transf.getFields().add(new Field());
                                transf.getFields().get(countFields).setName(rowMeta.getString(row, i).toString().trim());
                            }
                            countFields++;
                        }
                       
                        // keep the row 
                        capturedRows.add(row);

                    } catch (KettleValueException e) {
                        e.printStackTrace();
                    }
                }
            };
            step.addRowListener(rowAdapter);

            //System.out.println("\nStarting function runTransformation");
            transformation.startThreads();

            // waiting for the transformation to finish
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
        webRootPath = application.getRealPath("/").replace('\\', '/');
        contextWeb = request.getContextPath();
        
        String endpointTypeList = request.getParameter("endpointTypeList");
        directory = request.getParameter("directory");
        
        getTransformationMetadata(webRootPath + "kettle/system/listEndpoints.ktr", endpointTypeList);

        out.write(xmlResult);
    } catch (KettleException e) {
        e.printStackTrace();
        return;
    }

    /*
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
            
     */

%>    