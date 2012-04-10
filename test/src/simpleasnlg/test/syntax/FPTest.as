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
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	/**
	 * Test added to break the realiser 
	 * 
	 * @author portet
	 */
	
	public class FPTest extends SimpleNLG4Test
	{
		public var docFactory:NLGFactory;
		
		/**
		 * Instantiates a new text spec test.
		 * 
		 * @param name
		 *            the name
		 */
		public function FPTest(name:String = null)
		{
			super(name);
			docFactory = new NLGFactory(this.lexicon);
		}
	
		/**
		 * Basic tests.
		 */
		[Test]
		public function testHerLover():void
		{
			this.phraseFactory.setLexicon(this.lexicon);
			this.realiser.setLexicon(this.lexicon);
			
			// Create the pronoun 'she'
			var she:NLGElement = phraseFactory.createWord("she",LexicalCategory.PRONOUN);
	
			// Set possessive on the pronoun to make it 'her'
			she.setFeature(Feature.POSSESSIVE, true);
	
			// Create a noun phrase with the subject lover and the determiner
			// as she
			var herLover:PhraseElement = phraseFactory.createNounPhrase("lover", she);
	
			// Create a clause to say 'he be her lover'
			var clause:PhraseElement = phraseFactory.createClause("he", "be", herLover);
	
			// Add the cue phrase need the comma as orthography
			// currently doesn't handle this.
			// This could be expanded to be a noun phrase with determiner
			// 'two' and noun 'week', set to plural and with a premodifier of
			// 'after'
			clause.setFeature(Feature.CUE_PHRASE, "after two weeks,");
	
			// Add the 'for a fortnight' as a post modifier. Alternatively
			// this could be added as a prepositional phrase 'for' with a
			// complement of a noun phrase ('a' 'fortnight')
			clause.addPostModifierAsString("for a fortnight");
	
			// Set 'be' to 'was' as past tense
			clause.setFeature(Feature.TENSE,Tense.PAST);
	
			// Add the clause to a sentence.
			var sentence1:DocumentElement = docFactory.createSentenceWithElement(clause);
	
			// Realise the sentence
			var realised:NLGElement = this.realiser.realise(sentence1);
	
			// Retrieve the realisation and dump it to the console
	//		System.out.println(realised.getRealisation()); 		
			Assert.assertEquals("After two weeks, he was her lover for a fortnight.", realised.getRealisation());
		}
	
		/**
		 * Basic tests.
		 */
		[Test]
		public function testHerLovers():void
		{
			this.phraseFactory.setLexicon(this.lexicon);
	
			// Create the pronoun 'she'
			var she:NLGElement = phraseFactory.createWord("she",LexicalCategory.PRONOUN);
	
			// Set possessive on the pronoun to make it 'her'
			she.setFeature(Feature.POSSESSIVE, true);
	
			// Create a noun phrase with the subject lover and the determiner
			// as she
			var herLover:PhraseElement = phraseFactory.createNounPhrase("lover", she);
			herLover.setPlural(true);
	
			// Create the pronoun 'he'
			var he:NLGElement = phraseFactory.createNounPhrase("he", LexicalCategory.PRONOUN);
			he.setPlural(true);
	
			// Create a clause to say 'they be her lovers'
			var clause:PhraseElement = phraseFactory.createClause(he, "be", herLover);
			clause.setFeature(Feature.POSSESSIVE, true);
	
			// Add the cue phrase need the comma as orthography
			// currently doesn't handle this.
			// This could be expanded to be a noun phrase with determiner
			// 'two' and noun 'week', set to plural and with a premodifier of
			// 'after'
			clause.setFeature(Feature.CUE_PHRASE, "after two weeks,");
	
			// Add the 'for a fortnight' as a post modifier. Alternatively
			// this could be added as a prepositional phrase 'for' with a
			// complement of a noun phrase ('a' 'fortnight')
			clause.addPostModifierAsString("for a fortnight");
	
			// Set 'be' to 'was' as past tense
			clause.setFeature(Feature.TENSE,Tense.PAST);
			
			// Add the clause to a sentence.
			var sentence1:DocumentElement = docFactory.createSentenceWithElement(clause);
	
			// Realise the sentence
			var realised:NLGElement = this.realiser.realise(sentence1);
	
			// Retrieve the realisation and dump it to the console
	//		System.out.println(realised.getRealisation()); 
	
			Assert.assertEquals("After two weeks, they were her lovers for a fortnight.", realised.getRealisation());
		}
	
		/**
		 * combine two S's using cue phrase and gerund.
		 */
		[Test]
		public function testDavesHouse():void
		{
			this.phraseFactory.setLexicon(this.lexicon);
	
			var born:PhraseElement = phraseFactory.createClause("Dave Bus", "be", "born");
			born.setFeature(Feature.TENSE,Tense.PAST);
			born.addPostModifierAsString("in");
			born.setFeature(Feature.COMPLEMENTISER, "which");
	
			var theHouse:PhraseElement = phraseFactory.createNounPhrase("house", "the");
			theHouse.addComplement(born);
	
			var clause:PhraseElement = phraseFactory.createClause(theHouse, "be", phraseFactory.createPrepositionPhrase("in", "Edinburgh"));
			var sentence:DocumentElement = docFactory.createSentenceWithElement(clause);
			var realised:NLGElement = realiser.realise(sentence);
	//		System.out.println(realised.getRealisation()); 
	
			// Retrieve the realisation and dump it to the console
			Assert.assertEquals("The house which Dave Bus was born in is in Edinburgh.", realised.getRealisation());
		}
	
		/**
		 * combine two S's using cue phrase and gerund.
		 */
		[Test]
		public function testDaveAndAlbertsHouse():void
		{
			this.phraseFactory.setLexicon(this.lexicon);
	
			var dave:NLGElement = phraseFactory.createWord("Dave Bus", LexicalCategory.NOUN);
			var albert:NLGElement = phraseFactory.createWord("Albert", LexicalCategory.NOUN);
			
			var coord1:CoordinatedPhraseElement = new CoordinatedPhraseElement(dave, albert);
			
			var born:PhraseElement = phraseFactory.createClause(coord1, "be", "born");
			born.setFeature(Feature.TENSE,Tense.PAST);
			born.addPostModifierAsString("in");
			born.setFeature(Feature.COMPLEMENTISER, "which");
	
			var theHouse:PhraseElement = phraseFactory.createNounPhrase("house", "the");
			theHouse.addComplement(born);
	
			var clause:PhraseElement = phraseFactory.createClause(theHouse, "be", phraseFactory.createPrepositionPhrase("in", "Edinburgh"));
			var sentence:DocumentElement = docFactory.createSentenceWithElement(clause);
			
			var realised:NLGElement = realiser.realise(sentence);
	//		System.out.println(realised.getRealisation()); 
	
			// Retrieve the realisation and dump it to the console
			Assert.assertEquals("The house which Dave Bus and Albert were born in is in Edinburgh.", realised.getRealisation());
		}
	
		
		[Test]
		public function testEngineerHolidays():void
		{
			this.phraseFactory.setLexicon(this.lexicon);
	
			// Inner clause is 'I' 'make' 'sentence' 'for'.
			var inner:PhraseElement = phraseFactory.createClause("I","make", "sentence for");
			// Inner clause set to progressive.
			inner.setFeature(Feature.PROGRESSIVE,true);
			
			//Complementiser on inner clause is 'whom'
			inner.setFeature(Feature.COMPLEMENTISER, "whom");
			
			// create the engineer and add the inner clause as post modifier 
			var engineer:PhraseElement = phraseFactory.createNounPhrase("the engineer");
			engineer.addComplement(inner);
			
			// Outer clause is: 'the engineer' 'go' (preposition 'to' 'holidays')
			var outer:PhraseElement = phraseFactory.createClause(engineer,"go",phraseFactory.createPrepositionPhrase("to","holidays"));
	
			// Outer clause tense is Future.
			outer.setFeature(Feature.TENSE, Tense.FUTURE);
			
			// Possibly progressive as well not sure.
			outer.setFeature(Feature.PROGRESSIVE,true);
			
			//Outer clause postmodifier would be 'tomorrow'
			outer.addPostModifierAsString("tomorrow");
			var sentence:DocumentElement = docFactory.createSentenceWithElement(outer);
			var realised:NLGElement = realiser.realise(sentence);
	//		System.out.println(realised.getRealisation()); 
	
			// Retrieve the realisation and dump it to the console
			Assert.assertEquals("The engineer whom I am making sentence for will be going to holidays tomorrow.", realised.getRealisation());
		}
	
		
		[Test]
		public function testHousePoker():void
		{
			setUp();
			this.realiser.setLexicon(this.lexicon);
			
			var inner:PhraseElement = phraseFactory.createClause("I", "play", "poker");
			inner.setFeature(Feature.TENSE,Tense.PAST);
			inner.setFeature(Feature.COMPLEMENTISER, "where");
			
			var house:PhraseElement = phraseFactory.createNounPhrase("house", "the");
			house.addComplement(inner);
			
			var outer:SPhraseSpec = phraseFactory.createClause(null, "abandon", house);
			
			outer.addPostModifierAsString("since 1986");
			
			outer.setFeature(Feature.PASSIVE, true);
			outer.setFeature(Feature.PERFECT, true);
			
			var sentence:DocumentElement = docFactory.createSentenceWithElement(outer);
			var realised:NLGElement = realiser.realise(sentence);
	//		System.out.println(realised.getRealisation()); 
	
			// Retrieve the realisation and dump it to the console
			Assert.assertEquals("The house where I played poker has been abandoned since 1986.", realised.getRealisation());
		}
		
		
		[Test]
		public function testMayonnaise():void
		{
			this.phraseFactory.setLexicon(this.lexicon);
	
			var sandwich:NLGElement = phraseFactory.createNounPhrase("sandwich", LexicalCategory.NOUN);
			sandwich.setPlural(true);
			// 
			var first:PhraseElement = phraseFactory.createClause("I", "make", sandwich);
			first.setFeature(Feature.TENSE,Tense.PAST);
			first.setFeature(Feature.PROGRESSIVE,true);
			first.setPlural(false);
			
			var second:PhraseElement = phraseFactory.createClause("the mayonnaise", "run out");
			second.setFeature(Feature.TENSE,Tense.PAST);
			// 
			second.setFeature(Feature.COMPLEMENTISER, "when");
			
			first.addComplement(second);
			
			var sentence:DocumentElement = docFactory.createSentenceWithElement(first);
			var realised:NLGElement = realiser.realise(sentence);
	//		System.out.println(realised.getRealisation()); 
	
			// Retrieve the realisation and dump it to the console
			Assert.assertEquals("I was making sandwiches when the mayonnaise ran out.", realised.getRealisation());
		}
	}
}
