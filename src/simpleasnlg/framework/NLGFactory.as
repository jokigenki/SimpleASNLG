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
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Gender;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Person;
	import simpleasnlg.lexicon.Lexicon;
	import simpleasnlg.phrasespec.AdjPhraseSpec;
	import simpleasnlg.phrasespec.AdvPhraseSpec;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.PPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.phrasespec.VPPhraseSpec;
	
	/**
	 * <p>
	 * This class contains methods for creating syntactic phrases. These methods
	 * should be used instead of directly invoking new on SPhraseSpec, etc.
	 * 
	 * The phrase factory should be linked to s lexicon if possible (although it
	 * will work without one)
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class NLGFactory
	{
	
		/***
		 * CODING COMMENTS The original version of phraseFactory created a crude
		 * realisation of the phrase in the BASE_FORM feature. This was just for
		 * debugging purposes (note BASE_FORM on a WordElement is meaningful), I've
		 * zapped this as it was making things too complex
		 * 
		 * This version of phraseFactory replicates WordElements (instead of reusing
		 * them). I think this is because elemente are linked to their parent
		 * phrases, via the parent data member. May be good to check if this is
		 * actually necessary
		 * 
		 * The explicit list of pronouns below should be replaced by a reference to
		 * the lexicon
		 * 
		 * Things to sort out at some point...
		 * 
		 */
		/** The lexicon to be used with this factory. */
		private var lexicon:Lexicon;
	
		/** The list of English pronouns. */
		//@SuppressWarnings("nls")
		private static const PRONOUNS:Array = ["I", "you",
				"he", "she", "it", "me", "you", "him", "her", "it", "myself",
				"yourself", "himself", "herself", "itself", "mine", "yours", "his",
				"hers", "its", "we", "you", "they", "they", "they", "us", "you",
				"them", "them", "them", "ourselves", "yourselves", "themselves",
				"themselves", "themselves", "ours", "yours", "theirs", "theirs",
				"theirs", "there"];
	
		/** The list of first-person English pronouns. */
		//@SuppressWarnings("nls")
		private static const FIRST_PRONOUNS:Array = ["I", "me",
				"myself", "we", "us", "ourselves", "mine", "my", "ours", "our"];
	
		/** The list of second person English pronouns. */
		//@SuppressWarnings("nls")
		private static const SECOND_PRONOUNS:Array = ["you",
				"yourself", "yourselves", "yours", "your"];
	
		/** The list of reflexive English pronouns. */
		//@SuppressWarnings("nls")
		private static const REFLEXIVE_PRONOUNS:Array = [
				"myself", "yourself", "himself", "herself", "itself", "ourselves",
				"yourselves", "themselves"];
	
		/** The list of masculine English pronouns. */
		//@SuppressWarnings("nls")
		private static const MASCULINE_PRONOUNS:Array = ["he",
				"him", "himself", "his"];
	
		/** The list of feminine English pronouns. */
		//@SuppressWarnings("nls")
		private static const FEMININE_PRONOUNS:Array = ["she",
				"her", "herself", "hers"];
	
		/** The list of possessive English pronouns. */
		//@SuppressWarnings("nls")
		private static const POSSESSIVE_PRONOUNS:Array = [
				"mine", "ours", "yours", "his", "hers", "its", "theirs", "my",
				"our", "your", "her", "their"];
	
		/** The list of plural English pronouns. */
		//@SuppressWarnings("nls")
		private static const PLURAL_PRONOUNS:Array = [
			"we", "us", "ourselves", "ours", "our", "they", "them", "theirs", "their"];
	
		/** The list of English pronouns that can be singular or plural. */
		//@SuppressWarnings("nls")
		private static const EITHER_NUMBER_PRONOUNS:Array = ["there"];
	
		/** The list of expletive English pronouns. */
		//@SuppressWarnings("nls")
		private static const EXPLETIVE_PRONOUNS:Array = ["there"];
	
		/** regex for determining if a string is a single word or not **/
		private static const WORD_REGEX:String = "\\w*";

		/**
		 * Creates a new phrase factory with the associated lexicon.
		 * 
		 * @param newLexicon
		 *            the <code>Lexicon</code> to be used with this factory.
		 */
		public function NLGFactory(newLexicon:Lexicon = null)
		{
			if (newLexicon) setLexicon(newLexicon);
		}
	
		/**
		 * Sets the lexicon to be used by this factory. Passing a parameter of
		 * <code>null</code> will remove any existing lexicon from the factory.
		 * 
		 * @param newLexicon
		 *            the new <code>Lexicon</code> to be used.
		 */
		public function setLexicon(newLexicon:Lexicon):void
		{
			this.lexicon = newLexicon;
		}
	
		/**
		 * Creates a new element representing a word. If the word passed is already
		 * an <code>NLGElement</code> then that is returned unchanged. If a
		 * <code>String</code> is passed as the word then the factory will look up
		 * the <code>Lexicon</code> if one exists and use the details found to
		 * create a new <code>WordElement</code>.
		 * 
		 * @param word
		 *            the base word for the new element. This can be a
		 *            <code>NLGElement</code>, which is returned unchanged, or a
		 *            <code>String</code>, which is used to construct a new
		 *            <code>WordElement</code>.
		 * @param category
		 *            the <code>LexicalCategory</code> for the word.
		 * 
		 * @return an <code>NLGElement</code> representing the word.
		 */
		public function createWord(word:Object, category:LexicalCategory):NLGElement
		{
			var wordElement:NLGElement = null;
			if (word is NLGElement)
			{
				wordElement = NLGElement(word);
	
			}
			else if (word is String && this.lexicon != null)
			{
				// AG: change: should create a WordElement, not an
				// InflectedWordElement
				// wordElement = new InflectedWordElement(
				// (String) word, category);
				// if (this.lexicon != null) {
				// doLexiconLookUp(category, (String) word, wordElement);
				// }
				// wordElement = lexicon.getWord((String) word, category);
				wordElement = lexicon.lookupWord(String(word), category);
				if (PRONOUNS.indexOf(word) > -1)
				{
					setPronounFeatures(wordElement, String(word));
				}
			}
	
			return wordElement;
		}
	
		/**
		 * Create an inflected word element. InflectedWordElement represents a word
		 * that already specifies the morphological and other features that it
		 * should exhibit in a realisation. While normally, phrases are constructed
		 * using <code>WordElement</code>s, and features are set on phrases, it is
		 * sometimes desirable to set features directly on words (for example, when
		 * one wants to elide a specific word, but not its parent phrase).
		 * 
		 * <P>
		 * If the object passed is already a <code>WordElement</code>, then a new
		 * 
		 * <code>InflectedWordElement<code> is returned which wraps this <code>WordElement</code>
		 * . If the object is a <code>String</code>, then the
		 * <code>WordElement</code> representing this <code>String</code> is looked
		 * up, and a new
		 * <code>InflectedWordElement<code> wrapping this is returned. If no such <code>WordElement</code>
		 * is found, the element returned is an <code>InflectedWordElement</code>
		 * with the supplied string as baseform and no base <code>WordElement</code>
		 * . If an <code>NLGElement</code> is passed, this is returned unchanged.
		 * 
		 * @param word
		 *            the word
		 * @param category
		 *            the category
		 * @return an <code>InflectedWordElement</code>, or the original supplied
		 *         object if it is an <code>NLGElement</code>.
		 */
		public function createInflectedWord(word:Object, category:LexicalCategory):NLGElement
		{
			// first get the word element
			var inflElement:NLGElement = null;
	
			if (word is WordElement)
			{
				inflElement = new InflectedWordElement(WordElement(word));
			}
			else if (word is String)
			{
				var baseword:NLGElement = createWord(String(word), category);
	
				if (baseword != null && baseword is WordElement) {
					inflElement = new InflectedWordElement(WordElement(baseword));
				} else {
					inflElement = new InflectedWordElement(String(word), category);
				}
	
			} else if (word is NLGElement) {
				inflElement = NLGElement(word);
			}
	
			return inflElement;
	
		}
	
		/**
		 * A helper method to set the features on newly created pronoun words.
		 * 
		 * @param wordElement
		 *            the created element representing the pronoun.
		 * @param word
		 *            the base word for the pronoun.
		 */
		private function setPronounFeatures(wordElement:NLGElement, word:String):void
		{
			wordElement.setCategory(LexicalCategory.PRONOUN);
			
			if (FIRST_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setFeature(Feature.PERSON, Person.FIRST);
			}
			else if (SECOND_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setFeature(Feature.PERSON, Person.SECOND);
	
				if ("yourself" == word.toLowerCase())
				{ //$NON-NLS-1$
					wordElement.setPlural(false);
				}
				else if ("yourselves" == word.toLowerCase())
				{ //$NON-NLS-1$
					wordElement.setPlural(true);
				} else {
					wordElement.setFeature(Feature.NUMBER, NumberAgreement.BOTH);
				}
			} else {
				wordElement.setFeature(Feature.PERSON, Person.THIRD);
			}
			
			if (REFLEXIVE_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setFeature(LexicalFeature.REFLEXIVE, true);
			} else {
				wordElement.setFeature(LexicalFeature.REFLEXIVE, false);
			}
			
			if (MASCULINE_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setFeature(LexicalFeature.GENDER, Gender.MASCULINE);
			}
			else if (FEMININE_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setFeature(LexicalFeature.GENDER, Gender.FEMININE);
			} else {
				wordElement.setFeature(LexicalFeature.GENDER, Gender.NEUTER);
			}
	
			if (POSSESSIVE_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setFeature(Feature.POSSESSIVE, true);
			} else {
				wordElement.setFeature(Feature.POSSESSIVE, false);
			}
	
			if (PLURAL_PRONOUNS.indexOf(word) > -1 && !SECOND_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setPlural(true);
			}
			else if (!EITHER_NUMBER_PRONOUNS.indexOf(word) > -1) 
			{
				wordElement.setPlural(false);
			}
	
			if (EXPLETIVE_PRONOUNS.indexOf(word) > -1)
			{
				wordElement.setFeature(InternalFeature.NON_MORPH, true);
				wordElement.setFeature(LexicalFeature.EXPLETIVE_SUBJECT, true);
			}
		}
	
		/**
		 * A helper method to look up the lexicon for the given word.
		 * 
		 * @param category
		 *            the <code>LexicalCategory</code> of the word.
		 * @param word
		 *            the base form of the word.
		 * @param wordElement
		 *            the created element representing the word.
		 */
		//@SuppressWarnings("unused")
		private function doLexiconLookUp(category:LexicalCategory, word:String,
				wordElement:NLGElement):void
		{
			var baseWord:WordElement = null;
	
			if (LexicalCategory.NOUN == category
					&& this.lexicon.hasWord(word, LexicalCategory.PRONOUN))
			{
				baseWord = this.lexicon.lookupWord(word, LexicalCategory.PRONOUN);
	
				if (baseWord != null)
				{
					wordElement.setFeature(InternalFeature.BASE_WORD, baseWord);
					wordElement.setCategory(LexicalCategory.PRONOUN);
					if (!PRONOUNS.indexOf(word) > -1)
					{
						wordElement.setFeature(InternalFeature.NON_MORPH, true);
					}
				}
			} else {
				baseWord = this.lexicon.lookupWord(word, category);
				wordElement.setFeature(InternalFeature.BASE_WORD, baseWord);
			}
		}
		
		/**
		 * Creates a preposition phrase with the given preposition and complement.
		 * An <code>NLGElement</code> representing the preposition is added as the
		 * head feature of this phrase while the complement is added as a normal
		 * phrase complement.
		 * 
		 * @param preposition
		 *            the preposition to be used.
		 * @param complement
		 *            the complement of the phrase.
		 * @return a <code>PPPhraseSpec</code> representing this phrase.
		 */
		public function createPrepositionPhrase(preposition:Object = null, complement:Object = null):PPPhraseSpec
		{
			var phraseElement:PPPhraseSpec = new PPPhraseSpec(this);
				
			var prepositionalElement:NLGElement = createNLGElement(preposition,
				LexicalCategory.PREPOSITION);
			setPhraseHead(phraseElement, prepositionalElement);
			
			if (complement != null)
			{
				setComplement(phraseElement, complement);
			}
			
			return phraseElement;
		}
	
		/**
		 * A helper method for setting the complement of a phrase.
		 * 
		 * @param phraseElement
		 *            the created element representing this phrase.
		 * @param complement
		 *            the complement to be added.
		 */
		private function setComplement(phraseElement:PhraseElement, complement:Object):void
		{
			var complementElement:NLGElement = createNLGElement(complement);
			phraseElement.addComplement(complementElement);
		}
	
		/**
		 * This method creates an NLGElement from an object.
		 * If object is null, return null.
		 * If the object is already an NLGElement, it is returned unchanged.
		 * Exception: if it is an InflectedWordElement, return underlying WordElement.
		 * If it is a String which matches a lexicon entry or pronoun,
		 * the relevant WordElement is returned.
		 * If it is a different String, a wordElement is created if the string is a single word.
		 * Otherwise a StringElement is returned.
		 * Otherwise throw an exception
		 * 
		 * @param element
		 *            - object to look up
		 * @param category
		 *            - default lexical category of object
		 * @return NLGelement
		 */
		public function createNLGElement(element:Object, category:LexicalCategory = null):NLGElement
		{
			if (!category)
			{
				return createNLGElement(element, LexicalCategory.ANY);
			}
			
			if (element == null)
			{
				return null;
			}
			else if (element is InflectedWordElement)
			{
				// InflectedWordElement - return underlying word
				return InflectedWordElement(element).getBaseWord();
			}
			else if (element is StringElement)
			{
				// StringElement - look up in lexicon if it is a word
				// otherwise return element
				if (stringIsWord(StringElement(element).getRealisation(), category))
				{
					return createWord(StringElement(element).getRealisation(), category);
				}
				
				return StringElement(element);
			}
			else if (element is NLGElement)
			{
				// other NLGElement - return element
				return NLGElement(element);
			}
			else if (element is String)
			{
				// String - look up in lexicon if a word, otherwise return StringElement
				if (stringIsWord(String(element), category)) return createWord(element, category);
				
				return new StringElement(String(element));
			}
	
			throw new Error(element.toString() + " is not a valid type");
		}
	
		/**
		 * Creates a noun phrase with the given specifier and subject.
		 * 
		 * @param specifier
		 *            the specifier or determiner for the noun phrase.
		 * @param noun
		 *            the subject of the phrase.
		 * @return a <code>NPPhraseSpec</code> representing this phrase.
		 */
		public function createNounPhrase(noun:Object = null, specifier:Object = null):NPPhraseSpec
		{
			if (noun is NPPhraseSpec) return NPPhraseSpec(noun); // [OB] ignores specifier?
	
			var phraseElement:NPPhraseSpec = new NPPhraseSpec(this);
			var nounElement:NLGElement = createNLGElement(noun, LexicalCategory.NOUN);
			setPhraseHead(phraseElement, nounElement);
	
			if (specifier != null) phraseElement.setSpecifier(specifier);
	
			return phraseElement;
		}
		
		/**
		 * A helper method to set the head feature of the phrase.
		 * 
		 * @param phraseElement
		 *            the phrase element.
		 * @param headElement
		 *            the head element.
		 */
		private function setPhraseHead(phraseElement:PhraseElement, headElement:NLGElement):void
		{
			if (headElement != null)
			{
				phraseElement.setHead(headElement);
				headElement.setParent(phraseElement);
			}
		}
		
		/**
		 * Creates an adjective phrase wrapping the given adjective.
		 * 
		 * @param adjective
		 *            the main adjective for this phrase.
		 * @return a <code>AdjPhraseSpec</code> representing this phrase.
		 */
		public function createAdjectivePhrase(adjective:Object = null):AdjPhraseSpec
		{
			var phraseElement:AdjPhraseSpec = new AdjPhraseSpec(this);
	
			var adjectiveElement:NLGElement = createNLGElement(adjective, LexicalCategory.ADJECTIVE);
			setPhraseHead(phraseElement, adjectiveElement);
	
			return phraseElement;
		}
	
		/**
		 * Creates a verb phrase wrapping the main verb given. If a
		 * <code>String</code> is passed in then some parsing is done to see if the
		 * verb contains a particle, for example <em>fall down</em>. The first word
		 * is taken to be the verb while all other words are assumed to form the
		 * particle.
		 * 
		 * @param verb
		 *            the verb to be wrapped.
		 * @return a <code>VPPhraseSpec</code> representing this phrase.
		 */
		public function createVerbPhrase(verb:Object = null):VPPhraseSpec
		{
			var phraseElement:VPPhraseSpec = new VPPhraseSpec(this);
			phraseElement.setVerb(verb);
			setPhraseHead(phraseElement, phraseElement.getVerb());
			return phraseElement;
		}
	
		/**
		 * Creates an adverb phrase wrapping the given adverb.
		 * 
		 * @param adverb
		 *            the adverb for this phrase.
		 * @return a <code>AdvPhraseSpec</code> representing this phrase.
		 */
		public function createAdverbPhrase(adverb:String = null):AdvPhraseSpec
		{
			var phraseElement:AdvPhraseSpec = new AdvPhraseSpec(this);
	
			var adverbElement:NLGElement = createNLGElement(adverb,
					LexicalCategory.ADVERB);
			setPhraseHead(phraseElement, adverbElement);
			return phraseElement;
		}
	
		/**
		 * Creates a clause with the given subject, verb or verb phrase and direct
		 * object but no indirect object.
		 * 
		 * @param subject
		 *            the subject for the clause as a <code>NLGElement</code> or
		 *            <code>String</code>. This forms a noun phrase.
		 * @param verb
		 *            the verb for the clause as a <code>NLGElement</code> or
		 *            <code>String</code>. This forms a verb phrase.
		 * @param directObject
		 *            the direct object for the clause as a <code>NLGElement</code>
		 *            or <code>String</code>. This forms a complement for the
		 *            clause.
		 * @return a <code>SPhraseSpec</code> representing this phrase.
		 */
		public function  createClause(subject:Object = null, verb:Object = null, directObject:Object = null):SPhraseSpec
		{
			var phraseElement:SPhraseSpec = new SPhraseSpec(this);
	
			if (verb != null)
			{
				// AG: fix here: check if "verb" is a VPPhraseSpec or a Verb
				if (verb is PhraseElement) {
					phraseElement.setVerbPhrase(PhraseElement(verb));
				} else {
					phraseElement.setVerb(verb);
				}
			}
	
			if (subject != null)
				phraseElement.setSubject(subject);
	
			if (directObject != null) {
				phraseElement.setObject(directObject);
			}
	
			return phraseElement;
		}
	
		/*	*//**
		 * A helper method to set the verb phrase for a clause.
		 * 
		 * @param baseForm
		 *            the base form of the clause.
		 * @param verbPhrase
		 *            the verb phrase to be used in the clause.
		 * @param phraseElement
		 *            the current representation of the clause.
		 */
		/*
		 * private function setVerbPhrase(StringBuffer baseForm, NLGElement verbPhrase,
		 * PhraseElement phraseElement) { if (baseForm.length() > 0) {
		 * baseForm.append(' '); }
		 * baseForm.append(verbPhrase.getFeatureAsString(Feature.BASE_FORM));
		 * phraseElement.setFeature(Feature.VERB_PHRASE, verbPhrase);
		 * verbPhrase.setParent(phraseElement);
		 * verbPhrase.setFeature(Feature.DISCOURSE_FUNCTION,
		 * DiscourseFunction.VERB_PHRASE); if
		 * (phraseElement.hasFeature(Feature.GENDER)) {
		 * verbPhrase.setFeature(Feature.GENDER, phraseElement
		 * .getFeature(Feature.GENDER)); } if
		 * (phraseElement.hasFeature(Feature.NUMBER)) {
		 * verbPhrase.setFeature(Feature.NUMBER, phraseElement
		 * .getFeature(Feature.NUMBER)); } if
		 * (phraseElement.hasFeature(Feature.PERSON)) {
		 * verbPhrase.setFeature(Feature.PERSON, phraseElement
		 * .getFeature(Feature.PERSON)); } }
		 *//**
		 * A helper method to add the direct object to the clause.
		 * 
		 * @param baseForm
		 *            the base form for the clause.
		 * @param directObject
		 *            the direct object to be added.
		 * @param phraseElement
		 *            the current representation of this clause.
		 * @param function
		 *            the discourse function for this object.
		 */
		/*
		 * private function setObject(StringBuffer baseForm, Object object,
		 * PhraseElement phraseElement, DiscourseFunction function) { if
		 * (baseForm.length() > 0) { baseForm.append(' '); } if (object is
		 * NLGElement) { phraseElement.addComplement((NLGElement) object);
		 * baseForm.append(((NLGElement) object)
		 * .getFeatureAsString(Feature.BASE_FORM));
		 * 
		 * ((NLGElement) object).setFeature(Feature.DISCOURSE_FUNCTION, function);
		 * 
		 * if (((NLGElement) object).hasFeature(Feature.NUMBER)) {
		 * phraseElement.setFeature(Feature.NUMBER, ((NLGElement) object)
		 * .getFeature(Feature.NUMBER)); } } else if (object is String) {
		 * NLGElement complementElement = createNounPhrase(object);
		 * phraseElement.addComplement(complementElement);
		 * complementElement.setFeature(Feature.DISCOURSE_FUNCTION, function);
		 * baseForm.append((String) object); } }
		 */
		/*	*//**
		 * A helper method that sets the subjects on a clause.
		 * 
		 * @param phraseElement
		 *            the element representing the clause.
		 * @param subjectPhrase
		 *            the subject phrase for the clause.
		 * @param baseForm
		 *            the base form for the clause.
		 */
		/*
		 * private function setPhraseSubjects(PhraseElement phraseElement, NLGElement
		 * subjectPhrase, StringBuffer baseForm) {
		 * subjectPhrase.setParent(phraseElement); List<NLGElement> allSubjects =
		 * new Array<NLGElement>(); allSubjects.push(subjectPhrase);
		 * phraseElement.setFeature(Feature.SUBJECTS, allSubjects);
		 * baseForm.append(subjectPhrase.getFeatureAsString(Feature.BASE_FORM));
		 * subjectPhrase.setFeature(Feature.DISCOURSE_FUNCTION,
		 * DiscourseFunction.SUBJECT);
		 * 
		 * if (subjectPhrase.hasFeature(Feature.GENDER)) {
		 * phraseElement.setFeature(Feature.GENDER, subjectPhrase
		 * .getFeature(Feature.GENDER)); } if
		 * (subjectPhrase.hasFeature(Feature.NUMBER)) {
		 * phraseElement.setFeature(Feature.NUMBER, subjectPhrase
		 * .getFeature(Feature.NUMBER));
		 * 
		 * } if (subjectPhrase.hasFeature(Feature.PERSON)) {
		 * phraseElement.setFeature(Feature.PERSON, subjectPhrase
		 * .getFeature(Feature.PERSON)); } }
		 */
		/**
		 * Creates a canned text phrase with the given text.
		 * 
		 * @param text
		 *            the canned text.
		 * @return a <code>PhraseElement</code> representing this phrase.
		 */
		public function createStringElement(text:String = null):StringElement
		{
			return new StringElement(text);
		}
	
		/**
		 * Creates a new coordinated phrase with the given elements
		 * 
		 * @param ...coordinates
		 *            - the phrases to be coordinated
		 * @return <code>CoordinatedPhraseElement</code> for the given elements
		 */
		public function createCoordinatedPhrase(...coordinates):CoordinatedPhraseElement
		{
			return new CoordinatedPhraseElement(coordinates);
		}
	
		/***********************************************************************************
		 * Document level stuff
		 ***********************************************************************************/
	
		/**
		 * Creates a new document element with the given title and adds all of the
		 * given components in the list
		 * 
		 * @param title
		 *            the title of this element.
		 * @param components
		 *            a <code>List</code> of <code>NLGElement</code>s that form the
		 *            components of this element.
		 * @return a <code>DocumentElement</code>
		 */
		public function createDocument(title:String = null, components:Array = null):DocumentElement
		{
			var document:DocumentElement = new DocumentElement(DocumentCategory.DOCUMENT, title);
			
			if (components != null) {
				document.addComponents(components);
			}
			return document;
		}
	
		/**
		 * Creates a new document element with the given title and adds the given
		 * component.
		 * 
		 * @param title
		 *            the title for this element.
		 * @param component
		 *            an <code>NLGElement</code> that becomes the first component of
		 *            this document element.
		 * @return a <code>DocumentElement</code>
		 */
		public function createDocumentWithElement(title:String, component:NLGElement):DocumentElement
		{
			var element:DocumentElement = new DocumentElement(DocumentCategory.DOCUMENT, title);
	
			if (component != null) {
				element.addComponent(component);
			}
			return element;
		}
	
		/**
		 * Creates a new list element and adds all of the given components in the
		 * list
		 * 
		 * @param textComponents
		 *            a <code>List</code> of <code>NLGElement</code>s that form the
		 *            components of this element.
		 * @return a <code>DocumentElement</code> representing the list.
		 */
		public function createList(textComponents:Array = null):DocumentElement
		{
			var list:DocumentElement = new DocumentElement(DocumentCategory.LIST, null);
			if (textComponents) list.addComponents(textComponents);
			return list;
		}
	
		/**
		 * Creates a new section element with the given title and adds the given
		 * component.
		 * 
		 * @param component
		 *            an <code>NLGElement</code> that becomes the first component of
		 *            this document element.
		 * @return a <code>DocumentElement</code> representing the section.
		 */
		public function createListWithElement(component:NLGElement):DocumentElement
		{
			var list:DocumentElement = new DocumentElement(DocumentCategory.LIST, null);
			list.addComponent(component);
			return list;
		}
	
		/**
		 * Creates a list item for adding to a list element. The list item has the
		 * given component.
		 * 
		 * @return a <code>DocumentElement</code> representing the list item.
		 */
		public function createListItem(component:NLGElement = null):DocumentElement
		{
			var listItem:DocumentElement = new DocumentElement(DocumentCategory.LIST_ITEM, null);
			if (component) listItem.addComponent(component);
			return listItem;
		}
	
		/**
		 * Creates a new paragraph element and adds all of the given components in
		 * the list
		 * 
		 * @param components
		 *            a <code>List</code> of <code>NLGElement</code>s that form the
		 *            components of this element.
		 * @return a <code>DocumentElement</code> representing this paragraph
		 */
		public function createParagraph(components:Array = null):DocumentElement
		{
			 var paragraph:DocumentElement = new DocumentElement(DocumentCategory.PARAGRAPH, null);
			if (components != null) {
				paragraph.addComponents(components);
			}
			return paragraph;
		}
	
		/**
		 * Creates a new paragraph element and adds the given component
		 * 
		 * @param component
		 *            an <code>NLGElement</code> that becomes the first component of
		 *            this document element.
		 * @return a <code>DocumentElement</code> representing this paragraph
		 */
		public function createParagraphWithElement(component:NLGElement):DocumentElement
		{
			var paragraph:DocumentElement = new DocumentElement(DocumentCategory.PARAGRAPH, null);
			if (component != null) {
				paragraph.addComponent(component);
			}
			return paragraph;
		}
	
		/**
		 * Creates a new section element with the given title and adds all of the
		 * given components in the list
		 * 
		 * @param title
		 *            the title of this element.
		 * @param components
		 *            a <code>List</code> of <code>NLGElement</code>s that form the
		 *            components of this element.
		 * @return a <code>DocumentElement</code> representing the section.
		 */
		public function createSection(title:String = null, components:Array = null):DocumentElement
		{
			var section:DocumentElement = new DocumentElement(DocumentCategory.SECTION, title);
			if (components != null) {
				section.addComponents(components);
			}
			return section;
		}
	
		/**
		 * Creates a new section element with the given title and adds the given
		 * component.
		 * 
		 * @param title
		 *            the title for this element.
		 * @param component
		 *            an <code>NLGElement</code> that becomes the first component of
		 *            this document element.
		 * @return a <code>DocumentElement</code> representing the section.
		 */
		public function  createSectionWithElement(title:String, component:NLGElement):DocumentElement
		{
			var section:DocumentElement = new DocumentElement(DocumentCategory.SECTION, title);
			if (component != null)
			{
				section.addComponent(component);
			}
			return section;
		}
	
		/**
		 * Creates a new sentence element and adds all of the given components.
		 * 
		 * @param components
		 *            a <code>List</code> of <code>NLGElement</code>s that form the
		 *            components of this element.
		 * @return a <code>DocumentElement</code> representing this sentence
		 */
		public function createSentence(components:Array = null):DocumentElement
		{
			var sentence:DocumentElement = new DocumentElement(DocumentCategory.SENTENCE, null);
			if (components) sentence.addComponents(components);
			return sentence;
		}
	
		/**
		 * Creates a new sentence element
		 * 
		 * @param components
		 *            an <code>NLGElement</code> that becomes the first component of
		 *            this document element.
		 * @return a <code>DocumentElement</code> representing this sentence
		 */
		public function createSentenceWithElement(components:NLGElement):DocumentElement
		{
			var sentence:DocumentElement = new DocumentElement(DocumentCategory.SENTENCE, null);
			if (components) sentence.addComponent(components);
			return sentence;
		}
	
		/**
		 * Creates a sentence with the given subject, verb and direct object. The
		 * phrase factory is used to construct a clause that then forms the
		 * components of the sentence.
		 * 
		 * @param subject
		 *            the subject of the sentence.
		 * @param verb
		 *            the verb of the sentence.
		 * @param complement
		 *            the object of the sentence.
		 * @return a <code>DocumentElement</code> representing this sentence
		 */
		public function createSentenceFromElements(subject:Object, verb:Object, complement:Object = null):DocumentElement
		{
			var sentence:DocumentElement = new DocumentElement(DocumentCategory.SENTENCE, null);
			sentence.addComponent(createClause(subject, verb, complement));
			return sentence;
		}
	
		/**
		 * Creates a new sentence with the given canned text. The canned text is
		 * used to form a canned phrase (from the phrase factory) which is then
		 * added as the component to sentence element.
		 * 
		 * @param cannedSentence
		 *            the canned text as a <code>String</code>.
		 * @return a <code>DocumentElement</code> representing this sentence
		 */
		public function createCannedSentence(cannedSentence:String):DocumentElement
		{
			var sentence:DocumentElement = new DocumentElement(DocumentCategory.SENTENCE, null);
	
			if (cannedSentence != null) {
				sentence.addComponent(createStringElement(cannedSentence));
			}
			return sentence;
		}
		
		/**
		 * return true if string is a word
		 * 
		 * @param string
		 * @param category
		 * @return
		 */
		private function stringIsWord(string:String, category:LexicalCategory):Boolean
		{
			return lexicon != null
				&& (lexicon.hasWord(string, category)
					|| PRONOUNS.indexOf(string) > -1 || (string.match(WORD_REGEX)[0] == string));
		}
	}
}
