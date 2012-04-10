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
	
	import simpleasnlg.features.ClauseStatus;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	// TODO: Auto-generated Javadoc
	/**
	 * The Class STest.
	 */
	public class ClauseTest extends SimpleNLG4Test
	{
		// set up a few more fixtures
		/** The s4. */
		public var s1:SPhraseSpec;
		public var s2:SPhraseSpec;
		public var s3:SPhraseSpec;
		public var s4:SPhraseSpec;
	
		/**
		 * Instantiates a new s test.
		 * 
		 * @param name
		 *            the name
		 */
		public function ClauseTest(name:String = null)
		{
			super(name);
		}
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.test.SimplenlgTest#setUp()
		 */
		//@Before
		override public function setUp():void
		{
			super.setUp();
	
			// the woman kissed the man behind the curtain
			this.s1 = this.phraseFactory.createClause();
			this.s1.setSubject(this.woman);
			this.s1.setVerbPhrase(this.kiss);
			this.s1.setObject(this.man);
	
			// there is the dog on the rock
			this.s2 = this.phraseFactory.createClause();
			this.s2.setSubject("there"); //$NON-NLS-1$
			this.s2.setVerb("be"); //$NON-NLS-1$
			this.s2.setObject(this.dog);
			this.s2.addPostModifier(this.onTheRock);
	
			// the man gives the woman John's flower
			this.s3 = this.phraseFactory.createClause();
			this.s3.setSubject(this.man);
			this.s3.setVerbPhrase(this.give);
	
			var flower:NPPhraseSpec = this.phraseFactory.createNounPhrase("flower"); //$NON-NLS-1$
			var john:NPPhraseSpec = this.phraseFactory.createNounPhrase("John"); //$NON-NLS-1$
			john.setFeature(Feature.POSSESSIVE, true);
			flower.setFeature(InternalFeature.SPECIFIER, john);
			this.s3.setObject(flower);
			this.s3.setIndirectObject(this.woman);
	
			this.s4 = this.phraseFactory.createClause();
			this.s4.setFeature(Feature.CUE_PHRASE, "however"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
	
			var subject:CoordinatedPhraseElement = this.phraseFactory.createCoordinatedPhrase(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
	
			this.s4.setSubject(subject);
	
			var pick:PhraseElement = this.phraseFactory.createVerbPhrase("pick up"); //$NON-NLS-1$
			this.s4.setVerbPhrase(pick);
			this.s4.setObject("the balls"); //$NON-NLS-1$
			this.s4.addPostModifierAsString("in the shop"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
		}
	
		/**
		 * Initial test for basic sentences.
		 */
		[Test]
		public function testBasic():void
		{
			setUp();
			Assert.assertEquals("the woman kisses the man", this.realiser.realise(this.s1).getRealisation());
			Assert.assertEquals("there is the dog on the rock", this.realiser.realise(this.s2).getRealisation());
	
			setUp();
			Assert.assertEquals("the man gives the woman John's flower", this.realiser.realise(this.s3).getRealisation());
			Assert.assertEquals("however tomorrow Jane and Andrew will pick up the balls in the shop", this.realiser.realise(this.s4).getRealisation());
		}
	
		/**
		 * Test did not
		 */
		public function testDidNot():void
		{
			var s:PhraseElement = phraseFactory.createClause("John", "eat");
			s.setFeature(Feature.TENSE, Tense.PAST);
			s.setFeature(Feature.NEGATED, true);
	
			Assert.assertEquals("John did not eat", this.realiser.realise(s).getRealisation());
	
		}
	
		/**
		 * Test did not
		 */
		public function testVPNegation():void
		{
			// negate the VP
			var vp:PhraseElement = phraseFactory.createVerbPhrase("lie");
			vp.setFeature(Feature.TENSE, Tense.PAST);
			vp.setFeature(Feature.NEGATED, true);
			var compl:PhraseElement = phraseFactory.createVerbPhrase("etherize");
			compl.setFeature(Feature.TENSE, Tense.PAST);
			vp.setComplement(compl);
	
			var s:SPhraseSpec = phraseFactory.createClause(phraseFactory.createNounPhrase("patient", "the"), vp);
	
			Assert.assertEquals("the patient did not lie etherized", this.realiser.realise(s).getRealisation());
	
		}
	
		/**
		 * Test that pronominal args are being correctly cast as NPs.
		 */
		public function testPronounArguments():void
		{
			setUp();
			// the subject of s2 should have been cast into a pronominal NP
			var subj:NLGElement = this.s2.getFeatureAsElementList(InternalFeature.SUBJECTS)[0];
			Assert.assertTrue(subj.isA(PhraseCategory.NOUN_PHRASE));
			// Assert.assertTrue(LexicalCategory.PRONOUN.equals(((PhraseElement)
			// subj)
			// .getCategory()));
		}
	
		/**
		 * Tests for setting tense, aspect and passive from the sentence interface.
		 */
		[Test]
		public function testTenses():void
		{
			setUp();
			// simple past
			this.s3.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("the man gave the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// perfect
			this.s3.setFeature(Feature.PERFECT, true);
			Assert.assertEquals("the man had given the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// negation
			this.s3.setFeature(Feature.NEGATED, true);
			Assert.assertEquals("the man had not given the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			this.s3.setFeature(Feature.PROGRESSIVE, true);
			Assert.assertEquals("the man had not been giving the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// passivisation with direct and indirect object
			this.s3.setFeature(Feature.PASSIVE, true);
			// Assert.assertEquals(
			//				"John's flower had not been being given the woman by the man", //$NON-NLS-1$
			// this.realiser.realise(this.s3).getRealisation());
		}
	
		/**
		 * Test what happens when a sentence is subordinated as complement of a
		 * verb.
		 */
		[Test]
		public function testSubordination():void
		{
			setUp();
			// subordinate sentence by setting it as complement of a verb
			this.say.addComplement(this.s3);
	
			// check the getter
			Assert.assertEquals(ClauseStatus.SUBORDINATE, this.s3.getFeature(InternalFeature.CLAUSE_STATUS));
	
			// check realisation
			Assert.assertEquals("says that the man gives the woman John's flower", this.realiser.realise(this.say).getRealisation());
		}
	
		/**
		 * Test the various forms of a sentence, including subordinates.
		 */
		/**
		 * 
		 */
		[Test]
		public function testForm():void
		{
			setUp();
			// check the getter method
			Assert.assertEquals(Form.NORMAL, this.s1.getFeatureAsElement(InternalFeature.VERB_PHRASE).getFeature(Feature.FORM));
	
			// infinitive
			this.s1.setFeature(Feature.FORM, Form.INFINITIVE);
			Assert.assertEquals("to kiss the man", this.realiser.realise(this.s1).getRealisation()); //$NON-NLS-1$
	
			// gerund with "there"
			this.s2.setFeature(Feature.FORM, Form.GERUND);
			Assert.assertEquals("there being the dog on the rock", this.realiser.realise(this.s2).getRealisation());
	
			// gerund with possessive
			this.s3.setFeature(Feature.FORM, Form.GERUND);
			Assert.assertEquals("the man's giving the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// imperative
			this.s3.setFeature(Feature.FORM, Form.IMPERATIVE);
	
			Assert.assertEquals("give the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// subordinating the imperative to a verb should turn it to infinitive
			this.say.addComplement(this.s3);
	
			Assert.assertEquals("says to give the woman John's flower", this.realiser.realise(this.say).getRealisation());
	
			// imperative -- case II
			this.s4.setFeature(Feature.FORM, Form.IMPERATIVE);
			Assert.assertEquals("however tomorrow pick up the balls in the shop", this.realiser.realise(this.s4).getRealisation());
	
			// infinitive -- case II
			this.s4 = this.phraseFactory.createClause();
			this.s4.setFeature(Feature.CUE_PHRASE, "however"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
	
			var subject:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
	
			this.s4.setFeature(InternalFeature.SUBJECTS, subject);
	
			var pick:PhraseElement = this.phraseFactory.createVerbPhrase("pick up"); //$NON-NLS-1$
			this.s4.setFeature(InternalFeature.VERB_PHRASE, pick);
			this.s4.setObject("the balls"); //$NON-NLS-1$
			this.s4.addPostModifierAsString("in the shop"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
			this.s4.setFeature(Feature.FORM, Form.INFINITIVE);
			Assert.assertEquals("however to pick up the balls in the shop tomorrow", this.realiser.realise(this.s4).getRealisation());
		}
	
		/**
		 * Slightly more complex tests for forms.
		 */
		public function testForm2():void
		{
			setUp();
			// set s4 as subject of a new sentence
			var temp:SPhraseSpec = this.phraseFactory.createClause(this.s4, "be", "recommended"); //$NON-NLS-1$
	
			Assert.assertEquals("however tomorrow Jane and Andrew's picking up the " + "balls in the shop is recommended", this.realiser.realise(temp).getRealisation());
	
			// compose this with a new sentence
			// ER - switched direct and indirect object in sentence
			var temp2:SPhraseSpec = this.phraseFactory.createClause("I", "tell", temp); //$NON-NLS-1$ //$NON-NLS-2$
			temp2.setFeature(Feature.TENSE, Tense.FUTURE);
	
			var indirectObject:PhraseElement = this.phraseFactory.createNounPhrase("John"); //$NON-NLS-1$
	
			temp2.setIndirectObject(indirectObject);
	
			Assert.assertEquals("I will tell John that however tomorrow Jane and " + "Andrew's picking up the balls in the shop is " + "recommended", this.realiser.realise(temp2).getRealisation());
	
			// turn s4 to imperative and put it in indirect object position
	
			this.s4 = this.phraseFactory.createClause();
			this.s4.setFeature(Feature.CUE_PHRASE, "however"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
	
			var subject:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
	
			this.s4.setSubject(subject);
	
			var pick:PhraseElement = this.phraseFactory.createVerbPhrase("pick up"); //$NON-NLS-1$
			this.s4.setVerbPhrase(pick);
			this.s4.setObject("the balls"); //$NON-NLS-1$
			this.s4.addPostModifierAsString("in the shop"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
			this.s4.setFeature(Feature.FORM, Form.IMPERATIVE);
	
			temp2 = this.phraseFactory.createClause("I", "tell", this.s4); //$NON-NLS-1$ //$NON-NLS-2$
			indirectObject = this.phraseFactory.createNounPhrase("John"); //$NON-NLS-1$
			temp2.setIndirectObject(indirectObject);
			temp2.setFeature(Feature.TENSE, Tense.FUTURE);
	
			Assert.assertEquals("I will tell John however to pick up the balls " + "in the shop tomorrow", this.realiser.realise(temp2).getRealisation());
		}
	
		/**
		 * Tests for gerund forms and genitive subjects.
		 */
		[Test]
		public function testGerundsubject():void
		{
			setUp();
			// the man's giving the woman John's flower upset Peter
			var _s4:SPhraseSpec = this.phraseFactory.createClause();
			_s4.setVerbPhrase(this.phraseFactory.createVerbPhrase("upset")); //$NON-NLS-1$
			_s4.setFeature(Feature.TENSE, Tense.PAST);
			_s4.setObject(this.phraseFactory.createNounPhrase("Peter")); //$NON-NLS-1$
			this.s3.setFeature(Feature.PERFECT, true);
	
			// set the sentence as subject of another: makes it a gerund
			_s4.setSubject(this.s3);
	
			// suppress the genitive realisation of the NP subject in gerund
			// sentences
			this.s3.setFeature(Feature.SUPPRESS_GENITIVE_IN_GERUND, true);
	
			// check the realisation: subject should not be genitive
			Assert.assertEquals(
					"the man having given the woman John's flower upset Peter", //$NON-NLS-1$
					this.realiser.realise(_s4).getRealisation());
	
		}
	
		/**
		 * Some tests for multiple embedded sentences.
		 */
		[Test]
		public function testComplexSentence1():void
		{
			setUp();
			// the man's giving the woman John's flower upset Peter
			var complexS:SPhraseSpec = this.phraseFactory.createClause();
			complexS.setVerbPhrase(this.phraseFactory.createVerbPhrase("upset")); //$NON-NLS-1$
			complexS.setFeature(Feature.TENSE, Tense.PAST);
			complexS.setObject(this.phraseFactory.createNounPhrase("Peter")); //$NON-NLS-1$
			this.s3.setFeature(Feature.PERFECT, true);
			complexS.setSubject(this.s3);
	
			// check the realisation: subject should be genitive
			Assert.assertEquals("the man's having given the woman John's flower upset Peter", this.realiser.realise(complexS).getRealisation());
	
			setUp();
			// coordinate sentences in subject position
			var s5:SPhraseSpec = this.phraseFactory.createClause();
			s5.setSubject(this.phraseFactory.createNounPhrase("person", "some")); //$NON-NLS-1$ //$NON-NLS-2$
			s5.setVerbPhrase(this.phraseFactory.createVerbPhrase("stroke")); //$NON-NLS-1$
			s5.setObject(this.phraseFactory.createNounPhrase("cat", "the")); //$NON-NLS-1$ //$NON-NLS-2$
	
			var coord:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.s3, s5);
			complexS = this.phraseFactory.createClause();
			complexS.setVerbPhrase(this.phraseFactory.createVerbPhrase("upset")); //$NON-NLS-1$
			complexS.setFeature(Feature.TENSE, Tense.PAST);
			complexS.setObject(this.phraseFactory.createNounPhrase("Peter")); //$NON-NLS-1$
			complexS.setSubject(coord);
			this.s3.setFeature(Feature.PERFECT, true);
	
			Assert.assertEquals("the man's having given the woman John's flower and some person's stroking the cat upset Peter", this.realiser.realise(complexS).getRealisation());
	
			setUp();
			// now subordinate the complex sentence
			// coord.setClauseStatus(SPhraseSpec.ClauseType.MAIN);
			var s6:SPhraseSpec = this.phraseFactory.createClause();
			s6.setVerbPhrase(this.phraseFactory.createVerbPhrase("tell")); //$NON-NLS-1$
			s6.setFeature(Feature.TENSE, Tense.PAST);
			s6.setSubject(this.phraseFactory.createNounPhrase("boy", "the")); //$NON-NLS-1$ //$NON-NLS-2$
			// ER - switched indirect and direct object
			var indirect:PhraseElement = this.phraseFactory.createNounPhrase("girl", "every"); //$NON-NLS-1$
			s6.setIndirectObject(indirect);
			complexS = this.phraseFactory.createClause();
			complexS.setVerbPhrase(this.phraseFactory.createVerbPhrase("upset")); //$NON-NLS-1$
			complexS.setFeature(Feature.TENSE, Tense.PAST);
			complexS.setObject(this.phraseFactory.createNounPhrase("Peter")); //$NON-NLS-1$
			s6.setObject(complexS);
			coord = new CoordinatedPhraseElement(this.s3, s5);
			complexS.setSubject(coord);
			this.s3.setFeature(Feature.PERFECT, true);
			Assert.assertEquals("the boy told every girl that the man's having given the woman John's flower and some person's stroking the cat upset Peter", this.realiser.realise(s6).getRealisation());
	
		}
	
		/**
		 * More coordination tests.
		 */
		[Test]
		public function testComplexSentence3():void
		{
			setUp();
	
			this.s1 = this.phraseFactory.createClause();
			this.s1.setSubject(this.woman);
			this.s1.setVerb("kiss");
			this.s1.setObject(this.man);
	
			var _man:PhraseElement = this.phraseFactory.createNounPhrase("man", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.s3 = this.phraseFactory.createClause();
			this.s3.setSubject(_man);
			this.s3.setVerb("give");
	
			var flower:NPPhraseSpec = this.phraseFactory.createNounPhrase("flower"); //$NON-NLS-1$
			var john:NPPhraseSpec = this.phraseFactory.createNounPhrase("John"); //$NON-NLS-1$
			john.setFeature(Feature.POSSESSIVE, true);
			flower.setSpecifier(john);
			this.s3.setObject(flower);
	
			var _woman:PhraseElement = this.phraseFactory.createNounPhrase("woman", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.s3.setIndirectObject(_woman);
	
			// the coordinate sentence allows us to raise and lower complementiser
			var coord2:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.s1, this.s3);
			coord2.setFeature(Feature.TENSE, Tense.PAST);
	
			//this.realiser.setDebugMode(true);
			Assert.assertEquals("the woman kissed the man and the man gave the woman John's flower", this.realiser.realise(coord2).getRealisation());
		}
	
		// /**
		// * Sentence with clausal subject with verb "be" and a progressive feature
		// */
		// public void testComplexSentence2() {
		// SPhraseSpec subject = this.phraseFactory.createClause(
		// this.phraseFactory.createNounPhrase("the", "child"),
		// this.phraseFactory.createVerbPhrase("be"), this.phraseFactory
		// .createWord("difficult", LexicalCategory.ADJECTIVE));
		// subject.setFeature(Feature.PROGRESSIVE, true);
		// }
	
		/**
		 * Tests recogition of strings in API.
		 */
		[Test]
		public function testStringRecognition():void
		{
			// test recognition of forms of "be"
			var _s1:PhraseElement = this.phraseFactory.createClause("my cat", "be", "sad"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			Assert.assertEquals("my cat is sad", this.realiser.realise(_s1).getRealisation()); //$NON-NLS-1$
	
			// test recognition of pronoun for afreement
			var _s2:PhraseElement = this.phraseFactory.createClause("I", "want", "Mary"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
	
			Assert.assertEquals("I want Mary", this.realiser.realise(_s2).getRealisation()); //$NON-NLS-1$
	
			// test recognition of pronoun for correct form
			var subject:PhraseElement = this.phraseFactory.createNounPhrase("dog"); //$NON-NLS-1$
			subject.setFeature(InternalFeature.SPECIFIER, "a"); //$NON-NLS-1$
			subject.addPostModifierAsString("from next door"); //$NON-NLS-1$
			var object:PhraseElement = this.phraseFactory.createNounPhrase("I"); //$NON-NLS-1$
			var s:PhraseElement = this.phraseFactory.createClause(subject, "chase", object); //$NON-NLS-1$
			s.setFeature(Feature.PROGRESSIVE, true);
			Assert.assertEquals("a dog from next door is chasing me", this.realiser.realise(s).getRealisation());
		}
	
		/**
		 * Tests complex agreement.
		 */
		[Test]
		public function testAgreement():void
		{
			// basic agreement
			var np:NPPhraseSpec = this.phraseFactory.createNounPhrase("dog"); //$NON-NLS-1$
			np.setSpecifier("the"); //$NON-NLS-1$
			np.addPreModifierAsString("angry"); //$NON-NLS-1$
			var _s1:PhraseElement = this.phraseFactory.createClause(np, "chase", "John"); //$NON-NLS-1$ //$NON-NLS-2$
			Assert.assertEquals("the angry dog chases John", this.realiser.realise(_s1).getRealisation());
	
			// plural
			np = this.phraseFactory.createNounPhrase("dog"); //$NON-NLS-1$
			np.setSpecifier("the"); //$NON-NLS-1$
			np.addPreModifierAsString("angry"); //$NON-NLS-1$
			np.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			_s1 = this.phraseFactory.createClause(np, "chase", "John"); //$NON-NLS-1$ //$NON-NLS-2$
			Assert.assertEquals("the angry dogs chase John", this.realiser.realise(_s1).getRealisation());
	
			// test agreement with "there is"
			np = this.phraseFactory.createNounPhrase("dog"); //$NON-NLS-1$
			np.addPreModifierAsString("angry"); //$NON-NLS-1$
			np.setFeature(Feature.NUMBER, NumberAgreement.SINGULAR);
			np.setSpecifier("a"); //$NON-NLS-1$
			var _s2:PhraseElement = this.phraseFactory.createClause("there", "be", np); //$NON-NLS-1$ //$NON-NLS-2$
			Assert.assertEquals("there is an angry dog", this.realiser.realise(_s2).getRealisation());
	
			// plural with "there"
			np = this.phraseFactory.createNounPhrase("dog"); //$NON-NLS-1$
			np.addPreModifierAsString("angry"); //$NON-NLS-1$
			np.setSpecifier("a"); //$NON-NLS-1$
			np.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			_s2 = this.phraseFactory.createClause("there", "be", np); //$NON-NLS-1$ //$NON-NLS-2$
			Assert.assertEquals("there are some angry dogs", this.realiser.realise(_s2).getRealisation());
		}
	
		/**
		 * Tests passive.
		 */
		[Test]
		public function testPassive():void
		{
			// passive with just complement
			var _s1:SPhraseSpec = this.phraseFactory.createClause(null, "intubate", this.phraseFactory.createNounPhrase("baby", "the")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			_s1.setFeature(Feature.PASSIVE, true);
	
			Assert.assertEquals("the baby is intubated", this.realiser.realise(_s1).getRealisation());
	
			// passive with subject and complement
			_s1 = this.phraseFactory.createClause(null, "intubate", this.phraseFactory.createNounPhrase("baby", "the")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			_s1.setSubject(this.phraseFactory.createNounPhrase("the nurse")); //$NON-NLS-1$
			_s1.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("the baby is intubated by the nurse", this.realiser.realise(_s1).getRealisation());
	
			// passive with subject and indirect object
			var _s2:SPhraseSpec = this.phraseFactory.createClause(null, "give", this.phraseFactory.createNounPhrase("baby", "the")); //$NON-NLS-1$ //$NON-NLS-2$
	
			var morphine:PhraseElement = this.phraseFactory.createNounPhrase("50ug of morphine"); //$NON-NLS-1$
			_s2.setIndirectObject(morphine);
			_s2.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("the baby is given 50ug of morphine", this.realiser.realise(_s2).getRealisation());
	
			// passive with subject, complement and indirect object
			_s2 = this.phraseFactory.createClause(this.phraseFactory.createNounPhrase("nurse", "the"), "give", this.phraseFactory.createNounPhrase("baby", "the")); //$NON-NLS-1$ //$NON-NLS-2$
	
			morphine = this.phraseFactory.createNounPhrase("50ug of morphine"); //$NON-NLS-1$
			_s2.setIndirectObject(morphine);
			_s2.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("the baby is given 50ug of morphine by the nurse", this.realiser.realise(_s2).getRealisation());
	
			// test agreement in passive
			var _s3:PhraseElement = this.phraseFactory.createClause(new CoordinatedPhraseElement("my dog", "your cat"), "chase", "George"); //$NON-NLS-1$
			_s3.setFeature(Feature.TENSE, Tense.PAST);
			_s3.addFrontModifierAsString("yesterday"); //$NON-NLS-1$
			Assert.assertEquals("yesterday my dog and your cat chased George", this.realiser.realise(_s3).getRealisation());
	
			_s3 = this.phraseFactory.createClause(new CoordinatedPhraseElement("my dog", "your cat"), "chase", this.phraseFactory.createNounPhrase("George")); //$NON-NLS-1$
			_s3.setFeature(Feature.TENSE, Tense.PAST);
			_s3.addFrontModifierAsString("yesterday"); //$NON-NLS-1$
			_s3.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("yesterday George was chased by my dog and your cat", this.realiser.realise(_s3).getRealisation());
	
			// test correct pronoun forms
			var _s4:PhraseElement = this.phraseFactory.createClause(this.phraseFactory.createNounPhrase("he"), "chase", this.phraseFactory.createNounPhrase("I")); //$NON-NLS-1$
			Assert.assertEquals("he chases me", this.realiser.realise(_s4).getRealisation());
			_s4 = this.phraseFactory.createClause(this.phraseFactory.createNounPhrase("he"), "chase", this.phraseFactory.createNounPhrase("me")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			_s4.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("I am chased by him", this.realiser.realise(_s4).getRealisation()); //$NON-NLS-1$
	
			// same thing, but giving the S constructor "me". Should recognise
			// correct pro
			// anyway
			var _s5:PhraseElement = this.phraseFactory.createClause("him", "chase", "I"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			Assert.assertEquals("he chases me", this.realiser.realise(_s5).getRealisation()); //$NON-NLS-1$
	
			_s5 = this.phraseFactory.createClause("him", "chase", "I"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			_s5.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("I am chased by him", this.realiser.realise(_s5).getRealisation()); //$NON-NLS-1$
		}
		
		/**
		 * Test that complements set within the VP are raised when sentence is passivised.
		 */
		public function testPassiveWithInternalVPComplement():void
		{
			var vp:PhraseElement = this.phraseFactory.createVerbPhrase(phraseFactory.createWord("upset", LexicalCategory.VERB));
			vp.addComplement(phraseFactory.createNounPhrase("man", "the"));
			var _s6:PhraseElement = this.phraseFactory.createClause(phraseFactory.createNounPhrase("child", "the"), vp);
			_s6.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("the child upset the man", this.realiser.realise(_s6).getRealisation());
			
			_s6.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("the man was upset by the child", this.realiser.realise(_s6).getRealisation());
		}
	
		/**
		 * Tests tenses with modals.
		 */
		public function testModal():void
		{
			setUp();
			// simple modal in present tense
			this.s3.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			Assert.assertEquals("the man should give the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// modal + future -- uses present
			setUp();
			this.s3.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			this.s3.setFeature(Feature.TENSE, Tense.FUTURE);
			Assert.assertEquals("the man should give the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// modal + present progressive
			setUp();
			this.s3.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			this.s3.setFeature(Feature.TENSE, Tense.FUTURE);
			this.s3.setFeature(Feature.PROGRESSIVE, true);
			Assert.assertEquals("the man should be giving the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// modal + past tense
			setUp();
			this.s3.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			this.s3.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("the man should have given the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// modal + past progressive
			setUp();
			this.s3.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			this.s3.setFeature(Feature.TENSE, Tense.PAST);
			this.s3.setFeature(Feature.PROGRESSIVE, true);
	
			Assert.assertEquals("the man should have been giving the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
		}
	}
}
