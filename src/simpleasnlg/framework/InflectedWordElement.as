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
package simpleasnlg.framework
{
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	
	/**
	 * <p>
	 * This class defines the <code>NLGElement</code> that is used to represent an
	 * word that requires inflection by the morphology. It has convenience methods
	 * for retrieving the base form of the word (for example, <em>kiss</em>,
	 * <em>eat</em>) and for setting and retrieving the base word. The base word is
	 * a <code>WordElement</code> constructed by the lexicon.
	 * </p>
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class InflectedWordElement extends NLGElement
	{
		/**
		 * Constructs a new inflected word using the giving word as the base form or Constructs a new inflected word from a WordElement
		 * Constructing the word also requires a lexical category (such as noun,
		 * verb).
		 * 
		 * @param word
		 *            the base form for this inflected word or underlying wordelement.
		 * @param category
		 *            the lexical category for the word.
		 *            
		 */
		public function InflectedWordElement(word:*, category:LexicalCategory = null):void
		{
			super();
			
			if (word is String)
			{
				setFeature(LexicalFeature.BASE_FORM, word);
				setCategory(category);
			}
			else if (word is WordElement)
			{
				setFeature(InternalFeature.BASE_WORD, word);
				// AG: changed to use the default spelling variant
				// setFeature(LexicalFeature.BASE_FORM, word.getBaseForm());
				var defaultSpelling:String = word.getDefaultSpellingVariant();
				setFeature(LexicalFeature.BASE_FORM, defaultSpelling);
				
				if (category) setCategory(category)
				else setCategory(word.getCategory());
			}
		}
	
		/**
		 * This method returns null as the inflected word has no child components.
		 */
		override public function getChildren():Array
		{
			return null;
		}
	
		override public function toString():String
		{
			return "InflectedWordElement[" + getBaseForm() + ':' //$NON-NLS-1$
					+ getCategory().toString() + ']';
		}
	
		override public function printTree(indent:String):String
		{
			var print:String = "";
			print += "InflectedWordElement: base=" + getBaseForm() + ", category=" + getCategory().toString() + ", " + super.toString() + '\n'; //$NON-NLS-1$
			
			return print;
		}
	
		/**
		 * Retrieves the base form for this element. The base form is the originally
		 * supplied word.
		 * 
		 * @return a <code>String</code> forming the base form of the element.
		 */
		public function getBaseForm():String
		{
			return getFeatureAsString(LexicalFeature.BASE_FORM);
		}
	
		/**
		 * Sets the base word for this element.
		 * 
		 * @param word
		 *            the <code>WordElement</code> representing the base word as
		 *            read from the lexicon.
		 */
		public function setBaseWord(word:WordElement):void
		{
			setFeature(InternalFeature.BASE_WORD, word);
		}
	
		/**
		 * Retrieves the base word for this element.
		 * 
		 * @return the <code>WordElement</code> representing the base word as read
		 *         from the lexicon.
		 */
		public function getBaseWord():WordElement
		{
			var baseWord:NLGElement = this.getFeatureAsElement(InternalFeature.BASE_WORD);
			return baseWord is WordElement ? WordElement(baseWord) : null;
		}
	}
}
