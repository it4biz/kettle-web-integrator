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
@XmlRootElement(name = "transforms")
@XmlAccessorType (XmlAccessType.FIELD)
public class Transforms {
    
    @XmlElement(name = "transform")
    private List<Transform> transform;

    public Transforms(){
    }
    
    public List<Transform> getTransform() {
        return transform;
    }

    public void setTransform(List<Transform> transform) {
        this.transform = transform;
    } 
}
