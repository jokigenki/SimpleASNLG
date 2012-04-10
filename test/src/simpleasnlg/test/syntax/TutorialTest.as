/*
 * 
 * Copyright (C) 2010, University of Aberdeen
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package simpleasnlg.test.syntax
{
	import flexunit.framework.Assert;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InterrogativeType;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.lexicon.Lexicon;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.PPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.phrasespec.VPPhraseSpec;
	import simpleasnlg.realiser.english.Realiser;
	
	/**
	 * Tests from tutorial
	 * <hr>
	 * 
	 * <p>
	 * Copyright (C) 2011, University of Aberdeen
	 * </p>
	 * 
	 * <p>
	 * This program is free software: you can redistribute it and/or modify it under
	 * the terms of the GNU Lesser General Public License as published by the Free Software
	 * Foundation, either version 3 of the License, or (at your option) any later
	 * version.
	 * </p>
	 * 
	 * <p>
	 * This program is distributed in the hope that it will be useful, but WITHOUT
	 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
	 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
	 * details.
	 * </p>
	 * 
	 * <p>
	 * You should have received a copy of the GNU Lesser General Public License in the zip
	 * file. If not, see <a
	 * href="http://www.gnu.org/licenses/">www.gnu.org/licenses</a>.
	 * </p>
	 * 
	 * <p>
	 * For more details on SimpleNLG visit the project website at <a
	 * href="http://www.csd.abdn.ac.uk/research/simplenlg/"
	 * >www.csd.abdn.ac.uk/research/simplenlg</a> or email Dr Ehud Reiter at
	 * e.reiter@abdn.ac.uk
	 * </p>
	 * 
	 * @author ereiter
	 * 
	 */
	public class TutorialTest extends SimpleNLG4Test
	{
		public function TutorialTest(name:String = null)
		{
			super(name);
		}
	
	
		// no code in sections 1 and 2
		
		/**
		 * test section 3 code
		 */
		[Test]
		public function testSection3():void
		{
			var lexicon:Lexicon = Lexicon.getDefaultLexicon();                         // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory(lexicon);             // factory based on lexicon
	
			var s1:NLGElement = nlgFactory.createCannedSentence("my dog is happy");
			
			var r:Realiser = new Realiser(lexicon);
			
			var output:String = r.realiseSentence(s1);
			
			Assert.assertEquals("My dog is happy.", output);
		 }
		
		/**
		 * test section 5 code
		 */
		[Test]
		public function testSection5():void
		{
			var lexicon:Lexicon = Lexicon.getDefaultLexicon();                         // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory(lexicon);             // factory based on lexicon
			var realiser:Realiser = new Realiser(lexicon);
			
			var p:SPhraseSpec = nlgFactory.createClause();
			p.setSubject("my dog");
			p.setVerb("chase");
			p.setObject("George");
			
			var output:String = realiser.realiseSentence(p);
			Assert.assertEquals("My dog chases George.", output);
		 }
		
		/**
		 * test section 6 code
		 */
		[Test]
		public function testSection6():void
		{
			var lexicon:Lexicon = Lexicon.getDefaultLexicon();                         // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory(lexicon);             // factory based on lexicon
			var realiser:Realiser = new Realiser(lexicon);
			
			var p:SPhraseSpec = nlgFactory.createClause();
			p.setSubject("Mary");
			p.setVerb("chase");
			p.setObject("George");
			
			p.setFeature(Feature.TENSE, Tense.PAST); 
			var output:String = realiser.realiseSentence(p);
			Assert.assertEquals("Mary chased George.", output);
	
			p.setFeature(Feature.TENSE, Tense.FUTURE); 
			output = realiser.realiseSentence(p);
			Assert.assertEquals("Mary will chase George.", output);
	
			p.setFeature(Feature.NEGATED, true); 
			output = realiser.realiseSentence(p);
			Assert.assertEquals("Mary will not chase George.", output);
	
			p = nlgFactory.createClause();
			p.setSubject("Mary");
			p.setVerb("chase");
			p.setObject("George");
	 
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO);
			output = realiser.realiseSentence(p);
			Assert.assertEquals("Does Mary chase George?", output);
	
			p.setSubject("Mary");
			p.setVerb("chase");
			p.setFeature(Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT);
			output = realiser.realiseSentence(p);
			Assert.assertEquals("Who does Mary chase?", output);
	
			p = nlgFactory.createClause();
			p.setSubject("the dog");
			p.setVerb("wake up");
			output = realiser.realiseSentence(p);
			Assert.assertEquals("The dog wakes up.", output);
	
		 }
		
		/**
		 * test ability to use variant words
		 */
		[Test]
		public function testVariants():void
		{
			var lexicon:Lexicon = Lexicon.getDefaultLexicon();                         // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory(lexicon);             // factory based on lexicon
			var realiser:Realiser = new Realiser(lexicon);
			
			var p:SPhraseSpec = nlgFactory.createClause();
			p.setSubject("my dog");
			p.setVerb("is");  // variant of be
			p.setObject("George");
			
			var output:String = realiser.realiseSentence(p);
			Assert.assertEquals("My dog is George.", output);
			
			p = nlgFactory.createClause();
			p.setSubject("my dog");
			p.setVerb("chases");  // variant of chase
			p.setObject("George");
			
			output = realiser.realiseSentence(p);
			Assert.assertEquals("My dog chases George.", output);
	
	        p = nlgFactory.createClause();
			p.setSubject(nlgFactory.createNounPhrase("dog", "the"));   // variant of "dog"
			p.setVerb("is");  // variant of be
			p.setObject("happy");  // variant of happy
			output = realiser.realiseSentence(p);
			Assert.assertEquals("The dog is happy.", output);
			
			p = nlgFactory.createClause();
			p.setSubject(nlgFactory.createNounPhrase("dog", "the"));   // variant of "dog"
			p.setVerb("are");  // variant of be - correct to singular
			p.setObject("happy");  // variant of happy
			output = realiser.realiseSentence(p);
			Assert.assertEquals("The dog is happy.", output);
			
			p = nlgFactory.createClause();
			p.setSubject(nlgFactory.createNounPhrase("children", "the"));   // variant of "child"
			p.setVerb("is");  // variant of be
			p.setObject("happy");  // variant of happy
			output = realiser.realiseSentence(p);
			Assert.assertEquals("The children are happy.", output);
	
			// following functionality is enabled
			p = nlgFactory.createClause();
			p.setSubject(nlgFactory.createNounPhrase("dogs", "the"));   // variant of "dog"
			p.setVerb("is");  // variant of be
			p.setObject("happy");  // variant of happy
			output = realiser.realiseSentence(p);
			Assert.assertEquals("The dogs are happy.", output); //not changed to "The dog is happy"
		}
			
		/* Following code tests the section 5 to 15
		 * sections 5 & 6 are repeated here in order to match the simplenlg tutorial version 4
		 * James Christie
		 * June 2011
		 */
	
		/**
		 * test section 5 to match simplenlg tutorial version 4's code
		 */
		[Test]
		public function testSection5A():void
		{ 
			var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;      // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
			var realiser:Realiser = new Realiser( lexicon ) ;
			
			var p:SPhraseSpec = nlgFactory.createClause( ) ;
			p.setSubject( "Mary" ) ;
			p.setVerb( "chase" ) ;
			p.setObject( "the monkey" ) ;
			
			var output:String = realiser.realiseSentence( p ) ;
			Assert.assertEquals( "Mary chases the monkey.", output ) ;
		 } // testSection5A
		
		/**
		 * test section 6 to match simplenlg tutorial version 4' code
		 */
		[Test]
		public function testSection6A():void
		{ 
			var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;    // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
			var realiser:Realiser = new Realiser( lexicon ) ;
		
			var p:SPhraseSpec = nlgFactory.createClause( ) ;
			p.setSubject( "Mary" ) ;
			p.setVerb( "chase" ) ;
			p.setObject( "the monkey" ) ;
		
			p.setFeature( Feature.TENSE, Tense.PAST ) ; 
			var output:String = realiser.realiseSentence( p ) ;
			Assert.assertEquals( "Mary chased the monkey.", output ) ;
	
			p.setFeature( Feature.TENSE, Tense.FUTURE ) ; 
			output = realiser.realiseSentence( p ) ;
			Assert.assertEquals( "Mary will chase the monkey.", output ) ;
	
			p.setFeature( Feature.NEGATED, true ) ; 
			output = realiser.realiseSentence( p ) ;
			Assert.assertEquals( "Mary will not chase the monkey.", output ) ;
	
			p = nlgFactory.createClause( ) ;
			p.setSubject( "Mary" ) ;
			p.setVerb( "chase" ) ;
			p.setObject( "the monkey" ) ;
	
			p.setFeature( Feature.INTERROGATIVE_TYPE, InterrogativeType.YES_NO ) ;
			output = realiser.realiseSentence( p ) ;
			Assert.assertEquals( "Does Mary chase the monkey?", output ) ;
	
			p.setSubject( "Mary" ) ;
			p.setVerb( "chase" ) ;
			p.setFeature( Feature.INTERROGATIVE_TYPE, InterrogativeType.WHO_OBJECT ) ;
			output = realiser.realiseSentence( p ) ;
			Assert.assertEquals( "Who does Mary chase?", output ) ;
		} // textSection6A
		
		/**
		 * test section 7 code
		 */
		[Test]
			public function testSection7():void
			{ 
				var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;      // default simplenlg lexicon
				var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
				var realiser:Realiser = new Realiser( lexicon ) ;
				
				var p:SPhraseSpec = nlgFactory.createClause( ) ;
				p.setSubject( "Mary" ) ;
				p.setVerb( "chase" ) ;
				p.setObject( "the monkey" ) ;
				p.addComplementAsString( "very quickly" ) ;
				p.addComplementAsString( "despite her exhaustion" ) ;
				
				var output:String = realiser.realiseSentence( p ) ;
				Assert.assertEquals( "Mary chases the monkey very quickly despite her exhaustion.", output ) ;
			 } // testSection7
		
		/**
		 * test section 8 code
		 */
		[Test]
			public function testSection8():void
			{ 
				var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;      // default simplenlg lexicon
				var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
				var realiser:Realiser = new Realiser( lexicon ) ;
				
				var subject:NPPhraseSpec = nlgFactory.createNounPhrase( "Mary" ) ;
				var object:NPPhraseSpec = nlgFactory.createNounPhrase( "the monkey" ) ;
				var verb:VPPhraseSpec = nlgFactory.createVerbPhrase( "chase" ) ; ;
				subject.addModifierAsString( "fast" ) ;
				
				var p:SPhraseSpec = nlgFactory.createClause( ) ;
				p.setSubject( subject ) ;
				p.setVerb( verb ) ;
				p.setObject( object ) ;
				
				var outputA:String = realiser.realiseSentence( p ) ;
				Assert.assertEquals( "Fast Mary chases the monkey.", outputA ) ;
				
				verb.addModifierAsString( "quickly" ) ;
				
				var outputB:String = realiser.realiseSentence( p ) ;
				Assert.assertEquals( "Fast Mary quickly chases the monkey.", outputB ) ;
			 } // testSection8
		
		// there is no code specified in section 9
		
		/**
		 * test section 10 code
		 */
		[Test]
			public function testSection10():void
			{ 
				var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;      // default simplenlg lexicon
				var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
				var realiser:Realiser = new Realiser( lexicon ) ;
				
				var subject1:NPPhraseSpec = nlgFactory.createNounPhrase( "Mary" ) ;
				var subject2:NPPhraseSpec = nlgFactory.createNounPhrase( "giraffe", "your" ) ;
				
				// next line is not correct ~ should be nlgFactory.createCoordinatedPhrase ~ may be corrected in the API
				var subj:CoordinatedPhraseElement = nlgFactory.createCoordinatedPhrase( subject1, subject2 ) ;
				
				var verb:VPPhraseSpec = nlgFactory.createVerbPhrase( "chase" ) ; ;
	
				var p:SPhraseSpec = nlgFactory.createClause( ) ;
				p.setSubject( subj ) ;
				p.setVerb( verb ) ;
				p.setObject( "the monkey" ) ;
				
				var outputA:String = realiser.realiseSentence( p ) ;
				Assert.assertEquals( "Mary and your giraffe chase the monkey.", outputA ) ;
				
				var object1:NPPhraseSpec = nlgFactory.createNounPhrase( "the monkey" ) ;
				var object2:NPPhraseSpec = nlgFactory.createNounPhrase( "George" ) ;
				
				// next line is not correct ~ should be nlgFactory.createCoordinatedPhrase ~ may be corrected in the API
				var obj:CoordinatedPhraseElement = nlgFactory.createCoordinatedPhrase( object1, object2 ) ;
				obj.addCoordinate( "Martha" ) ;
				p.setObject( obj ) ;
				
				var outputB:String = realiser.realiseSentence( p ) ;
				Assert.assertEquals( "Mary and your giraffe chase the monkey, George and Martha.", outputB ) ;	
	
				obj.setFeature( Feature.CONJUNCTION, "or" ) ;
				
				var outputC:String = realiser.realiseSentence( p ) ;
				Assert.assertEquals( "Mary and your giraffe chase the monkey, George or Martha.", outputC ) ;	
		} // testSection10
		
		/**
		 * test section 11 code
		 */
		//@SuppressWarnings({ "deprecation" })
		[Test]
		public function testSection11( ):void
		{
			var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;     // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
	
			var realiser:Realiser = new Realiser( lexicon ) ;
			
			var pA:SPhraseSpec = nlgFactory.createClause( "Mary", "chase", "the monkey" ) ;
			pA.addComplementAsString( "in the park" ) ;
			
			var outputA:String = realiser.realiseSentence( pA ) ;		
			Assert.assertEquals( "Mary chases the monkey in the park.", outputA ) ;
			
			// alternative build paradigm
			var place:NPPhraseSpec = nlgFactory.createNounPhrase( "park" ) ;
			var pB:SPhraseSpec = nlgFactory.createClause( "Mary", "chase", "the monkey" ) ;
			
			place.setSpecifier( "the" );
			var pp:PPPhraseSpec = nlgFactory.createPrepositionPhrase( ) ;
			pp.addComplement( place ) ;
			pp.setPreposition( "in" ) ;
			
			pB.addComplement( pp ) ;
			
			var outputB:String = realiser.realiseSentence( pB ) ;		
			Assert.assertEquals( "Mary chases the monkey in the park.", outputB ) ;	
			
			place.addPreModifierAsString( "leafy" ) ;
			
			var outputC:String = realiser.realiseSentence( pB ) ;		
			Assert.assertEquals( "Mary chases the monkey in the leafy park.", outputC ) ;	
		 } // testSection11
	
		// section12 only has a code table as illustration
		
		/**
		 * test section 13 code
		 */
		[Test]
		public function testSection13( ):void
		{
			var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;     // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
	
			var realiser:Realiser = new Realiser( lexicon ) ;
		
			var s1:SPhraseSpec = nlgFactory.createClause( "my cat",   "like", "fish"  ) ;
			var s2:SPhraseSpec = nlgFactory.createClause( "my dog",  "like",  "big bones" ) ;
			var s3:SPhraseSpec = nlgFactory.createClause( "my horse", "like", "grass" ) ;		
			
			var c:CoordinatedPhraseElement = nlgFactory.createCoordinatedPhrase( ) ;
			c.addCoordinate( s1 ) ;
			c.addCoordinate( s2 ) ; // gives the wrong result ~ should be 'bones' but get 'bone' !
			c.addCoordinate( s3 ) ;
			
			var outputA:String = realiser.realiseSentence( c ) ;
			Assert.assertEquals( "My cat likes fish, my dog likes big bones and my horse likes grass.", outputA ) ;
			
			var p:SPhraseSpec = nlgFactory.createClause( "I", "be",  "happy" ) ;
			var q:SPhraseSpec = nlgFactory.createClause( "I", "eat", "fish" ) ;
			q.setFeature( Feature.COMPLEMENTISER, "because" ) ;
			q.setFeature( Feature.TENSE, Tense.PAST ) ;
			p.addComplement( q ) ;
			
			var outputB:String = realiser.realiseSentence( p ) ;
			Assert.assertEquals( "I am happy because I ate fish.", outputB ) ;
		} // testSection13
		
		/**
		 * test section 14 code
		 */
		[Test]
		public function testSection14( ):void
		{
			var lexicon:Lexicon = Lexicon.getDefaultLexicon( ) ;     // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory( lexicon ) ;  // factory based on lexicon
	
			var realiser:Realiser = new Realiser( lexicon ) ;
		
			var p1:SPhraseSpec = nlgFactory.createClause( "Mary", "chase", "the monkey" ) ;
			var p2:SPhraseSpec = nlgFactory.createClause( "The monkey", "fight back" ) ;
			var p3:SPhraseSpec = nlgFactory.createClause( "Mary", "be", "nervous" ) ;
			
			var s1:DocumentElement = nlgFactory.createSentenceWithElement( p1 ) ;
			var s2:DocumentElement = nlgFactory.createSentenceWithElement( p2 ) ;
			var s3:DocumentElement = nlgFactory.createSentenceWithElement( p3 ) ;
			
			var par1:DocumentElement = nlgFactory.createParagraph( [s1, s2, s3] ) ;
			
			var output14a:String = realiser.realise( par1 ).getRealisation() ;
			Assert.assertEquals( "Mary chases the monkey. The monkey fights back. Mary is nervous.\n\n", output14a ) ;
			//   actual output ~  Mary chases the monkey. The monkey fights back. Mary is nervous.
			// So what exactly is JUnit not happy about?
	 
			var section:DocumentElement = nlgFactory.createSection( "The Trials and Tribulation of Mary and the Monkey" ) ;
	        section.addComponent( par1 ) ;
	        var output14b:String = realiser.realise( section ).getRealisation() ;
	        Assert.assertEquals( "The Trials and Tribulation of Mary and the Monkey\nMary chases the monkey. The monkey fights back. Mary is nervous.\n\n", output14b ) ;
		} // testSection14
	
	} // class
}