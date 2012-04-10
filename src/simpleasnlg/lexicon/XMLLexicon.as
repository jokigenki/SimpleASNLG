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
	import com.steamshift.utils.Cloner;
	import com.steamshift.utils.StringUtils;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.core.ByteArrayAsset;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.IFeature;
	import simpleasnlg.features.Inflection;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.framework.ElementCategory;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.WordElement;
	
	/**
	 * This class loads words from an XML lexicon. All features specified in the
	 * lexicon are loaded
	 * 
	 * @author ereiter
	 * 
	 */
	public class XMLLexicon extends Lexicon
	{
		// node names in lexicon XML files
		private static const XML_BASE:String  		= "base"; // base form of Word
		private static const XML_CATEGORY:String  	= "category"; // base form of Word
		private static const XML_ID:String  		= "id"; // base form of Word
		private static const XML_WORD:String  		= "word"; // node defining a word
	
		protected var _lexiconXML:XML;
		protected var _loader:URLLoader;
		
		// lexicon
		private var words:Array; // set of words
		private var indexByID:Dictionary; // map from ID to word
		private var indexByBase:Dictionary; // map from base to set
		// of words with this
		// baseform
		private var indexByVariant:Dictionary; // map from variants
	
		[Embed("/simpleasnlg/lexicon/default-lexicon.xml", mimeType="application/octet-stream")]
		private static const DefaultXML:Class;
		
		// to set of words
		// with this variant
	
		/**********************************************************************/
		// constructors
		/**********************************************************************/
	
		/**
		 * Load an XML Lexicon from a named file
		 * 
		 * @param filename
		 */
		public function XMLLexicon(file:* = null)
		{
			super();
			
			var fileRef:File;
			if (!file)
			{
				createLexicon();
			}
			if (file is String)
			{
				fileRef = new File(file);
				createLexicon(fileRef.url);
			}
			else if (file is FileReference)
			{
				createLexicon(file.url);
			}
		}
	
		public static function getDefaultXML() : XML
		{
			var ba:ByteArrayAsset = ByteArrayAsset( new DefaultXML() );
			var xml:XML = new XML( ba.readUTFBytes( ba.length ) );
			
			return xml;    
		}
		
		/**
		 * method to actually load and index the lexicon from a URI
		 * 
		 * @param uri
		 */
		private function createLexicon(lexiconURI:String = null):void
		{
			if (lexiconURI)
			{
				if (!_loader) _loader = new URLLoader();
				_loader.load(new URLRequest(lexiconURI));
				_loader.addEventListener(Event.COMPLETE, _onXMLLoaded, false, 0, true);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, _onXMLLoadFail, false, 0, true);
			} else {
				_lexiconXML = XMLLexicon.getDefaultXML();
				_initLexicon();
			}
		}
		
		protected function _onXMLLoadFail (event:Event):void
		{
			trace("Lexicon XML load failed");
		}
		
		protected function _onXMLLoaded (event:Event):void
		{
			_loader.removeEventListener(Event.COMPLETE, _onXMLLoaded);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, _onXMLLoadFail);
			
			try
			{
				_lexiconXML = XML(_loader.data);
			}
			catch (e:Error)
			{
				trace("Lexicon XML is malformed:", e.message);
				return;
			}
			
			_initLexicon();
		}
		
		protected function _initLexicon ():void
		{
			_lexiconXML.ignoreWhitespace = true;
			
			// initialise objects
			words = new Array();
			indexByID = new Dictionary();
			indexByBase = new Dictionary();
			indexByVariant = new Dictionary();
	
			var wordsList:XMLList = _lexiconXML..word;
			
			for each (var wordXML:XML in wordsList)
			{
				var word:WordElement = convertNodeToWord(wordXML);
				words.push(word);
				IndexWord(word);
			}
	
			addSpecialCases();
			
			dispatchEvent(new Event(Event.COMPLETE) );
		}
	
		/**
		 * add special cases to lexicon
		 * 
		 */
		private function addSpecialCases():void
		{
			// add variants of "be"
			var be:WordElement = getWord("be", LexicalCategory.VERB);
			if (be != null)
			{
				updateIndex(be, "is", indexByVariant);
				updateIndex(be, "am", indexByVariant);
				updateIndex(be, "are", indexByVariant);
				updateIndex(be, "was", indexByVariant);
				updateIndex(be, "were", indexByVariant);
			}
		}
	
		protected function standardiseNodeName (nodeName:String):String
		{
			var parts:Array = nodeName.split("_");
			var len:int = parts.length;
			if (len == 1) return nodeName;
			
			for (var i:int = 1; i < len; i++)
			{
				var part:String = parts[i];
				parts[i] = part.charAt(0).toUpperCase() + part.slice(1);
			}
			
			return parts.join("");
		}
		
		/**
		 * create a simplenlg WordElement from a Word node in a lexicon XML file
		 * 
		 * @param wordNode
		 * @return
		 * @throws XPathUtilException
		 */
		private function convertNodeToWord(wordNode:XML):WordElement
		{
			if (wordNode.name() != XML_WORD) return null;
			
			// create word
			var word:WordElement = new WordElement();
			var inflections:Array = new Array();
			
			var nodes:XMLList = wordNode.children();
			
			for each (var featureNode:XML in nodes)
			{
				if (featureNode.nodeKind() == "element")
				{
					var feature:String = standardiseNodeName(featureNode.name());
					var value:String = featureNode.text();
					
					if (feature == null)
					{
						trace("Error in XML lexicon node for", word.toString());
						break;
					}
					
					if (feature.toLowerCase() == XML_BASE)
					{
						word.setBaseForm(value);
					}
					else if (feature.toLowerCase() == XML_CATEGORY)
					{
						word.setCategory(LexicalCategory[value.toUpperCase()])
					}
					else if (feature.toLowerCase() == XML_ID)
					{
						word.setId(value);
					}	
					else if (value == null || value == "")
					{
						// if this is an infl code, add it to inflections
						var infl:Inflection = Inflection.getInflCode(feature);
						
						if (infl != null)
						{
							inflections.push(infl);
						} else {
							// otherwise assume it's a boolean feature
							word.setFeatureByName(feature, true);
						}
					} else {
						word.setFeatureByName(feature, value);
					}
				}
			}
	
			// if no infl specified, assume regular
			if (inflections.length == 0)
			{
				inflections.push(Inflection.REGULAR);
			}
	
			// default inflection code is "reg" if we have it, else random pick form
			// infl codes available
			var defaultInfl:Inflection = inflections.indexOf(Inflection.REGULAR) > -1 ? Inflection.REGULAR : inflections[0];		
			
			word.setFeature(LexicalFeature.DEFAULT_INFL, defaultInfl);
			word.setDefaultInflectionalVariant(defaultInfl);
			
			var len:int = inflections.length;
			for (var i:int = 0; i < len; i++)
			{
				var inflection:Inflection = inflections[i];
				word.addInflectionalVariant(inflection);
			}
			
			// done, return word
			return word;
		}
	
		/**
		 * add word to internal indices
		 * 
		 * @param word
		 */
		private function IndexWord(word:WordElement):void
		{
			// first index by base form
			var base:String = word.getBaseForm();
			// shouldn't really need is, as all words have base forms
			if (base != null) {
				updateIndex(word, base, indexByBase);
			}
	
			// now index by ID, which should be unique (if present)
			var id:String = word.getId();
			if (id != null)
			{
				if (indexByID[id])
					trace("Lexicon error: ID " + id
							+ " occurs more than once");
				indexByID[id] = word;
			}
	
			// now index by variant
			var variants:Dictionary = getVariants(word);
			for (var variant:String in variants)
			{
				updateIndex(variants[variant], variant, indexByVariant);
			}
	
			// done
		}
	
		/**
		 * convenience method to update an index
		 * 
		 * @param word
		 * @param base
		 * @param index
		 */
		private function updateIndex(word:WordElement, base:String, index:Dictionary):void
		{
			if (!index[base]) index[base] = new Array();
			var arrayIndex:Array = index[base];
			arrayIndex.push(word);
		}
	
		/******************************************************************************************/
		// main methods to get data from lexicon
		/******************************************************************************************/
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.lexicon.Lexicon#getWords(java.lang.String,
		 * simpleasnlg.features.LexicalCategory)
		 */
		override public function getWords(baseForm:String, category:LexicalCategory = null):Array
		{
			if (!category) category = LexicalCategory.ANY;
			return getWordsFromIndex(baseForm, category, indexByBase);
		}
	
		/**
		 * get matching keys from an index map
		 * 
		 * @param indexKey
		 * @param category
		 * @param indexDictionary
		 * @return
		 */
		private function getWordsFromIndex(indexKey:String, category:LexicalCategory, indexDictionary:Dictionary):Array
		{
			var result:Array = new Array();
	
			if (!category) category = LexicalCategory.ANY;
			
			// case 1: unknown, return empty list
			if (indexDictionary[indexKey] == null) return result;
	
			var items:Array = indexDictionary[indexKey];
			var len:int = items.length;
			for (var i:int = 0; i < len; i++)
			{
				var word:WordElement = items[i];
				if (category == LexicalCategory.ANY || word.getCategory() == category) result.push(word.clone());
			}
	
			return result;
		}
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.lexicon.Lexicon#getWordsByID(java.lang.String)
		 */
		override public function getWordsByID(id:String):Array
		{
			var result:Array = new Array();
			if (indexByID[id])
			{
				result.push(indexByID[id].clone());
			}
			return result;
		}
	
		/*
		 * (non-Javadoc)
		 * 
		 * @see simpleasnlg.lexicon.Lexicon#getWordsFromVariant(java.lang.String,
		 * simpleasnlg.features.LexicalCategory)
		 */
		override public function getWordsFromVariant(variant:String, category:LexicalCategory = null):Array
		{
			return getWordsFromIndex(variant, category, indexByVariant);
		}
	
		/**
		 * quick-and-dirty routine for getting morph variants should be replaced by
		 * something better!
		 * 
		 * @param word
		 * @return
		 */
		private function getVariants(word:WordElement):Dictionary
		{
			var variants:Dictionary = new Dictionary();
			variants[word.getBaseForm()] = word;
			var category:ElementCategory = word.getCategory();
			if (category is LexicalCategory)
			{
				var clone:WordElement;
				switch (category)
				{
					case LexicalCategory.NOUN:
						clone = word.clone() as WordElement;
						clone.setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
						variants[getVariant(word, LexicalFeature.PLURAL, "s")] = clone;
						break;
		
					case LexicalCategory.ADJECTIVE:
						variants[getVariant(word, LexicalFeature.COMPARATIVE, "er")] = word;
						variants[getVariant(word, LexicalFeature.SUPERLATIVE, "est")] = word;
						break;
		
					case LexicalCategory.VERB:
						variants[getVariant(word, LexicalFeature.PRESENT3S, "s")] = word;
						variants[getVariant(word, LexicalFeature.PAST, "ed")] = word;
						variants[getVariant(word, LexicalFeature.PAST_PARTICIPLE, "ed")] = word;
						variants[getVariant(word, LexicalFeature.PRESENT_PARTICIPLE, "ing")] = word;
						break;
		
					default:
						// only base needed for other forms
				}
			}
			return variants;
		}
	
		/**
		 * quick-and-dirty routine for computing morph forms Should be replaced by
		 * something better!
		 * 
		 * @param word
		 * @param feature
		 * @param string
		 * @return
		 */
		private function getVariant(word:WordElement, feature:IFeature, suffix:String):String
		{
			if (word.baseForm == "bone")
			{
				trace("");	
			}
			
			if (word.hasFeature(feature))
				return word.getFeatureAsString(feature);
			else
				return getForm(word.getBaseForm(), suffix);
		}
	
		/**
		 * quick-and-dirty routine for standard orthographic changes Should be
		 * replaced by something better!
		 * 
		 * @param base
		 * @param suffix
		 * @return
		 */
		private function getForm(base:String, suffix:String):String
		{
			// add a suffix to a base form, with orthographic changes
	
			// rule 1 - convert final "y" to "ie" if suffix does not start with "i"
			// eg, cry + s = cries , not crys
			if (StringUtils.endsWith(base, "y") && !StringUtils.startsWith(suffix, "i"))
				base = base.substring(0, base.length - 1) + "ie";
	
			// rule 2 - drop final "e" if suffix starts with "e" or "i"
			// eg, like+ed = liked, not likeed
			if (StringUtils.endsWith(base,"e") &&
				(StringUtils.startsWith(suffix, "e")
				|| StringUtils.startsWith(suffix, "i")))
				base = base.substring(0, base.length - 1);
	
			// rule 3 - insert "e" if suffix is "s" and base ends in s, x, z, ch, sh
			// eg, watch+s -> watches, not watchs
			if (StringUtils.startsWith(suffix, "s") &&
				(StringUtils.endsWith(base, "s") ||
				 StringUtils.endsWith(base, "x") ||
				 StringUtils.endsWith(base, "z") ||
				 StringUtils.endsWith(base, "ch") ||
				 StringUtils.endsWith(base, "sh")))
				base = base + "e";
	
			// have made changes, now append and return
			return base + suffix; // eg, want + s = wants
		}
	}
}
