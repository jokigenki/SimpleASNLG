//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.10 in JDK 6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2011.06.02 at 10:58:15 AM CEST 
//


package simpleasnlg.xmlrealiser.wrapper
{
	import java.util.Array;
	import java.util.List;
	import javax.xml.bind.annotation.XmlAccessType;
	import javax.xml.bind.annotation.XmlAccessorType;
	import javax.xml.bind.annotation.XmlAttribute;
	import javax.xml.bind.annotation.XmlElement;
	import javax.xml.bind.annotation.XmlType;
	
	
	/**
	 * <p>Java class for CoordinatedPhraseElement complex type.
	 * 
	 * <p>The following schema fragment specifies the expected content contained within this class.
	 * 
	 * <pre>
	 * &lt;complexType name="CoordinatedPhraseElement">
	 *   &lt;complexContent>
	 *     &lt;extension base="{http://code.google.com/p/simplenlg/schemas/version1}NLGElement">
	 *       &lt;sequence>
	 *         &lt;element name="coord" type="{http://code.google.com/p/simplenlg/schemas/version1}NLGElement" maxOccurs="unbounded"/>
	 *       &lt;/sequence>
	 *       &lt;attGroup ref="{http://code.google.com/p/simplenlg/schemas/version1}CoordinatedPhraseAtts"/>
	 *     &lt;/extension>
	 *   &lt;/complexContent>
	 * &lt;/complexType>
	 * </pre>
	 * 
	 * 
	 */
	@XmlAccessorType(XmlAccessType.FIELD)
	@XmlType(name = "CoordinatedPhraseElement", propOrder = {
	    "coord"
	})
	public class XmlCoordinatedPhraseElement
	    extends XmlNLGElement
	{
	
	    @XmlElement(required = true)
	    protected List<XmlNLGElement> coord;
	    @XmlAttribute
	    protected String conj;
	    @XmlAttribute
	    protected XmlPhraseCategory cat;
	    @XmlAttribute(name = "PERSON")
	    protected XmlPerson person;
	    @XmlAttribute(name = "POSSESSIVE")
	    protected Boolean possessive;
	
	    /**
	     * Gets the value of the coord property.
	     * 
	     * <p>
	     * This accessor method returns a reference to the live list,
	     * not a snapshot. Therefore any modification you make to the
	     * returned list will be present inside the JAXB object.
	     * This is why there is not a <CODE>set</CODE> method for the coord property.
	     * 
	     * <p>
	     * For example, to add a new item, do as follows:
	     * <pre>
	     *    getCoord().push(newItem);
	     * </pre>
	     * 
	     * 
	     * <p>
	     * Objects of the following type(s) are allowed in the list
	     * {@link XmlNLGElement }
	     * 
	     * 
	     */
	    public List<XmlNLGElement> getCoord() {
	        if (coord == null) {
	            coord = new Array<XmlNLGElement>();
	        }
	        return this.coord;
	    }
	
	    /**
	     * Gets the value of the conj property.
	     * 
	     * @return
	     *     possible object is
	     *     {@link String }
	     *     
	     */
	    public String getConj() {
	        if (conj == null) {
	            return "and";
	        } else {
	            return conj;
	        }
	    }
	
	    /**
	     * Sets the value of the conj property.
	     * 
	     * @param value
	     *     allowed object is
	     *     {@link String }
	     *     
	     */
	    public function setConj(String value) {
	        this.conj = value;
	    }
	
	    /**
	     * Gets the value of the cat property.
	     * 
	     * @return
	     *     possible object is
	     *     {@link XmlPhraseCategory }
	     *     
	     */
	    public XmlPhraseCategory getCat() {
	        return cat;
	    }
	
	    /**
	     * Sets the value of the cat property.
	     * 
	     * @param value
	     *     allowed object is
	     *     {@link XmlPhraseCategory }
	     *     
	     */
	    public function setCat(XmlPhraseCategory value) {
	        this.cat = value;
	    }
	
	    /**
	     * Gets the value of the person property.
	     * 
	     * @return
	     *     possible object is
	     *     {@link XmlPerson }
	     *     
	     */
	    public XmlPerson getPERSON() {
	        return person;
	    }
	
	    /**
	     * Sets the value of the person property.
	     * 
	     * @param value
	     *     allowed object is
	     *     {@link XmlPerson }
	     *     
	     */
	    public function setPERSON(XmlPerson value) {
	        this.person = value;
	    }
	
	    /**
	     * Gets the value of the possessive property.
	     * 
	     * @return
	     *     possible object is
	     *     {@link Boolean }
	     *     
	     */
	    public Boolean isPOSSESSIVE() {
	        return possessive;
	    }
	
	    /**
	     * Sets the value of the possessive property.
	     * 
	     * @param value
	     *     allowed object is
	     *     {@link Boolean }
	     *     
	     */
	    public function setPOSSESSIVE(Boolean value) {
	        this.possessive = value;
	    }
	}
}
