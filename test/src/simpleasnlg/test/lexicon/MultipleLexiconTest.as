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
package simpleasnlg.test.lexicon
{
	import org.flexunit.Assert;
	
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.lexicon.MultipleLexicon;
	import simpleasnlg.lexicon.XMLLexicon;
	
	/**
	 * @author D. Westwater, Data2Text Ltd
	 *
	 */
	public class MultipleLexiconTest
	{
		// NIH, XML lexicon location
		public static const DB_FILENAME: String = "E:\\NIHDB\\lexAccess2009";
		public static const XML_FILENAME:String = "E:\\NIHDB\\default-lexicon.xml";
		
		// multi lexicon
		public var lexicon:MultipleLexicon;
	
	
		//@Before
		public function setUp():void
		{
			this.lexicon = new MultipleLexicon(new XMLLexicon(XML_FILENAME)/*, new NIHDBLexicon(DB_FILENAME)*/);
		}
	
		//@After
		public function tearDown():void
		{
			lexicon.close();
		}
	
		[Test]
		public function testBasics():void
		{
			SharedLexiconTests.doBasicTests(lexicon);
		}
		
		[Test]
		public function testMultipleSpecifics():void
		{
			
			// try to get word which is only in NIH lexicon
			var UK:WordElement = lexicon.getWord("UK");
			Assert.assertEquals("United Kingdom", UK.getFeatureAsString(LexicalFeature.ACRONYM_OF));
	
			var treeList:Array; 
			// test alwaysSearchAll flag
			var alwaysSearchAll:Boolean = lexicon.isAlwaysSearchAll();
			
			// tree as noun exists in both, but as verb only in NIH
			lexicon.setAlwaysSearchAll(true);
			Assert.assertEquals(3, lexicon.getWords("tree").length); // 3 = once in XML plus twice in NIH
	
			lexicon.setAlwaysSearchAll(false);
			Assert.assertEquals(1, lexicon.getWords("tree").length);
	
			// restore flag to original state
			lexicon.setAlwaysSearchAll(alwaysSearchAll);	
		}
	
	}
}
