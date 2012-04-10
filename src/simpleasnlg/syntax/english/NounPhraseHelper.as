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
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Gender;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.features.Person;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.WordElement;
	
	/**
	 * <p>
	 * This class contains static methods to help the syntax processor realise noun
	 * phrases.
	 * </p>
	 * 
	 * @author E. Reiter and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class NounPhraseHelper
	{
		/** The qualitative position for ordering premodifiers. */
		private static const QUALITATIVE_POSITION:int = 1;
	
		/** The colour position for ordering premodifiers. */
		private static const COLOUR_POSITION:int = 2;
	
		/** The classifying position for ordering premodifiers. */
		private static const CLASSIFYING_POSITION:int = 3;
	
		/** The noun position for ordering premodifiers. */
		private static const NOUN_POSITION:int = 4;
	
		/**
		 * The main method for realising noun phrases.
		 * 
		 * @param parent
		 *            the <code>SyntaxProcessor</code> that called this method.
		 * @param phrase
		 *            the <code>PhraseElement</code> to be realised.
		 * @return the realised <code>NLGElement</code>.
		 */
		public static function realise(parent:SyntaxProcessor, phrase:PhraseElement):NLGElement
		{
			var realisedElement:ListElement = null;
	
			if (phrase != null && !phrase.getFeatureAsBoolean(Feature.ELIDED))
			{
				realisedElement = new ListElement();
	
				if (phrase.getFeatureAsBoolean(Feature.PRONOMINAL))
				{
					realisedElement.addComponent(createPronoun(parent, phrase));
				} else {
					realiseSpecifier(phrase, parent, realisedElement);
					realisePreModifiers(phrase, parent, realisedElement);
					realiseHeadNoun(phrase, parent, realisedElement);
					PhraseHelper.realiseList(parent, realisedElement, phrase
							.getFeatureAsElementList(InternalFeature.COMPLEMENTS),
							DiscourseFunction.COMPLEMENT);
	
					PhraseHelper.realiseList(parent, realisedElement, phrase
							.getPostModifiers(), DiscourseFunction.POST_MODIFIER);
				}
			}
			return realisedElement;
		}
	
		/**
		 * Realises the head noun of the noun phrase.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the noun phrase.
		 */
		private static function realiseHeadNoun(phrase:PhraseElement,
				parent:SyntaxProcessor, realisedElement:ListElement):void
		{
			var headElement:NLGElement = phrase.getHead();
	
			if (headElement != null)
			{
				headElement.setFeature(Feature.ELIDED, phrase.getFeature(Feature.ELIDED));
				headElement.setFeature(LexicalFeature.GENDER, phrase.getFeature(LexicalFeature.GENDER));
				headElement.setFeature(InternalFeature.ACRONYM, phrase.getFeature(InternalFeature.ACRONYM));
				headElement.setFeature(Feature.NUMBER, phrase.getFeature(Feature.NUMBER));
				headElement.setFeature(Feature.PERSON, phrase.getFeature(Feature.PERSON));
				headElement.setFeature(Feature.POSSESSIVE, phrase.getFeature(Feature.POSSESSIVE));
				headElement.setFeature(Feature.PASSIVE, phrase.getFeature(Feature.PASSIVE));
				var currentElement:NLGElement = parent.realise(headElement);
				currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.SUBJECT);
				realisedElement.addComponent(currentElement);
			}
		}
	
		/**
		 * Realises the pre-modifiers of the noun phrase. Before being realised,
		 * pre-modifiers undergo some basic sorting based on adjective ordering.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the noun phrase.
		 */
		private static function realisePreModifiers(phrase:PhraseElement,
				parent:SyntaxProcessor, realisedElement:ListElement):void
		{
	
			var preModifiers:Array = phrase.getPreModifiers();
			if (phrase.getFeatureAsBoolean(Feature.ADJECTIVE_ORDERING))
			{
				preModifiers = sortNPPreModifiers(preModifiers);
			}
			PhraseHelper.realiseList(parent, realisedElement, preModifiers, DiscourseFunction.PRE_MODIFIER);
		}
	
		/**
		 * Realises the specifier of the noun phrase.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the noun phrase.
		 */
		private static function realiseSpecifier(phrase:PhraseElement,
				parent:SyntaxProcessor, realisedElement:ListElement):void
		{
			var specifierElement:NLGElement = phrase.getFeatureAsElement(InternalFeature.SPECIFIER);
	
			if (specifierElement != null && !phrase.getFeatureAsBoolean(InternalFeature.RAISED)
				&& !phrase.getFeatureAsBoolean(Feature.ELIDED))
			{
				if (!specifierElement.isA(LexicalCategory.PRONOUN))
				{
					specifierElement.setFeature(Feature.NUMBER, phrase.getFeature(Feature.NUMBER));
				}
				
				var currentElement:NLGElement = parent.realise(specifierElement);
				
				if (currentElement != null)
				{
					currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.SPECIFIER);
					realisedElement.addComponent(currentElement);
				}
			}
		}
	
		/**
		 * Sort the list of premodifiers for this noun phrase using adjective
		 * ordering (ie, "big" comes before "red")
		 * 
		 * @param originalModifiers
		 *            the original listing of the premodifiers.
		 * @return the sorted <code>List</code> of premodifiers.
		 */
		private static function sortNPPreModifiers(originalModifiers:Array):Array
		{
			var orderedModifiers:Array = null;
	
			if (originalModifiers == null || originalModifiers.length <= 1)
			{
				orderedModifiers = originalModifiers;
			} else {
				orderedModifiers = originalModifiers.concat();
				var changesMade:Boolean = false;
				do
				{
					changesMade = false;
					var len:int = orderedModifiers.length;
					for (var i:int = 0; i < len - 1; i++)
					{
						if (getMinPos(orderedModifiers[i]) > getMaxPos(orderedModifiers[i + 1]))
						{
							var temp:NLGElement = orderedModifiers[i];
							orderedModifiers[i] = orderedModifiers[i + 1];
							orderedModifiers[i + 1] = temp;
							changesMade = true;
						}
					}
				} while (changesMade == true);
			}
			return orderedModifiers;
		}
	
		/**
		 * Determines the minimim position at which this modifier can occur.
		 * 
		 * @param modifier
		 *            the modifier to be checked.
		 * @return the minimum position for this modifier.
		 */
		private static function getMinPos(modifier:NLGElement):int
		{
			var position:int = QUALITATIVE_POSITION;
	
			if (modifier.isA(LexicalCategory.NOUN) || modifier.isA(PhraseCategory.NOUN_PHRASE))
			{
				position = NOUN_POSITION;
			}
			else if (modifier.isA(LexicalCategory.ADJECTIVE) || modifier.isA(PhraseCategory.ADJECTIVE_PHRASE))
			{
				var adjective:WordElement = getHeadWordElement(modifier);
	
				if (adjective.getFeatureAsBoolean(LexicalFeature.QUALITATIVE))
				{
					position = QUALITATIVE_POSITION;
				}
				else if (adjective.getFeatureAsBoolean(LexicalFeature.COLOUR))
				{
					position = COLOUR_POSITION;
				} else if (adjective.getFeatureAsBoolean(LexicalFeature.CLASSIFYING))
				{
					position = CLASSIFYING_POSITION;
				}
			}
			return position;
		}
	
		/**
		 * Determines the maximim position at which this modifier can occur.
		 * 
		 * @param modifier
		 *            the modifier to be checked.
		 * @return the maximum position for this modifier.
		 */
		private static function getMaxPos(modifier:NLGElement):int
		{
			var position:int = NOUN_POSITION;
	
			if (modifier.isA(LexicalCategory.ADJECTIVE) || modifier.isA(PhraseCategory.ADJECTIVE_PHRASE))
			{
				var adjective:WordElement = getHeadWordElement(modifier);
	
				if (adjective.getFeatureAsBoolean(LexicalFeature.CLASSIFYING))
				{
					position = CLASSIFYING_POSITION;
				}
				else if (adjective.getFeatureAsBoolean(LexicalFeature.COLOUR))
				{
					position = COLOUR_POSITION;
				}
				else if (adjective.getFeatureAsBoolean(LexicalFeature.QUALITATIVE))
				{
					position = QUALITATIVE_POSITION;
				} else {
					position = CLASSIFYING_POSITION;
				}
			}
			return position;
		}
	
		/**
		 * Retrieves the correct representation of the word from the element. This
		 * method will find the <code>WordElement</code>, if it exists, for the
		 * given phrase or inflected word.
		 * 
		 * @param element
		 *            the <code>NLGElement</code> from which the head is required.
		 * @return the <code>WordElement</code>
		 */
		private static function getHeadWordElement(element:NLGElement):WordElement
		{
			var head:WordElement = null;
	
			if (element is WordElement)
			{
				head = WordElement(element);
			}
			else if (element is InflectedWordElement)
			{
				head = WordElement(element.getFeature(InternalFeature.BASE_WORD));
			}
			else if (element is PhraseElement)
			{
				head = getHeadWordElement(PhraseElement(element).getHead());
			}
					
			return head;
		}
	
		/**
		 * Creates the appropriate pronoun if the subject of the noun phrase is
		 * pronominal.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @return the <code>NLGElement</code> representing the pronominal.
		 */
		private static function createPronoun(parent:SyntaxProcessor,
				phrase:PhraseElement):NLGElement
		{
	
			var pronoun:String = "it"; //$NON-NLS-1$
			var phraseFactory:NLGFactory = phrase.getFactory();
			var personValue:Object = phrase.getFeature(Feature.PERSON);
	
			if (Person.FIRST == personValue)
			{
				pronoun = "I"; //$NON-NLS-1$
			}
			else if (Person.SECOND == personValue)
			{
				pronoun = "you"; //$NON-NLS-1$
			} else {
				var genderValue:Object = phrase.getFeature(LexicalFeature.GENDER);
				if (Gender.FEMININE == genderValue)
				{
					pronoun = "she"; //$NON-NLS-1$
				}
				else if (Gender.MASCULINE == genderValue)
				{
					pronoun = "he"; //$NON-NLS-1$
				}
			}
			// AG: createWord now returns WordElement; so we embed it in an
			// inflected word element here
			var element:NLGElement;
			var proElement:NLGElement = phraseFactory.createWord(pronoun, LexicalCategory.PRONOUN);
			
			if (proElement is WordElement)
			{
				element = new InflectedWordElement(WordElement(proElement));
				var wElement:WordElement = WordElement(proElement);
				element.setFeature(LexicalFeature.GENDER, wElement.getFeature(LexicalFeature.GENDER));	
				// Ehud - also copy over person
				element.setFeature(Feature.PERSON, wElement.getFeature(Feature.PERSON));	
			} else {
				element = proElement;
			}
			
			element.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.SPECIFIER);
			element.setFeature(Feature.POSSESSIVE, phrase.getFeature(Feature.POSSESSIVE));
			element.setFeature(Feature.NUMBER, phrase.getFeature(Feature.NUMBER));
	
			
			if (phrase.hasFeature(InternalFeature.DISCOURSE_FUNCTION))
			{
				element.setFeature(InternalFeature.DISCOURSE_FUNCTION, phrase.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			}		
	
			return element;
		}
	}
}
