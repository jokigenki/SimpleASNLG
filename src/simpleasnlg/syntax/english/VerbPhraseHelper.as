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
	import com.steamshift.collections.Stack;
	
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.InterrogativeType;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.framework.StringElement;
	import simpleasnlg.framework.WordElement;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	/**
	 * <p>
	 * This class contains static methods to help the syntax processor realise verb
	 * phrases. It adds auxiliary verbs into the element tree as required.
	 * </p>
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class VerbPhraseHelper
	{
	
		/**
		 * The main method for realising verb phrases.
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
			var vgComponents:Stack = null;
			var mainVerbRealisation:Stack = new Stack();
			var auxiliaryRealisation:Stack = new Stack();
	
			if (phrase != null)
			{
				vgComponents = createVerbGroup(parent, phrase);
				splitVerbGroup(vgComponents, mainVerbRealisation, auxiliaryRealisation);
	
				realisedElement = new ListElement();
	
				if (!phrase.hasFeature(InternalFeature.REALISE_AUXILIARY) || phrase.getFeatureAsBoolean(InternalFeature.REALISE_AUXILIARY))
				{
					realiseAuxiliaries(parent, realisedElement, auxiliaryRealisation);
	
					PhraseHelper.realiseList(parent, realisedElement, phrase.getPreModifiers(), DiscourseFunction.PRE_MODIFIER);
	
					realiseMainVerb(parent, phrase, mainVerbRealisation, realisedElement);
				}
				else if (isCopular(phrase.getHead()))
				{
					realiseMainVerb(parent, phrase, mainVerbRealisation, realisedElement);
					PhraseHelper.realiseList(parent, realisedElement, phrase.getPreModifiers(), DiscourseFunction.PRE_MODIFIER);
	
				} else {
					PhraseHelper.realiseList(parent, realisedElement, phrase.getPreModifiers(), DiscourseFunction.PRE_MODIFIER);
					realiseMainVerb(parent, phrase, mainVerbRealisation, realisedElement);
				}
				realiseComplements(parent, phrase, realisedElement);
				PhraseHelper.realiseList(parent, realisedElement, phrase.getPostModifiers(), DiscourseFunction.POST_MODIFIER);
			}
	
			return realisedElement;
		}
	
		/**
		 * Realises the auxiliary verbs in the verb group.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param realisedElement
		 *            the current realisation of the noun phrase.
		 * @param auxiliaryRealisation
		 *            the stack of auxiliary verbs.
		 */
		private static function realiseAuxiliaries(parent:SyntaxProcessor,
				realisedElement:ListElement, auxiliaryRealisation:Stack):void
		{
	
			var aux:NLGElement = null;
			var currentElement:NLGElement = null;
			while (auxiliaryRealisation.size > 0)
			{
				aux = auxiliaryRealisation.pop();
				currentElement = parent.realise(aux);
				if (currentElement != null)
				{
					realisedElement.addComponent(currentElement);
					currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION,
							DiscourseFunction.AUXILIARY);
				}
			}
		}
	
		/**
		 * Realises the main group of verbs in the phrase.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param mainVerbRealisation
		 *            the stack of the main verbs in the phrase.
		 * @param realisedElement
		 *            the current realisation of the noun phrase.
		 */
		private static function realiseMainVerb(parent:SyntaxProcessor,
				phrase:PhraseElement, mainVerbRealisation:Stack, realisedElement:ListElement):void {
	
			var currentElement:NLGElement = null;
			var main:NLGElement = null;
	
			while (mainVerbRealisation.size > 0)
			{
				main = mainVerbRealisation.pop();
				main.setFeature(Feature.INTERROGATIVE_TYPE, phrase.getFeature(Feature.INTERROGATIVE_TYPE));
				currentElement = parent.realise(main);
	
				if (currentElement != null)
				{
					realisedElement.addComponent(currentElement);
				}
			}
		}
	
		/**
		 * Realises the complements of this phrase.
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
	
			var indirects:ListElement = new ListElement();
			var directs:ListElement = new ListElement();
			var unknowns:ListElement = new ListElement();
			var discourseValue:Object = null;
			var currentElement:NLGElement = null;
	
			var list:Array = phrase.getFeatureAsElementList(InternalFeature.COMPLEMENTS);
			var len:int = list.length;
			for (var i:int = 0; i < len; i++)
			{
				var complement:NLGElement = list[i];
				discourseValue = complement.getFeature(InternalFeature.DISCOURSE_FUNCTION);
				currentElement = parent.realise(complement);
				if (currentElement != null)
				{
					currentElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.COMPLEMENT);
	
					if (DiscourseFunction.INDIRECT_OBJECT == discourseValue)
					{
						indirects.addComponent(currentElement);
					}
					else if (DiscourseFunction.OBJECT == discourseValue)
					{
						directs.addComponent(currentElement);
					} else {
						unknowns.addComponent(currentElement);
					}
				}
			}
			if (!InterrogativeType.isIndirectObject(phrase.getFeature(Feature.INTERROGATIVE_TYPE)))
			{
				realisedElement.addComponents(indirects.getChildren());
			}
			
			if (!phrase.getFeatureAsBoolean(Feature.PASSIVE))
			{
				if (!InterrogativeType.isObject(phrase.getFeature(Feature.INTERROGATIVE_TYPE)))
				{
					realisedElement.addComponents(directs.getChildren());
				}
				realisedElement.addComponents(unknowns.getChildren());
			}
		}
	
		/**
		 * Splits the stack of verb components into two sections. One being the verb
		 * associated with the main verb group, the other being associated with the
		 * auxiliary verb group.
		 * 
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 * @param mainVerbRealisation
		 *            the main group of verbs.
		 * @param auxiliaryRealisation
		 *            the auxiliary group of verbs.
		 */
		private static function splitVerbGroup(vgComponents:Stack, mainVerbRealisation:Stack, auxiliaryRealisation:Stack):void
		{
			var mainVerbSeen:Boolean = false;
	
			var len:int = vgComponents.size;
			for (var i:int = 0; i < len; i++)
			{
				var word:NLGElement = vgComponents.itemAt(i);
				if (!mainVerbSeen)
				{
					mainVerbRealisation.push(word);
					if (word.toString() != "not") { //$NON-NLS-1$
						mainVerbSeen = true;
					}
				} else {
					auxiliaryRealisation.push(word);
				}
			}
	
		}
	
		/**
		 * Creates a stack of verbs for the verb phrase. Additional auxiliary verbs
		 * are added as required based on the features of the verb phrase.
		 * 
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @return the verb group as a <code>Stack</code> of <code>NLGElement</code>
		 *         s.
		 */
		//@SuppressWarnings("deprecation")
		static private function createVerbGroup(parent:SyntaxProcessor, phrase:PhraseElement):Stack
		{
			 var actualModal:String = null;
			 var formValue:Object = phrase.getFeature(Feature.FORM);
			 var tenseValue:Tense = phrase.getTense();
			 var modal:String = phrase.getFeatureAsString(Feature.MODAL);
			 var modalPast:Boolean = false;
			 var vgComponents:Stack = new Stack();
			 var interrogative:Boolean = phrase.hasFeature(Feature.INTERROGATIVE_TYPE);
	
			if (Form.GERUND == formValue || Form.INFINITIVE == formValue)
			{
				tenseValue = Tense.PRESENT;
			}
	
			if (Form.INFINITIVE == formValue)
			{
				actualModal = "to"; //$NON-NLS-1$
			}
			else if (formValue == null || Form.NORMAL == formValue)
			{
				if (Tense.FUTURE == tenseValue
						&& modal == null
						&& ((!(phrase.getHead() is CoordinatedPhraseElement)) || (phrase
								.getHead() is CoordinatedPhraseElement && interrogative)))
				{
	
					actualModal = "will"; //$NON-NLS-1$
	
				}
				else if (modal != null)
				{
					actualModal = modal;
	
					if (Tense.PAST == tenseValue)
					{
						modalPast = true;
					}
				}
			}
	
			pushParticles(phrase, parent, vgComponents);
			var frontVG:NLGElement = grabHeadVerb(phrase, tenseValue, modal != null);
			checkImperativeInfinitive(formValue, frontVG);
	
			if (phrase.getFeatureAsBoolean(Feature.PASSIVE))
			{
				frontVG = addBe(frontVG, vgComponents, Form.PAST_PARTICIPLE);
			}
	
			if (phrase.getFeatureAsBoolean(Feature.PROGRESSIVE))
			{
				frontVG = addBe(frontVG, vgComponents, Form.PRESENT_PARTICIPLE);
			}
	
			if (phrase.getFeatureAsBoolean(Feature.PERFECT) || modalPast) {
				frontVG = addHave(frontVG, vgComponents, modal, tenseValue);
			}
	
			frontVG = pushIfModal(actualModal != null, phrase, frontVG, vgComponents);
			frontVG = createNot(phrase, vgComponents, frontVG, modal != null);
	
			if (frontVG != null)
			{
				pushFrontVerb(phrase, vgComponents, frontVG, formValue, interrogative);
			}
	
			pushModal(actualModal, phrase, vgComponents);
			return vgComponents;
		}
	
		/**
		 * Pushes the modal onto the stack of verb components.
		 * 
		 * @param actualModal
		 *            the modal to be used.
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 */
		private static function pushModal(actualModal:String, phrase:PhraseElement, vgComponents:Stack):void
		{
			if (actualModal != null && !phrase.getFeatureAsBoolean(InternalFeature.IGNORE_MODAL))
			{
				vgComponents.push(new InflectedWordElement(actualModal, LexicalCategory.MODAL));
			}
		}
	
		/**
		 * Pushes the front verb onto the stack of verb components.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 * @param frontVG
		 *            the first verb in the verb group.
		 * @param formValue
		 *            the <code>Form</code> of the phrase.
		 * @param interrogative
		 *            <code>true</code> if the phrase is interrogative.
		 */
		private static function pushFrontVerb(phrase:PhraseElement, vgComponents:Stack, frontVG:NLGElement, formValue:Object, interrogative:Boolean):void
		{
			if (Form.GERUND == formValue)
			{
				frontVG.setFeature(Feature.FORM, Form.PRESENT_PARTICIPLE);
				vgComponents.push(frontVG);
	
			}
			else if (Form.PAST_PARTICIPLE == formValue)
			{
				frontVG.setFeature(Feature.FORM, Form.PAST_PARTICIPLE);
				vgComponents.push(frontVG);
	
			}
			else if (Form.PRESENT_PARTICIPLE == formValue)
			{
				frontVG.setFeature(Feature.FORM, Form.PRESENT_PARTICIPLE);
				vgComponents.push(frontVG);
	
			}
			else if ((!(formValue == null || Form.NORMAL == formValue) || interrogative)
					&& !isCopular(phrase.getHead()) && vgComponents.size == 0)
			{
				// AG: fix below: if interrogative, only set non-morph feature in
				// case it's not WHO_SUBJECT OR WHAT_SUBJECT
				var interrogType:Object = phrase.getFeature(Feature.INTERROGATIVE_TYPE);
				if (!(InterrogativeType.WHO_SUBJECT == interrogType || InterrogativeType.WHAT_SUBJECT == interrogType))
				{
					frontVG.setFeature(InternalFeature.NON_MORPH, true);
				}
	
				vgComponents.push(frontVG);
	
			} else {
				var numToUse:NumberAgreement = determineNumber(phrase.getParent(), phrase);
				frontVG.setFeature(Feature.TENSE, phrase.getFeature(Feature.TENSE));
				frontVG.setFeature(Feature.PERSON, phrase.getFeature(Feature.PERSON));
				frontVG.setFeature(Feature.NUMBER, numToUse);
				vgComponents.push(frontVG);
			}
		}
	
		/**
		 * Adds <em>not</em> to the stack if the phrase is negated.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 * @param frontVG
		 *            the first verb in the verb group.
		 * @param hasModal
		 *            the phrase has a modal
		 * @return the new element for the front of the group.
		 */
		private static function createNot(phrase:PhraseElement, vgComponents:Stack, frontVG:NLGElement, hasModal:Boolean):NLGElement
		{
			var newFront:NLGElement = frontVG;
	
			if (phrase.getFeatureAsBoolean(Feature.NEGATED))
			{
				var factory:NLGFactory = phrase.getFactory();
	
				if (vgComponents.size > 0 || frontVG != null && isCopular(frontVG)) {
					vgComponents.push(new InflectedWordElement(
							"not", LexicalCategory.ADVERB)); //$NON-NLS-1$
				} else {
					if (frontVG != null && !hasModal) {
						frontVG.setFeature(Feature.NEGATED, true);
						vgComponents.push(frontVG);
					}
	
					vgComponents.push(new InflectedWordElement(
							"not", LexicalCategory.ADVERB)); //$NON-NLS-1$
	
					if (factory != null) {
						newFront = factory.createInflectedWord("do",
								LexicalCategory.VERB);
	
					} else {
						newFront = new InflectedWordElement(
								"do", LexicalCategory.VERB); //$NON-NLS-1$
					}
				}
			}
			return newFront;
		}
	
		/**
		 * Pushes the front verb on to the stack if the phrase has a modal.
		 * 
		 * @param hasModal
		 *            the phrase has a modal
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param frontVG
		 *            the first verb in the verb group.
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 * @return the new element for the front of the group.
		 */
		private static function pushIfModal(hasModal:Boolean, phrase:PhraseElement, frontVG:NLGElement, vgComponents:Stack):NLGElement
		{
			var newFront:NLGElement = frontVG;
			if (hasModal && !phrase.getFeatureAsBoolean(InternalFeature.IGNORE_MODAL))
			{
				if (frontVG != null)
				{
					frontVG.setFeature(InternalFeature.NON_MORPH, true);
					vgComponents.push(frontVG);
				}
				newFront = null;
			}
			return newFront;
		}
	
		/**
		 * Adds <em>have</em> to the stack.
		 * 
		 * @param frontVG
		 *            the first verb in the verb group.
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 * @param modal
		 *            the modal to be used.
		 * @param tenseValue
		 *            the <code>Tense</code> of the phrase.
		 * @return the new element for the front of the group.
		 */
		private static function addHave(frontVG:NLGElement, vgComponents:Stack, modal:String, tenseValue:Tense):NLGElement
		{
			var newFront:NLGElement = frontVG;
	
			if (frontVG != null)
			{
				frontVG.setFeature(Feature.FORM, Form.PAST_PARTICIPLE);
				vgComponents.push(frontVG);
			}
			newFront = new InflectedWordElement("have", LexicalCategory.VERB); //$NON-NLS-1$
			newFront.setFeature(Feature.TENSE, tenseValue);
			if (modal != null)
			{
				newFront.setFeature(InternalFeature.NON_MORPH, true);
			}
			return newFront;
		}
	
		/**
		 * Adds the <em>be</em> verb to the front of the group.
		 * 
		 * @param frontVG
		 *            the first verb in the verb group.
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 * @param frontForm
		 *            the form the current front verb is to take.
		 * @return the new element for the front of the group.
		 */
		private static function addBe(frontVG:NLGElement, vgComponents:Stack, frontForm:Form):NLGElement
		{
	
			if (frontVG != null)
			{
				frontVG.setFeature(Feature.FORM, frontForm);
				vgComponents.push(frontVG);
			}
			return new InflectedWordElement("be", LexicalCategory.VERB); //$NON-NLS-1$
		}
	
		/**
		 * Checks to see if the phrase is in imperative, infinitive or bare
		 * infinitive form. If it is then no morphology is done on the main verb.
		 * 
		 * @param formValue
		 *            the <code>Form</code> of the phrase.
		 * @param frontVG
		 *            the first verb in the verb group.
		 */
		private static function checkImperativeInfinitive(formValue:Object, frontVG:NLGElement):void
		{
			if ((Form.IMPERATIVE == formValue
					|| Form.INFINITIVE == formValue
					|| Form.BARE_INFINITIVE == formValue)
					&& frontVG != null)
			{
				frontVG.setFeature(InternalFeature.NON_MORPH, true);
			}
		}
	
		/**
		 * Grabs the head verb of the verb phrase and sets it to future tense if the
		 * phrase is future tense. It also turns off negation if the group has a
		 * modal.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param tenseValue
		 *            the <code>Tense</code> of the phrase.
		 * @param hasModal
		 *            <code>true</code> if the verb phrase has a modal.
		 * @return the modified head element
		 */
		private static function grabHeadVerb(phrase:PhraseElement, tenseValue:Tense, hasModal:Boolean):NLGElement
		{
			var frontVG:NLGElement = phrase.getHead();
	
			if (frontVG != null)
			{
				if (frontVG is WordElement)
				{
					frontVG = new InflectedWordElement(WordElement(frontVG));
				}
	
				//AG: tense value should always be set on frontVG 
				if (tenseValue != null)
				{
					frontVG.setFeature(Feature.TENSE, tenseValue);
				}
	
				// if (Tense.FUTURE.equals(tenseValue) && frontVG != null) {
				// frontVG.setFeature(Feature.TENSE, Tense.FUTURE);
				// }
	
				if (hasModal)
				{
					frontVG.setFeature(Feature.NEGATED, false);
				}
			}
	
			return frontVG;
		}
	
		/**
		 * Pushes the particles of the main verb onto the verb group stack.
		 * 
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @param parent
		 *            the parent <code>SyntaxProcessor</code> that will do the
		 *            realisation of the complementiser.
		 * @param vgComponents
		 *            the stack of verb components in the verb group.
		 */
		private static function pushParticles(phrase:PhraseElement, parent:SyntaxProcessor , vgComponents:Stack):void
		{
			var particle:Object = phrase.getFeature(Feature.PARTICLE);
	
			if (particle is String)
			{
				vgComponents.push(new StringElement(String(particle)));
			}
			else if (particle is NLGElement)
			{
				vgComponents.push(parent.realise(NLGElement(particle)));
			}
		}
	
		/**
		 * Determines the number agreement for the phrase ensuring that any number
		 * agreement on the parent element is inherited by the phrase.
		 * 
		 * @param parent
		 *            the parent element of the phrase.
		 * @param phrase
		 *            the <code>PhraseElement</code> representing this noun phrase.
		 * @return the <code>NumberAgreement</code> to be used for the phrase.
		 */
		private static function determineNumber(parent:NLGElement, phrase:PhraseElement):NumberAgreement
		{
			var numberValue:Object = phrase.getFeature(Feature.NUMBER);
			var number:NumberAgreement = null;
			if (numberValue != null && numberValue is NumberAgreement)
			{
				number = NumberAgreement(numberValue);
			} else {
				number = NumberAgreement.SINGULAR;
			}
	
			// Ehud Reiter = modified below to force number from VP for WHAT_SUBJECT and WHO_SUBJECT interrogatuves
			if (parent is PhraseElement)
			{
				if (parent.isA(PhraseCategory.CLAUSE)
						&& (PhraseHelper.isExpletiveSubject(PhraseElement(parent)) ||
								InterrogativeType.WHO_SUBJECT == parent.getFeature(Feature.INTERROGATIVE_TYPE) ||
								InterrogativeType.WHAT_SUBJECT == parent.getFeature(Feature.INTERROGATIVE_TYPE))
						&& isCopular(phrase.getHead()))
				{
	
					if (hasPluralComplement(phrase
							.getFeatureAsElementList(InternalFeature.COMPLEMENTS))) {
						number = NumberAgreement.PLURAL;
					} else {
						number = NumberAgreement.SINGULAR;
					}
				}
			}
			return number;
		}
	
		/**
		 * Checks to see if any of the complements to the phrase are plural.
		 * 
		 * @param complements
		 *            the list of complements of the phrase.
		 * @return <code>true</code> if any of the complements are plural.
		 */
		private static function hasPluralComplement(complements:Array):Boolean
		{
			var plural:Boolean = false;
			var eachComplement:NLGElement = null;
			var numberValue:Object = null;
	
			var i:int = 0;
			while (i < complements.length && !plural)
			{
				eachComplement = complements[i++];
	
				if (eachComplement != null && eachComplement.isA(PhraseCategory.NOUN_PHRASE))
				{
					numberValue = eachComplement.getFeature(Feature.NUMBER);
					if (numberValue != null && NumberAgreement.PLURAL == numberValue)
					{
						plural = true;
					}
				}
			}
			return plural;
		}
	
		/**
		 * Checks to see if the base form of the word is copular, i.e. <em>be</em>.
		 * 
		 * @param element
		 *            the element to be checked
		 * @return <code>true</code> if the element is copular.
		 */
		public static function isCopular(element:NLGElement):Boolean
		{
			var copular:Boolean = false;
	
			if (element is InflectedWordElement)
			{
				copular = "be" == InflectedWordElement(element).getBaseForm().toLowerCase();
	
			}
			else if (element is WordElement)
			{
				copular = "be" == WordElement(element).getBaseForm().toLowerCase();
	
			}
			else if (element is PhraseElement)
			{
				// get the head and check if it's "be"
				var head:NLGElement = element is SPhraseSpec
						? SPhraseSpec(element).getVerb()
						: PhraseElement(element).getHead();
	
				if (head != null)
				{
					copular = head is WordElement && "be" == WordElement(head).getBaseForm();
				}
			}
	
			return copular;
		}
	}
}
