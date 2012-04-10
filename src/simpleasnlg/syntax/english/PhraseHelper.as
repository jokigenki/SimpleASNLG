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
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	
	/**
	 * <p>
	 * This class contains static methods to help the syntax processor realise
	 * phrases.
	 * </p>
	 * 
	 * @author E. Reiter and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class PhraseHelper
	{
		/**
		 * The main method for realising phrases.
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
	
			if (phrase != null)
			{
				realisedElement = new ListElement();
	
				realiseList(parent, realisedElement, phrase.getPreModifiers(), DiscourseFunction.PRE_MODIFIER);
				realiseHead(parent, phrase, realisedElement);
				realiseComplements(parent, phrase, realisedElement);
	
				PhraseHelper.realiseList(parent, realisedElement, phrase.getPostModifiers(), DiscourseFunction.POST_MODIFIER);
			}
			
			return realisedElement;
		}
	
		/**
		 * Realises the complements of the phrase adding <em>and</em> where
		 * appropriate.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param realisedElement
		 *            the current realisation of the noun phrase.
		 */
		private static function realiseComplements(parent:SyntaxProcessor,
				phrase:PhraseElement, realisedElement:ListElement):void
		{
			var firstProcessed:Boolean = false;
			var currentElement:NLGElement = null;
	
			var list:Array = phrase.getFeatureAsElementList(InternalFeature.COMPLEMENTS)
			var len:int = list.length;
			for (var i:int = 0; i < len; i++)
			{
				var complement:NLGElement = list[i];
				currentElement = parent.realise(complement);
				if (currentElement != null)
				{
					currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.COMPLEMENT);
					if (firstProcessed)
					{
						realisedElement.addComponent(new InflectedWordElement("and", LexicalCategory.CONJUNCTION)); //$NON-NLS-1$
					} else {
						firstProcessed = true;
					}
					realisedElement.addComponent(currentElement);
				}
			}
		}
	
		/**
		 * Realises the head element of the phrase.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param realisedElement
		 *            the current realisation of the noun phrase.
		 */
		private static function realiseHead(parent:SyntaxProcessor, phrase:PhraseElement, realisedElement:ListElement):void
		{
			var head:NLGElement = phrase.getHead();
			if (head != null)
			{
				if (phrase.hasFeature(Feature.IS_COMPARATIVE))
				{
					head.setFeature(Feature.IS_COMPARATIVE, phrase.getFeature(Feature.IS_COMPARATIVE));
				}
				else if (phrase.hasFeature(Feature.IS_SUPERLATIVE))
				{
					head.setFeature(Feature.IS_SUPERLATIVE, phrase.getFeature(Feature.IS_SUPERLATIVE));
				}
				
				head = parent.realise(head);
				head.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.HEAD);
				realisedElement.addComponent(head);
			}
		}
	
		/**
		 * Iterates through a <code>List</code> of <code>NLGElement</code>s
		 * realisation each element and adding it to the on-going realisation of
		 * this clause.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param elementList
		 *            the <code>List</code> of <code>NLGElement</code>s to be
		 *            realised.
		 * @param function
		 *            the <code>DiscourseFunction</code> each element in the list is
		 *            to take. If this is <code>null</code> then the function is not
		 *            set and any existing discourse function is kept.
		 */
		public static function realiseList(parent:SyntaxProcessor, realisedElement:ListElement, elementList:Array, func:DiscourseFunction ):void
		{
			// AG: Change here: the original list structure is kept, i.e. rather
			// than taking the elements of the list and putting them in the realised
			// element, we now add the realised elements to a new list and put that
			// in the realised element list. This preserves constituency for
			// orthography and morphology processing later.
			var realisedList:ListElement = new ListElement();
			var currentElement:NLGElement = null;
			var len:int = elementList.length;
			for each (var eachElement:NLGElement in elementList)
			{
				currentElement = parent.realise(eachElement);
	
				if (currentElement != null)
				{
					currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, func);
					// realisedElement.addComponent(currentElement);
					
					if (eachElement.getFeatureAsBoolean(Feature.APPOSITIVE))
					{
						currentElement.setFeature(Feature.APPOSITIVE, true);
					}
					
					realisedList.addComponent(currentElement);
				}
			}
	
			if (realisedList.getChildren().length > 0)
			{
				realisedElement.addComponent(realisedList);
			}
		}
	
		/**
		 * Determines if the given phrase has an expletive as a subject.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> to be examined.
		 * @return <code>true</code> if the phrase has an expletive subject.
		 */
		public static function isExpletiveSubject(phrase:PhraseElement):Boolean
		{
			var subjects:Array = phrase.getFeatureAsElementList(InternalFeature.SUBJECTS);
			var expletive:Boolean = false;
	
			if (subjects.length == 1)
			{
				var subjectNP:NLGElement = subjects[0];
	
				if (subjectNP.isA(PhraseCategory.NOUN_PHRASE))
				{
					expletive = subjectNP.getFeatureAsBoolean(LexicalFeature.EXPLETIVE_SUBJECT);
				}
				else if (subjectNP.isA(PhraseCategory.CANNED_TEXT))
				{
					expletive = "there" == subjectNP.getRealisation().toLowerCase(); //$NON-NLS-1$
				}
			}
			return expletive;
		}
	}
}
