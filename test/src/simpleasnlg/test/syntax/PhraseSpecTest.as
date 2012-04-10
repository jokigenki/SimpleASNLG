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
package simpleasnlg.test.syntax
{
	import flexunit.framework.Assert;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.StringElement;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	/**
	 * test suite for simple XXXPhraseSpec classes
	 * @author ereiter
	 * 
	 */
	
	public class PhraseSpecTest extends SimpleNLG4Test
	{
	
		public function PhraseSpecTest(name:String = null)
		{
			super(name);
		}
	
		/**
		 * Test SPhraseSpec
		 */
		[Test]
		public function testSPhraseSpec():void
		{
			// simple test of methods
			var c1:SPhraseSpec = SPhraseSpec(phraseFactory.createClause());
			c1.setVerb("give");
			c1.setSubject("John");
			c1.setObject("an apple");
			c1.setIndirectObject("Mary");
			c1.setFeature(Feature.TENSE, Tense.PAST);
			c1.setFeature(Feature.NEGATED, true);
			
			// check getXXX methods
			Assert.assertEquals("give",  getBaseForm(c1.getVerb()));
			Assert.assertEquals("John", getBaseForm(c1.getSubject()));
			Assert.assertEquals("an apple", getBaseForm(c1.getObject()));
			Assert.assertEquals("Mary", getBaseForm(c1.getIndirectObject()));
			
			Assert.assertEquals("John did not give Mary an apple", this.realiser.realise(c1).getRealisation());
			
	
			
			// test modifier placement
			var c2:SPhraseSpec = SPhraseSpec(phraseFactory.createClause());
			c2.setVerb("see");
			c2.setSubject("the man");
			c2.setObject("me");
			c2.addModifierAsString("fortunately");
			c2.addModifierAsString("quickly");
			c2.addModifierAsString("in the park");
			// try setting tense directly as a feature
			c2.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("fortunately the man quickly saw me in the park", this.realiser.realise(c2).getRealisation());
		}
	
		// get string for head of constituent
		private function getBaseForm(constituent:NLGElement):String
		{
			if (constituent == null) return null;
			else if (constituent is StringElement) return constituent.getRealisation();
			else if (constituent is WordElement) return (WordElement(constituent)).getBaseForm();
			else if (constituent is InflectedWordElement) return getBaseForm(InflectedWordElement(constituent).getBaseWord());
			else if (constituent is PhraseElement) return getBaseForm(PhraseElement(constituent).getHead());
			else return null;
		}
	}
}
