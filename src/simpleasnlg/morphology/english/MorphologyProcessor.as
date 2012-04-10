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
package simpleasnlg.morphology.english
{
	
	
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.ElementCategory;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGModule;
	import simpleasnlg.framework.StringElement;
	import simpleasnlg.framework.WordElement;
	
	/**
	 * <p>
	 * This is the processor for handling morphology within the simpleasnlg. The
	 * processor inflects words form the base form depending on the features applied
	 * to the word. For example, <em>kiss</em> is inflected to <em>kissed</em> for
	 * past tense, <em>dog</em> is inflected to <em>dogs</em> for pluralisation.
	 * </p>
	 * 
	 * <p>
	 * As a matter of course, the processor will first use any user-defined
	 * inflection for the world. If no inflection is provided then the lexicon, if
	 * it exists, will be examined for the correct inflection. Failing this a set of
	 * very basic rules will be examined to inflect the word.
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
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class MorphologyProcessor extends NLGModule {
	
		override public function initialise():void
		{
			// Do nothing
		}
	
		
		override public function realise(element:NLGElement):NLGElement
		{
			var realisedElement:NLGElement  = null;
			var children:Array;
			
			if (element is InflectedWordElement)
			{
				realisedElement = doMorphology(InflectedWordElement(element));
	
			}
			else if (element is StringElement)
			{
				realisedElement = element;
			}
			else if (element is WordElement)
			{
				// AG: now retrieves the default spelling variant, not the baseform
				// String baseForm = ((WordElement) element).getBaseForm();
				var defaultSpell:String = WordElement(element).getDefaultSpellingVariant();
	
				if (defaultSpell != null)
				{
					realisedElement = new StringElement(defaultSpell);
				}
	
			}
			else if (element is DocumentElement)
			{
				children = element.getChildren();
				DocumentElement(element).setComponents(realiseList(children));
				realisedElement = element;
			}
			else if (element is ListElement)
			{
				realisedElement = new ListElement();
				ListElement(realisedElement).addComponents(realiseList(element.getChildren()));
	
			}
			else if (element is CoordinatedPhraseElement)
			{
				children = element.getChildren();
				CoordinatedPhraseElement(element).clearCoordinates();
	
				if (children != null && children.length > 0)
				{
					CoordinatedPhraseElement(element).addCoordinate( realise( children[0] ) );
	
					for (var index:int = 1; index < children.length; index++)
					{
						CoordinatedPhraseElement(element).addCoordinate(realise(children[index]));
					}
	
					realisedElement = element;
				}
	
			} else if (element != null) {
				realisedElement = element;
			}
	
			return realisedElement;
		}
	
		/**
		 * This is the main method for performing the morphology. It effectively
		 * examines the lexical category of the element and calls the relevant set
		 * of rules from <code>MorphologyRules</em>.
		 * 
		 * @param element
		 *            the <code>InflectedWordElement</code>
		 * @return an <code>NLGElement</code> reflecting the correct inflection for
		 *         the word.
		 */
		private function doMorphology(element:InflectedWordElement):NLGElement
		{
			var realisedElement:NLGElement = null;
			if (element.getFeatureAsBoolean(InternalFeature.NON_MORPH))
			{
				realisedElement = new StringElement(element.getBaseForm());
				realisedElement.setFeature(InternalFeature.DISCOURSE_FUNCTION,
						element.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			} else {
				var baseWord:NLGElement = element.getFeatureAsElement(InternalFeature.BASE_WORD);
	
				if (baseWord == null && this.lexicon != null)
				{
					baseWord = this.lexicon.lookupWord(element.getBaseForm());
				}
				var category:ElementCategory = element.getCategory();
				if (category is LexicalCategory)
				{
					switch (category)
					{
						case LexicalCategory.PRONOUN:
							realisedElement = MorphologyRules.doPronounMorphology(element);
							break;
		
						case LexicalCategory.NOUN:
							realisedElement = MorphologyRules.doNounMorphology(element, WordElement(baseWord));
							break;
		
						case LexicalCategory.VERB:
							realisedElement = MorphologyRules.doVerbMorphology(element, WordElement(baseWord));
							break;
		
						case LexicalCategory.ADJECTIVE:
							realisedElement = MorphologyRules.doAdjectiveMorphology(element, WordElement(baseWord));
							break;
		
						case LexicalCategory.ADVERB:
							realisedElement = MorphologyRules.doAdverbMorphology(element, WordElement(baseWord));
							break;
		
						default:
							realisedElement = new StringElement(element.getBaseForm());
							realisedElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, element.getFeature(InternalFeature.DISCOURSE_FUNCTION));
					}
				}
			}
			return realisedElement;
		}
	
		override public function realiseList(elements:Array):Array
		{
			var realisedElements:Array = new Array();
			var currentElement:NLGElement = null;
			var determiner:NLGElement = null;
	
			if (elements != null)
			{
				var len:int = elements.length;
				for (var i:int = 0; i < len; i++)
				{
					var eachElement:NLGElement = elements[i];
					currentElement = realise(eachElement);
	
					if (currentElement != null)
					{
						//pass the discourse function and appositive features -- important for orth processor
						currentElement.setFeature(Feature.APPOSITIVE, eachElement.getFeature(Feature.APPOSITIVE));
						var func:Object = eachElement.getFeature(InternalFeature.DISCOURSE_FUNCTION);
						
						if (func != null)
						{
							currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, func);
						}
						
						// realisedElements.push(realise(currentElement));
						realisedElements.push(currentElement);
	
						if (determiner == null && DiscourseFunction.SPECIFIER == currentElement.getFeature(InternalFeature.DISCOURSE_FUNCTION))
						{
							determiner = currentElement;
							determiner.setFeature(Feature.NUMBER, eachElement
									.getFeature(Feature.NUMBER));
							// MorphologyRules.doDeterminerMorphology(determiner,
							// currentElement.getRealisation());
	
						}
						else if (determiner != null)
						{
							if (currentElement is ListElement)
							{
								// list elements: ensure det matches first element
								var firstChild:NLGElement = (ListElement(currentElement)).getChildren()[0];
	
								if (firstChild != null)
								{
									//AG: need to check if child is a coordinate
									if (firstChild is CoordinatedPhraseElement)
									{
										MorphologyRules.doDeterminerMorphology(determiner, firstChild.getChildren()[0].getRealisation());
									} else {
										MorphologyRules.doDeterminerMorphology(determiner, firstChild.getRealisation());
									}
								}
	
							} else {
								// everything else: ensure det matches realisation
								MorphologyRules.doDeterminerMorphology(determiner, currentElement.getRealisation());
							}
	
							determiner = null;
						}
					}
				}
			}
	
			return realisedElements;
		}
	}
}
