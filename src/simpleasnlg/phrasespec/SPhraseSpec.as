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
	
	import simpleasnlg.features.ClauseStatus;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.IFeature;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.WordElement;
	
	/**
	 * <p>
	 * This class defines a clause (sentence-like phrase). It is essentially a
	 * wrapper around the <code>PhraseElement</code> class, with methods for setting
	 * common constituents such as Subject. For example, the <code>setVerb</code>
	 * method in this class sets the head of the element to be the specified verb
	 * 
	 * From an API perspective, this class is a simplified version of the
	 * SPhraseSpec class in simplenlg V3. It provides an alternative way for
	 * creating syntactic structures, compared to directly manipulating a V4
	 * <code>PhraseElement</code>.
	 * 
	 * Methods are provided for setting and getting the following constituents:
	 * <UL>
	 * <li>FrontModifier (eg, "Yesterday")
	 * <LI>Subject (eg, "John")
	 * <LI>PreModifier (eg, "reluctantly")
	 * <LI>Verb (eg, "gave")
	 * <LI>IndirectObject (eg, "Mary")
	 * <LI>Object (eg, "an apple")
	 * <LI>PostModifier (eg, "before school")
	 * </UL>
	 * Note that verb, indirect object, and object are propagated to the underlying
	 * verb phrase
	 * 
	 * NOTE: The setModifier method will attempt to automatically determine whether
	 * a modifier should be expressed as a FrontModifier, PreModifier, or
	 * PostModifier
	 * 
	 * Features (such as negated) must be accessed via the <code>setFeature</code>
	 * and <code>getFeature</code> methods (inherited from <code>NLGElement</code>).
	 * Features which are often set on SPhraseSpec include
	 * <UL>
	 * <LI>Form (eg, "John eats an apple" vs "John eating an apple")
	 * <LI>InterrogativeType (eg, "John eats an apple" vs "Is John eating an apple"
	 * vs "What is John eating")
	 * <LI>Modal (eg, "John eats an apple" vs "John can eat an apple")
	 * <LI>Negated (eg, "John eats an apple" vs "John does not eat an apple")
	 * <LI>Passive (eg, "John eats an apple" vs "An apple is eaten by John")
	 * <LI>Perfect (eg, "John ate an apple" vs "John has eaten an apple")
	 * <LI>Progressive (eg, "John eats an apple" vs "John is eating an apple")
	 * <LI>Tense (eg, "John ate" vs "John eats" vs "John will eat")
	 * </UL>
	 * Note that most features are propagated to the underlying verb phrase
	 * Premodifers are also propogated to the underlying VP
	 * 
	 * <code>SPhraseSpec</code> are produced by the <code>createClause</code> method
	 * of a <code>PhraseFactory</code>
	 * </p>
	 * 
	 * @author E. Reiter, University of Aberdeen.
	 * @version 4.1
	 * 
	 */
	public class SPhraseSpec extends PhraseElement
	{
		// the following features are copied to the VPPhraseSpec
		public static const vpFeatures:Array = [Feature.MODAL,
				Feature.TENSE, Feature.NEGATED, Feature.NUMBER, Feature.PASSIVE,
				Feature.PERFECT, Feature.PARTICLE, Feature.PERSON,
				Feature.PROGRESSIVE, InternalFeature.REALISE_AUXILIARY,
				Feature.FORM, Feature.INTERROGATIVE_TYPE];
	
		/**
		 * create an empty clause
		 */
		public function SPhraseSpec(phraseFactory:NLGFactory )
		{
			super(PhraseCategory.CLAUSE);
			this.setFactory(phraseFactory);
	
			// create VP
			setVerbPhrase(phraseFactory.createVerbPhrase());
	
			// set default values
			setFeature(Feature.ELIDED, false);
			setFeature(InternalFeature.CLAUSE_STATUS, ClauseStatus.MATRIX);
			setFeature(Feature.SUPRESSED_COMPLEMENTISER, false);
			setFeature(LexicalFeature.EXPLETIVE_SUBJECT, false);
			setFeature(Feature.COMPLEMENTISER, phraseFactory.createWord(
					"that", LexicalCategory.COMPLEMENTISER)); //$NON-NLS-1$
	
		}
	
		// intercept and override setFeature, to set VP features as needed
	
		/*
		 * adds a premodifier, if possible to the underlying VP
		 * 
		 * @see
		 * simpleasnlg.framework.PhraseElement#addPreModifier(simpleasnlg.framework.
		 * NLGElement)
		 */
		override public function addPreModifier(newPreModifier:NLGElement):void
		{
			var verbPhrase:NLGElement = NLGElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
	
			if (verbPhrase != null)
			{
				if (verbPhrase is PhraseElement)
				{
					PhraseElement(verbPhrase).addPreModifier(newPreModifier);
				}
				else if (verbPhrase is CoordinatedPhraseElement)
				{
					CoordinatedPhraseElement(verbPhrase).addPreModifier(newPreModifier);
				} else {
					super.addPreModifier(newPreModifier);
				}
			}
		}
		
		override public function addPreModifierAsString(newPreModifier:String):void
		{
			var verbPhrase:NLGElement = NLGElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
			
			if (verbPhrase != null)
			{
				if (verbPhrase is PhraseElement)
				{
					PhraseElement(verbPhrase).addPreModifierAsString(newPreModifier);
				}
				else if (verbPhrase is CoordinatedPhraseElement)
				{
					CoordinatedPhraseElement(verbPhrase).addPreModifierAsString(newPreModifier);
				} else {
					super.addPreModifierAsString(newPreModifier);
				}
			}
		}
	
		/*
		 * adds a complement, if possible to the underlying VP
		 * 
		 * @seesimpleasnlg.framework.PhraseElement#addComplement(simpleasnlg.framework.
		 * NLGElement)
		 */
		override public function addComplement(complement:NLGElement):void
		{
			var verbPhrase:PhraseElement = PhraseElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
			
			if (verbPhrase != null || verbPhrase is VPPhraseSpec)
				verbPhrase.addComplement(complement);
			else
				super.addComplement(complement);
		}
	
		/*
		* adds a feature, possibly to the underlying VP as well as the SPhraseSpec
		* itself
		* 
		* @see simpleasnlg.framework.NLGElement#setFeature(java.lang.String,
		* java.lang.Object)
		*/
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.framework.NLGElement#setFeature(java.lang.String, boolean)
		 */
		override public function setFeature(feature:IFeature, featureValue:*):void
		{
			super.setFeature(feature, featureValue);
			if (vpFeatures.indexOf(feature) > -1)
			{
				//PhraseElement verbPhrase = (PhraseElement) getFeatureAsElement(InternalFeature.VERB_PHRASE);
				//AG: bug fix: VP could be coordinate phrase, so cast to NLGElement not PhraseElement
				var verbPhrase:NLGElement;
				if (featureValue is Boolean) verbPhrase = NLGElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
				else verbPhrase = PhraseElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
				
				if (verbPhrase != null || verbPhrase is VPPhraseSpec)
				{
					verbPhrase.setFeature(feature, featureValue);
				}
			}
		}
		
		/**
		 * @return VP for this clause
		 */
		public function getVerbPhrase():NLGElement
		{
			return getFeatureAsElement(InternalFeature.VERB_PHRASE);
		}
	
		public function setVerbPhrase(vp:NLGElement):void
		{
			setFeature(InternalFeature.VERB_PHRASE, vp);
			vp.setParent(this); // needed for syntactic processing
		}
	
		/**
		 * Set the verb of a clause
		 * 
		 * @param verb
		 */
		public function setVerb(verb:Object):void
		{
			// get verb phrase element (create if necessary)
			var verbPhraseElement:NLGElement = getVerbPhrase();
	
			// set head of VP to verb (if this is VPPhraseSpec, and not a coord)
			if (verbPhraseElement != null && verbPhraseElement is VPPhraseSpec)
				VPPhraseSpec(verbPhraseElement).setVerb(verb);
	
			/*
			 * // WARNING - I don't understand verb phrase, so this may not work!!
			 * NLGElement verbElement = getFactory().createWord(verb,
			 * LexicalCategory.VERB);
			 * 
			 * // get verb phrase element (create if necessary) NLGElement
			 * verbPhraseElement = getVerbPhrase();
			 * 
			 * // set head of VP to verb (if this is VPPhraseSpec, and not a coord)
			 * if (verbPhraseElement != null && verbPhraseElement is
			 * VPPhraseSpec) ((VPPhraseSpec)
			 * verbPhraseElement).setHead(verbElement);
			 */}
	
		/**
		 * Returns the verb of a clause
		 * 
		 * @return verb of clause
		 */
		public function getVerb():NLGElement
		{
	
			// WARNING - I don't understand verb phrase, so this may not work!!
			var verbPhrase:PhraseElement = PhraseElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
			if (verbPhrase != null || verbPhrase is VPPhraseSpec)
				return verbPhrase.getHead();
			else
				// return null if VP is coordinated phrase
				return null;
		}
	
		/**
		 * Sets the subject of a clause (assumes this is the only subject)
		 * 
		 * @param subject
		 */
		public function setSubject(subject:Object):void
		{
			var subjectPhrase:NLGElement;
			if (subject is PhraseElement || subject is CoordinatedPhraseElement)
				subjectPhrase = NLGElement(subject);
			else
				subjectPhrase = getFactory().createNounPhrase(subject);
			var subjects :Array = new Array();
			subjects.push(subjectPhrase);
			setFeature(InternalFeature.SUBJECTS, subjects);
		}
	
		/**
		 * Returns the subject of a clause (assumes there is only one)
		 * 
		 * @return subject of clause (assume only one)
		 */
		public function getSubject():NLGElement
		{
			var subjects:Array = getFeatureAsElementList(InternalFeature.SUBJECTS);
			if (subjects == null || subjects.length == 0)
				return null;
			return subjects[0];
		}
		
		/**
		 * Sets the direct object of a clause (assumes this is the only direct
		 * object)
		 * 
		 * @param object
		 */
		public function setObject(object:Object):void
		{
			// get verb phrase element (create if necessary)
			var verbPhraseElement:NLGElement = getVerbPhrase();
	
			// set object of VP to verb (if this is VPPhraseSpec, and not a coord)
			if (verbPhraseElement != null && verbPhraseElement is VPPhraseSpec)
				VPPhraseSpec(verbPhraseElement).setObject(object);
		}
	
		/**
		 * Returns the direct object of a clause (assumes there is only one)
		 * 
		 * @return subject of clause (assume only one)
		 */
		public function getObject():NLGElement
		{
			var verbPhrase:PhraseElement = PhraseElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
			if (verbPhrase != null || verbPhrase is VPPhraseSpec)
				return VPPhraseSpec(verbPhrase).getObject();
			else
				// return null if VP is coordinated phrase
				return null;
		}
	
		/**
		 * Set the indirect object of a clause (assumes this is the only direct
		 * indirect object)
		 * 
		 * @param indirectObject
		 */
		public function setIndirectObject(indirectObject:Object):void
		{
			// get verb phrase element (create if necessary)
			var verbPhraseElement:NLGElement = getVerbPhrase();
	
			// set head of VP to verb (if this is VPPhraseSpec, and not a coord)
			if (verbPhraseElement != null && verbPhraseElement is VPPhraseSpec)
				VPPhraseSpec(verbPhraseElement).setIndirectObject(indirectObject);
		}
	
		/**
		 * Returns the indirect object of a clause (assumes there is only one)
		 * 
		 * @return subject of clause (assume only one)
		 */
		public function getIndirectObject():NLGElement
		{
			var verbPhrase:PhraseElement = PhraseElement(getFeatureAsElement(InternalFeature.VERB_PHRASE));
			if (verbPhrase != null || verbPhrase is VPPhraseSpec)
				return VPPhraseSpec(verbPhrase).getIndirectObject();
			else
				// return null if VP is coordinated phrase
				return null;
		}
	
		// note that addFrontModifier, addPostModifier, addPreModifier are inherited
		// from PhraseElement
		// likewise getFrontModifiers, getPostModifiers, getPreModifiers
	
		/**
		 * Add a modifier to a clause Use heuristics to decide where it goes
		 * 
		 * @param modifier
		 */
		override public function addModifier(modifier:NLGElement):void
		{
			// adverb is frontModifier if sentenceModifier
			// otherwise adverb is preModifier
			// string which is one lexicographic word is looked up in lexicon,
			// above rules apply if adverb
			// Everything else is postModifier
	
			if (modifier == null) return;
	
			// AdvP is premodifer (probably should look at head to see if
			// sentenceModifier)
			if (modifier is AdvPhraseSpec)
			{
				addPreModifier(modifier);
				return;
			}
	
			// extract WordElement if modifier is a single word
			var modifierWord:WordElement = null;
			if (modifier != null && modifier is WordElement)
			{
				modifierWord = WordElement(modifier);
			}
			else if (modifier != null && modifier is InflectedWordElement)
			{
				modifierWord = InflectedWordElement(modifier).getBaseWord();
			}
			
			if (modifierWord != null && modifierWord.getCategory() == LexicalCategory.ADVERB)
			{
				// adverb rules
				if (modifierWord.getFeatureAsBoolean(LexicalFeature.SENTENCE_MODIFIER))
					addFrontModifier(modifierWord);
				else
					addPreModifier(modifierWord);
				return;
			}
	
			// default case
			addPostModifier(modifier);
		}
		
		/**
		 * Add a modifier to a clause Use heuristics to decide where it goes
		 * 
		 * @param modifier
		 */
		override public function addModifierAsString(modifier:String):void
		{
			// adverb is frontModifier if sentenceModifier
			// otherwise adverb is preModifier
			// string which is one lexicographic word is looked up in lexicon,
			// above rules apply if adverb
			// Everything else is postModifier
			
			if (modifier == null) return;
			
			// get modifier as NLGElement if possible
			var modifierElement:NLGElement = null;
			var modifierString:String = String(modifier);
			if (modifierString.length > 0 && modifierString.indexOf(" ") == -1)
			{
				modifierElement = getFactory().createWord(modifier, LexicalCategory.ANY);
			}
			
			// if no modifier element, must be a complex string
			if (modifierElement == null)
			{
				addPostModifierAsString(modifier);
				return;
			}
			
			addModifier(modifierElement);
		}
		
		/**
		 * Does the clause have a subject, verb or object?
		 */
		public function get isEmpty ():Boolean
		{
			if (getFeature(Feature.CUE_PHRASE) ||
				getSubject() ||
				getVerb() ||
				getObject()) return false;
			
			return true;
		}
		
		public function get isComplete ():Boolean
		{
			if (getSubject() &&
				getVerb() &&
				getObject()) return true;
			
			return false;
		}
	}
}
