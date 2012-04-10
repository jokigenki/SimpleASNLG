/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is "Simplenlg".
 *
 * The Initial Developer of the Original Code is Ehud Reiter, Albert Gatt and Dave Westwater.
 * Portions created by Ehud Reiter, Albert Gatt and Dave Westwater are Copyright (C) 2010-11 The University of Aberdeen. All Rights Reserved.
 *
 * Actionscript Conversion by Owen Bennett
*
* Contributor(s): Ehud Reiter, Albert Gatt, Dave Wewstwater, Roman Kutlak, Margaret Mitchell, Owen Bennett
 */

package simpleasnlg.xmlrealiser
{
	import flash.filesystem.File;
	
	import simpleasnlg.xmlrealiser.wrapper.DocumentRealisation;
	import simpleasnlg.xmlrealiser.wrapper.NLGSpec;
	import simpleasnlg.xmlrealiser.wrapper.RecordSet;
	
	/**
	 * A recording is a utility class that holds xml objects for testing the
	 * xmlrealiser.
	 * 
	 * @author Christopher Howell Agfa Healthcare Corporation
	 * @author Albert Gatt, University of Malta
	 * 
	 */
	public class Recording
	{
		/** The recording on. */
		public var recordingOn:Boolean = false;
	
		/** The recording folder. */
		public var recordingFolder:String;
	
		/** The record. */
		public var record:RecordSet = null;
	
		/** The recording file. */
		public var recordingFile:File;
	
		/**
		 * Instantiate a Recording from an XML file. Recordings can contain multiple
		 * records, each of which represents a single element to be realised.
		 * 
		 * @param directoryPath
		 *            the path to the file
		 */
		public function Recording(directoryPath:String)
		{
			recordingFolder = directoryPath;
		}
	
		/**
		 * Recording on.
		 * 
		 * @return true, if successful
		 */
		public function RecordingOn():Boolean
		{
			return recordingOn;
		}
	
		/**
		 * Gets the recording file.
		 * 
		 * @return the string
		 */
		public function GetRecordingFile():String
		{
			if (recordingOn)
				return recordingFile.nativePath;
			else
				return "";
		}
	
		/**
		 * Start.
		 * 
		 * @throws IOException
		 *             Signals that an I/O exception has occurred.
		 */
		public function start():void
		{
			if (!recordingFolder || recordingFolder == "" || recordingOn)
			{
				return;
			}
	
			var recordingDir:File = new File(recordingFolder);
			if (!recordingDir.exists)
			{
				var ok:Boolean = recordingDir.createDirectory();
				if (!ok) return;
	
				recordingFile = File.createTempFile("xmlrealiser", ".xml", recordingDir);
				recordingOn = true;
				record = new RecordSet();
			}
		}
	
		/**
		 * Adds a record to this recording.
		 * 
		 * @param input
		 *            the DocumentElement in this record
		 * @param output
		 *            the realisation
		 */
		public function addRecord(simpleasnlg.xmlrealiser.wrapper.XmlDocumentElement input, output:String):void
		{
			if (!recordingOn) {
				return;
			}
			var t:DocumentRealisation = new DocumentRealisation();
			var testNumber:int = record.getRecord().length() + 1;
			var testName:String = "TEST_" + testNumber.toString();
			t.setName(testName);
			t.setDocument(input);
			t.setRealisation(output);
			record.getRecord().push(t);
		}
	
		/**
		 * Ends processing for this recording and writes it to an XML file.
		 * 
		 * @throws JAXBException
		 *             the jAXB exception
		 * @throws IOException
		 *             Signals that an I/O exception has occurred.
		 * @throws TransformerException
		 *             the transformer exception
		 */
		public function finish() throws JAXBException, IOException,
				TransformerException {
			if (!recordingOn) {
				return;
			}
	
			recordingOn = false;
			var os:FileOutputStream = new FileOutputStream(recordingFile);
			os.getChannel().truncate(0);
			writeRecording(record, os);
		}
	
		/**
		 * Write recording.
		 * 
		 * @param record
		 *            the record
		 * @param os
		 *            the os
		 * @throws JAXBException
		 *             the jAXB exception
		 * @throws IOException
		 *             Signals that an I/O exception has occurred.
		 * @throws TransformerException
		 *             the transformer exception
		 */
		public static function writeRecording(record:RecordSet, os:OutputStream):void
		{
			var jc:JAXBContext;
			jc = JAXBContext.newInstance(simpleasnlg.xmlrealiser.wrapper.RecordSet.class);
			var m:Marshaller = jc.createMarshaller();
	
			// For the meaning of the next property, see the
			// Java Architecture for XML Binding JAXB RI Vendor Extensions Runtime
			// Properties
			// It was added so that the namespace declarations would be at the top
			// of the file, once,
			// instead of on the elements.
			m.setProperty("com.sun.xml.internal.bind.namespacePrefixDictionaryper",
					new RecordingNamespacePrefixDictionaryper());
	
			var nlg:NLGSpec = new NLGSpec();
			nlg.setRecording(record);
	
			var osTemp:StringWriter = new StringWriter();
			m.marshal(nlg, osTemp);
	
			// Prettify it.
			var xmlInput:Source = new StreamSource(new StringReader(osTemp.toString()));
			var xmlOutput:StreamResult = new StreamResult(new OutputStreamWriter(os, "UTF-8"));
			var transformer:Transformer = TransformerFactory.newInstance().newTransformer();
			if (transformer != null)
			{
				transformer.setOutputProperty(OutputKeys.INDENT, "yes");
				transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
				transformer.transform(xmlInput, xmlOutput);
			}
		}
	}
}
	
/**
 * Coerces the JAXB marshaller to declare the "xsi" and "xsd" namespaces at the
 * root element instead of putting them inline on each element that uses one of
 * the namespaces.
 */
class RecordingNamespacePrefixDictionaryper extends NamespacePrefixDictionaryper {
	
	override public function getPreferredPrefix(namespaceUri:String, suggestion:String, requirePrefix:Boolean):String
	{
		return suggestion;
	}
	
	override public getPreDeclaredNamespaceUris2():Vector.<String>
	{
		return new <String>["xsi",
			"http://www.w3.org/2001/XMLSchema-instance", "xsd",
			"http://www.w3.org/2001/XMLSchema"];
	}
}
