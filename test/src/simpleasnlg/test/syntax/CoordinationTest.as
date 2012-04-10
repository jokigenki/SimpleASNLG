package simpleasnlg.test.syntax
{
	import flexunit.framework.Assert;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.PPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.phrasespec.VPPhraseSpec;
	
	/**
	 * Some tests for coordination, especially of coordinated VPs with modifiers.
	 * 
	 * @author Albert Gatt
	 * 
	 */
	public class CoordinationTest extends SimpleNLG4Test
	{
		public function CoordinationTest(name:String = null)
		{
			super(name);
		}
	
		/**
		 * Test pre and post-modification of coordinate VPs inside a sentence.
		 */
		[Test]
		public function testModifiedCoordVP():void
		{
			var coord:CoordinatedPhraseElement = this.phraseFactory.createCoordinatedPhrase(this.getUp, this.fallDown);
			coord.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("got up and fell down", this.realiser.realise(coord).getRealisation());
	
			// add a premodifier
			coord.addPreModifierAsString("slowly");
			Assert.assertEquals("slowly got up and fell down", this.realiser.realise(coord).getRealisation());
	
			// adda postmodifier
			coord.addPostModifier(this.behindTheCurtain);
			Assert.assertEquals("slowly got up and fell down behind the curtain", this.realiser.realise(coord).getRealisation());
	
			// put within the context of a sentence
			var s:SPhraseSpec = this.phraseFactory.createClause("Jake", coord);
			s.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("Jake slowly got up and fell down behind the curtain", this.realiser.realise(s).getRealisation());
	
			// add premod to the sentence
			s.addPreModifier(this.lexicon.getWord("however", LexicalCategory.ADVERB));
			Assert.assertEquals("Jake however slowly got up and fell down behind the curtain", this.realiser.realise(s).getRealisation());
	
			// add postmod to the sentence
			s.addPostModifier(this.inTheRoom);
			Assert.assertEquals("Jake however slowly got up and fell down behind the curtain in the room", this.realiser.realise(s).getRealisation());
		}
	
		/**
		 * Test due to Chris Howell -- create a complex sentence with front modifier
		 * and coordinateVP. This is a version in which we create the coordinate
		 * phrase directly.
		 */
		[Test]
		public function testCoordinateVPComplexSubject():void
		{
			// "As a result of the procedure the patient had an adverse contrast media reaction and went into cardiogenic shock."
			var s:SPhraseSpec = this.phraseFactory.createClause();
	
			s.setSubject(this.phraseFactory.createNounPhrase("patient", "the"));
	
			// first VP
			var vp1:VPPhraseSpec = this.phraseFactory.createVerbPhrase(this.lexicon.getWord("have", LexicalCategory.VERB));
			var np1:NPPhraseSpec = this.phraseFactory.createNounPhrase(this.lexicon.getWord("contrast media reaction", LexicalCategory.NOUN), "a");
			np1.addPreModifier(this.lexicon.getWord("adverse", LexicalCategory.ADJECTIVE));
			vp1.addComplement(np1);
	
			// second VP
			var vp2:VPPhraseSpec = this.phraseFactory.createVerbPhrase(this.lexicon.getWord("go", LexicalCategory.VERB));
			var pp:PPPhraseSpec = this.phraseFactory.createPrepositionPhrase("into", this.lexicon.getWord("cardiogenic shock", LexicalCategory.NOUN));
			vp2.addComplement(pp);
	
			// coordinate
			var coord:CoordinatedPhraseElement = this.phraseFactory.createCoordinatedPhrase(vp1, vp2);
			coord.setFeature(Feature.TENSE, Tense.PAST);
			Assert.assertEquals("had an adverse contrast media reaction and went into cardiogenic shock", this.realiser.realise(coord).getRealisation());
	
			// now put this in the sentence
			s.setVerbPhrase(coord);
			s.addFrontModifierAsString("As a result of the procedure");
			Assert.assertEquals("As a result of the procedure the patient had an adverse contrast media reaction and went into cardiogenic shock", this.realiser.realise(s).getRealisation());
	
		}
	
		/**
		 * Test setting a conjunction to null
		 */
		public function testNullConjunction():void
		{
			var p:SPhraseSpec = this.phraseFactory.createClause("I", "be", "happy");
			var q:SPhraseSpec = this.phraseFactory.createClause("I", "eat", "fish");
			var pq:CoordinatedPhraseElement = this.phraseFactory.createCoordinatedPhrase();
			pq.addCoordinate(p);
			pq.addCoordinate(q);
			pq.setFeature(Feature.CONJUNCTION, "");
	
			//should come out without conjunction
			Assert.assertEquals("I am happy I eat fish", this.realiser.realise(pq).getRealisation());
			
			//should come out without conjunction
			pq.setFeature(Feature.CONJUNCTION, null);
			Assert.assertEquals("I am happy I eat fish", this.realiser.realise(pq).getRealisation());
	
		}
	}
}
