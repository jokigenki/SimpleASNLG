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
	import flexunit.framework.TestCase;
	
	
	import org.flexunit.Assert;
	
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.lexicon.NIHDBLexicon;
	
	/**
	 * Tests for NIHDBLexicon
	 * 
	 * @author Ehud Reiter, Albert Gatt
	 */
	public class NIHDBLexiconTest extends TestCase
	{
		// lexicon object -- an instance of Lexicon
		public var lexicon:NIHDBLexicon = null;
	
		// DB location -- change this to point to the lex access data dir
		public static const DB_FILENAME:String = "A:\\corpora\\LEX\\lexAccess2011\\data\\HSqlDb\\lexAccess2011.data";
	
//		@Before
		/*
		 * * Sets up the accessor and runs it -- takes ca. 26 sec
		 */
		override public function setUp():void
		{
			this.lexicon = new NIHDBLexicon(DB_FILENAME);
		}
	
		/**
		 * Close the lexicon
		 */
		//@After
		override public function tearDown():void
		{
			super.tearDown();
	
			if (lexicon != null)
				lexicon.close();
		}
	
		//[Test]
		public function testBasics():void
		{
			SharedLexiconTests.doBasicTests(lexicon);
		}
	
		//[Test]
		public function testAcronyms():void
		{
			var uk:WordElement = lexicon.getWord("UK");
			var unitedKingdom:WordElement = lexicon.getWord("United Kingdom");
			var fullForms:Array = uk.getFeatureAsElementList(LexicalFeature.ACRONYM_OF);
	
			// "uk" is an acronym of 3 full forms
			Assert.assertEquals(3, fullForms.length());
			Assert.assertTrue(fullForms.indexOf(unitedKingdom) > -1);
		}
	
		//[Test]
		public function testStandardInflections():void
		{
			// test keepStandardInflection flag
			var keepInflectionsFlag:Boolean = lexicon.isKeepStandardInflections();
	
			lexicon.setKeepStandardInflections(true);
			var dog:WordElement = lexicon.getWord("dog", LexicalCategory.NOUN);
			Assert.assertEquals("dogs", dog.getFeatureAsString(LexicalFeature.PLURAL));
	
			lexicon.setKeepStandardInflections(false);
			var cat:WordElement = lexicon.getWord("cat", LexicalCategory.NOUN);
			Assert.assertEquals(null, cat.getFeatureAsString(LexicalFeature.PLURAL));
	
			// restore flag to original state
			lexicon.setKeepStandardInflections(keepInflectionsFlag);
		}
	
		/**
		 * Test for NIHDBLexicon functionality when several threads are using the
		 * same Lexicon
		 */
		//@SuppressWarnings("static-access")
		/*public function testMultiThreadApp():void
		{
	
			var runner1:LexThread = new LexThread("lie");
			var runner2:LexThread = new LexThread("bark");
			
			//schedule them and run them
			var service:ScheduledExecutorService = Executors.newScheduledThreadPool(2);
			service.schedule(runner1, 0, TimeUnit.MILLISECONDS);
			service.schedule(runner2, 0, TimeUnit.MILLISECONDS);
	
			try {
				Thread.currentThread().sleep(500);
			} catch(InterruptedException ie) {
				;//do nothing
			}
			
			service.shutdownNow();
			
			//check that the right words have been retrieved
			Assert.assertEquals( "lie", runner1.word.getBaseForm());
			Assert.assertEquals("bark", runner2.word.getBaseForm());
		}
		*/
	}
}
/*
* Class that implements a thread from which a lexical item can be retrieved
*/
/*
class LexThread extends Thread
{
	var word:WordElement;
	var base:String;
	
	public function LexThread(base:String)
	{
		this.base = base;
	}
	
	public function run():void
	{
		word = lexicon.getWord(base, LexicalCategory.VERB);
	}
}
*/
