//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.10 in JDK 6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2011.06.02 at 10:58:15 AM CEST 
//


package simpleasnlg.xmlrealiser.wrapper
{
	import javax.xml.bind.annotation.XmlAccessType;
	import javax.xml.bind.annotation.XmlAccessorType;
	import javax.xml.bind.annotation.XmlElement;
	import javax.xml.bind.annotation.XmlRootElement;
	import javax.xml.bind.annotation.XmlType;
	
	
	/**
	 * <p>Java class for anonymous complex type.
	 * 
	 * <p>The following schema fragment specifies the expected content contained within this class.
	 * 
	 * <pre>
	 * &lt;complexType>
	 *   &lt;complexContent>
	 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
	 *       &lt;choice>
	 *         &lt;element name="Request" type="{http://code.google.com/p/simplenlg/schemas/version1}RequestType"/>
	 *         &lt;element name="Recording" type="{http://code.google.com/p/simplenlg/schemas/version1}RecordSet"/>
	 *       &lt;/choice>
	 *     &lt;/restriction>
	 *   &lt;/complexContent>
	 * &lt;/complexType>
	 * </pre>
	 * 
	 * 
	 */
	@XmlAccessorType(XmlAccessType.FIELD)
	@XmlType(name = "", propOrder = {
	    "request",
	    "recording"
	})
	@XmlRootElement(name = "NLGSpec")
	public class NLGSpec {
	
	    @XmlElement(name = "Request")
	    protected RequestType request;
	    @XmlElement(name = "Recording")
	    protected RecordSet recording;
	
	    /**
	     * Gets the value of the request property.
	     * 
	     * @return
	     *     possible object is
	     *     {@link RequestType }
	     *     
	     */
	    public RequestType getRequest() {
	        return request;
	    }
	
	    /**
	     * Sets the value of the request property.
	     * 
	     * @param value
	     *     allowed object is
	     *     {@link RequestType }
	     *     
	     */
	    public function setRequest(RequestType value) {
	        this.request = value;
	    }
	
	    /**
	     * Gets the value of the recording property.
	     * 
	     * @return
	     *     possible object is
	     *     {@link RecordSet }
	     *     
	     */
	    public RecordSet getRecording() {
	        return recording;
	    }
	
	    /**
	     * Sets the value of the recording property.
	     * 
	     * @param value
	     *     allowed object is
	     *     {@link RecordSet }
	     *     
	     */
	    public function setRecording(RecordSet value) {
	        this.recording = value;
	    }
	}
}
