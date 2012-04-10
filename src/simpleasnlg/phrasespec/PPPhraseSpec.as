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
	
	
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	
	/**
	 * <p>
	 * This class defines a prepositional phrase.  It is essentially
	 * a wrapper around the <code>PhraseElement</code> class, with methods
	 * for setting common constituents such as object.
	 * For example, the <code>setPreposition</code> method in this class sets
	 * the head of the element to be the specified preposition
	 *
	 * From an API perspective, this class is a simplified version of the PPPhraseSpec
	 * class in simplenlg V3.  It provides an alternative way for creating syntactic
	 * structures, compared to directly manipulating a V4 <code>PhraseElement</code>.
	 * 
	 * Methods are provided for setting and getting the following constituents:
	 * <UL>
	 * <LI>Preposition		(eg, "in")
	 * <LI>Object     (eg, "the shop")
	 * </UL>
	 * 
	 * NOTE: PPPhraseSpec do not usually have modifiers or (user-set) features
	 * 
	 * <code>PPPhraseSpec</code> are produced by the <code>createPrepositionalPhrase</code>
	 * method of a <code>PhraseFactory</code>
	 * </p>
	 * 
	 * @author E. Reiter, University of Aberdeen.
	 * @version 4.1
	 * 
	 */
	public class PPPhraseSpec extends PhraseElement
	{
		public function PPPhraseSpec(phraseFactory:NLGFactory)
		{
			super(PhraseCategory.PREPOSITIONAL_PHRASE);
			this.setFactory(phraseFactory);
		}
		
		/** sets the preposition (head) of a prepositional phrase
		 * @param preposition
		 */
		public function setPreposition(preposition:Object):void
		{
			if (preposition is NLGElement)
			{
				setHead(preposition);
			} else {
				// create noun as word
				var prepositionalElement:NLGElement = getFactory().createWord(preposition, LexicalCategory.PREPOSITION);
	
				// set head of NP to nounElement
				setHead(prepositionalElement);
			}
		}
	
		/**
		 * @return preposition (head) of prepositional phrase
		 */
		public function getPreposition():NLGElement
		{
			return getHead();
		}
		
		/** Sets the  object of a PP
		 *
		 * @param object
		 */
		public function setObject(object:Object):void
		{
			var objectPhrase:PhraseElement = getFactory().createNounPhrase(object);
			objectPhrase.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
			addComplement(objectPhrase);
		}
		
		/**
		 * @return object of PP (assume only one)
		 */
		public function getObject():NLGElement
		{
			var complements:Array = getFeatureAsElementList(InternalFeature.COMPLEMENTS);
			var len:int = complements.length;
			for (var i:int = 0; i < len; i++)
			{
				var complement:NLGElement = complements[i];
				if (complement.getFeature(InternalFeature.DISCOURSE_FUNCTION) == DiscourseFunction.OBJECT) return complement;
			}
			
			return null;
		}
	}
}
