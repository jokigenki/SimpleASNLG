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
	import simpleasnlg.features.Gender;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Person;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	/**
	 * Tests for the NPPhraseSpec and CoordinateNPPhraseSpec classes.
	 * 
	 * @author agatt
	 */
	public class NounPhraseTest extends SimpleNLG4Test
	{
		/**
		 * Instantiates a new nP test.
		 * 
		 * @param name
		 *            the name
		 */
		public function NounPhraseTest(name:String = null)
		{
			super(name);
		}
	
		/**
		 * Test the setPlural() method in noun phrases.
		 */
		[Test]
		public function testPlural():void
		{
			this.np4.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			Assert.assertEquals("the rocks", this.realiser.realise(this.np4).getRealisation()); //$NON-NLS-1$
	
			this.np5.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			Assert.assertEquals("the curtains", this.realiser.realise(this.np5).getRealisation()); //$NON-NLS-1$
	
			this.np5.setFeature(Feature.NUMBER, NumberAgreement.SINGULAR);
			Assert.assertEquals(NumberAgreement.SINGULAR, this.np5.getFeature(Feature.NUMBER));
			Assert.assertEquals("the curtain", this.realiser.realise(this.np5).getRealisation()); //$NON-NLS-1$
	
			this.np5.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			Assert.assertEquals("the curtains", this.realiser.realise(this.np5).getRealisation()); //$NON-NLS-1$
		}
	
		/**
		 * Test the pronominalisation method for full NPs.
		 */
		[Test]
		public function testPronominalisation():void
		{
			// sing
			this.proTest1.setFeature(LexicalFeature.GENDER, Gender.FEMININE);
			this.proTest1.setFeature(Feature.PRONOMINAL, true);
			Assert.assertEquals("she", this.realiser.realise(this.proTest1).getRealisation()); //$NON-NLS-1$
	
			// sing, possessive
			this.proTest1.setFeature(Feature.POSSESSIVE, true);
			Assert.assertEquals("her", this.realiser.realise(this.proTest1).getRealisation()); //$NON-NLS-1$
	
			// plural pronoun
			this.proTest2.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			this.proTest2.setFeature(Feature.PRONOMINAL, true);
			Assert.assertEquals("they", this.realiser.realise(this.proTest2).getRealisation()); //$NON-NLS-1$
	
			// accusative: "them"
			this.proTest2.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
			Assert.assertEquals("them", this.realiser.realise(this.proTest2).getRealisation()); //$NON-NLS-1$
		}
		
		/**
		 * Test the pronominalisation method for full NPs (more thorough than above)
		 */
		[Test]
		public function testPronominalisation2():void
		{
			// Ehud - added extra pronominalisation tests
			var pro:NPPhraseSpec = phraseFactory.createNounPhrase("Mary");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.FIRST);
			var sent:SPhraseSpec = phraseFactory.createClause(pro,"like", "John");
			Assert.assertEquals("I like John.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("Mary");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.SECOND);
			sent = phraseFactory.createClause(pro,"like", "John");
			Assert.assertEquals("You like John.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("Mary");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.THIRD);
			pro.setFeature(LexicalFeature.GENDER, Gender.FEMININE);
			sent = phraseFactory.createClause(pro,"like", "John");
			Assert.assertEquals("She likes John.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("Mary");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.FIRST);
			pro.setPlural(true);
			sent = phraseFactory.createClause(pro,"like", "John");
			Assert.assertEquals("We like John.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("Mary");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.SECOND);
			pro.setPlural(true);
			sent = phraseFactory.createClause(pro,"like", "John");
			Assert.assertEquals("You like John.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("Mary");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.THIRD);
			pro.setPlural(true);
			pro.setFeature(LexicalFeature.GENDER, Gender.FEMININE);
			sent = phraseFactory.createClause(pro,"like", "John");
			Assert.assertEquals("They like John.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("John");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.FIRST);
			sent = phraseFactory.createClause("Mary", "like", pro);
			Assert.assertEquals("Mary likes me.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("John");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.SECOND);
			sent = phraseFactory.createClause("Mary", "like", pro);
			Assert.assertEquals("Mary likes you.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("John");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.THIRD);
			pro.setFeature(LexicalFeature.GENDER, Gender.MASCULINE);
			sent = phraseFactory.createClause("Mary", "like", pro);
			Assert.assertEquals("Mary likes him.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("John");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.FIRST);
			pro.setPlural(true);
			sent = phraseFactory.createClause("Mary", "like", pro);
			Assert.assertEquals("Mary likes us.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("John");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.SECOND);
			pro.setPlural(true);
			sent = phraseFactory.createClause("Mary", "like", pro);
			Assert.assertEquals("Mary likes you.", this.realiser.realiseSentence(sent));
			
			pro = phraseFactory.createNounPhrase("John");
			pro.setFeature(Feature.PRONOMINAL, true);
			pro.setFeature(Feature.PERSON, Person.THIRD);
			pro.setFeature(LexicalFeature.GENDER, Gender.MASCULINE);
			pro.setPlural(true);
			sent = phraseFactory.createClause("Mary", "like", pro);
			Assert.assertEquals("Mary likes them.", this.realiser.realiseSentence(sent));
		}
	
		/**
		 * Test premodification in NPS.
		 */
		[Test]
		public function testPremodification():void
		{
			this.man.addPreModifier(this.salacious);
			Assert.assertEquals("the salacious man", this.realiser.realise(this.man).getRealisation());
	
			this.woman.addPreModifier(this.beautiful);
			Assert.assertEquals("the beautiful woman", this.realiser.realise(this.woman).getRealisation());
	
			this.dog.addPreModifier(this.stunning);
			Assert.assertEquals("the stunning dog", this.realiser.realise(this.dog).getRealisation());
			
			//premodification with a WordElement
			this.man.setPreModifier(this.phraseFactory.createWord("idiotic", LexicalCategory.ADJECTIVE));
			Assert.assertEquals("the idiotic man", this.realiser.realise(this.man).getRealisation());
	
		}
	
		/**
		 * Test prepositional postmodification.
		 */
		[Test]
		public function testPostmodification():void
		{
			this.man.addPostModifier(this.onTheRock);
			Assert.assertEquals("the man on the rock", this.realiser.realise(this.man).getRealisation());
	
			this.woman.addPostModifier(this.behindTheCurtain);
			Assert.assertEquals("the woman behind the curtain", this.realiser.realise(this.woman).getRealisation());
			
			//postmodification with a WordElement
			this.man.setPostModifier(this.phraseFactory.createWord("jack", LexicalCategory.NOUN));
			Assert.assertEquals("the man jack", this.realiser.realise(this.man).getRealisation());
		}
		
		/**
		 * Test nominal complementation
		 */
		[Test]
		public function testComplementation():void
		{
			//complementation with a WordElement		
			this.man.setComplement(this.phraseFactory.createWord("jack", LexicalCategory.NOUN));
			Assert.assertEquals("the man jack", this.realiser.realise(this.man).getRealisation());
			
			this.woman.addComplement(this.behindTheCurtain);
			Assert.assertEquals("the woman behind the curtain", this.realiser.realise(this.woman).getRealisation());				
		}
	
		/**
		 * Test possessive constructions.
		 */
		[Test]
		public function testPossessive():void
		{
			// simple possessive 's: 'a man's'
			var possNP:PhraseElement = this.phraseFactory.createNounPhrase("man", "a"); //$NON-NLS-1$ //$NON-NLS-2$
			possNP.setFeature(Feature.POSSESSIVE, true);
			Assert.assertEquals("a man's", this.realiser.realise(possNP).getRealisation());
	
			// now set this possessive as specifier of the NP 'the dog'
			this.dog.setFeature(InternalFeature.SPECIFIER, possNP);
			Assert.assertEquals("a man's dog", this.realiser.realise(this.dog).getRealisation());
	
			// convert possNP to pronoun and turn "a dog" into "his dog"
			// need to specify gender, as default is NEUTER
			possNP.setFeature(LexicalFeature.GENDER, Gender.MASCULINE);
			possNP.setFeature(Feature.PRONOMINAL, true);
			Assert.assertEquals("his dog", this.realiser.realise(this.dog).getRealisation());
	
			// make it slightly more complicated: "his dog's rock"
			this.dog.setFeature(Feature.POSSESSIVE, true); // his dog's
	
			// his dog's rock (substituting "the"
			// for the
			// entire phrase)
			this.np4.setFeature(InternalFeature.SPECIFIER, this.dog);
			Assert.assertEquals("his dog's rock", this.realiser.realise(this.np4).getRealisation());
		}
	
		/**
		 * Test NP coordination.
		 */
		[Test]
		public function testCoordination():void
		{
			var cnp1:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.dog, this.woman);
			// simple coordination
			Assert.assertEquals("the dog and the woman", this.realiser.realise(cnp1).getRealisation());
	
			// simple coordination with complementation of entire coordinate NP
			cnp1.addComplement(this.behindTheCurtain);
			Assert.assertEquals("the dog and the woman behind the curtain", this.realiser.realise(cnp1).getRealisation());
	
			// raise the specifier in this cnp
			// Assert.assertEquals(true, cnp1.raiseSpecifier()); // should return
			// true as all
			// sub-nps have same spec
			// assertEquals("the dog and woman behind the curtain",
			// realiser.realise(cnp1));
		}
	
		/**
		 * Another battery of tests for NP coordination.
		 */
		[Test]
		public function testCoordination2():void
		{
			// simple coordination of complementised nps
			this.dog.clearComplements();
			this.woman.clearComplements();
	
			var cnp1:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.dog, this.woman);
			cnp1.setFeature(Feature.RAISE_SPECIFIER, true);
			var realised:NLGElement = this.realiser.realise(cnp1);
			Assert.assertEquals("the dog and woman", realised.getRealisation());
	
			this.dog.addComplement(this.onTheRock);
			this.woman.addComplement(this.behindTheCurtain);
	
			var cnp2:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.dog, this.woman);
	
			this.woman.setFeature(InternalFeature.RAISED, false);
			Assert.assertEquals("the dog on the rock and the woman behind the curtain", this.realiser.realise(cnp2).getRealisation());
	
			// complementised coordinates + outer pp modifier
			cnp2.addPostModifier(this.inTheRoom);
			Assert.assertEquals("the dog on the rock and the woman behind the curtain in the room", this.realiser.realise(cnp2).getRealisation());
	
			// set the specifier for this cnp; should unset specifiers for all inner
			// coordinates
			var every:NLGElement = this.phraseFactory.createWord("every", LexicalCategory.DETERMINER); //$NON-NLS-1$
	
			cnp2.setFeature(InternalFeature.SPECIFIER, every);
	
			Assert.assertEquals("every dog on the rock and every woman behind the curtain in the room", this.realiser.realise(cnp2).getRealisation());
	
			// pronominalise one of the constituents
			this.dog.setFeature(Feature.PRONOMINAL, true); // ="it"
			this.dog.setFeature(InternalFeature.SPECIFIER, this.phraseFactory.createWord("the", LexicalCategory.DETERMINER));
			// raising spec still returns true as spec has been set
			cnp2.setFeature(Feature.RAISE_SPECIFIER, true);
	
			// CNP should be realised with pronominal internal const
			Assert.assertEquals("it and every woman behind the curtain in the room", this.realiser.realise(cnp2).getRealisation());
		}
	
		/**
		 * Test possessives in coordinate NPs.
		 */
		[Test]
		public function testPossessiveCoordinate():void
		{
			// simple coordination
			var cnp2:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.dog, this.woman);
			Assert.assertEquals("the dog and the woman", this.realiser.realise(cnp2).getRealisation());
	
			// set possessive -- wide-scope by default
			cnp2.setFeature(Feature.POSSESSIVE, true);
			Assert.assertEquals("the dog and the woman's", this.realiser.realise(cnp2).getRealisation());
	
			// set possessive with pronoun
			this.dog.setFeature(Feature.PRONOMINAL, true);
			this.dog.setFeature(Feature.POSSESSIVE, true);
			cnp2.setFeature(Feature.POSSESSIVE, true);
			Assert.assertEquals("its and the woman's", this.realiser.realise(cnp2).getRealisation());
	
		}
	
		/**
		 * Test A vs An.
		 */
		[Test]
		public function testAAn():void
		{
			var _dog:PhraseElement = this.phraseFactory.createNounPhrase("dog", "a"); //$NON-NLS-1$ //$NON-NLS-2$
			Assert.assertEquals("a dog", this.realiser.realise(_dog).getRealisation());
	
			_dog.addPreModifierAsString("enormous"); //$NON-NLS-1$
	
			Assert.assertEquals("an enormous dog", this.realiser.realise(_dog).getRealisation());
	
			var elephant:PhraseElement = this.phraseFactory.createNounPhrase("elephant", "a"); //$NON-NLS-1$ //$NON-NLS-2$
			Assert.assertEquals("an elephant", this.realiser.realise(elephant).getRealisation());
	
			elephant.addPreModifierAsString("big"); //$NON-NLS-1$
			Assert.assertEquals("a big elephant", this.realiser.realise(elephant).getRealisation());
	
			// test treating of plural specifiers
			_dog.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
	
			Assert.assertEquals("some enormous dogs", this.realiser.realise(_dog).getRealisation());
		}
		
		/**
		 * Further tests for a/an agreement with coordinated premodifiers
		 */
		public function testAAnCoord():void
		{
			var _dog:NPPhraseSpec = this.phraseFactory.createNounPhrase("dog", "a");
			_dog.addPreModifier(this.phraseFactory.createCoordinatedPhrase("enormous", "black"));
			var realisation:String = this.realiser.realise(_dog).getRealisation();
			Assert.assertEquals("an enormous and black dog", realisation);
		}
		
		/**
		 * Test for a/an agreement with numbers
		 */
		public function testAAnWithNumbers():void
		{
			var num:NPPhraseSpec = this.phraseFactory.createNounPhrase("change", "a");
			var realisation:String;
			
			//no an with "one"
			num.setPreModifierAsString("one percent");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("a one percent change", realisation);
			
			//an with "eighty"
			num.setPreModifierAsString("eighty percent");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an eighty percent change", realisation);
			
			
			//an with 80
			num.setPreModifierAsString("80%");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 80% change", realisation);
			
			//an with 80000
			num.setPreModifierAsString("80000");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 80000 change", realisation);
			
			//an with 11,000
			num.setPreModifierAsString("11,000");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 11,000 change", realisation);
			
			//an with 18
			num.setPreModifierAsString("18%");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 18% change", realisation);
			
			//a with 180
			num.setPreModifierAsString("180");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("a 180 change", realisation);
			
			//a with 1100
			num.setPreModifierAsString("1100");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("a 1100 change", realisation);			
			
			//a with 180,000
			num.setPreModifierAsString("180,000");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("a 180,000 change", realisation);
			
			//an with 11000
			num.setPreModifierAsString("11000");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 11000 change", realisation);
	
			
			//an with 18000
			num.setPreModifierAsString("18000");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 18000 change", realisation);
			
			//an with 18.1
			num.setPreModifierAsString("18.1%");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 18.1% change", realisation);
			
			//an with 11.1
			num.setPreModifierAsString("11.1%");
			realisation = this.realiser.realise(num).getRealisation();
			Assert.assertEquals("an 11.1% change", realisation);
	
		}
	
		/**
		 * Test Modifier "guess" placement.
		 */
		[Test]
		public function testModifier():void
		{
			var _dog:PhraseElement = this.phraseFactory.createNounPhrase("dog", "a"); //$NON-NLS-1$ //$NON-NLS-2$
			_dog.addPreModifierAsString("angry"); //$NON-NLS-1$
	
			Assert.assertEquals("an angry dog", this.realiser.realise(_dog).getRealisation());
	
			_dog.addPostModifierAsString("in the park"); //$NON-NLS-1$
			Assert.assertEquals("an angry dog in the park", this.realiser.realise(_dog).getRealisation());
	
			var cat:PhraseElement = this.phraseFactory.createNounPhrase("cat", "a"); //$NON-NLS-1$ //$NON-NLS-2$
			cat.addPreModifier(this.phraseFactory.createAdjectivePhrase("angry")); //$NON-NLS-1$
			Assert.assertEquals("an angry cat", this.realiser.realise(cat).getRealisation());
	
			cat.addPostModifier(this.phraseFactory.createPrepositionPhrase("in", "the park")); //$NON-NLS-1$ //$NON-NLS-2$
			Assert.assertEquals("an angry cat in the park", this.realiser.realise(cat).getRealisation());
		}
	}
}
