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
package simpleasnlg.lexicon
{
	// [TODO] make this work!
	import gov.nih.nlm.nls.lexAccess.Api.LexAccessApi;
	import gov.nih.nlm.nls.lexAccess.Api.LexAccessApiResult;
	import gov.nih.nlm.nls.lexCheck.Lib.AdjEntry;
	import gov.nih.nlm.nls.lexCheck.Lib.AdvEntry;
	import gov.nih.nlm.nls.lexCheck.Lib.InflVar;
	import gov.nih.nlm.nls.lexCheck.Lib.LexRecord;
	import gov.nih.nlm.nls.lexCheck.Lib.NounEntry;
	import gov.nih.nlm.nls.lexCheck.Lib.VerbEntry;
	
	
	
	import simpleasnlg.features.Inflection;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.WordElement;
	import com.steamshift.utils.StringUtils;
	
	/**
	 * This class gets Words from the NIH Specialist Lexicon
	 * 
	 * @author ereiter
	 * 
	 */
	public class NIHDBLexicon extends Lexicon {
	
		// default DB parameters
		private static var DB_HSQL_DRIVER:String = "org.hsqldb.jdbcDriver"; // DB driver
		private static var DB_HQSL_JDBC:String = "jdbc:hsqldb:"; // JDBC specifier for
		// HSQL
		private static var DB_DEFAULT_USERNAME:String = "sa"; // DB username
		private static var DB_DEFAULT_PASSWORD:String = ""; // DB password
		private static var DB_HSQL_EXTENSION:String = ".data"; // filename extension for
		// HSQL DB
	
		// class variables
		private var conn:Connection = null; // DB connection
		private var lexdb:LexAccessApi = null; // Lexicon access object
	
		// if false, don't keep standard inflections in the Word object
		private var keepStandardInflections:Boolean = false;
	
		/****************************************************************************/
		// constructors
		/****************************************************************************/
	
		/**
		 * set up lexicon using file which contains downloaded lexAccess HSQL DB and
		 * default passwords
		 * 
		 * @param filename
		 *            of HSQL DB
		 */
		public function NIHDBLexicon(filename:String, driver:String = null, url:String = null, username:String = null, password:String = null)
		{
			super();
			
			if (filename)
			{
				// get rid of .data at end of filename if necessary
				var dbfilename:String = filename;
				if (StringUtils.endsWith(dbfilename, DB_HSQL_EXTENSION))
				{
					dbfilename = dbfilename.substring(0, dbfilename.length() - DB_HSQL_EXTENSION.length());
				}
				
				// try to open DB and set up lexicon
				try {
					Class.forName(DB_HSQL_DRIVER);
					conn = DriverManager.getConnection(DB_HQSL_JDBC + dbfilename,
							DB_DEFAULT_USERNAME, DB_DEFAULT_PASSWORD);
					// now set up lexical access object
					lexdb = new LexAccessApi(conn);
		
				} catch (ex:Error) {
					trace("Cannot open lexical db: " + ex.message);
					// probably should thrown an exception
				}
			}
			else
			{
				try {
					Class.forName(driver);
					conn = DriverManager.getConnection(url, username, password);
					// now set up lexical access object
					lexdb = new LexAccessApi(conn);
				} catch (ex:Error) {
					trace("Cannot open lexical db: " + ex.message);
					// probably should thrown an exception
				}
			}
		}
	
		// need more constructors for general case...
	
		/***************** methods to set global parameters ****************************/
	
		/**
		 * reports whether Words include standard (derivable) inflections
		 * 
		 * @return true if standard inflections are kept
		 */
		public function isKeepStandardInflections():Boolean
		{
			return keepStandardInflections;
		}
	
		/**
		 * set whether Words should include standard (derivable) inflections
		 * 
		 * @param keepStandardInflections
		 *            - if true, standard inflections are kept
		 */
		public function setKeepStandardInflections(keepStandardInflections:Boolean):void
		{
			this.keepStandardInflections = keepStandardInflections;
		}
	
		/****************************************************************************/
		// core methods to retrieve words from DB
		/****************************************************************************/
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.lexicon.Lexicon#getWords(java.lang.String,
		 * simpleasnlg.features.LexicalCategory)
		 */
		override public function getWords(baseForm:String, category:LexicalCategory):Array
		{
			// get words from DB
			try {
				var lexResult:LexAccessApiResult = lexdb.GetLexRecordsByBase(baseForm, LexAccessApi.B_EXACT);			
				return getWordsFromLexResult(category, lexResult);
			}
			catch (error:Error)
			{
				trace("Lexical DB error: " + ex.toString());
				// probably should thrown an exception
			}
			return null;
		}
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.lexicon.Lexicon#getWordsByID(java.lang.String)
		 */
		override public function getWordsByID(id:String):Array
		{
			// get words from DB
			try {
				var lexResult:LexAccessApiResult = lexdb.GetLexRecords(id);
				return getWordsFromLexResult(LexicalCategory.ANY, lexResult);
			}
			catch (error:Error)
			{
				trace("Lexical DB error: " + ex.toString());
				// probably should thrown an exception
			}
			return null;
		}
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.lexicon.Lexicon#getWordsFromVariant(java.lang.String,
		 * simpleasnlg.features.LexicalCategory)
		 */
		override public function getWordsFromVariant(variant:String, category:LexicalCategory):Array
		{
			// get words from DB
			try {
				var lexResult:LexAccessApiResult = lexdb.GetLexRecords(variant);
				return getWordsFromLexResult(category, lexResult);
			}
			catch (error:Error)
			{
				trace("Lexical DB error: " + ex.toString());
				// probably should thrown an exception
			}
			return null;
		}
	
		/****************************************************************************/
		// other methods
		/****************************************************************************/
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.lexicon.Lexicon#close()
		 */
		override public function close() {
			if (lexdb != null)
				lexdb.CleanUp();
		}
	
		/**
		 * make a WordElement from a lexical record. Currently just specifies basic
		 * params and inflections Should do more in the future!
		 * 
		 * @param record
		 * @return
		 */
		private function makeWord(record:LexRecord):WordElement
		{
			// get basic data
			var baseForm:String = record.GetBase();		
			var category:LexicalCategory = getSimplenlgCategory(record);
			var id:String = record.GetEui();
	
			// create word class
			var wordElement:WordElement = new WordElement(baseForm, category, id);
	
			// now add type information
			switch (category)
			{
				case ADJECTIVE:
					addAdjectiveInfo(wordElement, record.GetCatEntry().GetAdjEntry());
					break;
				case ADVERB:
					addAdverbInfo(wordElement, record.GetCatEntry().GetAdvEntry());
					break;
				case NOUN:
					addNounInfo(wordElement, record.GetCatEntry().GetNounEntry());
					break;
				case VERB:
					addVerbInfo(wordElement, record.GetCatEntry().GetVerbEntry());
					break;
				// ignore closed class words
			}
	
			var defaultInfl:Inflection = Inflection(wordElement.getDefaultInflectionalVariant());
	
			// now add inflected forms
			// if (keepStandardInflections || !standardInflections(record,
			// category)) {
			for each (var inflection:Inflection in record.GetInflVarsAndAgreements().GetInflValues())
			{
				var simplenlgInflection:String = getSimplenlgInflection(inflection.GetInflection());
	
				if (simplenlgInflection != null)
				{
					var inflectedForm:String = inflection.GetVar();
					var inflType:Inflection = Inflection.getInflCode(inflection.GetType());
	
					// store all inflectional variants, except for regular ones
					// unless explicitly set
					if (inflType != null && !(Inflection.REGULAR == inflType && !this.keepStandardInflections))
					{
						wordElement.addInflectionalVariant(inflType, simplenlgInflection, inflectedForm);
					}
	
					// if the infl variant is the default, also set this feature on
					// the word
					if (defaultInfl == null || (defaultInfl == inflType && !(Inflection.REGULAR == inflType && !this.keepStandardInflections)))
					{
						wordElement.setFeature(simplenlgInflection, inflectedForm);
					}
	
					// wordElement
					// .setFeature(simplenlgInflection, inflection.GetVar());
				}
			}
			// }
	
			// add acronym info
			addAcronymInfo(wordElement, record);
	
			// now add spelling variants
			addSpellingVariants(wordElement, record);
	
			return wordElement;
		}
	
		/**
		 * return list of WordElement from LexAccessApiResult
		 * 
		 * @param category
		 *            - desired category (eg, NOUN) (this filters list)
		 * @param lexResult
		 *            - the LexAccessApiResult
		 * @return list of WordElement
		 */
		private function getWordsFromLexResult(category:LexicalCategory, lexResult:LexAccessApiResult):Array
		{
			var records:Array = lexResult.GetJavaObjs();
	
			// set up array of words to return
			var wordElements:Array = new Array();
	
			// iterate through result records, adding to words as appropriate
			for each (var record:LexRecord in records)
			{
				if (category == LexicalCategory.ANY || category == getSimplenlgCategory(record)) wordElements.push(makeWord(record));
			}
			return wordElements;
		}
	
		/**
		 * check if this record has a standard (regular) inflection
		 * 
		 * @param record
		 * @param simplenlg
		 *            syntactic category
		 * @return true if standard (regular) inflection
		 */
		//@SuppressWarnings("unused")
		private function standardInflections(record:LexRecord, category:LexicalCategory):Boolean
		{
			var variants:Array = null;
			switch (category)
			{
				case NOUN:
					variants = record.GetCatEntry().GetNounEntry().GetVariants();
					break;
				case ADJECTIVE:
					variants = record.GetCatEntry().GetAdjEntry().GetVariants();
					break;
				case ADVERB:
					variants = record.GetCatEntry().GetAdvEntry().GetVariants();
					break;
				case MODAL:
					variants = record.GetCatEntry().GetModalEntry().GetVariant();
					break;
				case VERB:
					if (record.GetCatEntry().GetVerbEntry() != null) // aux verbs (eg
						// be) won't
						// have verb
						// entries
						variants = record.GetCatEntry().GetVerbEntry().GetVariants();
					break;
			}
	
			return variants.length > 0  && variants.indexOf("reg") > -1;
		}
	
		/***********************************************************************************/
		// The following methods map codes in the NIH Specialist Lexicon
		// into the codes used in simplenlg
		/***********************************************************************************/
	
		/**
		 * get the simplenlg LexicalCategory of a record
		 * 
		 * @param cat
		 * @return
		 */
		private function getSimplenlgCategory(record:LexRecord):LexicalCategory
		{
			var cat:String = record.GetCategory();
			if (cat == null) return LexicalCategory.ANY;
			else if (cat == "noun") return LexicalCategory.NOUN;
			else if (cat == "verb") return LexicalCategory.VERB;
			else if (cat == "aux" && record.GetBase() == "be") // return aux "be"
				// as a VERB
				// not needed for other aux "have" and "do", they have a verb entry
				return LexicalCategory.VERB;
			else if (cat == "adj") return LexicalCategory.ADJECTIVE;
			else if (cat == "adv") return LexicalCategory.ADVERB;
			else if (cat == "pron") return LexicalCategory.PRONOUN;
			else if (cat == "det") return LexicalCategory.DETERMINER;
			else if (cat == "prep") return LexicalCategory.PREPOSITION;
			else if (cat == "conj") return LexicalCategory.CONJUNCTION;
			else if (cat == "compl") return LexicalCategory.COMPLEMENTISER;
			else if (cat == "modal") return LexicalCategory.MODAL;
	
			// return ANY for other cats
			else
				return LexicalCategory.ANY;
		}
	
		/**
		 * convert an inflection type in NIH lexicon into one used by simplenlg
		 * return null if no simplenlg equivalent to NIH inflection type
		 * 
		 * @param NIHInflection
		 *            - inflection type in NIH lexicon
		 * @return inflection type in simplenlg
		 */
		private function getSimplenlgInflection(NIHInflection:String):String
		{
			if (NIHInflection == null) return null;
			else if (NIHInflection == "comparative") return LexicalFeature.COMPARATIVE;
			else if (NIHInflection == "superlative") return LexicalFeature.SUPERLATIVE;
			else if (NIHInflection == "plural") return LexicalFeature.PLURAL;
			else if (NIHInflection == "pres3s") return LexicalFeature.PRESENT3S;
			else if (NIHInflection == "past") return LexicalFeature.PAST;
			else if (NIHInflection == "pastPart") return LexicalFeature.PAST_PARTICIPLE;
			else if (NIHInflection == "presPart") return LexicalFeature.PRESENT_PARTICIPLE;
			else
				// no equvalent in simplenlg, eg clitic or negative
				return null;
		}
	
		/**
		 * extract adj information from NIH AdjEntry record, and add to a simplenlg
		 * WordElement For now just extract position info
		 * 
		 * @param wordElement
		 * @param AdjEntry
		 */
		private function addAdjectiveInfo(wordElement:WordElement, adjEntry:AdjEntry):void
		{
			var qualitativeAdj:Boolean = false;
			var colourAdj:Boolean = false;
			var classifyingAdj:Boolean = false;
			var predicativeAdj:Boolean = false;
			var positions:Array = adjEntry.GetPosition();
			for each (var position:String in positions)
			{
				if (StringUtils.startsWith(position, "attrib(1)")) qualitativeAdj = true;
				else if (StringUtils.startsWith(position, "attrib(2)")) colourAdj = true;
				else if (StringUtils.startsWith(position, "attrib(3)")) classifyingAdj = true;
				else if (StringUtils.startsWith(position, "pred")) predicativeAdj = true;
				// ignore other positions
			}
			// ignore (for now) other info in record
			wordElement.setFeature(LexicalFeature.QUALITATIVE, qualitativeAdj);
			wordElement.setFeature(LexicalFeature.COLOUR, colourAdj);
			wordElement.setFeature(LexicalFeature.CLASSIFYING, classifyingAdj);
			wordElement.setFeature(LexicalFeature.PREDICATIVE, predicativeAdj);
			return;
		}
	
		/**
		 * extract adv information from NIH AdvEntry record, and add to a simplenlg
		 * WordElement For now just extract modifier type
		 * 
		 * @param wordElement
		 * @param AdvEntry
		 */
		private function addAdverbInfo(wordElement:WordElement, advEntry:AdvEntry):void
		{
			var verbModifier:Boolean = false;
			var sentenceModifier:Boolean = false;
			var intensifier:Boolean = false;
	
			var modifications:Array = advEntry.GetModification();
			for each (var modification:String in modifications)
			{
				if (StringUtils.startsWith(modification, "verb_modifier"))
					verbModifier = true;
				else if (StringUtils.startsWith(modification, "sentence_modifier"))
					sentenceModifier = true;
				else if (StringUtils.startsWith(modification, "intensifier"))
					intensifier = true;
				// ignore other modification types
			}
			// ignore (for now) other info in record
			wordElement.setFeature(LexicalFeature.VERB_MODIFIER, verbModifier);
			wordElement.setFeature(LexicalFeature.SENTENCE_MODIFIER, sentenceModifier);
			wordElement.setFeature(LexicalFeature.INTENSIFIER, intensifier);
			return;
		}
	
		/**
		 * extract noun information from NIH NounEntry record, and add to a
		 * simplenlg WordElement For now just extract whether count/non-count and
		 * whether proper or not
		 * 
		 * @param wordElement
		 * @param nounEntry
		 */
		private function addNounInfo(wordElement:WordElement, nounEntry:NounEntry):void
		{
			var proper:Boolean = nounEntry.IsProper();
			// boolean nonCountVariant = false;
			// boolean regVariant = false;
	
			// add the inflectional variants
			var variants:Array = nounEntry.GetVariants();
	
			if (!variants.isEmpty())
			{
				var wordVariants:Array = new Array();
	
				for each (var v:String in variants)
				{
					var index:int = v.indexOf("|");
					var code:String;
	
					if (index > -1)
					{
						code = v.substring(0, index).toLowerCase().trim();
					} else {
						code = v.toLowerCase();
					}
	
					var infl:Inflection = Inflection.getInflCode(code);
	
					if (infl != null) {
						wordVariants.push(infl);
						wordElement.addInflectionalVariant(infl);
					}
				}
	
				// if the variants include "reg", this is the default, otherwise
				// just a random pick
				var defaultVariant:Inflection = wordVariants.indexOf(Inflection.REGULAR) > -1 || wordVariants.length == 0 ? Inflection.REGULAR : wordVariants[0];			
				wordElement.setFeature(LexicalFeature.DEFAULT_INFL, defaultVariant);
				wordElement.setDefaultInflectionalVariant(defaultVariant);
			}
	
			// for (String variant : variants) {
			// if (variant.startsWith("uncount")
			// || variant.startsWith("groupuncount"))
			// nonCountVariant = true;
			//
			// if (variant.startsWith("reg"))
			// regVariant = true;
			// // ignore other variant info
			// }
	
			// lots of words have both "reg" and "unCount", indicating they
			// can be used in either way. Regard such words as normal,
			// only flag as nonCount if unambiguous
			// wordElement.setFeature(LexicalFeature.NON_COUNT, nonCountVariant
			// && !regVariant);
			wordElement.setFeature(LexicalFeature.PROPER, proper);
			// ignore (for now) other info in record
	
			return;
		}
	
		/**
		 * extract verb information from NIH VerbEntry record, and add to a
		 * simplenlg WordElement For now just extract transitive, instransitive,
		 * and/or ditransitive
		 * 
		 * @param wordElement
		 * @param verbEntry
		 */
		private function addVerbInfo(wordElement:WordElement, verbEntry:VerbEntry):void
		{
			if (verbEntry == null)
			{ // should only happen for aux verbs, which have
				// auxEntry instead of verbEntry in NIH Lex
				// just flag as transitive and return
				wordElement.setFeature(LexicalFeature.INTRANSITIVE, false);
				wordElement.setFeature(LexicalFeature.TRANSITIVE, true);
				wordElement.setFeature(LexicalFeature.DITRANSITIVE, false);
				return;
			}
	
			var intransitiveVerb:Boolean = notEmpty(verbEntry.GetIntran());
			var transitiveVerb:Boolean = notEmpty(verbEntry.GetTran()) || notEmpty(verbEntry.GetCplxtran());
			var ditransitiveVerb:Boolean = notEmpty(verbEntry.GetDitran());
	
			wordElement.setFeature(LexicalFeature.INTRANSITIVE, intransitiveVerb);
			wordElement.setFeature(LexicalFeature.TRANSITIVE, transitiveVerb);
			wordElement.setFeature(LexicalFeature.DITRANSITIVE, ditransitiveVerb);
	
			// add the inflectional variants
			var variants:Array = verbEntry.GetVariants();
	
			if (variants.length > 0)
			{
				var wordVariants:Array = new Array();
	
				for each (var v:String in variants)
				{
					var index:int = v.indexOf("|");
					var code:String;
					var infl:Inflection;
	
					if (index > -1)
					{
						code = v.substring(0, index).toLowerCase();
						infl = Inflection.getInflCode(code);					
	
					} else {
						infl = Inflection.getInflCode(v.toLowerCase());
					}
	
					if (infl != null) {
						wordElement.addInflectionalVariant(infl);
						wordVariants.push(infl);
					}
				}
	
				// if the variants include "reg", this is the default, otherwise
				// just a random pick
				var defaultVariant:Inflection = wordVariants.indexOf(Inflection.REGULAR) > -1 || wordVariants.length == 0 ? Inflection.REGULAR : wordVariants[0];
	//			wordElement.setFeature(LexicalFeature.INFLECTIONS, wordVariants);
	//			wordElement.setFeature(LexicalFeature.DEFAULT_INFL, defaultVariant);
				wordElement.setDefaultInflectionalVariant(defaultVariant);
			}
	
			// ignore (for now) other info in record
			return;
		}
	
		/**
		 * convenience method to test that a list is not null and not empty
		 * 
		 * @param list
		 * @return
		 */
		//@SuppressWarnings("unchecked")
		private function notEmpty(list:Array):Boolean
		{
			return list != null && list.length > 0;
		}
	
		/**
		 * extract information about acronyms from NIH record, and add to a
		 * simplenlg WordElement.
		 * 
		 * <P>
		 * Acronyms are represented as lists of word elements. Any acronym will have
		 * a list of full form word elements, retrievable via
		 * {@link LexicalFeature#ACRONYM_OF}
		 * 
		 * @param wordElement
		 * @param record
		 */
		private function addAcronymInfo(wordElement:WordElement, record:LexRecord)
		{
			// NB: the acronyms are actually the full forms of which the word is an
			// acronym
			var acronyms:Array = record.GetAcronyms();
	
			if (acronyms.length > 0)
			{
				// the list of full forms of which this word is an acronym
				var acronymOf:Array = wordElement.getFeatureAsElementList(LexicalFeature.ACRONYM_OF);
	
				// keep all acronym full forms and set them up as wordElements
				for each (var fullForm:String in acronyms)
				{
					if (fullForm.indexOf("|") > -1)
					{
						// get the acronym id
						var acronymID:String = fullForm.substring(fullForm.indexOf("|") + 1, fullForm.length());
						// create the full form element
						var fullFormWE:WordElement = this.getWordByID(acronymID);
	
						if (fullForm != null)
						{
							// add as full form of this acronym
							acronymOf.push(fullFormWE);
	
							// List<NLGElement> fullFormAcronyms = fullFormWE
							// .getFeatureAsElementList(LexicalFeature.ACRONYMS);
							// fullFormAcronyms.push(wordElement);
							// fullFormWE.setFeature(LexicalFeature.ACRONYMS,
							// fullFormAcronyms);
						}
					}
				}
	
				// set all the full forms for this acronym
				wordElement.setFeature(LexicalFeature.ACRONYM_OF, acronymOf);
			}
	
			// if (!acronyms.isEmpty()) {
			//
			// String acronym = acronyms[0];
			// // remove anything after a |, this will be an NIH ID
			// if (acronym.contains("|"))
			// acronym = acronym.substring(0, acronym.indexOf("|"));
			// wordElement.setFeature(LexicalFeature.ACRONYM_OF, acronym);
			// }
	
			return;
		}
	
		/**
		 * Extract info about the spelling variants of a word from an NIH record,
		 * and add to the simplenlg Woordelement.
		 * 
		 * <P>
		 * Spelling variants are represented as lists of strings, retrievable via
		 * {@link LexicalFeature#SPELL_VARS}
		 * 
		 * @param wordElement
		 * @param record
		 */
		private function addSpellingVariants(wordElement:WordElement, record:LexRecord):void
		{
			var vars:Vector.<String> = record.GetSpellingVars();
	
			if (vars != null && vars.length > 0)
			{
				var wordVars:Array = new Array();
				for each (var wordVar:String in vars)
				{
					wordVars.push(wordVar);
				}
				wordElement.setFeature(LexicalFeature.SPELL_VARS, wordVars);
			}
	
			// we set the default spelling var as the baseForm
			wordElement.setFeature(LexicalFeature.DEFAULT_SPELL, wordElement.getBaseForm());
		}
	}
}
