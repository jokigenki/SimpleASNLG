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
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.StringElement;
	
	/**
	 * This class incorporates a few tests for adjectival phrases. Also tests for
	 * adverbial phrase specs, which are very similar
	 * @author agatt
	 */
	public class AdjectivePhraseTest extends SimpleNLG4Test
	{
		/**
		 * Instantiates a new adj p test.
		 * 
		 * @param name
		 *            the name
		 */
		public function AdjectivePhraseTest(name:String = null)
		{
			super(name);
		}
	
		/**
		 * Test premodification & coordination of Adjective Phrases (Not much else
		 * to simpleasnlg.test)
		 */
		[Test]
		public function testAdj():void
		{
			// form the adjphrase "incredibly salacious"
			this.salacious.addPreModifier(this.phraseFactory.createAdverbPhrase("incredibly")); //$NON-NLS-1$
			Assert.assertEquals("incredibly salacious", this.realiser.realise(this.salacious).getRealisation());
	
			// form the adjphrase "incredibly beautiful"
			this.beautiful.addPreModifierAsString("amazingly"); //$NON-NLS-1$
			Assert.assertEquals("amazingly beautiful", this.realiser.realise(this.beautiful).getRealisation());
	
			// coordinate the two aps
			var coordap:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.salacious, this.beautiful);
			Assert.assertEquals("incredibly salacious and amazingly beautiful", this.realiser.realise(coordap).getRealisation());
	
			// changing the inner conjunction
			coordap.setFeature(Feature.CONJUNCTION, "or"); //$NON-NLS-1$
			Assert.assertEquals("incredibly salacious or amazingly beautiful", this.realiser.realise(coordap).getRealisation());
	
			// coordinate this with a new AdjPhraseSpec
			var coord2:CoordinatedPhraseElement = new CoordinatedPhraseElement(coordap, this.stunning);
			Assert.assertEquals("incredibly salacious or amazingly beautiful and stunning", this.realiser.realise(coord2).getRealisation());
	
			// add a premodifier the coordinate phrase, yielding
			// "seriously and undeniably incredibly salacious or amazingly beautiful
			// and stunning"
			var preMod:CoordinatedPhraseElement = new CoordinatedPhraseElement(new StringElement("seriously"), new StringElement("undeniably")); //$NON-NLS-1$//$NON-NLS-2$
	
			coord2.addPreModifier(preMod);
			Assert.assertEquals("seriously and undeniably incredibly salacious or amazingly beautiful and stunning", this.realiser.realise(coord2).getRealisation());
	
			// adding a coordinate rather than coordinating should give a different
			// result
			coordap.addCoordinate(this.stunning);
			Assert.assertEquals("incredibly salacious, amazingly beautiful or stunning", this.realiser.realise(coordap).getRealisation());
		}
	
		/**
		 * Simple test of adverbials
		 */
		[Test]
		public function testAdv():void
		{
			var sent:PhraseElement = this.phraseFactory.createClause("John", "eat"); //$NON-NLS-1$ //$NON-NLS-2$
	
			var adv:PhraseElement = this.phraseFactory.createAdverbPhrase("quickly"); //$NON-NLS-1$
	
			sent.addPreModifier(adv);
	
			Assert.assertEquals("John quickly eats", this.realiser.realise(sent).getRealisation());
	
			adv.addPreModifierAsString("very"); //$NON-NLS-1$
	
			Assert.assertEquals("John very quickly eats", this.realiser.realise(sent).getRealisation());
	
		}
	}
}
