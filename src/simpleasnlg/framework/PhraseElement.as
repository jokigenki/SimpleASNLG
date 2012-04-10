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
	import com.steamshift.utils.ArrayUtils;
	import com.steamshift.utils.StringUtils;
	
	import flash.utils.Dictionary;
	
	import simpleasnlg.features.ClauseStatus;
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	
	/**
	 * <p>
	 * This class defines a phrase. It covers the expected phrase types: noun
	 * phrases, verb phrases, adjective phrases, adverb phrases and prepositional
	 * phrases as well as also covering clauses. Phrases can be constructed from
	 * scratch by setting the correct features of the phrase elements. However, it
	 * is strongly recommended that the <code>PhraseFactory</code> is used to
	 * construct phrases.
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class PhraseElement extends NLGElement
	{
		/**
		 * Creates a new phrase of the given type.
		 * 
		 * @param newCategory
		 *            the <code>PhraseCategory</code> type for this phrase.
		 */
		public function PhraseElement(newCategory:PhraseCategory)
		{
			setCategory(newCategory);
	
			// set default feature value
			setFeature(Feature.ELIDED, false);
		}
	
		/**
		 * <p>
		 * This method retrieves the child components of this phrase. The list
		 * returned will depend on the category of the element.<br>
		 * <ul>
		 * <li>Clauses consist of cue phrases, front modifiers, pre-modifiers,
		 * subjects, verb phrases and complements.</li>
		 * <li>Noun phrases consist of the specifier, pre-modifiers, the noun
		 * subjects, complements and post-modifiers.</li>
		 * <li>Verb phrases consist of pre-modifiers, the verb group, complements
		 * and post-modifiers.</li>
		 * <li>Canned text phrases have no children thus an empty list will be
		 * returned.</li>
		 * <li>All the other phrases consist of pre-modifiers, the main phrase
		 * element, complements and post-modifiers.</li>
		 * </ul>
		 * </p>
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s representing the
		 *         child elements of this phrase.
		 */
		override public function getChildren():Array
		{
			var children:Array = new Array();
			var category:ElementCategory = getCategory();
			var currentElement:NLGElement = null;
	
			if (category is PhraseCategory)
			{
				switch (category)
				{
					case PhraseCategory.CLAUSE:
						currentElement = getFeatureAsElement(Feature.CUE_PHRASE);
						if (currentElement != null) children.push(currentElement);
						children = children.concat(getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS));
						children = children.concat(getFeatureAsElementList(InternalFeature.PREMODIFIERS));
						children = children.concat(getFeatureAsElementList(InternalFeature.SUBJECTS));
						children = children.concat(getFeatureAsElementList(InternalFeature.VERB_PHRASE));
						children = children.concat(getFeatureAsElementList(InternalFeature.COMPLEMENTS));
						break;
		
					case PhraseCategory.NOUN_PHRASE:
						currentElement = getFeatureAsElement(InternalFeature.SPECIFIER);
						if (currentElement != null) children.push(currentElement);
						children = children.concat(getFeatureAsElementList(InternalFeature.PREMODIFIERS));
						
						currentElement = getHead();
						if (currentElement != null) children.push(currentElement);
						children = children.concat(getFeatureAsElementList(InternalFeature.COMPLEMENTS));
						children = children.concat(getFeatureAsElementList(InternalFeature.POSTMODIFIERS));
						break;
		
					case PhraseCategory.VERB_PHRASE:
						children = children.concat(getFeatureAsElementList(InternalFeature.PREMODIFIERS));
						currentElement = getHead();
						if (currentElement != null) children.push(currentElement);
						children = children.concat(getFeatureAsElementList(InternalFeature.COMPLEMENTS));
						children = children.concat(getFeatureAsElementList(InternalFeature.POSTMODIFIERS));
						break;
		
					case PhraseCategory.CANNED_TEXT:
						// Do nothing
						break;
		
					default:
						children = children.concat(getFeatureAsElementList(InternalFeature.PREMODIFIERS));
						currentElement = getHead();
						if (currentElement != null) children.push(currentElement);
						children = children.concat(getFeatureAsElementList(InternalFeature.COMPLEMENTS));
						children = children.concat(getFeatureAsElementList(InternalFeature.POSTMODIFIERS));
				}
			}
			return children;
		}
	
		/**
		 * Sets the head, or main component, of this current phrase. For example,
		 * the head for a verb phrase should be a verb while the head of a noun
		 * phrase should be a noun. <code>String</code>s are converted to
		 * <code>StringElement</code>s. If <code>null</code> is passed in as the new
		 * head then the head feature is removed.
		 * 
		 * @param newHead
		 *            the new value for the head of this phrase.
		 */
		public function setHead(newHead:Object):void
		{
			if (newHead == null) {
				removeFeature(InternalFeature.HEAD);
				return;
			}
			var headElement:NLGElement;
			if (newHead is NLGElement) headElement = NLGElement(newHead);
			else headElement = new StringElement(String(newHead));
	
			setFeature(InternalFeature.HEAD, headElement);
		}
	
		/**
		 * Retrieves the current head of this phrase.
		 * 
		 * @return the <code>NLGElement</code> representing the head.
		 */
		public function getHead():NLGElement
		{
			return getFeatureAsElement(InternalFeature.HEAD);
		}

		/**
		 * remove complements of the specified DiscourseFunction
		 * 
		 * @param function
		 */
		private function removeComplements(func:DiscourseFunction):void
		{
			var complement:NLGElement;
			var complements:Array = getFeatureAsElementList(InternalFeature.COMPLEMENTS);
			if (func == null || complements == null) return;
			
			var complementsToRemove:Array = new Array();
			var len:int = complements.length;
			for (var i:int = 0; i < len; i++)
			{
				complement = complements[i];
				if (func == complement.getFeature(InternalFeature.DISCOURSE_FUNCTION)) complementsToRemove.push(complement);
			}
			
			if (complementsToRemove.length > 0)
			{
				for each (complement in complementsToRemove)
				{
					ArrayUtils.remove(complements, complement);
				}
				setFeature(InternalFeature.COMPLEMENTS, complements);
			}
	
			return;
		}
	
		/**
		 * <p>
		 * Adds a new complement to the phrase element. Complements will be realised
		 * in the syntax after the head element of the phrase. Complements differ
		 * from post-modifiers in that complements are crucial to the understanding
		 * of a phrase whereas post-modifiers are optional.
		 * </p>
		 * 
		 * <p>
		 * If the new complement being added is a <em>clause</em> or a
		 * <code>CoordinatedPhraseElement</code> then its clause status feature is
		 * set to <code>ClauseStatus.SUBORDINATE</code> and it's discourse function
		 * is set to <code>DiscourseFunction.OBJECT</code> by default unless an
		 * existing discourse function exists on the complement.
		 * </p>
		 * 
		 * <p>
		 * Complements can have different functions. For example, the phrase <I>John
		 * gave Mary a flower</I> has two complements, one a direct object and one
		 * indirect. If a complement is not specified for its discourse function,
		 * then this is automatically set to <code>DiscourseFunction.OBJECT</code>.
		 * </p>
		 * 
		 * @param newComplement
		 *            the new complement as an <code>NLGElement</code>.
		 */
		public function addComplement(newComplement:NLGElement):void
		{
			var complements:Array = getFeatureAsElementList(InternalFeature.COMPLEMENTS);
			if (complements == null) complements = [];
			
			// check if the new complement has a discourse function; if not, assume
			// object
			if(!newComplement.hasFeature(InternalFeature.DISCOURSE_FUNCTION))
			{
				newComplement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
			}
			
			complements.push(newComplement);
			setFeature(InternalFeature.COMPLEMENTS, complements);
			
			if (newComplement.isA(PhraseCategory.CLAUSE) || newComplement is CoordinatedPhraseElement)
			{
				newComplement.setFeature(InternalFeature.CLAUSE_STATUS, ClauseStatus.SUBORDINATE);
				
				if (!newComplement.hasFeature(InternalFeature.DISCOURSE_FUNCTION))
				{
					newComplement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
				}
			}
		}
		
		/**
		 * <p>
		 * Adds a new complement to the phrase element. Complements will be realised
		 * in the syntax after the head element of the phrase. Complements differ
		 * from post-modifiers in that complements are crucial to the understanding
		 * of a phrase whereas post-modifiers are optional.
		 * </p>
		 * 
		 * @param newComplement
		 *            the new complement as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */
		public function addComplementAsString (newComplement:String):void
		{
			addComplement(new StringElement(newComplement));
		}
	
		
		/**
		 * <p>
		 * Sets a complement of the phrase element. If a complement already exists
		 * of the same DISCOURSE_FUNCTION, it is removed. This replaces complements
		 * set earlier via {@link #addComplement(NLGElement)}
		 * </p>
		 * 
		 * @param newComplement
		 *            the new complement as an <code>NLGElement</code>.
		 */
		public function setComplement(newComplement:NLGElement):void
		{
			var func:DiscourseFunction = DiscourseFunction(newComplement.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			removeComplements(func);
			addComplement(newComplement);
		}
		
		/**
		 * <p>
		 * Sets the complement to the phrase element. This replaces any complements
		 * set earlier.
		 * </p>
		 * 
		 * @param newComplement
		 *            the new complement as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */
		public function setComplementAsString(newComplement:String):void
		{
			setFeature(InternalFeature.COMPLEMENTS, null);
			addComplementAsString(newComplement);
		}
	
		/**
		 * Adds a new post-modifier to the phrase element. Post-modifiers will be
		 * realised in the syntax after the complements.
		 * 
		 * @param newPostModifier
		 *            the new post-modifier as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */	
		public function addPostModifier(newPostModifier:NLGElement):void
		{
			var postModifiers:Array = getFeatureAsElementList(InternalFeature.POSTMODIFIERS);
			if (postModifiers == null) postModifiers = []

			postModifiers.push(newPostModifier);
			setFeature(InternalFeature.POSTMODIFIERS, postModifiers);
		}
		
		/**
		 * Adds a new post-modifier to the phrase element. Post-modifiers will be
		 * realised in the syntax after the complements.
		 * 
		 * @param newPostModifier
		 *            the new post-modifier as an <code>NLGElement</code>.
		 */
		public function addPostModifierAsString (newPostModifier:String):void
		{
			addPostModifier(new StringElement(newPostModifier));
		}
	
		/**
		 * Set the postmodifier for this phrase. This resets all previous
		 * postmodifiers to <code>null</code> and replaces them with the given
		 * string.
		 * 
		 * @param newPostModifier
		 *            the postmodifier
		 */
		public function setPostModifier(newPostModifier:NLGElement):void
		{
			this.setFeature(InternalFeature.POSTMODIFIERS, null);
			addPostModifier(newPostModifier);
		}
		
		/**
		 * Set the postmodifier for this phrase. This resets all previous
		 * postmodifiers to <code>null</code> and replaces them with the given
		 * string.
		 * 
		 * @param newPostModifier
		 *            the postmodifier
		 */
		public function setPostModifierAsString (newPostModifier:String):void
		{
			this.setFeature(InternalFeature.POSTMODIFIERS, null);
			addPostModifierAsString(newPostModifier);
		}
	
		/**
		 * Adds a new front modifier to the phrase element.
		 * 
		 * @param newFrontModifier
		 *            the new front modifier as an <code>NLGElement</code>.
		 */
		public function addFrontModifier(newFrontModifier:NLGElement):void
		{
			var frontModifiers:Array = getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS);
			if (frontModifiers == null) frontModifiers = []
	
			frontModifiers.push(newFrontModifier);
			setFeature(InternalFeature.FRONT_MODIFIERS, frontModifiers);
		}
		/**
 		* Adds a new front modifier to the phrase element.
		* 
		* @param newFrontModifier
		*            the new front modifier as a <code>String</code>. It is used to
		*            create a <code>StringElement</code>.
		*/
		public function addFrontModifierAsString (newFrontModifier:String):void
		{
			addFrontModifier(new StringElement(newFrontModifier));
		}
	
		/**
		 * Set the frontmodifier for this phrase. This resets all previous front
		 * modifiers to <code>null</code> and replaces them with the given string.
		 * 
		 * @param newFrontModifier
		 *            the front modifier
		 */
		public function setFrontModifier(newFrontModifier:NLGElement):void
		{
			this.setFeature(InternalFeature.FRONT_MODIFIERS, null);
			addFrontModifier(newFrontModifier);
		}
	
		/**
		 * Adds a new pre-modifier to the phrase element.
		 * 
		 * @param newPreModifier
		 *            the new pre-modifier as an <code>NLGElement</code>.
		 */
		public function addPreModifier(newPreModifier:NLGElement):void
		{
			var preModifiers:Array = getFeatureAsElementList(InternalFeature.PREMODIFIERS);
			if (preModifiers == null) preModifiers = [];

			preModifiers.push(newPreModifier);
			setFeature(InternalFeature.PREMODIFIERS, preModifiers);
		}
		
		/**
		 * Adds a new pre-modifier to the phrase element.
		 * 
		 * @param newPreModifier
		 *            the new pre-modifier as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */
		public function addPreModifierAsString (newPreModifier:String):void
		{
			addPreModifier(new StringElement(newPreModifier));
		}
	
		/**
		 * Set the premodifier for this phrase. This resets all previous
		 * premodifiers to <code>null</code> and replaces them with the given
		 * string.
		 * 
		 * @param newPreModifier
		 *            the premodifier
		 */
		public function setPreModifier(newPreModifier:NLGElement):void
		{
			this.setFeature(InternalFeature.PREMODIFIERS, null);
			addPreModifier(newPreModifier);
		}
	
		/**
		 * Set the premodifier for this phrase. This resets all previous
		 * premodifiers to <code>null</code> and replaces them with the given
		 * string.
		 * 
		 * @param newPreModifier
		 *            the new pre-modifier as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */
		public function setPreModifierAsString (newPreModifier:String):void
		{
			this.setFeature(InternalFeature.PREMODIFIERS, null);
			addPreModifierAsString(newPreModifier);
		}
		
		/**
		 * Add a modifier to a phrase Use heuristics to decide where it goes
		 * 
		 * @param modifier
		 */
		public function addModifier(modifier:NLGElement):void
		{
			// default addModifier - always make modifier a preModifier
			if (modifier == null) return;
	
			// assume is preModifier, add in appropriate form
			addPreModifier(modifier);
		}
		
		/**
		 * Set the premodifier for this phrase. This resets all previous
		 * premodifiers to <code>null</code> and replaces them with the given
		 * string.
		 * 
		 * @param newPreModifier
		 *            the premodifier
		 */
		public function addModifierAsString(modifier:String):void
		{
			if (modifier == null) return;
			addPreModifierAsString(String(modifier));
		}
	
		/**
		 * Retrieves the current list of pre-modifiers for the phrase.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s.
		 */
		public function getPreModifiers():Array
		{
			return getFeatureAsElementList(InternalFeature.PREMODIFIERS);
		}
	
		/**
		 * Retrieves the current list of post modifiers for the phrase.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s.
		 */
		public function getPostModifiers():Array
		{
			return getFeatureAsElementList(InternalFeature.POSTMODIFIERS);
		}
	
		/**
		 * Retrieves the current list of frony modifiers for the phrase.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s.
		 */
		public function getFrontModifiers():Array
		{
			return getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS);
		}
	
		override public function printTree(indent:String):String
		{
			var thisIndent:String = indent == null ? " |-" : indent + " |-"; //$NON-NLS-1$ //$NON-NLS-2$
			var childIndent:String = indent == null ? " | " : indent + " | "; //$NON-NLS-1$ //$NON-NLS-2$
			var lastIndent:String = indent == null ? " \\-" : indent + " \\-"; //$NON-NLS-1$ //$NON-NLS-2$
			var lastChildIndent:String = indent == null ? "   " : indent + "   "; //$NON-NLS-1$ //$NON-NLS-2$
			var print:String = "";
			
			print += "PhraseElement: category=" + getCategory().toString() + ", features="; //$NON-NLS-1$
	
			var features:Dictionary = getAllFeatures();
			print += StringUtils.mapToString(features);
			print += "\n"; //$NON-NLS-1$

			var children:Array = getChildren();
			var length:int = children.length - 1;
	
			for (var index:int = 0; index < length; index++)
			{
				print += thisIndent + children[index].printTree(childIndent);
			}
			if (length >= 0)
			{
				print += lastIndent + children[length].printTree(lastChildIndent);
			}
			
			return print;
		}
	
		/**
		 * Removes all existing complements on the phrase.
		 */
		public function clearComplements():void
		{
			removeFeature(InternalFeature.COMPLEMENTS);
		}
	
		/**
		 * Sets the determiner for the phrase. This only has real meaning on noun
		 * phrases and is added here for convenience. Determiners are some times
		 * referred to as specifiers.
		 * 
		 * @param newDeterminer
		 *            the new determiner for the phrase.
		 * @deprecated Use NPPhraseSpec#setSpecifier(Object) directly
		 */
		[Deprecated]
		public function setDeterminer(newDeterminer:Object):void
		{
			var factory:NLGFactory = new NLGFactory();
			var determinerElement:NLGElement = factory.createWord(newDeterminer,
					LexicalCategory.DETERMINER);
	
			if (determinerElement != null)
			{
				determinerElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.SPECIFIER);
				setFeature(InternalFeature.SPECIFIER, determinerElement);
				determinerElement.setParent(this);
			}
		}
	}
}
