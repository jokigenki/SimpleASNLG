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
	import com.steamshift.utils.Cloner;
	
	import flexunit.framework.Assert;
	
	import simpleasnlg.aggregation.ClauseCoordinationRule;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.features.Gender;
	import simpleasnlg.features.InterrogativeType;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Person;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	/**
	 * Tests from third parties
	 * @author ereiter
	 * 
	 */
	public class ExternalTest extends SimpleNLG4Test
	{
		public function ExternalTest(name:String = null)
		{
			super(name);
		}
	
		/**
		 * Basic tests
		 * 
		 */
		[Test]
		public function testForcher():void
		{
			// Bjorn Forcher's tests
			this.phraseFactory.setLexicon(this.lexicon);
			var s1:PhraseElement= this.phraseFactory.createClause(null, "associate", "Marie");
			s1.setFeature(Feature.PASSIVE, true);
			var pp1:PhraseElement = this.phraseFactory.createPrepositionPhrase("with"); //$NON-NLS-1$
			pp1.addComplementAsString("Peter"); //$NON-NLS-1$
			pp1.addComplementAsString("Paul"); //$NON-NLS-1$
			s1.addPostModifier(pp1);
	
			Assert.assertEquals("Marie is associated with Peter and Paul", this.realiser.realise(s1).getRealisation());
			var s2:SPhraseSpec = this.phraseFactory.createClause();
			s2.setSubject(this.phraseFactory.createNounPhrase("Peter")); //$NON-NLS-1$
			s2.setVerb("have"); //$NON-NLS-1$
			s2.setObject("something to do"); //$NON-NLS-1$
			s2.addPostModifier(this.phraseFactory.createPrepositionPhrase("with", "Paul")); //$NON-NLS-1$ //$NON-NLS-2$
	
			Assert.assertEquals("Peter has something to do with Paul", this.realiser.realise(s2).getRealisation());
		}
	
		[Test]
		public function testLu():void
		{
			// Xin Lu's test
			this.phraseFactory.setLexicon(this.lexicon);
			var s1:PhraseElement= this.phraseFactory.createClause("we", "consider", "John"); //$NON-NLS-1$
			s1.addPostModifierAsString("a friend"); //$NON-NLS-1$
	
			Assert.assertEquals("we consider John a friend", this.realiser.realise(s1).getRealisation());
		}
	
		[Test]
		public function testDwight():void
		{
			// Rachel Dwight's test
			this.phraseFactory.setLexicon(this.lexicon);
	
			var noun4:NPPhraseSpec = this.phraseFactory.createNounPhrase("FGFR3 gene in every cell"); //$NON-NLS-1$
	
			noun4.setSpecifier("the");
	
			var prep1:PhraseElement = this.phraseFactory.createPrepositionPhrase("of", noun4); //$NON-NLS-1$
	
			var noun1:PhraseElement = this.phraseFactory.createNounPhrase("patient's mother", "the"); //$NON-NLS-1$ //$NON-NLS-2$
	
			var noun2:PhraseElement = this.phraseFactory.createNounPhrase("patient's father", "the"); //$NON-NLS-1$ //$NON-NLS-2$
	
			var noun3:PhraseElement = this.phraseFactory.createNounPhrase("changed copy"); //$NON-NLS-1$
			noun3.addPreModifierAsString("one"); //$NON-NLS-1$
			noun3.addComplement(prep1);
	
			var coordNoun1:CoordinatedPhraseElement = new CoordinatedPhraseElement(noun1, noun2);
			coordNoun1.setConjunction( "or"); //$NON-NLS-1$
	
			var verbPhrase1:PhraseElement = this.phraseFactory.createVerbPhrase("have"); //$NON-NLS-1$
			verbPhrase1.setFeature(Feature.TENSE,Tense.PRESENT);
	
			var sentence1:PhraseElement = this.phraseFactory.createClause(coordNoun1, verbPhrase1, noun3);
	
			//realiser.setDebugMode(true);
			Assert.assertEquals("the patient's mother or the patient's father has one changed copy of the FGFR3 gene in every cell", this.realiser.realise(sentence1).getRealisation());
	
			// Rachel's second test
			noun3 = this.phraseFactory.createNounPhrase("gene test", "a"); //$NON-NLS-1$ //$NON-NLS-2$
			noun2 = this.phraseFactory.createNounPhrase("LDL test", "an"); //$NON-NLS-1$ //$NON-NLS-2$
			noun1 = this.phraseFactory.createNounPhrase("clinic", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			verbPhrase1 = this.phraseFactory.createVerbPhrase("perform"); //$NON-NLS-1$
	
			var coord1:CoordinatedPhraseElement = new CoordinatedPhraseElement(noun2, noun3);
			sentence1 = this.phraseFactory.createClause(noun1, verbPhrase1, coord1);
			sentence1.setFeature(Feature.TENSE,Tense.PAST);
	
			Assert.assertEquals("the clinic performed an LDL test and a gene test", this.realiser.realise(sentence1).getRealisation());
		}
	
		[Test]
		public function testNovelli():void {
			// Nicole Novelli's test
			var p:PhraseElement = this.phraseFactory.createClause(
					"Mary", "chase", "George"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
	
			var pp:PhraseElement = this.phraseFactory.createPrepositionPhrase("in", "the park"); //$NON-NLS-1$ //$NON-NLS-2$
			p.addPostModifier(pp);
	
			Assert.assertEquals("Mary chases George in the park", this.realiser.realise(p).getRealisation());
	
			// another question from Nicole
			var run:SPhraseSpec = this.phraseFactory.createClause("you", "go", "running"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			run.setFeature(Feature.MODAL, "should"); //$NON-NLS-1$
			run.addPreModifierAsString("really"); //$NON-NLS-1$
			var think:SPhraseSpec = this.phraseFactory.createClause("I", "think"); //$NON-NLS-1$ //$NON-NLS-2$
			think.setObject(run);
			run.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
	
			var text:String = this.realiser.realise(think).getRealisation();
			Assert.assertEquals("I think you should really go running", text); //$NON-NLS-1$
		}
	
		[Test]
		public function testPiotrek():void
		{
			// Piotrek Smulikowski's test
			this.phraseFactory.setLexicon(this.lexicon);
			var sent:PhraseElement = this.phraseFactory.createClause("I", "shoot", "the duck"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			sent.setFeature(Feature.TENSE,Tense.PAST);
	
			var loc:PhraseElement = this.phraseFactory.createPrepositionPhrase("at", "the Shooting Range"); //$NON-NLS-1$ //$NON-NLS-2$
			sent.addPostModifier(loc);
			sent.setFeature(Feature.CUE_PHRASE, "then"); //$NON-NLS-1$
	
			Assert.assertEquals("then I shot the duck at the Shooting Range", this.realiser.realise(sent).getRealisation());
		}
	
		[Test]
		public function testPrescott():void
		{
			// Michael Prescott's test
			this.phraseFactory.setLexicon(this.lexicon);
			var embedded:PhraseElement = this.phraseFactory.createClause("Jill", "prod", "Spot"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			var sent:PhraseElement = this.phraseFactory.createClause("Jack", "see", embedded); //$NON-NLS-1$ //$NON-NLS-2$
			embedded.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
			embedded.setFeature(Feature.FORM, Form.BARE_INFINITIVE);
	
			Assert.assertEquals("Jack sees Jill prod Spot", this.realiser.realise(sent).getRealisation());
		}
	
		[Test]
		public function testWissner():void
		{
			// Michael Wissner's text
			setUp();
	
			var p:PhraseElement = this.phraseFactory.createClause("a wolf", "eat"); //$NON-NLS-1$ //$NON-NLS-2$
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("what does a wolf eat", this.realiser.realise(p).getRealisation());
		}
		
		[Test]
		public function testPhan():void
		{
			// Thomas Phan's text
	
			setUp();
			
			var subjectElement:PhraseElement = phraseFactory.createNounPhrase("I");
		    var verbElement:PhraseElement = phraseFactory.createVerbPhrase("run");
	
		    var prepPhrase:PhraseElement = phraseFactory.createPrepositionPhrase("from");
			prepPhrase.addComplementAsString("home");
			
			verbElement.addComplement(prepPhrase);
		    var newSentence:SPhraseSpec = phraseFactory.createClause();
			newSentence.setSubject(subjectElement);
			newSentence.setVerbPhrase(verbElement);
	
			Assert.assertEquals("I run from home", this.realiser.realise(newSentence).getRealisation());
	
		}
	
		[Test]
		public function testKerber():void
		{
			// Frederic Kerber's tests
	        var sp:SPhraseSpec =  phraseFactory.createClause("he", "need");
	        var secondSp:SPhraseSpec = phraseFactory.createClause();
	        secondSp.setVerb("build");
	        secondSp.setObject("a house");
	        secondSp.setFeature(Feature.FORM,Form.INFINITIVE);
	        sp.setObject("stone");
	        sp.addComplement(secondSp);
	        Assert.assertEquals("he needs stone to build a house", this.realiser.realise(sp).getRealisation());
	       
	        var sp2:SPhraseSpec = phraseFactory.createClause("he", "give");
	        sp2.setIndirectObject("I");
	        sp2.setObject("the book");
	        Assert.assertEquals("he gives me the book", this.realiser.realise(sp2).getRealisation());
	
		}
		
		[Test]
		public function testStephenson():void
		{
			// Bruce Stephenson's test
			var qs2:SPhraseSpec = this.phraseFactory.createClause();
			qs2 = this.phraseFactory.createClause();
			qs2.setSubject("moles of Gold");
			qs2.setVerb("are");
			qs2.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			qs2.setFeature(Feature.PASSIVE, false);
			qs2.setFeature(Feature.INTERROGATIVE_TYPE,InterrogativeType.HOW_MANY);
			qs2.setObject("in a 2.50 g sample of pure Gold");
			var sentence:DocumentElement = this.phraseFactory.createSentenceWithElement(qs2);
			Assert.assertEquals("How many moles of Gold are in a 2.50 g sample of pure Gold?", this.realiser.realise(sentence).getRealisation());
		}
		
		[Test]
		public function testPierre():void
		{
			// John Pierre's test
			var p:SPhraseSpec = this.phraseFactory.createClause("Mary", "chase", "George");
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_OBJECT);
			Assert.assertEquals("What does Mary chase?", realiser.realiseSentence(p));
	
			p = this.phraseFactory.createClause("Mary", "chase", "George");
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			Assert.assertEquals("Does Mary chase George?", realiser.realiseSentence(p));
	
			p = this.phraseFactory.createClause("Mary", "chase", "George");
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHERE);
			Assert.assertEquals("Where does Mary chase George?", realiser.realiseSentence(p));
	
			p = this.phraseFactory.createClause("Mary", "chase", "George");
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHY);
			Assert.assertEquals("Why does Mary chase George?", realiser.realiseSentence(p));
	
			p = this.phraseFactory.createClause("Mary", "chase", "George");
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.HOW);
			Assert.assertEquals("How does Mary chase George?", realiser.realiseSentence(p));
	
	
		}
		
		[Test]
		public function testData2Text():void
		{
			// Data2Text tests
			// test OK to have number at end of sentence
			var p:SPhraseSpec = this.phraseFactory.createClause("the dog", "weigh", "12");
			Assert.assertEquals("The dog weighes 12.", realiser.realiseSentence(p));
			
			// test OK to have "there be" sentence with "there" as a StringElement
			var dataDropout2:NLGElement = this.phraseFactory.createNLGElement("data dropouts");
			dataDropout2.setPlural(true);
			var sentence2:SPhraseSpec = this.phraseFactory.createClause();
			sentence2.setSubject(this.phraseFactory.createStringElement("there"));
			sentence2.setVerb("be");
			sentence2.setObject(dataDropout2);
			Assert.assertEquals("There are data dropouts.", realiser.realiseSentence(sentence2));
			
			// test OK to have gerund form verb
			var weather1:SPhraseSpec = this.phraseFactory.createClause("SE 10-15", "veer", "S 15-20");
			weather1.setFeature(Feature.FORM, Form.GERUND);
			Assert.assertEquals("SE 10-15 veering S 15-20.", realiser.realiseSentence(weather1));		
	
			// test OK to have subject only
			var weather2:SPhraseSpec = this.phraseFactory.createClause("cloudy and misty", "be", "XXX");
			weather2.getVerbPhrase().setFeature(Feature.ELIDED, true);
			Assert.assertEquals("Cloudy and misty.", realiser.realiseSentence(weather2));
			
			// test OK to have VP only
			var weather3:SPhraseSpec = this.phraseFactory.createClause("S 15-20", "increase", "20-25");
			weather3.setFeature(Feature.FORM, Form.GERUND);
			weather3.getSubject().setFeature(Feature.ELIDED, true);
			Assert.assertEquals("Increasing 20-25.", realiser.realiseSentence(weather3));		
			
			// conjoined test
			var weather4:SPhraseSpec = this.phraseFactory.createClause("S 20-25", "back", "SSE");
			weather4.setFeature(Feature.FORM, Form.GERUND);
			weather4.getSubject().setFeature(Feature.ELIDED, true);
			
			var coord:CoordinatedPhraseElement = new CoordinatedPhraseElement();
			coord.addCoordinate(weather1);
			coord.addCoordinate(weather3);
			coord.addCoordinate(weather4);
			coord.setConjunction("then");
			Assert.assertEquals("SE 10-15 veering S 15-20, increasing 20-25 then backing SSE.", realiser.realiseSentence(coord));		
			
	
			// no verb
			var weather5:SPhraseSpec = this.phraseFactory.createClause("rain", null, "likely");
			Assert.assertEquals("Rain likely.", realiser.realiseSentence(weather5));
	
		}
		
		[Test]
		public function testRafael():void
		{
			// Rafael Valle's tests
			var ss:Array = new Array();
			var coord:ClauseCoordinationRule = new ClauseCoordinationRule();
			coord.setFactory(this.phraseFactory);
			
			ss.push(this.agreePhrase("John Lennon")); // john lennon agreed with it  
			ss.push(this.disagreePhrase("Geri Halliwell")); // Geri Halliwell disagreed with it
			ss.push(this.commentPhrase("Melanie B")); // Melanie B commented on it
			ss.push(this.agreePhrase("you")); // you agreed with it
			ss.push(this.commentPhrase("Emma Bunton")); //Emma Bunton commented on it
	
			var results:Array = coord.applyArray(ss);
			var ret:Array = this.realizeAll(results);
			var out:String = ret.join(", ");
			
			Assert.assertEquals("John Lennon and you agreed with it, Geri Halliwell disagreed with it, Melanie B and Emma Bunton commented on it", out);
		}
		
		private function commentPhrase(name:String):NLGElement
		{  // used by testRafael
			var s:SPhraseSpec = phraseFactory.createClause();
			s.setSubject(phraseFactory.createNounPhrase(name));
			s.setVerbPhrase(phraseFactory.createVerbPhrase("comment on"));
			s.setObject("it");
			s.setFeature(Feature.TENSE, Tense.PAST);
			return s;
		}
	
		private function agreePhrase(name:String):NLGElement
		{  // used by testRafael
			var s:SPhraseSpec = phraseFactory.createClause();
			s.setSubject(phraseFactory.createNounPhrase(name));
			s.setVerbPhrase(phraseFactory.createVerbPhrase("agree with"));
			s.setObject("it");
			s.setFeature(Feature.TENSE, Tense.PAST);
			return s;
		}
	
		private function disagreePhrase(name:String):NLGElement
		{  // used by testRafael
			var s:SPhraseSpec = phraseFactory.createClause();
			s.setSubject(phraseFactory.createNounPhrase(name));
			s.setVerbPhrase(phraseFactory.createVerbPhrase("disagree with"));
			s.setObject("it");
			s.setFeature(Feature.TENSE, Tense.PAST);
			return s;
		}
	
		private function realizeAll(results:Array):Array
		{ // used by testRafael
			var ret:Array = new Array();
			var len:int = results.length;
			for (var i:int = 0; i < len; i++)
			{
				var e:NLGElement = results[i];
				var r:String = this.realiser.realise(e).getRealisation();
				ret.push(r);
			}
			return ret;
		}
		
		[Test]
		public function testWikipedia():void
		{
			// test code fragments in wikipedia
			// realisation
			var subject:NPPhraseSpec = phraseFactory.createNounPhrase("woman", "the");
			subject.setPlural(true);
			var sentence:SPhraseSpec = phraseFactory.createClause(subject, "smoke");
			sentence.setFeature(Feature.NEGATED, true);
			Assert.assertEquals("The women do not smoke.", realiser.realiseSentence(sentence));
	
			// aggregation
			var s1:SPhraseSpec = phraseFactory.createClause("the man", "be", "hungry");
			var s2:SPhraseSpec = phraseFactory.createClause("the man", "buy", "an apple");
			var result:NLGElement = new ClauseCoordinationRule().applyElements(s1, s2);
			Assert.assertEquals("The man is hungry and buys an apple.", realiser.realiseSentence(result));
	
		}
		
		[Test]
		public function testLean():void
		{
			// A Lean's test
			var sentence:SPhraseSpec = phraseFactory.createClause();
			sentence.setVerb("be");
			sentence.setObject("a ball");
			sentence.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			Assert.assertEquals("What is a ball?", realiser.realiseSentence(sentence));
			
			sentence = phraseFactory.createClause();
			sentence.setVerb("be");
			var object:NPPhraseSpec = phraseFactory.createNounPhrase("example");
			object.setPlural(true);
			object.addModifierAsString("of jobs");
			sentence.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHAT_SUBJECT);
			sentence.setObject(object);
			Assert.assertEquals("What are examples of jobs?", realiser.realiseSentence(sentence));
			
			var p:SPhraseSpec = phraseFactory.createClause(); 
	        var sub1:NPPhraseSpec = phraseFactory.createNounPhrase("Mary"); 
	           
	        sub1.setFeature(LexicalFeature.GENDER, Gender.FEMININE); 
	        sub1.setFeature(Feature.PRONOMINAL, true); 
	        sub1.setFeature(Feature.PERSON, Person.FIRST); 
	        p.setSubject(sub1); 
	        p.setVerb("chase"); 
	        p.setObject("the monkey"); 
	
	        var output2:String = realiser.realiseSentence(p); // Realiser created earlier. 
	        Assert.assertEquals("I chase the monkey.", output2);
	
	
		}
		
		[Test]
		public function testKalijurand():void
		{
			// K Kalijurand's test
	        var lemma:String = "walk"; 
	
	        var word:WordElement = lexicon.lookupWord(lemma,  LexicalCategory.VERB); 
	        var inflectedWord:InflectedWordElement = new InflectedWordElement(word); 
	
	        inflectedWord.setFeature(Feature.FORM, Form.PAST_PARTICIPLE); 
	        var form:String = realiser.realise(inflectedWord).getRealisation(); 
	        Assert.assertEquals("walked", form);
	
	
	        inflectedWord = new InflectedWordElement(word); 
	
	        inflectedWord.setFeature(Feature.PERSON, Person.THIRD); 
	        form = realiser.realise(inflectedWord).getRealisation(); 
	        Assert.assertEquals("walks", form);
		}
	}
}