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
	import com.steamshift.utils.StringUtils;
	
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.features.Gender;
	import simpleasnlg.features.Inflection;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Person;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.StringElement;
	import simpleasnlg.framework.WordElement;
	
	/**
	 * <p>
	 * This abstract class contains a number of rules for doing simple inflection.
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
	 * @version 4.0 16-Mar-2011 modified to use correct base form (ER)
	 */
	public class MorphologyRules
	{
		/**
		 * A triple array of Pronouns organised by singular/plural,
		 * possessive/reflexive/subjective/objective and by gender/person.
		 */
		//@SuppressWarnings("nls")
		private static const PRONOUNS:Vector.<Vector.<Vector.<String>>> = new <Vector.<Vector.<String>>>[
			new <Vector.<String>>[
				new <String>["I", "you", "he", "she", "it"],
				new <String>["me", "you", "him", "her", "it"],
				new <String>["myself", "yourself", "himself", "herself", "itself"],
				new <String>["mine", "yours", "his", "hers", "its"],
				new <String>["my", "your", "his", "her", "its"]
			],
			new <Vector.<String>>[
				new <String>["we", "you", "they", "they", "they"],
				new <String>["us", "you", "them", "them", "them"],
				new <String>["ourselves", "yourselves", "themselves", "themselves", "themselves"],
				new <String>["ours", "yours", "theirs", "theirs", "theirs"],
				new <String>["our", "your", "their", "their", "their"]
			]];
	
		private static const WH_PRONOUNS:Vector.<String> = new <String>["who", "what", "which",
				"where", "why", "how", "how many"];
	
		/**
		 * This method performs the morphology for nouns.
		 * 
		 * @param element
		 *            the <code>InflectedWordElement</code>.
		 * @param baseWord
		 *            the <code>WordElement</code> as created from the lexicon
		 *            entry.
		 * @return a <code>StringElement</code> representing the word after
		 *         inflection.
		 */
		public static function doNounMorphology(element:InflectedWordElement, baseWord:WordElement):StringElement
		{
			var realised:String = "";
	
			// base form from baseWord if it exists, otherwise from element
			var baseForm:String = getBaseForm(element, baseWord);
	
			if (element.isPlural() && !element.getFeatureAsBoolean(LexicalFeature.PROPER))
			{
	
				var pluralForm:String = null;
	
				// AG changed: now check if default infl is uncount
				// if (element.getFeatureAsBoolean(LexicalFeature.NON_COUNT)
				// .booleanValue()) {
				// pluralForm = baseForm;
				var elementDefaultInfl:String = element.getFeatureAsString(LexicalFeature.DEFAULT_INFL);
				if (elementDefaultInfl != null && elementDefaultInfl == "uncount")
				{
					pluralForm = baseForm;
				} else {
					pluralForm = element.getFeatureAsString(LexicalFeature.PLURAL);
				}
	
				if (pluralForm == null && baseWord != null) {
					// AG changed: now check if default infl is uncount
					// if (baseWord.getFeatureAsBoolean(LexicalFeature.NON_COUNT)
					// .booleanValue()) {
					// pluralForm = baseForm;
					var baseDefaultInfl:String = baseWord.getFeatureAsString(LexicalFeature.DEFAULT_INFL);
					if (baseDefaultInfl != null && baseDefaultInfl == "uncount")
					{
						pluralForm = baseForm;
					} else {
						pluralForm = baseWord.getFeatureAsString(LexicalFeature.PLURAL);
					}
				}
	
				if (pluralForm == null)
				{
					var pattern:Object = element.getFeature(LexicalFeature.DEFAULT_INFL);
					if (Inflection.GRECO_LATIN_REGULAR == pattern)
					{
						pluralForm = buildGrecoLatinPluralNoun(baseForm);
					} else {
						pluralForm = buildRegularPluralNoun(baseForm);
					}
				}
				realised += pluralForm;
	
			} else {
				realised += baseForm;
			}
	
			realised = checkPossessive(element, realised);
			var realisedElement:StringElement = new StringElement(realised.toString());
			realisedElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, element.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			return realisedElement;
		}
	
		/**
		 * Builds a plural for regular nouns. The rules are performed in this order:
		 * <ul>
		 * <li>For nouns ending <em>-Cy</em>, where C is any consonant, the ending
		 * becomes <em>-ies</em>. For example, <em>fly</em> becomes <em>flies</em>.</li>
		 * <li>For nouns ending <em>-ch</em>, <em>-s</em>, <em>-sh</em>, <em>-x</em>
		 * or <em>-z</em> the ending becomes <em>-es</em>. For example, <em>box</em>
		 * becomes <em>boxes</em>.</li>
		 * <li>All other nouns have <em>-s</em> appended the other end. For example,
		 * <em>dog</em> becomes <em>dogs</em>.</li>
		 * </ul>
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @return the inflected word.
		 */
		private static function buildRegularPluralNoun(baseForm:String):String 
		{
			var plural:String = null;
			if (baseForm != null)
			{
				if (baseForm.match(".*[b-z&&[^eiou]]y\\b"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("y\\b"), "ies"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (baseForm.match(".*[szx(ch)(sh)]\\b"))
				{ //$NON-NLS-1$
					plural = baseForm + "es"; //$NON-NLS-1$
				} else {
					plural = baseForm + "s"; //$NON-NLS-1$
				}
			}
			return plural;
		}
	
		/**
		 * Builds a plural for Greco-Latin regular nouns. The rules are performed in
		 * this order:
		 * <ul>
		 * <li>For nouns ending <em>-us</em> the ending becomes <em>-i</em>. For
		 * example, <em>focus</em> becomes <em>foci</em>.</li>
		 * <li>For nouns ending <em>-ma</em> the ending becomes <em>-mata</em>. For
		 * example, <em>trauma</em> becomes <em>traumata</em>.</li>
		 * <li>For nouns ending <em>-a</em> the ending becomes <em>-ae</em>. For
		 * example, <em>larva</em> becomes <em>larvae</em>.</li>
		 * <li>For nouns ending <em>-um</em> or <em>-on</em> the ending becomes
		 * <em>-a</em>. For example, <em>taxon</em> becomes <em>taxa</em>.</li>
		 * <li>For nouns ending <em>-sis</em> the ending becomes <em>-ses</em>. For
		 * example, <em>analysis</em> becomes <em>analyses</em>.</li>
		 * <li>For nouns ending <em>-is</em> the ending becomes <em>-ides</em>. For
		 * example, <em>cystis</em> becomes <em>cystides</em>.</li>
		 * <li>For nouns ending <em>-men</em> the ending becomes <em>-mina</em>. For
		 * example, <em>foramen</em> becomes <em>foramina</em>.</li>
		 * <li>For nouns ending <em>-ex</em> the ending becomes <em>-ices</em>. For
		 * example, <em>index</em> becomes <em>indices</em>.</li>
		 * <li>For nouns ending <em>-x</em> the ending becomes <em>-ces</em>. For
		 * example, <em>matrix</em> becomes <em>matrices</em>.</li>
		 * </ul>
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @return the inflected word.
		 */
		private static function buildGrecoLatinPluralNoun(baseForm:String):String
		{
			var plural:String = null;
			if (baseForm != null)
			{
				if (StringUtils.endsWith(baseForm, "us"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("us\\b"), "i"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "ma"))
				{ //$NON-NLS-1$
					plural = baseForm + "ta"; //$NON-NLS-1$
				}
				else if (StringUtils.endsWith(baseForm, "a"))
				{ //$NON-NLS-1$
					plural = baseForm + "e"; //$NON-NLS-1$
				}
				else if (baseForm.match(".*[(um)(on)]\\b"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("[(um)(on)]\\b"), "a"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "sis"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("sis\\b"), "ses"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "is"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("is\\b"), "ides"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "men"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("men\\b"), "mina"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "ex"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("ex\\b"), "ices"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "x"))
				{ //$NON-NLS-1$
					plural = baseForm.replace(new RegExp("x\\b"), "ces"); //$NON-NLS-1$ //$NON-NLS-2$
				} else {
					plural = baseForm;
				}
			}
			return plural;
		}
	
		/**
		 * This method performs the morphology for verbs.
		 * 
		 * @param element
		 *            the <code>InflectedWordElement</code>.
		 * @param baseWord
		 *            the <code>WordElement</code> as created from the lexicon
		 *            entry.
		 * @return a <code>StringElement</code> representing the word after
		 *         inflection.
		 */
		public static function doVerbMorphology(element:InflectedWordElement, baseWord:WordElement):NLGElement
		{
			var realised:String = null;
			var numberValue:Object = element.getFeature(Feature.NUMBER);
			var personValue:Object = element.getFeature(Feature.PERSON);
			var tense:Object = element.getFeature(Feature.TENSE);
			var tenseValue:Tense;
	
			// AG: change to avoid deprecated getTense
			// if tense value is Tense, cast it, else default to present
			if (tense is Tense) {
				tenseValue = Tense(tense);
			} else {
				tenseValue = Tense.PRESENT;
			}
	
			var formValue:Object = element.getFeature(Feature.FORM);
			var patternValue:Object = element.getFeature(LexicalFeature.DEFAULT_INFL);
	
			// base form from baseWord if it exists, otherwise from element
			var baseForm:String = getBaseForm(element, baseWord);
	
			if (element.getFeatureAsBoolean(Feature.NEGATED) || Form.BARE_INFINITIVE == formValue)
			{
				realised = baseForm;
			}
			else if (Form.PRESENT_PARTICIPLE == formValue)
			{
				realised = element.getFeatureAsString(LexicalFeature.PRESENT_PARTICIPLE);
	
				if (realised == null && baseWord != null)
				{
					realised = baseWord.getFeatureAsString(LexicalFeature.PRESENT_PARTICIPLE);
				}
	
				if (realised == null)
				{
					if (Inflection.REGULAR_DOUBLE == patternValue)
					{
						realised = buildDoublePresPartVerb(baseForm);
					} else {
						realised = buildRegularPresPartVerb(baseForm);
					}
				}
			}
			else if (Tense.PAST == tenseValue || Form.PAST_PARTICIPLE == formValue)
			{
				if (Form.PAST_PARTICIPLE == formValue)
				{
					realised = element.getFeatureAsString(LexicalFeature.PAST_PARTICIPLE);
	
					if (realised == null && baseWord != null)
					{
						realised = baseWord.getFeatureAsString(LexicalFeature.PAST_PARTICIPLE);
					}
	
					if (realised == null)
					{
						if ("be" == baseForm.toLowerCase())
						{ //$NON-NLS-1$
							realised = "been"; //$NON-NLS-1$
						}
						else if (Inflection.REGULAR_DOUBLE == patternValue)
						{
							realised = buildDoublePastVerb(baseForm);
						} else {
							realised = buildRegularPastVerb(baseForm, numberValue);
						}
					}
				} else {
					realised = element.getFeatureAsString(LexicalFeature.PAST);
	
					if (realised == null && baseWord != null)
					{
						realised = baseWord.getFeatureAsString(LexicalFeature.PAST);
					}
	
					if (realised == null)
					{
						if (Inflection.REGULAR_DOUBLE == patternValue)
						{
							realised = buildDoublePastVerb(baseForm);
						} else {
							realised = buildRegularPastVerb(baseForm, numberValue);
						}
					}
				}
			}
			else if ((numberValue == null || NumberAgreement.SINGULAR == numberValue)
					&& (personValue == null || Person.THIRD == personValue)
					&& (tenseValue == null || Tense.PRESENT == tenseValue))
			{
				realised = element.getFeatureAsString(LexicalFeature.PRESENT3S);
	
				if (realised == null && baseWord != null && "be" != baseForm.toLowerCase())
				{ //$NON-NLS-1$
					realised = baseWord.getFeatureAsString(LexicalFeature.PRESENT3S);
				}
				if (realised == null)
				{
					realised = buildPresent3SVerb(baseForm);
				}
			} else {
				if ("be" == baseForm.toLowerCase())
				{ //$NON-NLS-1$
					if (Person.FIRST == personValue && (NumberAgreement.SINGULAR == numberValue || numberValue == null))
					{
						realised = "am"; //$NON-NLS-1$
					} else {
						realised = "are"; //$NON-NLS-1$
					}
				} else {
					realised = baseForm;
				}
			}
			var realisedElement:StringElement = new StringElement(realised);
			realisedElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, element.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			return realisedElement;
		}
	
		/**
		 * return the base form of a word
		 * 
		 * @param element
		 * @param baseWord
		 * @return
		 */
		private static function getBaseForm(element:InflectedWordElement, baseWord:WordElement):String
		{
			// unclear what the right behaviour should be
			// for now, prefer baseWord.getBaseForm() to element.getBaseForm() for
			// verbs (ie, "is" mapped to "be")
			// but prefer element.getBaseForm() to baseWord.getBaseForm() for other
			// words (ie, "children" not mapped to "child")
	
			// AG: changed this to get the default spelling variant
			// needed to preserve spelling changes in the VP
	
			if (LexicalCategory.VERB == element.getCategory())
			{
				if (baseWord != null && baseWord.getDefaultSpellingVariant() != null)
					return baseWord.getDefaultSpellingVariant();
				else
					return element.getBaseForm();
			} else {
				if (element.getBaseForm() != null)
					return element.getBaseForm();
				else if (baseWord == null)
					return null;
				else
					return baseWord.getDefaultSpellingVariant();
			}
	
			// if (LexicalCategory.VERB == element.getCategory()) {
			// if (baseWord != null && baseWord.getBaseForm() != null)
			// return baseWord.getBaseForm();
			// else
			// return element.getBaseForm();
			// } else {
			// if (element.getBaseForm() != null)
			// return element.getBaseForm();
			// else if (baseWord == null)
			// return null;
			// else
			// return baseWord.getBaseForm();
			// }
		}
	
		/**
		 * Checks to see if the noun is possessive. If it is then nouns in ending in
		 * <em>-s</em> become <em>-s'</em> while every other noun has <em>-'s</em> appended to
		 * the end.
		 * 
		 * @param element
		 *            the <code>InflectedWordElement</code>
		 * @param realised
		 *            the realisation of the word.
		 */
		private static function checkPossessive(element:InflectedWordElement, realised:String):String
		{
			if (element.getFeatureAsBoolean(Feature.POSSESSIVE))
			{
				if (realised.charAt(realised.length - 1) == 's')
				{
					realised += '\'';
				} else {
					realised += "'s"; //$NON-NLS-1$
				}
			}
			
			return realised;
		}
	
		/**
		 * Builds the third-person singular form for regular verbs. The rules are
		 * performed in this order:
		 * <ul>
		 * <li>If the verb is <em>be</em> the realised form is <em>is</em>.</li>
		 * <li>For verbs ending <em>-ch</em>, <em>-s</em>, <em>-sh</em>, <em>-x</em>
		 * or <em>-z</em> the ending becomes <em>-es</em>. For example,
		 * <em>preach</em> becomes <em>preaches</em>.</li>
		 * <li>For verbs ending <em>-y</em> the ending becomes <em>-ies</em>. For
		 * example, <em>fly</em> becomes <em>flies</em>.</li>
		 * <li>For every other verb, <em>-s</em> is added to the end of the word.</li>
		 * </ul>
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @return the inflected word.
		 */
		private static function buildPresent3SVerb(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				if (baseForm.toLowerCase() == "be")
				{ //$NON-NLS-1$
					morphology = "is"; //$NON-NLS-1$
				}
				else if (baseForm.match(".*[szx(ch)(sh)]\\b"))
				{ //$NON-NLS-1$
					morphology = baseForm + "es"; //$NON-NLS-1$
				}
				else if (baseForm.match(".*[b-z&&[^eiou]]y\\b"))
				{ //$NON-NLS-1$
					morphology = baseForm.replace(new RegExp("y\\b"), "ies"); //$NON-NLS-1$ //$NON-NLS-2$
				} else {
					morphology = baseForm + "s"; //$NON-NLS-1$
				}
			}
			return morphology;
		}
	
		/**
		 * Builds the past-tense form for regular verbs. The rules are performed in
		 * this order:
		 * <ul>
		 * <li>If the verb is <em>be</em> and the number agreement is plural then
		 * the realised form is <em>were</em>.</li>
		 * <li>If the verb is <em>be</em> and the number agreement is singular then
		 * the realised form is <em>was</em>.</li>
		 * <li>For verbs ending <em>-e</em> the ending becomes <em>-ed</em>. For
		 * example, <em>chased</em> becomes <em>chased</em>.</li>
		 * <li>For verbs ending <em>-Cy</em>, where C is any consonant, the ending
		 * becomes <em>-ied</em>. For example, <em>dry</em> becomes <em>dried</em>.</li>
		 * <li>For every other verb, <em>-ed</em> is added to the end of the word.</li>
		 * </ul>
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @param number
		 *            the number agreement for the word.
		 * @return the inflected word.
		 */
		private static function buildRegularPastVerb(baseForm:String, number:Object):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				if (baseForm.toLowerCase() == "be")
				{ //$NON-NLS-1$
					if (NumberAgreement.PLURAL == number)
					{
						morphology = "were"; //$NON-NLS-1$
					} else {
						morphology = "was"; //$NON-NLS-1$
					}
				}
				else if (StringUtils.endsWith(baseForm, "e"))
				{ //$NON-NLS-1$
					morphology = baseForm + "d"; //$NON-NLS-1$
				}
				else if (baseForm.match(".*[b-z&&[^eiou]]y\\b"))
				{ //$NON-NLS-1$
					morphology = baseForm.replace(new RegExp("y\\b"), "ied"); //$NON-NLS-1$ //$NON-NLS-2$
				} else {
					morphology = baseForm + "ed"; //$NON-NLS-1$
				}
			}
			return morphology;
		}
	
		/**
		 * Builds the past-tense form for verbs that follow the doubling form of the
		 * last consonant. <em>-ed</em> is added to the end after the last consonant
		 * is doubled. For example, <em>tug</em> becomes <em>tugged</em>.
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @return the inflected word.
		 */
		private static function buildDoublePastVerb(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				morphology = baseForm + baseForm.charAt(baseForm.length - 1) + "ed"; //$NON-NLS-1$
			}
			return morphology;
		}
	
		/**
		 * Builds the present participle form for regular verbs. The rules are
		 * performed in this order:
		 * <ul>
		 * <li>If the verb is <em>be</em> then the realised form is <em>being</em>.</li>
		 * <li>For verbs ending <em>-ie</em> the ending becomes <em>-ying</em>. For
		 * example, <em>tie</em> becomes <em>tying</em>.</li>
		 * <li>For verbs ending <em>-ee</em>, <em>-oe</em> or <em>-ye</em> then
		 * <em>-ing</em> is added to the end. For example, <em>canoe</em> becomes
		 * <em>canoeing</em>.</li>
		 * <li>For other verbs ending in <em>-e</em> the ending becomes
		 * <em>-ing</em>. For example, <em>chase</em> becomes <em>chasing</em>.</li>
		 * <li>For all other verbs, <em>-ing</em> is added to the end. For example,
		 * <em>dry</em> becomes <em>drying</em>.</li>
		 * </ul>
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @param number
		 *            the number agreement for the word.
		 * @return the inflected word.
		 */
		private static function buildRegularPresPartVerb(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				if (baseForm.toLowerCase() == "be")
				{ //$NON-NLS-1$
					morphology = "being"; //$NON-NLS-1$
				}
				else if (StringUtils.endsWith(baseForm, "ie"))
				{ //$NON-NLS-1$
					morphology = baseForm.replace(new RegExp("ie\\b"), "ying"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (baseForm.match(".*[^iyeo]e\\b"))
				{ //$NON-NLS-1$
					morphology = baseForm.replace(new RegExp("e\\b"), "ing"); //$NON-NLS-1$ //$NON-NLS-2$
				} else {
					morphology = baseForm + "ing"; //$NON-NLS-1$
				}
			}
			return morphology;
		}
	
		/**
		 * Builds the present participle form for verbs that follow the doubling
		 * form of the last consonant. <em>-ing</em> is added to the end after the
		 * last consonant is doubled. For example, <em>tug</em> becomes
		 * <em>tugging</em>.
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @return the inflected word.
		 */
		private static function buildDoublePresPartVerb(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				morphology = baseForm + baseForm.charAt(baseForm.length - 1) + "ing"; //$NON-NLS-1$
			}
			return morphology;
		}
	
		/**
		 * This method performs the morphology for adjectives.
		 * 
		 * @param element
		 *            the <code>InflectedWordElement</code>.
		 * @param baseWord
		 *            the <code>WordElement</code> as created from the lexicon
		 *            entry.
		 * @return a <code>StringElement</code> representing the word after
		 *         inflection.
		 */
		public static function doAdjectiveMorphology(element:InflectedWordElement, baseWord:WordElement):NLGElement
		{
			var realised:String = null;
			var patternValue:Object = element.getFeature(LexicalFeature.DEFAULT_INFL);
	
			// base form from baseWord if it exists, otherwise from element
			var baseForm:String = getBaseForm(element, baseWord);
	
			if (element.getFeatureAsBoolean(Feature.IS_COMPARATIVE))
			{
				realised = element.getFeatureAsString(LexicalFeature.COMPARATIVE);
	
				if (realised == null && baseWord != null)
				{
					realised = baseWord.getFeatureAsString(LexicalFeature.COMPARATIVE);
				}
				if (realised == null)
				{
					if (Inflection.REGULAR_DOUBLE == patternValue)
					{
						realised = buildDoubleCompAdjective(baseForm);
					} else {
						realised = buildRegularComparative(baseForm);
					}
				}
			}
			else if (element.getFeatureAsBoolean(Feature.IS_SUPERLATIVE))
			{
				realised = element.getFeatureAsString(LexicalFeature.SUPERLATIVE);
	
				if (realised == null && baseWord != null) {
					realised = baseWord
							.getFeatureAsString(LexicalFeature.SUPERLATIVE);
				}
				if (realised == null)
				{
					if (Inflection.REGULAR_DOUBLE == patternValue)
					{
						realised = buildDoubleSuperAdjective(baseForm);
					} else {
						realised = buildRegularSuperlative(baseForm);
					}
				}
			} else {
				realised = baseForm;
			}
			var realisedElement:StringElement = new StringElement(realised);
			realisedElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, element.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			return realisedElement;
		}
	
		/**
		 * Builds the comparative form for adjectives that follow the doubling form
		 * of the last consonant. <em>-er</em> is added to the end after the last
		 * consonant is doubled. For example, <em>fat</em> becomes <em>fatter</em>.
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @return the inflected word.
		 */
		private static function buildDoubleCompAdjective(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				morphology = baseForm + baseForm.charAt(baseForm.length - 1) + "er"; //$NON-NLS-1$
			}
			return morphology;
		}
	
		/**
		 * Builds the comparative form for regular adjectives. The rules are
		 * performed in this order:
		 * <ul>
		 * <li>For verbs ending <em>-Cy</em>, where C is any consonant, the ending
		 * becomes <em>-ier</em>. For example, <em>brainy</em> becomes
		 * <em>brainier</em>.</li>
		 * <li>For verbs ending <em>-e</em> the ending becomes <em>-er</em>. For
		 * example, <em>fine</em> becomes <em>finer</em>.</li>
		 * <li>For all other verbs, <em>-er</em> is added to the end. For example,
		 * <em>clear</em> becomes <em>clearer</em>.</li>
		 * </ul>
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @param number
		 *            the number agreement for the word.
		 * @return the inflected word.
		 */
		private static function buildRegularComparative(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				if (baseForm.match(".*[b-z&&[^eiou]]y\\b"))
				{ //$NON-NLS-1$
					morphology = baseForm.replace(new RegExp("y\\b"), "ier"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "e"))
				{ //$NON-NLS-1$
					morphology = baseForm + "r"; //$NON-NLS-1$
				} else {
					morphology = baseForm + "er"; //$NON-NLS-1$
				}
			}
			return morphology;
		}
	
		/**
		 * Builds the superlative form for adjectives that follow the doubling form
		 * of the last consonant. <em>-est</em> is added to the end after the last
		 * consonant is doubled. For example, <em>fat</em> becomes <em>fattest</em>.
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @return the inflected word.
		 */
		private static function buildDoubleSuperAdjective(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				morphology = baseForm + baseForm.charAt(baseForm.length - 1) + "est"; //$NON-NLS-1$
			}
			return morphology;
		}
	
		/**
		 * Builds the superlative form for regular adjectives. The rules are
		 * performed in this order:
		 * <ul>
		 * <li>For verbs ending <em>-Cy</em>, where C is any consonant, the ending
		 * becomes <em>-iest</em>. For example, <em>brainy</em> becomes
		 * <em>brainiest</em>.</li>
		 * <li>For verbs ending <em>-e</em> the ending becomes <em>-est</em>. For
		 * example, <em>fine</em> becomes <em>finest</em>.</li>
		 * <li>For all other verbs, <em>-est</em> is added to the end. For example,
		 * <em>clear</em> becomes <em>clearest</em>.</li>
		 * </ul>
		 * 
		 * @param baseForm
		 *            the base form of the word.
		 * @param number
		 *            the number agreement for the word.
		 * @return the inflected word.
		 */
		private static function buildRegularSuperlative(baseForm:String):String
		{
			var morphology:String = null;
			if (baseForm != null)
			{
				if (baseForm.match(".*[b-z&&[^eiou]]y\\b"))
				{ //$NON-NLS-1$
					morphology = baseForm.replace(new RegExp("y\\b"), "iest"); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else if (StringUtils.endsWith(baseForm, "e"))
				{ //$NON-NLS-1$
					morphology = baseForm + "st"; //$NON-NLS-1$
				} else {
					morphology = baseForm + "est"; //$NON-NLS-1$
				}
			}
			return morphology;
		}
	
		/**
		 * This method performs the morphology for adverbs.
		 * 
		 * @param element
		 *            the <code>InflectedWordElement</code>.
		 * @param baseWord
		 *            the <code>WordElement</code> as created from the lexicon
		 *            entry.
		 * @return a <code>StringElement</code> representing the word after
		 *         inflection.
		 */
		public static function doAdverbMorphology(element:InflectedWordElement, baseWord:WordElement):NLGElement
		{
			var realised:String = null;
	
			// base form from baseWord if it exists, otherwise from element
			var baseForm:String = getBaseForm(element, baseWord);
	
			if (element.getFeatureAsBoolean(Feature.IS_COMPARATIVE))
			{
				realised = element.getFeatureAsString(LexicalFeature.COMPARATIVE);
	
				if (realised == null && baseWord != null)
				{
					realised = baseWord.getFeatureAsString(LexicalFeature.COMPARATIVE);
				}
				if (realised == null)
				{
					realised = buildRegularComparative(baseForm);
				}
			}
			else if (element.getFeatureAsBoolean(Feature.IS_SUPERLATIVE))
			{
				realised = element.getFeatureAsString(LexicalFeature.SUPERLATIVE);
	
				if (realised == null && baseWord != null)
				{
					realised = baseWord.getFeatureAsString(LexicalFeature.SUPERLATIVE);
				}
				if (realised == null)
				{
					realised = buildRegularSuperlative(baseForm);
				}
			} else {
				realised = baseForm;
			}
			var realisedElement:StringElement = new StringElement(realised);
			realisedElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, element.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			return realisedElement;
		}
	
		/**
		 * This method performs the morphology for pronouns.
		 * 
		 * @param element
		 *            the <code>InflectedWordElement</code>.
		 * @return a <code>StringElement</code> representing the word after
		 *         inflection.
		 */
		public static function doPronounMorphology(element:InflectedWordElement):NLGElement
		{
			var realised:String = null;
	
			if (!element.getFeatureAsBoolean(InternalFeature.NON_MORPH) && !isWHPronoun(element))
			{
				var genderValue:Object = element.getFeature(LexicalFeature.GENDER);
				var personValue:Object = element.getFeature(Feature.PERSON);
				var discourseValue:Object = element.getFeature(InternalFeature.DISCOURSE_FUNCTION);
	
				var numberIndex:int = element.isPlural() ? 1 : 0;
				var genderIndex:int = (genderValue is Gender) ? (Gender(genderValue)).ordinal : 2;
				var personIndex:int = (personValue is Person) ? (Person(personValue)).ordinal : 2;
	
				if (personIndex == 2)
				{
					personIndex += genderIndex;
				}
	
				var positionIndex:int = 0;
	
				if (element.getFeatureAsBoolean(LexicalFeature.REFLEXIVE))
				{
					positionIndex = 2;
				}
				else if (element.getFeatureAsBoolean(Feature.POSSESSIVE))
				{
					positionIndex = 3;
					if (DiscourseFunction.SPECIFIER == discourseValue)
					{
						positionIndex++;
					}
				} else {
					positionIndex = (DiscourseFunction.SUBJECT == discourseValue && !element.getFeatureAsBoolean(Feature.PASSIVE))
							|| (DiscourseFunction.OBJECT == discourseValue && element.getFeatureAsBoolean(Feature.PASSIVE))
							|| DiscourseFunction.SPECIFIER == discourseValue
							|| (DiscourseFunction.COMPLEMENT == discourseValue && element.getFeatureAsBoolean(Feature.PASSIVE)) ? 0 : 1;
				}
				realised = PRONOUNS[numberIndex][positionIndex][personIndex];
			} else {
				realised = element.getBaseForm();
			}
			var realisedElement:StringElement = new StringElement(realised);
			realisedElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, element.getFeature(InternalFeature.DISCOURSE_FUNCTION));
	
			return realisedElement;
		}
	
		private static function isWHPronoun(word:InflectedWordElement):Boolean
		{
			var base:String = word.getBaseForm();
			var wh:Boolean = false;
	
			if (base != null)
			{
				var len:int = WH_PRONOUNS.length;
				for (var i:int = 0; i < len && !wh; i++)
				{
					wh = WH_PRONOUNS[i] == base;
				}
			}
	
			return wh;
		}
	
		/**
		 * This method performs the morphology for determiners.
		 * 
		 * @param determiner
		 *            the <code>InflectedWordElement</code>.
		 * @param realisation
		 *            the current realisation of the determiner.
		 */
		public static function doDeterminerMorphology(determiner:NLGElement, realisation:String):void
		{
			if (realisation != null)
			{
				if (determiner.getRealisation() == "a")
				{ //$NON-NLS-1$
					if (determiner.isPlural())
					{
						determiner.setRealisation("some");
					}
					else if (DeterminerAgrHelper.requiresAn(realisation))
					{
						determiner.setRealisation("an");
					}
	
					// } else if (realisation.matches(MorphologyRules.AN_AGREEMENT)
					// || realisation
					// .matches(MorphologyRules.AN_NUMERAL_AGREEMENT)) {
					// if (!isAnException(realisation)) {
					// determiner.setRealisation("an");
					// }
					// }
				}
			}
		}
	
		// /**
		// * check whether a string beginning with a vowel is an exception and
		// doesn't
		// * take "an" (e.g. "a one percent change")
		// *
		// * @return
		// */
		// private static boolean isAnException(String string) {
		// for (String ex : MorphologyRules.AN_EXCEPTIONS) {
		// if (string.matches("^" + ex + ".*")) {
		// // if (string.equalsIgnoreCase(ex)) {
		// return true;
		// }
		// }
		//
		// return false;
		// }
	}
}
