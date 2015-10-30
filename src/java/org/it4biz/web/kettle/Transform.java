/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.it4biz.web.kettle;

import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author fernandommota
 */
@XmlRootElement(name = "transform")
@XmlAccessorType (XmlAccessType.FIELD)
public class Transform {
    
    @XmlAttribute
    private String name;
    @XmlAttribute
    private String directory;
    @XmlAttribute
    private int id;
    
    @XmlElementWrapper(name = "params")
    private List<Param> param;
    @XmlElementWrapper(name = "fields")
    private List<Field> field;

    
    public Transform(){
    }
    /*
    public Transform(int lengthParams, int lengthFields){
        param = new Param[lengthParams];
        field = new Field[lengthFields];
    }*/

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDirectory() {
        return directory;
    }

    
    public void setDirectory(String directory) {
        this.directory = directory;
    }

    public int getId() {
        return id;
    }

   
    public void setId(int id) {
        this.id = id;
    }

    
    public List<Param> getParams() {
        return param;
    }

    
    public void setParams(List<Param> params) {
        this.param = params;
    }

    public List<Field> getFields() {
        return field;
    }

    
    public void setFields(List<Field> fields) {
        this.field = fields;
    }
    
    
}
