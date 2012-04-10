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
	import simpleasnlg.features.ClauseStatus;
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.InterrogativeType;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Person;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.phrasespec.VPPhraseSpec;
	
	/**
	 * <p>
	 * This is a helper class containing the main methods for realising the syntax
	 * of clauses. It is used exclusively by the <code>SyntaxProcessor</code>.
	 * </p>
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class ClauseHelper {
	
		/**
		 * The main method for controlling the syntax realisation of clauses.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that called this
		 *            method.
		 * @param phrase
		 *            the <code>PhraseElement</code> representation of the clause.
		 * @return the <code>NLGElement</code> representing the realised clause.
		 */
		public static function realise(parent:SyntaxProcessor, phrase:PhraseElement):NLGElement
		{
			var realisedElement:ListElement = null;
			var phraseFactory:NLGFactory = phrase.getFactory();
			var splitVerb:NLGElement = null;
			var interrogObj:Boolean = false;
	
			if (phrase != null)
			{
				realisedElement = new ListElement();
				var verbElement:NLGElement = phrase.getFeatureAsElement(InternalFeature.VERB_PHRASE);
	
				if (verbElement == null)
				{
					verbElement = phrase.getHead();
				}
	
				checkSubjectNumberPerson(phrase, verbElement);
				checkDiscourseFunction(phrase);
				copyFrontModifiers(phrase, verbElement);
				addComplementiser(phrase, parent, realisedElement);
				addCuePhrase(phrase, parent, realisedElement);
	
				if (phrase.hasFeature(Feature.INTERROGATIVE_TYPE))
				{
					var inter:Object = phrase.getFeature(Feature.INTERROGATIVE_TYPE);
					interrogObj = InterrogativeType.WHAT_OBJECT == inter || InterrogativeType.WHO_OBJECT == inter;
					splitVerb = realiseInterrogative(phrase, parent, realisedElement, phraseFactory, verbElement);
				} else {
					PhraseHelper.realiseList(parent, realisedElement, phrase.getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS), DiscourseFunction.FRONT_MODIFIER);
				}
	
				addSubjectsToFront(phrase, parent, realisedElement, splitVerb);
				
				var passiveSplitVerb:NLGElement = addPassiveComplementsNumberPerson(phrase, parent, realisedElement, verbElement);
	
				if (passiveSplitVerb != null)
				{
					splitVerb = passiveSplitVerb;
				}
	
				// realise verb needs to know if clause is object interrogative
				realiseVerb(phrase, parent, realisedElement, splitVerb, verbElement, interrogObj);
				addPassiveSubjects(phrase, parent, realisedElement, phraseFactory);
				addInterrogativeFrontModifiers(phrase, parent, realisedElement);
				addEndingTo(phrase, parent, realisedElement, phraseFactory);
			}
			return realisedElement;
		}
	
		/**
		 * Adds <em>to</em> to the end of interrogatives concerning indirect
		 * objects. For example, <em>who did John give the flower <b>to</b></em>.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param phraseFactory
		 *            the phrase factory to be used.
		 */
		private static function addEndingTo(phrase:PhraseElement, parent:SyntaxProcessor, realisedElement:ListElement, phraseFactory:NLGFactory):void
		{
			if (InterrogativeType.WHO_INDIRECT_OBJECT == phrase.getFeature(Feature.INTERROGATIVE_TYPE))
			{
				var word:NLGElement = phraseFactory.createWord("to", LexicalCategory.PREPOSITION); //$NON-NLS-1$
				realisedElement.addComponent(parent.realise(word));
			}
		}
	
		/**
		 * Adds the front modifiers to the end of the clause when dealing with
		 * interrogatives.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 */
		private static function addInterrogativeFrontModifiers(phrase:PhraseElement, parent:SyntaxProcessor, realisedElement:ListElement):void
		{
			var currentElement:NLGElement = null;
			
			if (phrase.hasFeature(Feature.INTERROGATIVE_TYPE))
			{
				var list:Array = phrase.getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS)
				var len:int = list.length;
				for (var i:int = 0; i < len; i++)
				{
					var subject:NLGElement = list[i];
					currentElement = parent.realise(subject);
					
					if (currentElement != null)
					{
						currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.FRONT_MODIFIER);
	
						realisedElement.addComponent(currentElement);
					}
				}
			}
		}
	
		/**
		 * Realises the subjects of a passive clause.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param phraseFactory
		 *            the phrase factory to be used.
		 */
		private static function addPassiveSubjects(phrase:PhraseElement, parent:SyntaxProcessor, realisedElement:ListElement, phraseFactory:NLGFactory):void
		{
			var currentElement:NLGElement = null;
	
			if (phrase.getFeatureAsBoolean(Feature.PASSIVE))
			{
				var allSubjects:Array = phrase.getFeatureAsElementList(InternalFeature.SUBJECTS);
	
				if (allSubjects.length > 0 || phrase.hasFeature(Feature.INTERROGATIVE_TYPE))
				{
					realisedElement.addComponent(parent.realise(phraseFactory.createPrepositionPhrase("by"))); //$NON-NLS-1$
				}
	
				var len:int = allSubjects.length;
				for (var i:int = 0; i < len; i++)
				{
					var subject:NLGElement = allSubjects[i];
					subject.setFeature(Feature.PASSIVE, true);
					if (subject.isA(PhraseCategory.NOUN_PHRASE) || subject is CoordinatedPhraseElement)
					{
						currentElement = parent.realise(subject);
						if (currentElement != null)
						{
							currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.SUBJECT);
							realisedElement.addComponent(currentElement);
						}
					}
				}
			}
		}
	
		/**
		 * Realises the verb part of the clause.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param splitVerb
		 *            an <code>NLGElement</code> representing the subjects that
		 *            should split the verb
		 * @param verbElement
		 *            the <code>NLGElement</code> representing the verb phrase for
		 *            this clause.
		 * @param whObj
		 *            whether the VP is part of an object WH-interrogative
		 */
		private static function realiseVerb(phrase:PhraseElement,
				parent:SyntaxProcessor, realisedElement:ListElement,
				splitVerb:NLGElement, verbElement:NLGElement, whObj:Boolean):void
		{
	
			setVerbFeatures(phrase, verbElement);
	
			var currentElement:NLGElement = parent.realise(verbElement);
			if (currentElement != null)
			{
				if (splitVerb == null)
				{
					currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.VERB_PHRASE);
	
					realisedElement.addComponent(currentElement);
	
				} else {
					if (currentElement is ListElement)
					{
						var children:Array = currentElement.getChildren();
						currentElement = children[0];
						currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.VERB_PHRASE);
						realisedElement.addComponent(currentElement);
						realisedElement.addComponent(splitVerb);
	
						var len:int = children.length;
						for (var eachChild:int = 1; eachChild < len; eachChild++)
						{
							currentElement = children[eachChild];
							currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.VERB_PHRASE);
							realisedElement.addComponent(currentElement);
						}
					} else {
						currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.VERB_PHRASE);
	
						if (whObj)
						{
							realisedElement.addComponent(currentElement);
							realisedElement.addComponent(splitVerb);
						} else {
							realisedElement.addComponent(splitVerb);
							realisedElement.addComponent(currentElement);
						}
					}
				}
			}
		}
	
		/**
		 * Ensures that the verb inherits the features from the clause.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param verbElement
		 *            the <code>NLGElement</code> representing the verb phrase for
		 *            this clause.
		 */
		private static function setVerbFeatures(phrase:PhraseElement, verbElement:NLGElement):void
		{
			// this routine copies features from the clause to the VP.
			// it is disabled, as this copying is now done automatically
			// when features are set in SPhraseSpec
			// if (verbElement != null) {
			// verbElement.setFeature(Feature.INTERROGATIVE_TYPE, phrase
			// .getFeature(Feature.INTERROGATIVE_TYPE));
			// verbElement.setFeature(InternalFeature.COMPLEMENTS, phrase
			// .getFeature(InternalFeature.COMPLEMENTS));
			// verbElement.setFeature(InternalFeature.PREMODIFIERS, phrase
			// .getFeature(InternalFeature.PREMODIFIERS));
			// verbElement.setFeature(Feature.FORM, phrase
			// .getFeature(Feature.FORM));
			// verbElement.setFeature(Feature.MODAL, phrase
			// .getFeature(Feature.MODAL));
			// verbElement.setNegated(phrase.isNegated());
			// verbElement.setFeature(Feature.PASSIVE, phrase
			// .getFeature(Feature.PASSIVE));
			// verbElement.setFeature(Feature.PERFECT, phrase
			// .getFeature(Feature.PERFECT));
			// verbElement.setFeature(Feature.PROGRESSIVE, phrase
			// .getFeature(Feature.PROGRESSIVE));
			// verbElement.setTense(phrase.getTense());
			// verbElement.setFeature(Feature.FORM, phrase
			// .getFeature(Feature.FORM));
			// verbElement.setFeature(LexicalFeature.GENDER, phrase
			// .getFeature(LexicalFeature.GENDER));
			// }
		}
	
		/**
		 * Realises the complements of passive clauses; also sets number, person for
		 * passive
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param verbElement
		 *            the <code>NLGElement</code> representing the verb phrase for
		 *            this clause.
		 */
		private static function addPassiveComplementsNumberPerson(
				phrase:PhraseElement, parent:SyntaxProcessor,
				realisedElement:ListElement, verbElement:NLGElement):NLGElement
		{
			var passiveNumber:Object = null;
			var passivePerson:Object = null;
			var currentElement:NLGElement = null;
			var splitVerb:NLGElement = null;
			var verbPhrase:NLGElement = phrase.getFeatureAsElement(InternalFeature.VERB_PHRASE);
	
			if (phrase.getFeatureAsBoolean(Feature.PASSIVE) && verbPhrase != null
					&& InterrogativeType.WHAT_OBJECT != phrase.getFeature(Feature.INTERROGATIVE_TYPE))
			{
	
				var list:Array = verbPhrase.getFeatureAsElementList(InternalFeature.COMPLEMENTS);
				// complements of a clause are stored in the VPPhraseSpec
				
				var len:int = list.length;
				for (var i:int = 0; i < len; i++)
				{
					var subject:NLGElement = list[i];
					// AG: complement needn't be an NP
					// subject.isA(PhraseCategory.NOUN_PHRASE) &&
					if (DiscourseFunction.OBJECT == subject.getFeature(InternalFeature.DISCOURSE_FUNCTION))
					{
						subject.setFeature(Feature.PASSIVE, true);
						currentElement = parent.realise(subject);
	
						if (currentElement != null)
						{
							currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.OBJECT);
	
							if (phrase.hasFeature(Feature.INTERROGATIVE_TYPE))
							{
								splitVerb = currentElement;
							} else {
								realisedElement.addComponent(currentElement);
							}
						}
	
						if (passiveNumber == null) {
							passiveNumber = subject.getFeature(Feature.NUMBER);
						} else {
							passiveNumber = NumberAgreement.PLURAL;
						}
	
						if (Person.FIRST == subject.getFeature(Feature.PERSON))
						{
							passivePerson = Person.FIRST;
						}
						else if (Person.SECOND == subject.getFeature(Feature.PERSON) && Person.FIRST != passivePerson)
						{
							passivePerson = Person.SECOND;
						}
						else if (passivePerson == null)
						{
							passivePerson = Person.THIRD;
						}
	
						if (Form.GERUND == phrase.getFeature(Feature.FORM)
								&& !phrase.getFeatureAsBoolean(Feature.SUPPRESS_GENITIVE_IN_GERUND)
										)
						{
							subject.setFeature(Feature.POSSESSIVE, true);
						}
					}
				}
			}
	
			if (verbElement != null)
			{
				if (passivePerson != null)
				{
					verbElement.setFeature(Feature.PERSON, passivePerson);
					// below commented out. for non-passive, number and person set
					// by checkSubjectNumberPerson
					// } else {
					// verbElement.setFeature(Feature.PERSON, phrase
					// .getFeature(Feature.PERSON));
				}
				if (passiveNumber != null) {
					verbElement.setFeature(Feature.NUMBER, passiveNumber);
				}
			}
			return splitVerb;
		}
	
		/**
		 * Adds the subjects to the beginning of the clause unless the clause is
		 * infinitive, imperative or passive, or the subjects split the verb.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param splitVerb
		 *            an <code>NLGElement</code> representing the subjects that
		 *            should split the verb
		 */
		private static function addSubjectsToFront(phrase:PhraseElement, parent:SyntaxProcessor, realisedElement:ListElement, splitVerb:NLGElement):void
		{
			if (Form.INFINITIVE != phrase.getFeature(Feature.FORM)
					&& Form.IMPERATIVE != phrase.getFeature(Feature.FORM)
					&& !phrase.getFeatureAsBoolean(Feature.PASSIVE)
					&& splitVerb == null)
			{
				var listElement:ListElement = realiseSubjects(phrase, parent);
				realisedElement.addComponents(listElement.getChildren());
			}
		}
	
		/**
		 * Realises the subjects for the clause.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 */
		private static function realiseSubjects(phrase:PhraseElement, parent:SyntaxProcessor):ListElement
		{
			var currentElement:NLGElement = null;
			var realisedElement:ListElement = new ListElement();
	
			var list:Array = phrase.getFeatureAsElementList(InternalFeature.SUBJECTS)
			var len:int = list.length;
			for (var i:int = 0; i < len; i++)
			{
				var subject:NLGElement = list[i];
				subject.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.SUBJECT);
				if (Form.GERUND == phrase.getFeature(Feature.FORM)
						&& !phrase.getFeatureAsBoolean(Feature.SUPPRESS_GENITIVE_IN_GERUND))
				{
					subject.setFeature(Feature.POSSESSIVE, true);
				}
				currentElement = parent.realise(subject);
				if (currentElement != null) {
					realisedElement.addComponent(currentElement);
				}
			}
			return realisedElement;
		}
	
		/**
		 * This is the main controlling method for handling interrogative clauses.
		 * The actual steps taken are dependent on the type of question being asked.
		 * The method also determines if there is a subject that will split the verb
		 * group of the clause. For example, the clause
		 * <em>the man <b>should give</b> the woman the flower</em> has the verb
		 * group indicated in <b>bold</b>. The phrase is rearranged as yes/no
		 * question as
		 * <em><b>should</b> the man <b>give</b> the woman the flower</em> with the
		 * subject <em>the man</em> splitting the verb group.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param phraseFactory
		 *            the phrase factory to be used.
		 * @param verbElement
		 *            the <code>NLGElement</code> representing the verb phrase for
		 *            this clause.
		 * @return an <code>NLGElement</code> representing a subject that should
		 *         split the verb
		 */
		private static function realiseInterrogative(phrase:PhraseElement,
				parent:SyntaxProcessor, realisedElement:ListElement,
				phraseFactory:NLGFactory, verbElement:NLGElement):NLGElement
		{
			var splitVerb:NLGElement = null;
	
			if (phrase.getParent() != null)
			{
				phrase.getParent().setFeature(InternalFeature.INTERROGATIVE, true);
			}
	
			var type:Object = phrase.getFeature(Feature.INTERROGATIVE_TYPE);
	
			if (type is InterrogativeType)
			{
				switch (type)
				{
					case InterrogativeType.YES_NO:
						splitVerb = realiseYesNo(phrase, parent, verbElement, phraseFactory, realisedElement);
						break;
		
					case InterrogativeType.WHO_SUBJECT:
						realiseInterrogativeKeyWord("who", LexicalCategory.PRONOUN, parent, realisedElement, phraseFactory);
						phrase.removeFeature(InternalFeature.SUBJECTS);
						break;
		
					case InterrogativeType.WHAT_SUBJECT:
						realiseInterrogativeKeyWord("what", LexicalCategory.PRONOUN, parent, realisedElement, phraseFactory);
						phrase.removeFeature(InternalFeature.SUBJECTS);
						break;
		
					case InterrogativeType.HOW:
					case InterrogativeType.WHY:
					case InterrogativeType.WHERE:
						realiseInterrogativeKeyWord(type.toString().toLowerCase(), LexicalCategory.PRONOUN, parent, realisedElement, phraseFactory);
						splitVerb = realiseYesNo(phrase, parent, verbElement, phraseFactory, realisedElement);
						break;
		
					case InterrogativeType.HOW_MANY:
						realiseInterrogativeKeyWord("how", LexicalCategory.PRONOUN, parent, realisedElement, phraseFactory);
						realiseInterrogativeKeyWord("many", LexicalCategory.ADVERB, parent, realisedElement, phraseFactory);
						break;
		
					case InterrogativeType.WHO_OBJECT:
					case InterrogativeType.WHO_INDIRECT_OBJECT:
						//				realiseInterrogativeKeyWord("who", parent, realisedElement, //$NON-NLS-1$
						// phraseFactory);
						splitVerb = realiseObjectWHInterrogative("who", phrase, parent, realisedElement, phraseFactory);
		
						// if (!hasAuxiliary(phrase)) {
						// addDoAuxiliary(phrase, parent, phraseFactory,
						// realisedElement);
						// }
						break;
		
					case InterrogativeType.WHAT_OBJECT:
						splitVerb = realiseObjectWHInterrogative("what", phrase, parent, realisedElement, phraseFactory);
						break;
		
					default:
						break;
				}
			}
	
			return splitVerb;
		}
	
		/*
		 * Check if a sentence has an auxiliary (needed to relise questions
		 * correctly)
		 */
		private static function hasAuxiliary(phrase:PhraseElement):Boolean
		{
			return phrase.hasFeature(Feature.MODAL)
					|| phrase.getFeatureAsBoolean(Feature.PERFECT)
					|| phrase.getFeatureAsBoolean(Feature.PROGRESSIVE)
					|| Tense.FUTURE == phrase.getFeature(Feature.TENSE);
		}
	
		/**
		 * Controls the realisation of <em>wh</em> object questions.
		 * 
		 * @param keyword
		 *            the wh word
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param phraseFactory
		 *            the phrase factory to be used.
		 * @param subjects
		 *            the <code>List</code> of subjects in the clause.
		 * @return an <code>NLGElement</code> representing a subject that should
		 *         split the verb
		 */
		private static function realiseObjectWHInterrogative(keyword:String,
				phrase:PhraseElement, parent:SyntaxProcessor,
				realisedElement:ListElement, phraseFactory:NLGFactory):NLGElement
		{
			var splitVerb:NLGElement = null;
			realiseInterrogativeKeyWord(keyword, LexicalCategory.PRONOUN, parent, realisedElement, phraseFactory);
	
			// if (Tense.FUTURE != phrase.getFeature(Feature.TENSE)) &&
			// !copular) {
			if (!hasAuxiliary(phrase) && !VerbPhraseHelper.isCopular(phrase))
			{
				addDoAuxiliary(phrase, parent, phraseFactory, realisedElement);
			}
			else if (!phrase.getFeatureAsBoolean(Feature.PASSIVE))
			{
				splitVerb = realiseSubjects(phrase, parent);
			}
	
			return splitVerb;
		}
	
		/**
		 * Adds a <em>do</em> verb to the realisation of this clause.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param phraseFactory
		 *            the phrase factory to be used.
		 */
		private static function addDoAuxiliary(phrase:PhraseElement,
				parent:SyntaxProcessor, phraseFactory:NLGFactory,
				realisedElement:ListElement):void
		{
	
			var doPhrase:PhraseElement = phraseFactory.createVerbPhrase("do"); //$NON-NLS-1$
			doPhrase.setFeature(Feature.TENSE, phrase.getFeature(Feature.TENSE));
			doPhrase.setFeature(Feature.PERSON, phrase.getFeature(Feature.PERSON));
			doPhrase.setFeature(Feature.NUMBER, phrase.getFeature(Feature.NUMBER));
			realisedElement.addComponent(parent.realise(doPhrase));
		}
	
		/**
		 * Realises the key word of the interrogative. For example, <em>who</em>,
		 * <em>what</em>
		 * 
		 * @param keyWord
		 *            the key word of the interrogative.
		 * @param cat
		 *            the category (usually pronoun, but not in the case of
		 *            "how many")
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param phraseFactory
		 *            the phrase factory to be used.
		 */
		private static function realiseInterrogativeKeyWord(keyWord:String,
				cat:LexicalCategory, parent:SyntaxProcessor,
				realisedElement:ListElement, phraseFactory:NLGFactory):void
		{
	
			if (keyWord != null)
			{
				var question:NLGElement = phraseFactory.createWord(keyWord, cat);
				var currentElement:NLGElement = parent.realise(question);
	
				if (currentElement != null)
				{
					realisedElement.addComponent(currentElement);
				}
			}
		}
	
		/**
		 * Performs the realisation for YES/NO types of questions. This may involve
		 * adding an optional <em>do</em> auxiliary verb to the beginning of the
		 * clause. The method also determines if there is a subject that will split
		 * the verb group of the clause. For example, the clause
		 * <em>the man <b>should give</b> the woman the flower</em> has the verb
		 * group indicated in <b>bold</b>. The phrase is rearranged as yes/no
		 * question as
		 * <em><b>should</b> the man <b>give</b> the woman the flower</em> with the
		 * subject <em>the man</em> splitting the verb group.
		 * 
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 * @param phraseFactory
		 *            the phrase factory to be used.
		 * @param verbElement
		 *            the <code>NLGElement</code> representing the verb phrase for
		 *            this clause.
		 * @param subjects
		 *            the <code>List</code> of subjects in the clause.
		 * @return an <code>NLGElement</code> representing a subject that should
		 *         split the verb
		 */
		private static function realiseYesNo(phrase:PhraseElement,
				parent:SyntaxProcessor, verbElement:NLGElement,
				phraseFactory:NLGFactory, realisedElement:ListElement):NLGElement
		{
	
			var splitVerb:NLGElement = null;
	
			if (!(verbElement is VPPhraseSpec && VerbPhraseHelper.isCopular(VPPhraseSpec(verbElement).getVerb()))
					&& !phrase.getFeatureAsBoolean(Feature.PROGRESSIVE)
					&& !phrase.hasFeature(Feature.MODAL)
					&& Tense.FUTURE != phrase.getFeature(Feature.TENSE)
					&& !phrase.getFeatureAsBoolean(Feature.NEGATED)
					&& !phrase.getFeatureAsBoolean(Feature.PASSIVE))
			{
				addDoAuxiliary(phrase, parent, phraseFactory, realisedElement);
			} else {
				splitVerb = realiseSubjects(phrase, parent);
			}
			return splitVerb;
		}
	
		/**
		 * Realises the cue phrase for the clause if it exists.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 */
		private static function addCuePhrase(phrase:PhraseElement, parent:SyntaxProcessor, realisedElement:ListElement):void
		{
			var cuePhrase:NLGElement = phrase.getFeatureAsElement(Feature.CUE_PHRASE);
			var currentElement:NLGElement = parent.realise(cuePhrase);
	
			if (currentElement != null)
			{
				currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.CUE_PHRASE);
				realisedElement.addComponent(currentElement);
			}
		}
	
		/**
		 * Checks to see if this clause is a subordinate clause. If it is then the
		 * complementiser is added as a component to the realised element
		 * <b>unless</b> the complementiser has been suppressed.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the clause.
		 */
		private static function addComplementiser(phrase:PhraseElement,
				parent:SyntaxProcessor, realisedElement:ListElement):void
		{
	
			var currentElement:NLGElement;
	
			if (ClauseStatus.SUBORDINATE == phrase.getFeature(InternalFeature.CLAUSE_STATUS)
					&& !phrase.getFeatureAsBoolean(Feature.SUPRESSED_COMPLEMENTISER))
			{
				currentElement = parent.realise(phrase.getFeatureAsElement(Feature.COMPLEMENTISER));
	
				if (currentElement != null)
				{
					realisedElement.addComponent(currentElement);
				}
			}
		}
	
		/**
		 * Copies the front modifiers of the clause to the list of post-modifiers of
		 * the verb only if the phrase has infinitive form.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param verbElement
		 *            the <code>NLGElement</code> representing the verb phrase for
		 *            this clause.
		 */
		private static function copyFrontModifiers(phrase:PhraseElement, verbElement:NLGElement):void
		{
			var frontModifiers:Array = phrase.getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS);
			var clauseForm:Object = phrase.getFeature(Feature.FORM);
			var eachModifier:NLGElement;
			var len:int;
			var i:int;
			
			// bug fix by Chris Howell (Agfa) -- do not overwrite existing post-mods
			// in the VP
			if (verbElement != null)
			{
				var phrasePostModifiers:Array = phrase.getFeatureAsElementList(InternalFeature.POSTMODIFIERS);
	
				if (verbElement is PhraseElement)
				{
					var verbPostModifiers:Array = verbElement.getFeatureAsElementList(InternalFeature.POSTMODIFIERS);
	
					len = phrasePostModifiers.length;
					for (i = 0; i < len; i++)
					{
						eachModifier = phrasePostModifiers[i];
						// need to check that VP doesn't already contain the
						// post-modifier
						// this only happens if the phrase has already been realised
						// and later modified, with realiser called again. In that
						// case, postmods will be copied over twice
						if (verbPostModifiers.indexOf(eachModifier) == -1)
						{
							PhraseElement(verbElement).addPostModifier(eachModifier);
						}
					}
				}
			}
	
			// if (verbElement != null) {
			// verbElement.setFeature(InternalFeature.POSTMODIFIERS, phrase
			// .getFeature(InternalFeature.POSTMODIFIERS));
			// }
	
			if (Form.INFINITIVE == clauseForm)
			{
				phrase.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
	
				len = frontModifiers.length;
				for (i = 0; i < len; i++)
				{
					eachModifier = frontModifiers[i];
					if (verbElement is PhraseElement)
					{
						PhraseElement(verbElement).addPostModifier(eachModifier);
					}
				}
				phrase.removeFeature(InternalFeature.FRONT_MODIFIERS);
				if (verbElement != null)
				{
					verbElement.setFeature(InternalFeature.NON_MORPH, true);
				}
			}
		}
	
		/**
		 * Checks the discourse function of the clause and alters the form of the
		 * clause as necessary. The following algorithm is used: <br>
		 * 
		 * <pre>
		 * If the clause represents a direct or indirect object then 
		 *      If form is currently Imperative then
		 *           Set form to Infinitive
		 *           Suppress the complementiser
		 *      If form is currently Gerund and there are no subjects
		 *      	 Suppress the complementiser
		 * If the clause represents a subject then
		 *      Set the form to be Gerund
		 *      Suppress the complementiser
		 * </pre>
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 */
		private static function checkDiscourseFunction(phrase:PhraseElement):void
		{
			var subjects:Array = phrase.getFeatureAsElementList(InternalFeature.SUBJECTS);
			var clauseForm:Object = phrase.getFeature(Feature.FORM);
			var discourseValue:Object = phrase.getFeature(InternalFeature.DISCOURSE_FUNCTION);
	
			if (DiscourseFunction.OBJECT == discourseValue
					|| DiscourseFunction.INDIRECT_OBJECT == discourseValue)
			{
				if (Form.IMPERATIVE == clauseForm)
				{
					phrase.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
					phrase.setFeature(Feature.FORM, Form.INFINITIVE);
				}
				else if (Form.GERUND == clauseForm && subjects.length == 0)
				{
					phrase.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
				}
			}
			else if (DiscourseFunction.SUBJECT == discourseValue)
			{
				phrase.setFeature(Feature.FORM, Form.GERUND);
				phrase.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
			}
		}
	
		/**
		 * Checks the subjects of the phrase to determine if there is more than one
		 * subject. This ensures that the verb phrase is correctly set. Also set
		 * person correctly
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this clause.
		 * @param verbElement
		 *            the <code>NLGElement</code> representing the verb phrase for
		 *            this clause.
		 */
		private static function checkSubjectNumberPerson(phrase:PhraseElement, verbElement:NLGElement):void
		{
			var currentElement:NLGElement = null;
			var subjects:Array = phrase.getFeatureAsElementList(InternalFeature.SUBJECTS);
			var pluralSubjects:Boolean = false;
			var person:Person = null;
	
			if (subjects != null)
			{
				switch (subjects.length)
				{
					case 0:
						break;
		
					case 1:
						currentElement = subjects[0];
						// coordinated NP with "and" are plural (not coordinated NP with
						// "or")
						if (currentElement is CoordinatedPhraseElement && CoordinatedPhraseElement(currentElement).checkIfPlural())
							pluralSubjects = true;
						else if (currentElement.getFeature(Feature.NUMBER) == NumberAgreement.PLURAL)
							pluralSubjects = true;
						else if (currentElement.isA(PhraseCategory.NOUN_PHRASE)) {
							var currentHead:NLGElement = currentElement.getFeatureAsElement(InternalFeature.HEAD);
							person = Person(currentElement.getFeature(Feature.PERSON));
							if (!currentHead) break;
							if ((currentHead.getFeature(Feature.NUMBER) == NumberAgreement.PLURAL))
								pluralSubjects = true;
							else if (currentHead is ListElement)
							{
								pluralSubjects = true;
								/*
								 * } else if (currentElement is
								 * CoordinatedPhraseElement &&
								 * "and".equals(currentElement.getFeatureAsString(
								 * //$NON-NLS-1$ Feature.CONJUNCTION))) { pluralSubjects
								 * = true;
								 */
							}
						}
						break;
		
					default:
						pluralSubjects = true;
					}
			}
			if (verbElement != null)
			{
				verbElement.setFeature(Feature.NUMBER, pluralSubjects ? NumberAgreement.PLURAL : phrase.getFeature(Feature.NUMBER));
				if (person != null) verbElement.setFeature(Feature.PERSON, person);
			}
		}
	}
}
