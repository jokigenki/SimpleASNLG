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
package simpleasnlg.orthography.english
{
	
	
	import com.steamshift.utils.StringUtils;
	
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentCategory;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.ElementCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGModule;
	import simpleasnlg.framework.StringElement;
	
	/**
	 * <p>
	 * This processing module deals with punctuation when applied to
	 * <code>DocumentElement</code>s. The punctuation currently handled by this
	 * processor includes the following (as of version 4.0):
	 * <ul>
	 * <li>Capitalisation of the first letter in sentences.</li>
	 * <li>Termination of sentences with a period if not interrogative.</li>
	 * <li>Termination of sentences with a question mark if they are interrogative.</li>
	 * <li>Replacement of multiple conjunctions with a comma. For example,
	 * <em>John and Peter and Simon</em> becomes <em>John, Peter and Simon</em>.</li>
	 * </ul>
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class OrthographyProcessor extends NLGModule {
	
		override public function initialise():void
		{
			// No initialisation.
		}
	
		override public function realise(element:NLGElement):NLGElement
		{
			var realisedElement:NLGElement = null;
	
			if (element != null)
			{
				var category:ElementCategory = element.getCategory();
	
				if (category is DocumentCategory && element is DocumentElement) 
				{
					var components:Array = DocumentElement(element).getComponents();
	
					switch (category)
					{
						case DocumentCategory.SENTENCE:
							realisedElement = realiseSentence(components, element);
							break;
		
						case DocumentCategory.LIST_ITEM:
							if (components != null && components.length > 0)
							{
								// recursively realise whatever's in the list item
								// NB: this will realise embedded lists within list
								// items
								realisedElement = new ListElement(realiseList(components));
							}
							break;
		
						default:
							DocumentElement(element).setComponents(realiseList(components));
							realisedElement = element;
					}
	
				}
				else if (element is ListElement)
				{
					// AG: changes here: if we have a premodifier, then we ask the
					// realiseList method to separate with a comma.
					// if it's a postmod, we need commas at the start and end only if it's appositive
					var buffer:String = "";
					var children:Array = element.getChildren();
					var func:Object = null;
					
					if (children.length > 0)
					{
						var firstChild:NLGElement = children[0];
						func = firstChild.getFeature(InternalFeature.DISCOURSE_FUNCTION);
					}
					
					if (DiscourseFunction.PRE_MODIFIER == func)
					{
						buffer = realiseComponentList(buffer, element.getChildren(), ",");
					}
					else if (DiscourseFunction.POST_MODIFIER == func)
					{
						var postmods:Array = element.getChildren();
						var len:int = postmods.length;
						for (var i:int = 0; i < len; i++)
						{
							var postmod:NLGElement = postmods[i];
							
							//if the postmod is appositive, it's sandwiched in commas
							if (postmod.getFeatureAsBoolean(Feature.APPOSITIVE))
							{
								buffer += ", ";
								buffer += realise(postmod);
								if (i < len - 1) buffer += ", ";
							} else {
								buffer += realise(postmod);
								buffer += " ";
							}
						}
					} else {
						buffer = realiseComponentList(buffer, element.getChildren(), "");
					}
					
					// realiseList(buffer, element.getChildren(), "");
					realisedElement = new StringElement(buffer);
				}
				else if (element is CoordinatedPhraseElement)
				{
					realisedElement = realiseCoordinatedPhrase(element.getChildren());
				} else {
					realisedElement = element;
				}
	
				// make the realised element inherit the original category
				// essential if list items are to be properly formatted later
				if (realisedElement != null)
				{
					realisedElement.setCategory(category);
				}
				
				addTrailingComma(realisedElement);
				removePunctSpace(realisedElement);
			}
	
			return realisedElement;
		}
	
		/**
		 * adds a comma to realised element
		 * @param realisedElement
		 */
		private function addTrailingComma (realisedElement:NLGElement):void
		{
			if (realisedElement.getFeature(InternalFeature.DISCOURSE_FUNCTION) == DiscourseFunction.CUE_PHRASE)
			{
				var realisation:String = realisedElement.getRealisation();
				
				if (realisation != null)
				{
					realisation += ",";
					realisedElement.setRealisation(realisation);
				}
			}
		}
		
		/**
		 * removes extra spaces preceding punctuation from a realised element
		 * @param realisedElement
		 */
		private function removePunctSpace(realisedElement:NLGElement):void
		{
			if (!realisedElement) return;
			
			var realisation:String = realisedElement.getRealisation();
			
			if (realisation != null)
			{
				realisation = StringUtils.findAndReplace(" ,", ",", realisation).string;
				realisedElement.setRealisation(realisation);
			}
		}
		
		/**
		 * Performs the realisation on a sentence. This includes adding the
		 * terminator and capitalising the first letter.
		 * 
		 * @param components
		 *            the <code>List</code> of <code>NLGElement</code>s representing
		 *            the components that make up the sentence.
		 * @param element
		 *            the <code>NLGElement</code> representing the sentence.
		 * @return the realised element as an <code>NLGElement</code>.
		 */
		private function realiseSentence(components:Array, element:NLGElement):NLGElement
		{
			var realisedElement:NLGElement = null;
			
			if (components != null && components.length > 0)
			{
				var realisation:String = "";
				realisation = realiseComponentList(realisation, components, "");
	
				realisation = capitaliseFirstLetter(realisation);
				realisation = terminateSentence(realisation, element.getFeatureAsBoolean(InternalFeature.INTERROGATIVE));
	
				DocumentElement(element).clearComponents();
				// realisation.append(' ');
				element.setRealisation(realisation.toString());
				realisedElement = element;
			}
			return realisedElement;
		}
	
		/**
		 * Adds the sentence terminator to the sentence. This is a period ('.') for
		 * normal sentences or a question mark ('?') for interrogatives.
		 * 
		 * @param realisation
		 *            the <code>StringBuffer<code> containing the current 
		 * realisation of the sentence.
		 * @param interrogative
		 *            a <code>boolean</code> flag showing <code>true</code> if the
		 *            sentence is an interrogative, <code>false</code> otherwise.
		 */
		private function terminateSentence(realisation:String, interrogative:Boolean):String
		{
			var character:String = realisation.charAt(realisation.length - 2);
			if (character != '.' && character != '?')
			{
				if (interrogative)
				{
					realisation += '?';
				} else {
					realisation += '.';
				}
			}
			
			return realisation;
		}
	
		/**
		 * Capitalises the first character of a sentence if it is a lower case
		 * letter.
		 * 
		 * @param realisation
		 *            the <code>StringBuffer<code> containing the current 
		 * realisation of the sentence.
		 */
		private function capitaliseFirstLetter(realisation:String):String
		{
			var character:String = realisation.charAt(0);
			if (character >= 'a' && character <= 'z')
			{
				character = character.toUpperCase();
				realisation = character + realisation.slice(1);
			}
			
			return realisation;
		}
	
		override public function realiseList(elements:Array):Array
		{
			var realisedList:Array = new Array();
	
			if (elements != null && elements.length > 0)
			{
				var len:int = elements.length;
				for (var i:int = 0; i < len; i++)
				{
					var eachElement:NLGElement = elements[i];
					if (eachElement is DocumentElement)
					{
						realisedList.push(realise(eachElement));
					} else {
						realisedList.push(eachElement);
					}
				}
			}
			return realisedList;
		}
	
		/**
		 * Realises a list of elements appending the result to the on-going
		 * realisation.
		 * 
		 * @param realisation
		 *            the <code>StringBuffer<code> containing the current 
		 * 			  realisation of the sentence.
		 * @param components
		 *            the <code>List</code> of <code>NLGElement</code>s representing
		 *            the components that make up the sentence.
		 * @param listSeparator
		 *            the string to use to separate elements of the list, empty if
		 *            no separator needed
		 */
		private function realiseComponentList(realisation:String, components:Array, listSeparator:String):String
		{
			var realisedChild:NLGElement = null;
	
			for (var i:int = 0; i < components.length; i++)
			{
				var thisElement:NLGElement = components[i];
				realisedChild = realise(thisElement);
				var childRealisation:String = realisedChild.getRealisation();
	
				// check that the child realisation is non-empty
				if (childRealisation != null && childRealisation.length > 0 && !childRealisation.match("^[\\s\\n]+$"))
				{
					realisation += realisedChild.getRealisation();
	
					if (components.length > 1 && i < components.length - 1)
					{
						realisation += listSeparator;
					}
	
					realisation += ' ';
				}
			}
	
			if (realisation.length > 0)
			{
				realisation = realisation.slice(0, realisation.length - 1);
			}
			
			return realisation;
		}
	
		/**
		 * Realises coordinated phrases. Where there are more than two coordinates,
		 * then a comma replaces the conjunction word between all the coordinates
		 * save the last two. For example, <em>John and Peter and Simon</em> becomes
		 * <em>John, Peter and Simon</em>.
		 * 
		 * @param components
		 *            the <code>List</code> of <code>NLGElement</code>s representing
		 *            the components that make up the sentence.
		 * @return the realised element as an <code>NLGElement</code>.
		 */
		private function realiseCoordinatedPhrase(components:Array):NLGElement
		{
			var realisation:String = "";
			var realisedChild:NLGElement = null;
	
			var length:int = components.length;
	
			for (var index:int = 0; index < length; index++)
			{
				realisedChild = components[index];
				if (index < length - 2 && DiscourseFunction.CONJUNCTION == realisedChild.getFeature(InternalFeature.DISCOURSE_FUNCTION))
				{
					realisation += ", "; //$NON-NLS-1$
				} else {
					realisedChild = realise(realisedChild);
					realisation += realisedChild.getRealisation() + ' ';
				}
			}
			realisation = realisation.slice(0, realisation.length - 1);
			return new StringElement(realisation.toString().replace(" ,", ",")); //$NON-NLS-1$ //$NON-NLS-2$
		}
	}
}
