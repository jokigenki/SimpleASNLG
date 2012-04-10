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
	import simpleasnlg.features.InterrogativeType;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	/**
	 * JUnit test case for interrogatives.
	 * 
	 * @author agatt
	 */
	public class InterrogativeTest extends SimpleNLG4Test
	{
		// set up a few more fixtures
		/** The s5. */
		public var s1:SPhraseSpec;
		public var s2:SPhraseSpec;
		public var s3:SPhraseSpec;
		public var s4:SPhraseSpec;
		public var s5:SPhraseSpec;
	
		/**
		 * Instantiates a new interrogative test.
		 * 
		 * @param name
		 *            the name
		 */
		public function InterrogativeTest(name:String = null)
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
	
			// // there is the dog on the rock
			// this.s2 = new SPhraseSpec();
			// this.s2.setSubject("there");
			// this.s2.setHead("be");
			// this.s2.setComplement(this.dog);
			// this.s2.addModifier(SModifierPosition.POST_VERB, this.onTheRock);
			//
			// // the man gives the woman John's flower
			var john:PhraseElement = this.phraseFactory.createNounPhrase("John"); //$NON-NLS-1$
			john.setFeature(Feature.POSSESSIVE, true);
			var flower:PhraseElement = this.phraseFactory.createNounPhrase("flower", john); //$NON-NLS-1$
			var _woman:PhraseElement = this.phraseFactory.createNounPhrase("woman", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.s3 = this.phraseFactory.createClause(this.man, this.give, flower);
			this.s3.setIndirectObject(_woman);
	
			var subjects:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
			this.s4 = this.phraseFactory.createClause(subjects, "pick up", "the balls"); //$NON-NLS-1$
			this.s4.addPostModifierAsString("in the shop"); //$NON-NLS-1$
			this.s4.setFeature(Feature.CUE_PHRASE, "however"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
			// this.s5 = new SPhraseSpec();
			// this.s5.setSubject(new NPPhraseSpec("the", "dog"));
			// this.s5.setHead("be");
			// this.s5.setComplement(new NPPhraseSpec("the", "rock"),
			// DiscourseFunction.OBJECT);
	
		}
	
		/**
		 * Tests a couple of fairly simple questions.
		 */
		[Test]
		public function testSimpleQuestions():void
		{
			setUp();
			this.phraseFactory.setLexicon(this.lexicon);
			this.realiser.setLexicon(this.lexicon);
	
			// simple present
			this.s1 = this.phraseFactory.createClause(this.woman, this.kiss, this.man);
			this.s1.setFeature(Feature.TENSE, Tense.PRESENT);
			this.s1.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
	
			var docFactory:NLGFactory = new NLGFactory(this.lexicon);
			var sent:DocumentElement = docFactory.createSentenceWithElement(this.s1);
			Assert.assertEquals("Does the woman kiss the man?", this.realiser.realise(sent).getRealisation());
	
			// simple past
			// sentence: "the woman kissed the man"
			this.s1 = this.phraseFactory.createClause(this.woman, this.kiss, this.man);
			this.s1.setFeature(Feature.TENSE, Tense.PAST);
			this.s1.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("did the woman kiss the man", this.realiser.realise(this.s1).getRealisation());
	
			// copular/existential: be-fronting
			// sentence = "there is the dog on the rock"
			this.s2 = this.phraseFactory.createClause("there", "be", this.dog); //$NON-NLS-1$ //$NON-NLS-2$
			this.s2.addPostModifier(this.onTheRock);
			this.s2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("is there the dog on the rock", this.realiser.realise(this.s2).getRealisation());
	
			// perfective
			// sentence -- "there has been the dog on the rock"
			this.s2 = this.phraseFactory.createClause("there", "be", this.dog); //$NON-NLS-1$ //$NON-NLS-2$
			this.s2.addPostModifier(this.onTheRock);
			this.s2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			this.s2.setFeature(Feature.PERFECT, true);
			Assert.assertEquals("has there been the dog on the rock", this.realiser.realise(this.s2).getRealisation());
	
			// progressive
			// sentence: "the man was giving the woman John's flower"
			var john:PhraseElement = this.phraseFactory.createNounPhrase("John"); //$NON-NLS-1$
			john.setFeature(Feature.POSSESSIVE, true);
			var flower:PhraseElement = this.phraseFactory.createNounPhrase("flower", john); //$NON-NLS-1$
			var _woman:PhraseElement = this.phraseFactory.createNounPhrase("woman", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.s3 = this.phraseFactory.createClause(this.man, this.give, flower);
			this.s3.setIndirectObject(_woman);
			this.s3.setFeature(Feature.TENSE, Tense.PAST);
			this.s3.setFeature(Feature.PROGRESSIVE, true);
			this.s3.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			var realised:NLGElement = this.realiser.realise(this.s3);
			Assert.assertEquals("was the man giving the woman John's flower", realised.getRealisation());
	
			// modal
			// sentence: "the man should be giving the woman John's flower"
			setUp();
			john = this.phraseFactory.createNounPhrase("John"); //$NON-NLS-1$
			john.setFeature(Feature.POSSESSIVE, true);
			flower = this.phraseFactory.createNounPhrase("flower", john); //$NON-NLS-1$
			_woman = this.phraseFactory.createNounPhrase("woman", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.s3 = this.phraseFactory.createClause(this.man, this.give, flower);
			this.s3.setIndirectObject(_woman);
			this.s3.setFeature(Feature.TENSE, Tense.PAST);
			this.s3.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			this.s3.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			Assert.assertEquals("should the man have given the woman John's flower", this.realiser.realise(this.s3).getRealisation());
	
			// complex case with cue phrases
			// sentence: "however, tomorrow, Jane and Andrew will pick up the balls
			// in the shop"
			// this gets the front modifier "tomorrow" shifted to the end
			setUp();
			var subjects:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
			this.s4 = this.phraseFactory.createClause(subjects, "pick up", "the balls"); //$NON-NLS-1$
			this.s4.addPostModifierAsString("in the shop"); //$NON-NLS-1$
			this.s4.setFeature(Feature.CUE_PHRASE, "however,"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("however, will Jane and Andrew pick up the balls in the shop tomorrow", this.realiser.realise(this.s4).getRealisation());
		}
	
		/**
		 * Test for sentences with negation.
		 */
		[Test]
		public function testNegatedQuestions():void
		{
			setUp();
			this.phraseFactory.setLexicon(this.lexicon);
			this.realiser.setLexicon(this.lexicon);
	
			// sentence: "the woman did not kiss the man"
			this.s1 = this.phraseFactory.createClause(this.woman, "kiss", this.man);
			this.s1.setFeature(Feature.TENSE, Tense.PAST);
			this.s1.setFeature(Feature.NEGATED, true);
			this.s1.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("did the woman not kiss the man", this.realiser.realise(this.s1).getRealisation());
	
			// sentence: however, tomorrow, Jane and Andrew will not pick up the
			// balls in the shop
			var subjects:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
			this.s4 = this.phraseFactory.createClause(subjects, "pick up", "the balls"); //$NON-NLS-1$
			this.s4.addPostModifierAsString("in the shop"); //$NON-NLS-1$
			this.s4.setFeature(Feature.CUE_PHRASE, "however,"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
			this.s4.setFeature(Feature.NEGATED, true);
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("however, will Jane and Andrew not pick up the balls in the shop tomorrow", this.realiser.realise(this.s4).getRealisation());
		}
	
		/**
		 * Tests for coordinate VPs in question form.
		 */
		[Test]
		public function testCoordinateVPQuestions():void
		{
			// create a complex vp: "kiss the dog and walk in the room"
			setUp();
			var complex:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.kiss, this.walk);
			this.kiss.addComplement(this.dog);
			this.walk.addComplement(this.inTheRoom);
	
			// sentence: "However, tomorrow, Jane and Andrew will kiss the dog and
			// will walk in the room"
			var subjects:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"),  this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
			this.s4 = this.phraseFactory.createClause(subjects, complex);
			this.s4.setFeature(Feature.CUE_PHRASE, "however"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
	
			Assert.assertEquals("however tomorrow Jane and Andrew will kiss the dog and will walk in the room", this.realiser.realise(this.s4).getRealisation());
	
			// setting to interrogative should automatically give us a single,
			// wide-scope aux
			setUp();
			subjects = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
			this.kiss.addComplement(this.dog);
			this.walk.addComplement(this.inTheRoom);
			complex = new CoordinatedPhraseElement(this.kiss, this.walk);
			this.s4 = this.phraseFactory.createClause(subjects, complex);
			this.s4.setFeature(Feature.CUE_PHRASE, "however"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
	
			Assert.assertEquals("however will Jane and Andrew kiss the dog and walk in the room tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// slightly more complex -- perfective
			setUp();
			this.realiser.setLexicon(this.lexicon);
			subjects = new CoordinatedPhraseElement(this.phraseFactory.createNounPhrase("Jane"), this.phraseFactory.createNounPhrase("Andrew")); //$NON-NLS-1$
			complex = new CoordinatedPhraseElement(this.kiss, this.walk);
			this.kiss.addComplement(this.dog);
			this.walk.addComplement(this.inTheRoom);
			this.s4 = this.phraseFactory.createClause(subjects, complex);
			this.s4.setFeature(Feature.CUE_PHRASE, "however"); //$NON-NLS-1$
			this.s4.addFrontModifierAsString("tomorrow"); //$NON-NLS-1$
			this.s4.setFeature(Feature.TENSE, Tense.FUTURE);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			this.s4.setFeature(Feature.PERFECT, true);
	
			Assert.assertEquals("however will Jane and Andrew have kissed the dog and walked in the room tomorrow", this.realiser.realise(this.s4).getRealisation());
		}
	
		/**
		 * Test for simple WH questions in present tense.
		 */
		[Test]
		public function testSimpleQuestions2():void
		{
			setUp();
			this.realiser.setLexicon(this.lexicon);
			var s:PhraseElement = this.phraseFactory.createClause("the woman", "kiss", "the man"); //$NON-NLS-1$
	
			// try with the simple yes/no type first
			s.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("does the woman kiss the man", this.realiser.realise(s).getRealisation());
	
			// now in the passive
			s = this.phraseFactory.createClause("the woman", "kiss", "the man"); //$NON-NLS-1$
			s.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			s.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("is the man kissed by the woman", this.realiser.realise(s).getRealisation());
	
			// // subject interrogative with simple present
			// // sentence: "the woman kisses the man"
			s = this.phraseFactory.createClause("the woman", "kiss", "the man"); //$NON-NLS-1$
			s.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
	
			Assert.assertEquals("who kisses the man", this.realiser.realise(s).getRealisation());
	
			// object interrogative with simple present
			s = this.phraseFactory.createClause("the woman", "kiss", "the man"); //$NON-NLS-1$
			s.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
			Assert.assertEquals("who does the woman kiss", this.realiser.realise(s).getRealisation());
	
			// subject interrogative with passive
			s = this.phraseFactory.createClause("the woman", "kiss", "the man"); //$NON-NLS-1$
			s.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			s.setFeature(Feature.PASSIVE, true);
			Assert.assertEquals("who is the man kissed by", this.realiser.realise(s).getRealisation());
		}
	
		/**
		 * Test for wh questions.
		 */
		[Test]
		public function testWHQuestions():void
		{
			// subject interrogative
			setUp();
			this.realiser.setLexicon(this.lexicon);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			Assert.assertEquals("however who will pick up the balls in the shop tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// subject interrogative in passive
			setUp();
			this.s4.setFeature(Feature.PASSIVE, true);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
	
			Assert.assertEquals("however who will the balls be picked up in the shop by tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// object interrogative
			setUp();
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE,
					InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("however what will Jane and Andrew pick up in the shop tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// object interrogative with passive
			setUp();
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			this.s4.setFeature(Feature.PASSIVE, true);
	
			Assert.assertEquals("however what will be picked up in the shop by Jane and Andrew tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// how-question + passive
			setUp();
			this.s4.setFeature(Feature.PASSIVE, true);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.HOW);
			Assert.assertEquals("however how will the balls be picked up in the shop by Jane and Andrew tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// // why-question + passive
			setUp();
			this.s4.setFeature(Feature.PASSIVE, true);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHY);
			Assert.assertEquals("however why will the balls be picked up in the shop by Jane and Andrew tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// how question with modal
			setUp();
			this.s4.setFeature(Feature.PASSIVE, true);
			this.s4.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.HOW);
			this.s4.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			Assert.assertEquals("however how should the balls be picked up in the shop by Jane and Andrew tomorrow", this.realiser.realise(this.s4).getRealisation());
	
			// indirect object
			setUp();
			this.realiser.setLexicon(this.lexicon);
			this.s3.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_INDIRECT_OBJECT);
			Assert.assertEquals("who does the man give John's flower to", this.realiser.realise(this.s3).getRealisation());
		}
	
		/**
		 * Test questions in the tutorial.
		 */
		[Test]
		public function testTutorialQuestions():void
		{
			setUp();
			this.realiser.setLexicon(this.lexicon);
	
			var p:PhraseElement = this.phraseFactory.createClause("Mary", "chase", "George"); //$NON-NLS-1$
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("does Mary chase George", this.realiser.realise(p).getRealisation());
	
			p = this.phraseFactory.createClause("Mary", "chase", "George"); //$NON-NLS-1$
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
			Assert.assertEquals("who does Mary chase", this.realiser.realise(p).getRealisation());
		}
	
		/**
		 * Subject WH Questions with modals
		 */
		[Test]
		public function testModalWHSubjectQuestion():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause(this.dog, "upset", this.man);
			p.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("the dog upset the man", this.realiser.realise(p).getRealisation());
	
			// first without modal
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			Assert.assertEquals("who upset the man", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			Assert.assertEquals("what upset the man", this.realiser.realise(p).getRealisation());
	
			// now with modal auxiliary
			p.setFeature(Feature.MODAL, "may");
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			Assert.assertEquals("who may have upset the man", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.TENSE, Tense.FUTURE);
			Assert.assertEquals("who may upset the man", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.TENSE, Tense.PAST);
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			Assert.assertEquals("what may have upset the man", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.TENSE, Tense.FUTURE);
			Assert.assertEquals("what may upset the man", this.realiser.realise(p).getRealisation());
		}
	
		/**
		 * Subject WH Questions with modals
		 */
		[Test]
		public function testModalWHObjectQuestion():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause(this.dog, "upset", this.man);
			p.setFeature(Feature.TENSE, Tense.PAST);
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
	
			Assert.assertEquals("who did the dog upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.MODAL, "may");
			Assert.assertEquals("who may the dog have upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what may the dog have upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.TENSE, Tense.FUTURE);
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
			Assert.assertEquals("who may the dog upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what may the dog upset", this.realiser.realise(p).getRealisation());
		}
	
		/**
		 * Questions with tenses requiring auxiliaries + subject WH
		 */
		[Test]
		public function testAuxWHSubjectQuestion():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause(this.dog, "upset", this.man);
			p.setFeature(Feature.TENSE, Tense.PRESENT);
			p.setFeature(Feature.PERFECT, true);
			Assert.assertEquals("the dog has upset the man", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			Assert.assertEquals("who has upset the man", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			Assert.assertEquals("what has upset the man", this.realiser.realise(p).getRealisation());
		}
	
		/**
		 * Questions with tenses requiring auxiliaries + subject WH
		 */
		[Test]
		public function testAuxWHObjectQuestion():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause(this.dog, "upset", this.man);
	
			// first without any aux
			p.setFeature(Feature.TENSE, Tense.PAST);
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what did the dog upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
			Assert.assertEquals("who did the dog upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.TENSE, Tense.PRESENT);
			p.setFeature(Feature.PERFECT, true);
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
			Assert.assertEquals("who has the dog upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what has the dog upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.TENSE, Tense.FUTURE);
			p.setFeature(Feature.PERFECT, true);
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
			Assert.assertEquals("who will the dog have upset", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what will the dog have upset", this.realiser.realise(p).getRealisation());
	
		}
	
		/**
		 * Test for questions with "be"
		 */
		[Test]
		public function testBeQuestions():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause(
				this.phraseFactory.createNounPhrase("ball", "a"),
				this.phraseFactory.createWord("be", LexicalCategory.VERB),
				this.phraseFactory.createNounPhrase("toy", "a"));
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what is a ball", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("is a ball a toy", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			Assert.assertEquals("what is a toy", this.realiser.realise(p).getRealisation());
	
			var p2:SPhraseSpec = this.phraseFactory.createClause("Mary", "be", "beautiful");
			p2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHY);
			Assert.assertEquals("why is Mary beautiful", this.realiser.realise(p2).getRealisation());
	
			p2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			Assert.assertEquals("who is beautiful", this.realiser.realise(p2).getRealisation());
		}
	
		/**
		 * Test for questions with "be" in future tense
		 */
		[Test]
		public function testBeQuestionsFuture():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause(
				this.phraseFactory.createNounPhrase("ball", "a"),
				this.phraseFactory.createWord("be", LexicalCategory.VERB),
				this.phraseFactory.createNounPhrase("toy", "a"));
			p.setFeature(Feature.TENSE, Tense.FUTURE);
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what will a ball be", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("will a ball be a toy", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			Assert.assertEquals("what will be a toy", this.realiser.realise(p).getRealisation());
	
			var p2:SPhraseSpec = this.phraseFactory.createClause("Mary", "be", "beautiful");
			p2.setFeature(Feature.TENSE, Tense.FUTURE);
			p2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHY);
			Assert.assertEquals("why will Mary be beautiful", this.realiser.realise(p2).getRealisation());
	
			p2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			Assert.assertEquals("who will be beautiful", this.realiser.realise(p2).getRealisation());
		}
	
		/**
		 * Tests for WH questions with be in past tense
		 */
		[Test]
		public function testBeQuestionsPast():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause(
				this.phraseFactory.createNounPhrase("ball", "a"),
				this.phraseFactory.createWord("be", LexicalCategory.VERB),
				this.phraseFactory.createNounPhrase("toy", "a"));
			p.setFeature(Feature.TENSE, Tense.PAST);
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what was a ball", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("was a ball a toy", this.realiser.realise(p).getRealisation());
	
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			Assert.assertEquals("what was a toy", this.realiser.realise(p).getRealisation());
	
			var p2:SPhraseSpec = this.phraseFactory.createClause("Mary", "be", "beautiful");
			p2.setFeature(Feature.TENSE, Tense.PAST);
			p2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHY);
			Assert.assertEquals("why was Mary beautiful", this.realiser.realise(p2).getRealisation());
	
			p2.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_SUBJECT);
			Assert.assertEquals("who was beautiful", this.realiser.realise(p2).getRealisation());
		}
	}
}
