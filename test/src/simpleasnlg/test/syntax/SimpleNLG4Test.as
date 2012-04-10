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
	import flexunit.framework.TestCase;
	
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.lexicon.Lexicon;
	import simpleasnlg.lexicon.XMLLexicon;
	import simpleasnlg.phrasespec.VPPhraseSpec;
	import simpleasnlg.realiser.english.Realiser;
	
	/**
	 * This class is the base class for all JUnit simpleasnlg.test cases for
	 * simpleasnlg. It sets up a a JUnit fixture, i.e. the basic objects (basic
	 * constituents) that all other tests can use.
	 * @author agatt
	 */
	public class SimpleNLG4Test extends TestCase
	{
		/** The realiser. */
		public var realiser:Realiser;
	
		public var phraseFactory:NLGFactory;
		
		public var lexicon:Lexicon;
		
		/** The pro test2. */
		public var man:PhraseElement;
		public var woman:PhraseElement;
		public var dog:PhraseElement;
		public var boy:PhraseElement;
		public var np4:PhraseElement;
		public var np5:PhraseElement;
		public var np6:PhraseElement;
		public var proTest1:PhraseElement;
		public var proTest2:PhraseElement;
	
		/** The salacious. */
		public var beautiful:PhraseElement;
		public var stunning:PhraseElement;
		public var salacious:PhraseElement;
	
		/** The under the table. */
		public var onTheRock:PhraseElement;
		public var behindTheCurtain:PhraseElement;
		public var inTheRoom:PhraseElement;
		public var underTheTable:PhraseElement;
	
		/** The say. */
		public var kick:VPPhraseSpec;
		public var kiss:VPPhraseSpec;
		public var walk:VPPhraseSpec;
		public var talk:VPPhraseSpec;
		public var getUp:VPPhraseSpec;
		public var fallDown:VPPhraseSpec;
		public var give:VPPhraseSpec;
		public var say:VPPhraseSpec;
	
		/**
		 * Instantiates a new simplenlg test.
		 * 
		 * @param name
		 *            the name
		 */
		public function SimpleNLG4Test(name:String = null)
		{
			super(name);
		}
	
		/**
		 * Set up the variables we'll need for this simpleasnlg.test to run (Called
		 * automatically by JUnit)
		 */
		//@Before
		override public function setUp():void
		{
			//this.lexicon = new NIHDBLexicon("A:\\corpora\\LEX\\lexAccess2011\\data\\HSqlDb\\lexAccess2011.data"); // NIH lexicon
			//lexicon = new XMLLexicon("E:\\NIHDB\\default-lexicon.xml");    // default XML lexicon
			lexicon = Lexicon.getDefaultLexicon();  // built in lexicon
			this.phraseFactory = new NLGFactory(this.lexicon);
			this.realiser = new Realiser(this.lexicon);
			//this.realiser.setDebugMode(true);
			
			this.man = this.phraseFactory.createNounPhrase("man", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.woman = this.phraseFactory.createNounPhrase("woman", "the");  //$NON-NLS-1$//$NON-NLS-2$
			this.dog = this.phraseFactory.createNounPhrase("dog", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.boy = this.phraseFactory.createNounPhrase("boy", "the"); //$NON-NLS-1$ //$NON-NLS-2$
	
			this.beautiful = this.phraseFactory.createAdjectivePhrase("beautiful"); //$NON-NLS-1$
			this.stunning = this.phraseFactory.createAdjectivePhrase("stunning"); //$NON-NLS-1$
			this.salacious = this.phraseFactory.createAdjectivePhrase("salacious"); //$NON-NLS-1$
	
			this.onTheRock = this.phraseFactory.createPrepositionPhrase("on"); //$NON-NLS-1$
			this.np4 = this.phraseFactory.createNounPhrase("rock", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.onTheRock.addComplement(this.np4);
	
			this.behindTheCurtain = this.phraseFactory.createPrepositionPhrase("behind"); //$NON-NLS-1$
			this.np5 = this.phraseFactory.createNounPhrase("curtain", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.behindTheCurtain.addComplement(this.np5);
	
			this.inTheRoom = this.phraseFactory.createPrepositionPhrase("in"); //$NON-NLS-1$
			this.np6 = this.phraseFactory.createNounPhrase("room", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.inTheRoom.addComplement(this.np6);
	
			this.underTheTable = this.phraseFactory.createPrepositionPhrase("under"); //$NON-NLS-1$
			this.underTheTable.addComplement(this.phraseFactory.createNounPhrase("table", "the")); //$NON-NLS-1$ //$NON-NLS-2$
	
			this.proTest1 = this.phraseFactory.createNounPhrase("singer", "the"); //$NON-NLS-1$ //$NON-NLS-2$
			this.proTest2 = this.phraseFactory.createNounPhrase("person", "some"); //$NON-NLS-1$ //$NON-NLS-2$
	
			this.kick = this.phraseFactory.createVerbPhrase("kick"); //$NON-NLS-1$
			this.kiss = this.phraseFactory.createVerbPhrase("kiss"); //$NON-NLS-1$
			this.walk = this.phraseFactory.createVerbPhrase("walk"); //$NON-NLS-1$
			this.talk = this.phraseFactory.createVerbPhrase("talk"); //$NON-NLS-1$
			this.getUp = this.phraseFactory.createVerbPhrase("get up"); //$NON-NLS-1$
			this.fallDown = this.phraseFactory.createVerbPhrase("fall down"); //$NON-NLS-1$
			this.give = this.phraseFactory.createVerbPhrase("give"); //$NON-NLS-1$
			this.say = this.phraseFactory.createVerbPhrase("say"); //$NON-NLS-1$
		}
	}
}
