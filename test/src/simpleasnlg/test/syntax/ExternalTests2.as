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
	import simpleasnlg.features.Form;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.phrasespec.AdvPhraseSpec;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.phrasespec.VPPhraseSpec;
	
	/**
	 * Further tests from third parties
	 * @author Albert Gatt, University of Malta and University of Aberdeen
	 *
	 */
	public class ExternalTests2 extends SimpleNLG4Test
	{
		public function ExternalTests2(name:String = null)
		{
			super(name);
			// TODO Auto-generated constructor stub
		}
	
		/**
		 * Check that empty phrases are not realised as "null"
		 */
		public function testEmptyPhraseRealisation():void
		{
			var emptyClause:SPhraseSpec = this.phraseFactory.createClause();
			Assert.assertEquals("", this.realiser.realise(emptyClause).getRealisation());
		}
			
		/**
		 * Check that empty coordinate phrases are not realised as "null"
		 */
		public function testEmptyCoordination():void
		{		
			//first a simple phrase with no coordinates
			var coord:CoordinatedPhraseElement = this.phraseFactory.createCoordinatedPhrase();
			Assert.assertEquals("", this.realiser.realise(coord).getRealisation());
			
			//now one with a premodifier and nothing else
			coord.addPreModifier(this.phraseFactory.createAdjectivePhrase("nice"));
			Assert.assertEquals("nice", this.realiser.realise(coord).getRealisation());			
		}
		
		/**
		 * Test change from "a" to "an" in the presence of a premodifier with a vowel
		 */
		public function testIndefiniteWithVowelPremodifier():void
		{
			var s:SPhraseSpec = this.phraseFactory.createClause("there", "be");
			s.setFeature(Feature.TENSE, Tense.PRESENT);
			var np:NPPhraseSpec = this.phraseFactory.createNounPhrase("stenosis", "a");
			s.setObject(np);
			
			//check without modifiers -- article should be "a"
			Assert.assertEquals("there is a stenosis", this.realiser.realise(s).getRealisation());
			
			//add a single modifier -- should turn article to "an"
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("eccentric"));
			Assert.assertEquals("there is an eccentric stenosis", this.realiser.realise(s).getRealisation());
		}
		
		/**
		 * Test for indefinite article changing back to a when given a consonant premodifier
		 */
		public function testIndefiniteWithConsonantPremodifier():void
		{
			var s:SPhraseSpec = this.phraseFactory.createClause("there", "be");
			s.setFeature(Feature.TENSE, Tense.PRESENT);
			var np:NPPhraseSpec = this.phraseFactory.createNounPhrase("elephant", "a");
			s.setObject(np);
			
			//check without modifiers -- article should be "an"
			Assert.assertEquals("there is an elephant", this.realiser.realise(s).getRealisation());
			
			//add a single modifier -- should turn article to "a"
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("magic"));
			Assert.assertEquals("there is a magic elephant", this.realiser.realise(s).getRealisation());
		}
		
		/**
		 * Test for indefinite not changing with eu words
		 */
		public function testIndefiniteWithEUPremodifier():void
		{
			var s:SPhraseSpec = this.phraseFactory.createClause("there", "be");
			s.setFeature(Feature.TENSE, Tense.PRESENT);
			var np:NPPhraseSpec = this.phraseFactory.createNounPhrase("elephant", "a");
			s.setObject(np);
			
			//check without modifiers -- article should be "an"
			Assert.assertEquals("there is an elephant", this.realiser.realise(s).getRealisation());
			
			//add a single modifier -- should turn article to "a"
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("european"));
			Assert.assertEquals("there is a european elephant", this.realiser.realise(s).getRealisation());
		}
		
		/**
		 * Test for indefinite article not changing when in front of u*vowel words, but changing in front of u* words
		 */
		public function testIndefiniteWithUPremodifier():void
		{
			var s:SPhraseSpec = this.phraseFactory.createClause("there", "be");
			s.setFeature(Feature.TENSE, Tense.PRESENT);
			var np:NPPhraseSpec = this.phraseFactory.createNounPhrase("boss", "a");
			s.setObject(np);
			
			//check without modifiers -- article should be "a"
			Assert.assertEquals("there is a boss", this.realiser.realise(s).getRealisation());
			
			//add a single modifier -- article should remain "a"
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("union"));
			Assert.assertEquals("there is a union boss", this.realiser.realise(s).getRealisation());
			
			s = this.phraseFactory.createClause("there", "be");
			s.setFeature(Feature.TENSE, Tense.PRESENT);
			np = this.phraseFactory.createNounPhrase("tissue", "a");
			s.setObject(np);
			
			//check without modifiers -- article should be "a"
			Assert.assertEquals("there is a tissue", this.realiser.realise(s).getRealisation());
			
			//add a single modifier -- article should remain "a"
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("used"));
			Assert.assertEquals("there is a used tissue", this.realiser.realise(s).getRealisation());
			
			s = this.phraseFactory.createClause("there", "be");
			s.setFeature(Feature.TENSE, Tense.PRESENT);
			np = this.phraseFactory.createNounPhrase("station", "a");
			s.setObject(np);
			
			//check without modifiers -- article should be "a"
			Assert.assertEquals("there is a station", this.realiser.realise(s).getRealisation());
			
			//add a single modifier -- article should change to "an"
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("underground"));
			Assert.assertEquals("there is an underground station", this.realiser.realise(s).getRealisation());
		}
		
		/**
		 * Test for comma separation between premodifers
		 */
		public function testMultipleAdjPremodifiers():void
		{
			var np:NPPhraseSpec = this.phraseFactory.createNounPhrase("stenosis", "a");
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("eccentric"));
			np.addPreModifier(this.phraseFactory.createAdjectivePhrase("discrete"));
			Assert.assertEquals("an eccentric, discrete stenosis", this.realiser.realise(np).getRealisation());				
		}
		
		/**
		 * Test for comma separation between verb premodifiers
		 */
		public function testMultipleAdvPremodifiers():void
		{	
			var adv1:AdvPhraseSpec = this.phraseFactory.createAdverbPhrase("slowly");
			var adv2:AdvPhraseSpec = this.phraseFactory.createAdverbPhrase("discretely");
	
			//case 1: concatenated premods: should have comma
			var vp:VPPhraseSpec = this.phraseFactory.createVerbPhrase("run");
			vp.addPreModifier(adv1);
			vp.addPreModifier(adv2);
			Assert.assertEquals("slowly, discretely runs", this.realiser.realise(vp).getRealisation());
					
			//case 2: coordinated premods: no comma
			var vp2:VPPhraseSpec = this.phraseFactory.createVerbPhrase("eat");
			vp2.addPreModifier(this.phraseFactory.createCoordinatedPhrase(adv1, adv2));
			Assert.assertEquals("slowly and discretely eats", this.realiser.realise(vp2).getRealisation());
		}
	
		public function testParticipleModifier():void
		{
			var verb:String = "associate";
			var adjP:VPPhraseSpec = this.phraseFactory.createVerbPhrase(verb);
			adjP.setFeature(Feature.TENSE, Tense.PAST);
			
			var np:NPPhraseSpec = this.phraseFactory.createNounPhrase("thrombus", "a");
			np.addPreModifier(adjP);
			var realised:String = this.realiser.realise(np).getRealisation();
			
			// cch TESTING The following line doesn't work when the lexeme is a
			// verb.
			// morphP.preMod.push(new AdjPhraseSpec((Lexeme)modifier));
	
			// It doesn't work for verb "associate" as adjective past participle.
			// Instead of realizing as "associated" it realizes as "ed".
			// Need to use verb phrase.
	
			// cch TODO : handle general case making phrase type corresponding to
			// lexeme category and usage.
		}
		
		/**
		 * Check that setComplement replaces earlier complements
		 */
		public function testSetComplement():void
		{
			var s:SPhraseSpec = this.phraseFactory.createClause();
			s.setSubject("I");
			s.setVerb("see");
			s.setObject("a dog");
			
			Assert.assertEquals("I see a dog", this.realiser.realise(s).getRealisation());
			
			s.setObject("a cat");
			Assert.assertEquals("I see a cat", this.realiser.realise(s).getRealisation());
			
			s.setObject("a wolf");
			Assert.assertEquals("I see a wolf", this.realiser.realise(s).getRealisation());
	
		}
		
		public function testPlural ():void
		{
			var singular:SPhraseSpec = this.phraseFactory.createClause("my dog", "like", phraseFactory.createNounPhrase("bone", "a"));
			
			Assert.assertEquals("My dog likes a bone.", realiser.realiseSentence(singular));
			
			var plural:SPhraseSpec = this.phraseFactory.createClause("my dog", "like", "bones");
			
			Assert.assertEquals("My dog likes bones.", realiser.realiseSentence(plural));
		}
		
		/**
		 * Test for subclauses involving WH-complements
		 * Based on a query by Owen Bennett
		 */
		public function testSubclauses():void
		{
			//Once upon a time there was an Accountant, called Jeff, who lived in a forest.
			
			//accountant phrase
			var acct:NPPhraseSpec = this.phraseFactory.createNounPhrase("accountant", "a");
			
			//first postmodifier of "an accountant" 
			var sub1:VPPhraseSpec = this.phraseFactory.createVerbPhrase("call");
			sub1.addComplementAsString("Jeff");
			sub1.setFeature(Feature.FORM, Form.PAST_PARTICIPLE);
			//this is an appositive modifier, which makes simplenlg put it between commas
			sub1.setFeature(Feature.APPOSITIVE, true);
			acct.addPostModifier(sub1);
			
			//second postmodifier of "an accountant" is "who lived in a forest"
			var sub2:SPhraseSpec = this.phraseFactory.createClause();
			var subvp:VPPhraseSpec = this.phraseFactory.createVerbPhrase("live");
			subvp.setFeature(Feature.TENSE, Tense.PAST);
			subvp.setComplement(this.phraseFactory.createPrepositionPhrase("in", this.phraseFactory.createNounPhrase("forest", "a")));
			sub2.setVerbPhrase(subvp);
			//simplenlg can't yet handle wh-clauses in NPs, so we need to hack it by setting the subject to "who"
			sub2.setSubject("who");
			acct.addPostModifier(sub2);
			
			//main sentence		
			var s:SPhraseSpec = this.phraseFactory.createClause("there", "be", acct);
			s.setFeature(Feature.TENSE, Tense.PAST);
			
			//add front modifier "once upon a time"
			s.addFrontModifierAsString("once upon a time");
			
			Assert.assertEquals("once upon a time there was an accountant, called Jeff, who lived in a forest", this.realiser.realise(s).getRealisation());
		}
		
		/**
		 * Test for subclauses involving WH-complements
		 * Based on a query by Owen Bennett
		 */
		public function testSubclausesForRSS():void
		{
			//Once upon a time there was an Accountant, called Jeff, who lived in a forest.
			
			// create empty clause
			var s:SPhraseSpec = this.phraseFactory.createClause();
			s.setFeature(Feature.TENSE, Tense.PAST);
			
			//add front modifier "once upon a time"
			s.addFrontModifierAsString("once upon a time");
			
			// set subject and verb
			s.setSubject("there");
			s.setVerb("be");
			
			//accountant phrase
			var acct:NPPhraseSpec = this.phraseFactory.createNounPhrase("accountant", "a");
			s.setObject(acct);
			
			//first postmodifier of "an accountant" 
			var sub1:VPPhraseSpec = this.phraseFactory.createVerbPhrase("call");
			sub1.addComplementAsString("Jeff");
			sub1.setFeature(Feature.FORM, Form.PAST_PARTICIPLE);
			//this is an appositive modifier, which makes simplenlg put it between commas
			sub1.setFeature(Feature.APPOSITIVE, true);
			acct.addPostModifier(sub1);
			
			//second postmodifier of "an accountant" is "who lived in a forest"
			var sub2:SPhraseSpec = this.phraseFactory.createClause();
			var subvp:VPPhraseSpec = this.phraseFactory.createVerbPhrase("live");
			subvp.setFeature(Feature.TENSE, Tense.PAST);
			subvp.setComplement(this.phraseFactory.createPrepositionPhrase("in", this.phraseFactory.createNounPhrase("forest", "a")));
			sub2.setVerbPhrase(subvp);
			//simplenlg can't yet handle wh-clauses in NPs, so we need to hack it by setting the subject to "who"
			sub2.setSubject("who");
			acct.addPostModifier(sub2);
			
			Assert.assertEquals("once upon a time there was an accountant, called Jeff, who lived in a forest", this.realiser.realise(s).getRealisation());
		}
	}
}
