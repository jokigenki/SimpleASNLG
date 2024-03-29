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

package simpleasnlg.phrasespec
{
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	/**
	 * <p>
	 * This class defines a adverbial phrase.  It is essentially
	 * a wrapper around the <code>PhraseElement</code> class, with methods
	 * for setting common constituents such as preModifier.
	 * For example, the <code>setAdverb</code> method in this class sets
	 * the head of the element to be the specified adverb
	 *
	 * From an API perspective, this class is a simplified version of the AdvPhraseSpec
	 * class in simplenlg V3.  It provides an alternative way for creating syntactic
	 * structures, compared to directly manipulating a V4 <code>PhraseElement</code>.
	 * 
	 * Methods are provided for setting and getting the following constituents:
	 * <UL>
	 * <LI>PreModifier		(eg, "very")
	 * <LI>Adverb        (eg, "quickly")
	 * </UL>
	 * 
	 * NOTE: AdvPhraseSpec do not usually have (user-set) features
	 * 
	 * <code>AdvPhraseSpec</code> are produced by the <code>createAdverbPhrase</code>
	 * method of a <code>PhraseFactory</code>
	 * </p>
	 * 
	 * @author E. Reiter, University of Aberdeen.
	 * @version 4.1
	 * 
	 */
	public class AdvPhraseSpec extends PhraseElement {
	
	
		public function AdvPhraseSpec(phraseFactory:NLGFactory)
		{
			super(PhraseCategory.ADVERB_PHRASE);
			this.setFactory(phraseFactory);
		}
	
		/** sets the adverb (head) of the phrase
		 * @param adverb
		 */
		public function setAdverb(adverb:Object):void
		{
			if (adverb is NLGElement)
				setHead(adverb);
			else {
				// create noun as word
				var adverbElement:NLGElement = getFactory().createWord(adverb, LexicalCategory.ADVERB);
	
				// set head of NP to nounElement
				setHead(adverbElement);
			}
		}
	
		/**
		 * @return adverb (head) of  phrase
		 */
		public function getAdverb():NLGElement
		{
			return getHead();
		}
		
		// inherit usual modifier routines
	}
}
