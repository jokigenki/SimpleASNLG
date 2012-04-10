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
package simpleasnlg.test.xmlrealiser
{
	import flash.filesystem.File;
	
	import simpleasnlg.xmlrealiser.XMLRealiser;

	/**
	 * This class is intended for regression testing of the XMl realiser framework.
	 * It works by accepting an xml file (representing the test cases) and a path to
	 * the lexicon file to use, and instantiating an <code>XMLRealiser</code> to map
	 * the XML to simplenlg objects. It outputs the results in an XML file, named
	 * like the input file (with the suffix <i>out</i>), in which the realisation
	 * has been appended to each test case.
	 * 
	 * @author Christopher Howell, Agfa Healthcare Corporation
	 */
	public class Tester
	{
		/**
		 * The main method. The arguments expecetd are:
		 * <OL>
		 * <LI>-test</LI>
		 * <LI>path to xml file with recording element, or to a directory containing
		 * such files, OR path to file with request element, or to a directory
		 * containing such files</LI>
		 * <LI>path to the file containing the NIH DB lexicon to use</LI>
		 * </OL>
		 * 
		 * @param args
		 *            the arguments
		 */
		public static function main(args:Vector.<String>):void
		{
			var processTestSets:Boolean;
			var testsPath:String = "";
			var xmlFile:String = "";
			var lexDB:String;
			var ix:int = 0;
			var usage:String = "usage: Tester [-test <xml file with Recording element or path to such files> | "
					+ "<xml file with Request element>] <NIH db location>";
	
			if (args.length < 2)
			{
				trace(usage);
				return;
			}
	
			if (args[ix].matches("-test"))
			{
				ix++;
				processTestSets = true;
				testsPath = args[ix++];
			} else {
				processTestSets = false;
				xmlFile = args[ix++];
			}
	
			if (args.length < ix + 1) {
				trace(usage);
				return;
			}
	
			lexDB = (String) args[ix];
			XMLRealiser.setLexicon(LexiconType.NIHDB, lexDB);
	
			if (processTestSets)
			{
				var testFiles:Vector.<File>;
				var filter:FilenameFilter = new TestFilenameFilter();
				var path:File = new File(testsPath);
				if (path.isDirectory()) {
					testFiles = listFiles(path, filter, true);
				} else {
					testFiles = new Vector<File>();
					testFiles.push(path);
				}
import com.steamshift.utils.StringUtils;
	
				for each (var testFile:File in testFiles)
				{
					try {
						var reader:FileReader = new FileReader(testFile);
						var input:RecordSet = XMLRealiser.getRecording(reader);
						var output:RecordSet = new RecordSet();
						output.setName(input.getName());
	
						for each (var test:DocumentRealisation in input.getRecord())
						{
							var testOut:DocumentRealisation = new DocumentRealisation();
							testOut.setName(test.getName());
							testOut.setDocument(test.getDocument());
							var realisation:String = XMLRealiser.realise(test.getDocument());
							testOut.setRealisation(realisation);
							output.getRecord().push(testOut);
						}
	
						var outFileName:String = testFile.getAbsolutePath();
						outFileName = outFileName.replaceFirst("\\.xml$", "Out.xml");
						var outFile:FileOutputStream = new FileOutputStream(outFileName);
						outFile.getChannel().truncate(0);
						Recording.writeRecording(output, outFile);
	
					} catch (XMLRealiserException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (FileNotFoundException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (JAXBException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (TransformerException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
	
			} else {
				var result:String = "";
				var reader:FileReader;
				try {
					reader = new FileReader(xmlFile);
				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					return;
				}
	
				try
				{
					result = XMLRealiser.realise(XMLRealiser.getRequest(reader).getDocument());
				}
				catch (e:Error)
				{
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
	
				trace(result);
			}
		}
	
		// /////////////// copied code ///////////////////////////////
		// Copied from http://snippets.dzone.com/posts/show/1875
		/**
		 * List files as array.
		 * 
		 * @param directory
		 *            the directory
		 * @param filter
		 *            the filter
		 * @param recurse
		 *            the recurse
		 * @return the file[]
		 */
		public static function listFilesAsArray(directory:File, filter:FilenameFilter, recurse:Boolean):Vector.<File>
		{
			var files:Vector.<File> = listFiles(directory, filter, recurse);
			// Java4: Collection files = listFiles(directory, filter, recurse);
	
			return files;
		}
	
		/**
		 * List files.
		 * 
		 * @param directory
		 *            the directory
		 * @param filter
		 *            the filter
		 * @param recurse
		 *            the recurse
		 * @return the collection
		 */
		public static function listFiles(directory:File, filter:FilenameFilter, recurse:Boolean):Vector.<File>
		{
			// List of files / directories
			var files:Vector<File> = new Vector<File>();
			// Java4: Vector files = new Vector();
	
			// Get files / directories in the directory
			var entries:Array = directory.getDirectoryListing();
	
			// Go over entries
			for each (var entry:File in entries)
			{
				// Java4: for (int f = 0; f < files.length; f++) {
				// Java4: File entry = (File) files[f];
	
				// If there is no filter or the filter accepts the
				// file / directory, add it to the list
				if (filter == null || filter.accept(directory, entry.getName())) {
					files[files.length] = entry;
				}
	
				// If the file is a directory and the recurse flag
				// is set, recurse into the directory
				if (recurse && entry.isDirectory())
				{
					files = files.concat(listFiles(entry, filter, recurse));
				}
			}
	
			// Return collection of files
			return files;
		}
	}
}

// //////////////////////// end of copied code ////////////////////////

class TestFilenameFilter implements FilenameFilter
{
	override public function accept(dir:File, name:String):Boolean
	{
		return (StringUtils.endsWith(name, ".xml") && !StringUtils.endsWith("Out.xml"));
	}
}
