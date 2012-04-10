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
package simpleasnlg.syntax.english
{
	import simpleasnlg.features.Feature;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.ElementCategory;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGModule;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.WordElement;
	
	/**
	 * <p>
	 * This is the processor for handling syntax within the simpleasnlg. The processor
	 * translates phrases into lists of words.
	 * </p>
	 * 
	 * <p>
	 * All processing modules perform realisation on a tree of
	 * <code>NLGElement</code>s. The modules can alter the tree in whichever way
	 * they wish. For example, the syntax processor replaces phrase elements with
	 * list elements consisting of inflected words while the morphology processor
	 * replaces inflected words with string elements.
	 * </p>
	 * 
	 * <p>
	 * <b>N.B.</b> the use of <em>module</em>, <em>processing module</em> and
	 * <em>processor</em> is interchangeable. They all mean an instance of this
	 * class.
	 * </p>
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class SyntaxProcessor extends NLGModule {
	
		override public function initialise():void
		{
			// Do nothing
		}
	
		override public function realise(element:NLGElement):NLGElement
		{
			var realisedElement:NLGElement = null;
	
			if (element != null && !element.getFeatureAsBoolean(Feature.ELIDED))
			{
				if (element is DocumentElement)
				{
					var children:Array = element.getChildren();
					DocumentElement(element).setComponents(realiseList(children));
					realisedElement = element;
				}
				else if (element is PhraseElement)
				{
					realisedElement = realisePhraseElement(PhraseElement(element));
				}
				else if (element is ListElement)
				{
					realisedElement = new ListElement();
					ListElement(realisedElement).addComponents(realiseList(element.getChildren()));
				}
				else if (element is InflectedWordElement)
				{
					var baseForm:String = InflectedWordElement(element).getBaseForm();
					var category:ElementCategory = element.getCategory();
	
					if (this.lexicon != null && baseForm != null)
					{
						var word:WordElement = InflectedWordElement(element).getBaseWord();
	
						if (word == null)
						{
							if (category is LexicalCategory)
							{
								word = this.lexicon.lookupWord(baseForm, LexicalCategory(category));
							} else {
								word = this.lexicon.lookupWord(baseForm);
							}
						}
	
						if (word != null)
						{
							InflectedWordElement(element).setBaseWord(word);						
						}
					}
	
					realisedElement = element;
				}
				else if (element is WordElement)
				{
					// AG: need to check if it's a word element, in which case it
					// needs to be marked for inflection
					var infl:InflectedWordElement = new InflectedWordElement(WordElement(element));
	
					// // the inflected word inherits all features from the base
					// word
					var featureNames:Array = element.getAllFeatureNames();
					for each (var featureName:String in featureNames)
					{
						infl.setFeatureByName(featureName, element.getFeatureByName(featureName));
					}
	
					realisedElement = realise(infl);
				}
				else if (element is CoordinatedPhraseElement)
				{
					realisedElement = CoordinatedPhraseHelper.realise(this, CoordinatedPhraseElement(element));
				} else {
					realisedElement = element;
				}
			}
	
			// Remove the spurious ListElements that have only one element.
			if (realisedElement is ListElement)
			{
				if (ListElement(realisedElement).size == 1)
				{
					realisedElement = ListElement(realisedElement).getFirst();
				}
			}
			
			return realisedElement;
		}
	
		override public function realiseList(elements:Array):Array
		{
			var realisedList:Array = new Array();
			var childRealisation:NLGElement = null;
	
			if (elements != null)
			{
				var len:int = elements.length;
				for (var i:int = 0; i < len; i++)
				{
					var eachElement:NLGElement = elements[i];
					if (eachElement != null)
					{
						childRealisation = realise(eachElement);
						if (childRealisation != null)
						{
							if (childRealisation is ListElement)
							{
								realisedList = realisedList.concat(ListElement(childRealisation).getChildren());
							} else {
								realisedList.push(childRealisation);
							}
						}
					}
				}
			}
			return realisedList;
		}
	
		/**
		 * Realises a phrase element.
		 * 
		 * @param phrase
		 *            the element to be realised
		 * @return the realised element.
		 */
		private function realisePhraseElement(phrase:PhraseElement):NLGElement
		{
			var realisedElement:NLGElement = null;
	
			if (phrase != null)
			{
				var category:ElementCategory = phrase.getCategory();
	
				if (category is PhraseCategory)
				{
					switch (category)
					{
						case PhraseCategory.CLAUSE:
							realisedElement = ClauseHelper.realise(this, phrase);
							break;
		
						case PhraseCategory.NOUN_PHRASE:
							realisedElement = NounPhraseHelper.realise(this, phrase);
							break;
		
						case PhraseCategory.VERB_PHRASE:
							realisedElement = VerbPhraseHelper.realise(this, phrase);
							break;
		
						case PhraseCategory.PREPOSITIONAL_PHRASE:
						case PhraseCategory.ADJECTIVE_PHRASE:
						case PhraseCategory.ADVERB_PHRASE:
							realisedElement = PhraseHelper.realise(this, phrase);
							break;
		
						default:
							realisedElement = phrase;
							break;
					}
				}
			}
			
			return realisedElement;
		}
	}
}
