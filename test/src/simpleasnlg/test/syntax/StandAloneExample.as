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
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.StringElement;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.lexicon.Lexicon;
	import simpleasnlg.lexicon.XMLLexicon;
	import simpleasnlg.phrasespec.AdjPhraseSpec;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.PPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.realiser.english.Realiser;
	
	/**
	 * @author D. Westwater, Data2Text Ltd
	 *
	 */
	public class StandAloneExample
	{
		/**
		 * @param args
		 */
		public static function main(args:Vector.<String>):void
		{
			// below is a simple complete example of using simplenlg V4
			// afterwards is an example of using simplenlg just for morphology
			
			// set up
			var lexicon:Lexicon = new XMLLexicon();                          // default simplenlg lexicon
			var nlgFactory:NLGFactory = new NLGFactory(lexicon);             // factory based on lexicon
	
			// create sentences
			// 	"John did not go to the bigger park. He played football there."
			var thePark:NPPhraseSpec = nlgFactory.createNounPhrase("park", "the");   // create an NP
			var bigp:AdjPhraseSpec = nlgFactory.createAdjectivePhrase("big");        // create AdjP
			bigp.setFeature(Feature.IS_COMPARATIVE, true);                       // use comparative form ("bigger")
			thePark.addModifier(bigp);                                        // add adj as modifier in NP
			// above relies on default placement rules.  You can force placement as a premodifier
			// (before head) by using addPreModifier
			var toThePark:PPPhraseSpec = nlgFactory.createPrepositionPhrase("to");    // create a PP
			toThePark.setObject(thePark);                                     // set PP object
			// could also just say nlgFactory.createPrepositionPhrase("to", the Park);
	
			var johnGoToThePark:SPhraseSpec = nlgFactory.createClause("John", "go", toThePark);
	
			johnGoToThePark.setFeature(Feature.TENSE,Tense.PAST);              // set tense
			johnGoToThePark.setFeature(Feature.NEGATED, true);                 // set negated
			
			// note that constituents (such as subject and object) are set with setXXX methods
			// while features are set with setFeature
	
			// create a sentence DocumentElement from SPhraseSpec
			var sentence:DocumentElement = nlgFactory.createSentenceWithElement(johnGoToThePark);
	
			// below creates a sentence DocumentElement by concatenating strings
			var hePlayed:StringElement = new StringElement("he played");        
			var there:StringElement = new StringElement("there");
			var football:WordElement = new WordElement("football");
	
			var sentence2:DocumentElement = nlgFactory.createSentence();
			sentence2.addComponent(hePlayed);
			sentence2.addComponent(football);
			sentence2.addComponent(there);
	
			// now create a paragraph which contains these sentences
			var paragraph:DocumentElement = nlgFactory.createParagraph();
			paragraph.addComponent(sentence);
			paragraph.addComponent(sentence2);
	
			// create a realiser.  Note that a lexicon is specified, this should be
			// the same one used by the NLGFactory
			var realiser:Realiser = new Realiser(lexicon);
			//realiser.setDebugMode(true);     // uncomment this to print out debug info during realisation
			var realised:NLGElement = realiser.realise(paragraph);
	
			trace(realised.getRealisation());
	
			// end of main example
			
			// second example - using simplenlg just for morphology
			// below is clumsy as direct access to morphology isn't properly supported in V4.2
			// hopefully will be better supported in later versions
		
			// get word element for "child"
			var word:WordElement = WordElement(nlgFactory.createWord("child", LexicalCategory.NOUN));
			// create InflectedWordElement from word element
			var inflectedWord:InflectedWordElement = new InflectedWordElement(word);
			// set the inflected word to plural
			inflectedWord.setPlural(true);
			// realise the inflected word
			var result:String = realiser.realise(inflectedWord).getRealisation();
			
			trace(result);
		}
	}
}
