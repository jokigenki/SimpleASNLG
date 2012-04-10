package simpleasnlg.test.lexicon
{
	import flexunit.framework.TestCase;
	
	
	import org.flexunit.Assert;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Inflection;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.lexicon.Lexicon;
	import simpleasnlg.lexicon.NIHDBLexicon;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.realiser.english.Realiser;
	
	/**
	 * Tests on the use of spelling and inflectional variants, using the
	 * NIHDBLexicon.
	 * 
	 * @author bertugatt
	 * 
	 */
	public class LexicalVariantsTests extends TestCase
	{
		// lexicon object -- an instance of Lexicon
		//var lexicon:NIHDBLexicon = null;
		public var lexicon:Lexicon;
		
		// factory for phrases
		public var factory:NLGFactory;
	
		// realiser
		public var realiser:Realiser;
	
		// DB location -- change this to point to the lex access data dir
		public static const DB_FILENAME:String = "A:\\corpora\\LEX\\lexAccess2011\\data\\HSqlDb\\lexAccess2011";
	
		//@Override
		//@Before
		/*
		 * * Sets up the accessor and runs it -- takes ca. 26 sec
		 */
		override public function setUp():void
		{
			//this.lexicon = new NIHDBLexicon(DB_FILENAME);
			this.lexicon = Lexicon.getDefaultLexicon();
			this.factory = new NLGFactory(lexicon);
			this.realiser = new Realiser(this.lexicon);
		}
	
		/**
		 * Close the lexicon
		 */
		//@After
		override public function tearDown():void
		{
			super.tearDown();
	
			if (lexicon != null)
				lexicon.close();
		}
	
		/**
		 * check that spelling variants are properly set
		 */
		[Test]
		public function testSpellingVariants():void
		{
			var asd:WordElement = lexicon.getWord("Adams-Stokes disease");
			var spellVars:Array = asd.getFeatureAsStringList(LexicalFeature.SPELL_VARS.toString());
			Assert.assertTrue(spellVars.indexOf("Adams Stokes disease") > -1);
			Assert.assertTrue(spellVars.indexOf("Adam-Stokes disease") > -1);
			Assert.assertEquals(2, spellVars.length);
			Assert.assertEquals(asd.getBaseForm(), asd.getFeatureAsString(LexicalFeature.DEFAULT_SPELL));
	
			// default spell variant is baseform
			Assert.assertEquals("Adams-Stokes disease", asd
					.getDefaultSpellingVariant());
	
			// default spell variant changes
			asd.setDefaultSpellingVariant("Adams Stokes disease");
			Assert.assertEquals("Adams Stokes disease", asd
					.getDefaultSpellingVariant());
		}
	
		/**
		 * Test spelling/orthographic variants with different inflections
		 */
		[Test]
		public function testSpellingVariantWithInflection():void
		{
			var word:WordElement = lexicon.getWord("formalization");
			var spellVars:Array = word.getFeatureAsStringList(LexicalFeature.SPELL_VARS.toString());
			Assert.assertTrue(spellVars.indexOf("formalisation") > -1);
			Assert.assertEquals(Inflection.REGULAR, word.getDefaultInflectionalVariant());
	
			// create with default spelling
			var np:NPPhraseSpec = factory.createNounPhrase(word, "the");
			np.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			Assert.assertEquals("the formalizations", this.realiser.realise(np)
					.getRealisation());
	
			// reset spell var
			word.setDefaultSpellingVariant("formalisation");
			Assert.assertEquals("the formalisations", this.realiser.realise(np)
					.getRealisation());
		}
	
		/**
		 * Test the inflectional variants for a verb.
		 */
		[Test]
		public function testVerbInflectionalVariants():void
		{
			var word:WordElement = lexicon.getWord("lie", LexicalCategory.VERB);
			Assert.assertEquals(Inflection.REGULAR, word.getDefaultInflectionalVariant());
	
			// default past is "lied"
			var infl:InflectedWordElement = new InflectedWordElement(word);
			infl.setFeature(Feature.TENSE, Tense.PAST);
			var past:String = realiser.realise(infl).getRealisation();
			Assert.assertEquals("lied", past);
	
			// switch to irregular
			word.setDefaultInflectionalVariant(Inflection.IRREGULAR);
			infl = new InflectedWordElement(word);
			infl.setFeature(Feature.TENSE, Tense.PAST);
			past = realiser.realise(infl).getRealisation();
			Assert.assertEquals("lay", past);
	
			// switch back to regular
			word.setDefaultInflectionalVariant(Inflection.REGULAR);
			Assert.assertEquals(null, word.getFeature(LexicalFeature.PAST));
			infl = new InflectedWordElement(word);
			infl.setFeature(Feature.TENSE, Tense.PAST);
			past = realiser.realise(infl).getRealisation();
			Assert.assertEquals("lied", past);
		}
	
		/**
		 * Test inflectional variants for nouns
		 */
		[Test]
		public function testNounInflectionalVariants():void
		{
			var word:WordElement = lexicon.getWord("sanctum", LexicalCategory.NOUN);
			Assert.assertEquals(Inflection.REGULAR, word
					.getDefaultInflectionalVariant());
	
			// reg plural shouldn't be stored
			Assert.assertEquals(null, word.getFeature(LexicalFeature.PLURAL));
			var infl:InflectedWordElement = new InflectedWordElement(word);
			infl.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			var plur:String = realiser.realise(infl).getRealisation();
			Assert.assertEquals("sanctums", plur);
	
			// switch to glreg
			word.setDefaultInflectionalVariant(Inflection.GRECO_LATIN_REGULAR);
			infl = new InflectedWordElement(word);
			infl.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			plur = realiser.realise(infl).getRealisation();
			Assert.assertEquals("sancta", plur);
	
			// and back to reg
			word.setDefaultInflectionalVariant(Inflection.REGULAR);
			infl = new InflectedWordElement(word);
			infl.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			plur = realiser.realise(infl).getRealisation();
			Assert.assertEquals("sanctums", plur);
		}
	
		/**
		 * Check that spelling variants are preserved during realisation of NPs
		 */
		[Test]
		public function testSpellingVariantsInNP():void
		{
			var asd:WordElement = lexicon.getWord("Adams-Stokes disease");
			Assert.assertEquals("Adams-Stokes disease", asd.getDefaultSpellingVariant());
			var np:NPPhraseSpec = this.factory.createNounPhrase(asd);
			var thethe:WordElement = lexicon.getWord("the"); 
			np.setSpecifier(thethe);
			//this.realiser.setDebugMode(true);
			Assert.assertEquals("the Adams-Stokes disease", this.realiser.realise(np).getRealisation());
	
			// change spelling var
			asd.setDefaultSpellingVariant("Adams Stokes disease");
			Assert.assertEquals("Adams Stokes disease", asd.getDefaultSpellingVariant());
			Assert.assertEquals("the Adams Stokes disease", this.realiser.realise(np).getRealisation());
	
			np.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			Assert.assertEquals("the Adams Stokes diseases", this.realiser.realise(np).getRealisation());
		}
	
		/**
		 * Check that spelling variants are preserved during realisation of VPs
		 */
		[Test]
		public function testSpellingVariantsInVP():void
		{
			var eth:WordElement = WordElement(factory.createWord("etherise", LexicalCategory.VERB));
			Assert.assertEquals("etherize", eth.getDefaultSpellingVariant());
			eth.setDefaultSpellingVariant("etherise");
			Assert.assertEquals("etherise", eth.getDefaultSpellingVariant());
			var s:SPhraseSpec = this.factory.createClause(this.factory.createNounPhrase("doctor", "the"), eth, this.factory.createNounPhrase("the patient"));
			Assert.assertEquals("the doctor etherises the patient", this.realiser.realise(s).getRealisation());
		}
	
	}
}
