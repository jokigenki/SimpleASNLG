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
	
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Person;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.phrasespec.VPPhraseSpec;
	
	// TODO: Auto-generated Javadoc
	/**
	 * These are tests for the verb phrase and coordinate VP classes.
	 * @author agatt
	 */
	public class VerbPhraseTest extends SimpleNLG4Test
	{
		/**
		 * Instantiates a new vP test.
		 * 
		 * @param name
		 *            the name
		 */
		public function VerbPhraseTest(name:String = null)
		{
			super(name);
		}


import simpleasnlg.framework.CoordinatedPhraseElement;
import simpleasnlg.framework.PhraseElement;
	
		/**
		 * Some tests to check for an early bug which resulted in reduplication of
		 * verb particles in the past tense e.g. "fall down down" or "creep up up"
		 */
		[Test]
		public function testVerbParticle():void
		{
			var v:VPPhraseSpec = this.phraseFactory.createVerbPhrase("fall down"); //$NON-NLS-1$
	
			Assert.assertEquals("down", v.getFeatureAsString(Feature.PARTICLE)); //$NON-NLS-1$
	
			Assert.assertEquals("fall", WordElement(v.getVerb()).getBaseForm()); //$NON-NLS-1$
	
			v.setFeature(Feature.TENSE,Tense.PAST);
			v.setFeature(Feature.PERSON, Person.THIRD);
			v.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
	
			Assert.assertEquals("fell down", this.realiser.realise(v).getRealisation()); //$NON-NLS-1$
	
			v.setFeature(Feature.FORM, Form.PAST_PARTICIPLE);
			Assert.assertEquals("fallen down", this.realiser.realise(v).getRealisation()); //$NON-NLS-1$
		}
	
		/**
		 * Tests for the tense and aspect.
		 */
		[Test]
		public function testSimplePast():void
		{
			// "fell down"
			this.fallDown.setFeature(Feature.TENSE,Tense.PAST);
			Assert.assertEquals("fell down", this.realiser.realise(this.fallDown).getRealisation()); //$NON-NLS-1$
	
		}
	
		/**
		 * Test tense aspect.
		 */
		[Test]
		public function testTenseAspect():void
		{
			// had fallen down
			this.realiser.setLexicon(this.lexicon);
			this.fallDown.setFeature(Feature.TENSE,Tense.PAST);
			this.fallDown.setFeature(Feature.PERFECT, true);
	
			Assert.assertEquals("had fallen down", this.realiser.realise(this.fallDown).getRealisation());
	
			// had been falling down
			this.fallDown.setFeature(Feature.PROGRESSIVE, true);
			Assert.assertEquals("had been falling down", this.realiser.realise(this.fallDown).getRealisation());
	
			// will have been kicked
			this.kick.setFeature(Feature.PASSIVE, true);
			this.kick.setFeature(Feature.PERFECT, true);
			this.kick.setFeature(Feature.TENSE,Tense.FUTURE);
			Assert.assertEquals("will have been kicked", this.realiser.realise(this.kick).getRealisation());
	
			// will have been being kicked
			this.kick.setFeature(Feature.PROGRESSIVE, true);
			Assert.assertEquals("will have been being kicked", this.realiser.realise(this.kick).getRealisation());
	
			// will not have been being kicked
			this.kick.setFeature(Feature.NEGATED, true);
			Assert.assertEquals("will not have been being kicked", this.realiser.realise(this.kick).getRealisation());
	
			// passivisation should suppress the complement
			this.kick.clearComplements();
			this.kick.addComplement(this.man);
			Assert.assertEquals("will not have been being kicked", this.realiser.realise(this.kick).getRealisation());
	
			// de-passivisation should now give us "will have been kicking the man"
			this.kick.setFeature(Feature.PASSIVE, false);
			Assert.assertEquals("will not have been kicking the man", this.realiser.realise(this.kick).getRealisation());
	
			// remove the future tense --
			// this is a test of an earlier bug that would still realise "will"
			this.kick.setFeature(Feature.TENSE,Tense.PRESENT);
			Assert.assertEquals("has not been kicking the man", this.realiser.realise(this.kick).getRealisation());
		}
	
		/**
		 * Test for realisation of VP complements.
		 */
		[Test]
		public function testComplementation():void
		{
			// was kissing Mary
			var mary:PhraseElement = this.phraseFactory.createNounPhrase("Mary"); //$NON-NLS-1$
			mary.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
			this.kiss.clearComplements();
			this.kiss.addComplement(mary);
			this.kiss.setFeature(Feature.PROGRESSIVE, true);
			this.kiss.setFeature(Feature.TENSE,Tense.PAST);
	
			Assert.assertEquals("was kissing Mary", this.realiser.realise(this.kiss).getRealisation());
	
			var mary2:CoordinatedPhraseElement = new CoordinatedPhraseElement(mary, this.phraseFactory.createNounPhrase("Susan")); //$NON-NLS-1$
			// add another complement -- should come out as "Mary and Susan"
			this.kiss.clearComplements();
			this.kiss.addComplement(mary2);
			Assert.assertEquals("was kissing Mary and Susan", this.realiser.realise(this.kiss).getRealisation());
	
			// passivise -- should make the direct object complement disappear
			// Note: The verb doesn't come out as plural because agreement
			// is determined by the sentential subjects and this VP isn't inside a
			// sentence
			this.kiss.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("was being kissed", this.realiser.realise(this.kiss).getRealisation());
	
			// make it plural (this is usually taken care of in SPhraseSpec)
			this.kiss.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			Assert.assertEquals("were being kissed", this.realiser.realise(this.kiss).getRealisation());
	
			// depassivise and add post-mod: yields "was kissing Mary in the room"
			this.kiss.addPostModifier(this.inTheRoom);
			this.kiss.setFeature(Feature.PASSIVE, false);
			this.kiss.setFeature(Feature.NUMBER, NumberAgreement.SINGULAR);
			Assert.assertEquals("was kissing Mary and Susan in the room", this.realiser.realise(this.kiss).getRealisation());
	
			// passivise again: should make direct object disappear, but not postMod
			// ="was being kissed in the room"
			this.kiss.setFeature(Feature.PASSIVE, true);
			this.kiss.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			Assert.assertEquals("were being kissed in the room", this.realiser.realise(this.kiss).getRealisation());
		}
	
		/**
		 * This tests for the default complement ordering, relative to pre and
		 * postmodifiers.
		 */
		[Test]
		public function testComplementation2():void
		{
			// give the woman the dog
			this.woman.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.INDIRECT_OBJECT);
			this.dog.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
			this.give.clearComplements();
			this.give.addComplement(this.dog);
			this.give.addComplement(this.woman);
			Assert.assertEquals("gives the woman the dog", this.realiser.realise(this.give).getRealisation());
	
			// add a few premodifiers and postmodifiers
			this.give.addPreModifierAsString("slowly"); //$NON-NLS-1$
			this.give.addPostModifier(this.behindTheCurtain);
			this.give.addPostModifier(this.inTheRoom);
			Assert.assertEquals("slowly gives the woman the dog behind the curtain in the room", this.realiser.realise(this.give).getRealisation());
	
			// reset the arguments
			this.give.clearComplements();
			this.give.addComplement(this.dog);
			var womanBoy:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.woman, this.boy);
			womanBoy.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.INDIRECT_OBJECT);
			this.give.addComplement(womanBoy);
	
			// if we unset the passive, we should get the indirect objects
			// they won't be coordinated
			this.give.setFeature(Feature.PASSIVE, false);
			Assert.assertEquals("slowly gives the woman and the boy the dog behind the curtain in the room", this.realiser.realise(this.give).getRealisation());
	
			// set them to a coordinate instead
			// set ONLY the complement INDIRECT_OBJECT, leaves OBJECT intact
			this.give.clearComplements();
			this.give.addComplement(womanBoy);
			this.give.addComplement(this.dog);
			var complements:Array = this.give.getFeatureAsElementList(InternalFeature.COMPLEMENTS);
	
			var indirectCount:int = 0;
			var len:int = complements.length;
			for (var i:int = 0; i < len; i++)
			{
				var eachElement:NLGElement = complements[i];
				if (DiscourseFunction.INDIRECT_OBJECT == eachElement.getFeature(InternalFeature.DISCOURSE_FUNCTION))
				{
					indirectCount++;
				}
			}
			Assert.assertEquals(1, indirectCount); // only one indirect object
			// where
			// there were two before
	
			Assert.assertEquals("slowly gives the woman and the boy the dog behind the curtain in the room", this.realiser.realise(this.give).getRealisation());
		}
	
		/**
		 * Test for complements raised in the passive case.
		 */
		[Test]
		public function testPassiveComplement():void
		{
			// add some arguments
			this.dog.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
			this.woman.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.INDIRECT_OBJECT);
			this.give.addComplement(this.dog);
			this.give.addComplement(this.woman);
			Assert.assertEquals("gives the woman the dog", this.realiser.realise(this.give).getRealisation());
	
			// add a few premodifiers and postmodifiers
			this.give.addPreModifierAsString("slowly"); //$NON-NLS-1$
			this.give.addPostModifier(this.behindTheCurtain);
			this.give.addPostModifier(this.inTheRoom);
			Assert.assertEquals("slowly gives the woman the dog behind the curtain in the room", this.realiser.realise(this.give).getRealisation());
	
			// passivise: This should suppress "the dog"
			this.give.clearComplements();
			this.give.addComplement(this.dog);
			this.give.addComplement(this.woman);
			this.give.setFeature(Feature.PASSIVE, true);
	
			Assert.assertEquals("is slowly given the woman behind the curtain in the room", this.realiser.realise(this.give).getRealisation());
		}
	
		/**
		 * Test VP with sentential complements. This tests for structures like "said
		 * that John was walking"
		 */
		[Test]
		public function testClausalComp():void
		{
			this.phraseFactory.setLexicon(this.lexicon);
			var s:SPhraseSpec = this.phraseFactory.createClause();
	
			s.setSubject(this.phraseFactory.createNounPhrase("John")); //$NON-NLS-1$
	
			// Create a sentence first
			var maryAndSusan:CoordinatedPhraseElement = new CoordinatedPhraseElement(
					this.phraseFactory.createNounPhrase("Mary"), //$NON-NLS-1$
					this.phraseFactory.createNounPhrase("Susan")); //$NON-NLS-1$
	
			this.kiss.clearComplements();
			s.setVerbPhrase(this.kiss);
			s.setObject(maryAndSusan);
			s.setFeature(Feature.PROGRESSIVE, true);
			s.setFeature(Feature.TENSE,Tense.PAST);
			s.addPostModifier(this.inTheRoom);
			Assert.assertEquals("John was kissing Mary and Susan in the room", this.realiser.realise(s).getRealisation());
	
			// make the main VP past
			this.say.setFeature(Feature.TENSE,Tense.PAST);
			Assert.assertEquals("said", this.realiser.realise(this.say).getRealisation());
	
			// now add the sentence as complement of "say". Should make the sentence
			// subordinate
			// note that sentential punctuation is suppressed
			this.say.addComplement(s);
			Assert.assertEquals("said that John was kissing Mary and Susan in the room", this.realiser.realise(this.say).getRealisation());
	
			// add a postModifier to the main VP
			// yields [says [that John was kissing Mary and Susan in the room]
			// [behind the curtain]]
			this.say.addPostModifier(this.behindTheCurtain);
			Assert.assertEquals("said that John was kissing Mary and Susan in the room behind the curtain", this.realiser.realise(this.say).getRealisation());
	
			// create a new sentential complement
			var s2:PhraseElement = this.phraseFactory.createClause(this.phraseFactory.createNounPhrase("all"), "be", this.phraseFactory.createAdjectivePhrase("fine")); //$NON-NLS-1$
	
			s2.setFeature(Feature.TENSE,Tense.FUTURE);
			Assert.assertEquals("all will be fine", this.realiser.realise(s2).getRealisation());
	
			// add the new complement to the VP
			// yields [said [that John was kissing Mary and Susan in the room and
			// all will be fine] [behind the curtain]]
			var s3:CoordinatedPhraseElement = new CoordinatedPhraseElement(s, s2);
			this.say.clearComplements();
			this.say.addComplement(s3);
	
			// first with outer complementiser suppressed
			s3.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
			Assert.assertEquals("said that John was kissing Mary and Susan in the room and all will be fine behind the curtain", this.realiser.realise(this.say).getRealisation());
	
			setUp();
			s = this.phraseFactory.createClause();
	
			s.setSubject(this.phraseFactory.createNounPhrase("John")); //$NON-NLS-1$
	
			// Create a sentence first
			maryAndSusan = new CoordinatedPhraseElement(
					this.phraseFactory.createNounPhrase("Mary"), //$NON-NLS-1$
					this.phraseFactory.createNounPhrase("Susan")); //$NON-NLS-1$
	
			s.setVerbPhrase(this.kiss);
			s.setObject(maryAndSusan);
			s.setFeature(Feature.PROGRESSIVE, true);
			s.setFeature(Feature.TENSE,Tense.PAST);
			s.addPostModifier(this.inTheRoom);
			s2 = this.phraseFactory.createClause(this.phraseFactory.createNounPhrase("all"), "be", this.phraseFactory.createAdjectivePhrase("fine")); //$NON-NLS-1$
	
			s2.setFeature(Feature.TENSE,Tense.FUTURE);
			// then with complementiser not suppressed and not aggregated
			s3 = new CoordinatedPhraseElement(s, s2);
			this.say.addComplement(s3);
			this.say.setFeature(Feature.TENSE,Tense.PAST);
			this.say.addPostModifier(this.behindTheCurtain);
			
			Assert.assertEquals("said that John was kissing Mary and Susan in the room and that all will be fine behind the curtain", this.realiser.realise(this.say).getRealisation());
	
		}
	
		/**
		 * Test VP coordination and aggregation:
		 * <OL>
		 * <LI>If the simpleasnlg.features of a coordinate VP are set, they should be
		 * inherited by its daughter VP;</LI>
		 * <LI>2. We can aggregate the coordinate VP so it's realised with one
		 * wide-scope auxiliary</LI>
		 */
		[Test]
		public function testCoordination():void
		{
			// simple case
			this.kiss.addComplement(this.dog);
			this.kick.addComplement(this.boy);
	
			var coord1:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.kiss, this.kick);
	
			coord1.setFeature(Feature.PERSON, Person.THIRD);
			coord1.setFeature(Feature.TENSE,Tense.PAST);
			Assert.assertEquals("kissed the dog and kicked the boy", this.realiser.realise(coord1).getRealisation());
	
			// with negation: should be inherited by all components
			coord1.setFeature(Feature.NEGATED, true);
			this.realiser.setLexicon(this.lexicon);
			Assert.assertEquals("did not kiss the dog and did not kick the boy", this.realiser.realise(coord1).getRealisation());
	
			// set a modal
			coord1.setFeature(Feature.MODAL, "could"); //$NON-NLS-1$
			Assert.assertEquals("could not have kissed the dog and could not have kicked the boy", this.realiser.realise(coord1).getRealisation());
	
			// set perfect and progressive
			coord1.setFeature(Feature.PERFECT, true);
			coord1.setFeature(Feature.PROGRESSIVE, true);
			Assert.assertEquals("could not have been kissing the dog and could not have been kicking the boy", this.realiser.realise(coord1).getRealisation());
	
			// now aggregate
			coord1.setFeature(Feature.AGGREGATE_AUXILIARY, true);
			Assert.assertEquals("could not have been kissing the dog and kicking the boy", this.realiser.realise(coord1).getRealisation());
		}
	}
}
