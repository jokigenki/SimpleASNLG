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
	import simpleasnlg.framework.LexicalCategory;
	
	/** This class contains a set of lexicons, which are searched in
	 * order for the specified word
	 * 
	 * @author ereiter
	 *
	 */
	public class MultipleLexicon extends Lexicon {
		
		/* if this flag is true, all lexicons are searched for
		 * this word, even after a match is found
		 * it is false by default
		 * */
		private var alwaysSearchAll:Boolean = false;
		
		/* list of lexicons, in order in which they are searched */
		private var lexiconList:Array = null;
	
		/**********************************************************************/
		// constructors
		/**********************************************************************/
		
		/**
		 * create an empty multi lexicon
		 */
		public function MultipleLexicon(...lexicons)
		{
			super();
			lexiconList = new Array();
			alwaysSearchAll = false;
			
			if (lexicons)
			{
				var len:int = lexiconList.length;
				for (var i:int = 0; i < len; i++)
				{
					var lex:Lexicon = lexiconList[i];
					lexiconList.push(lex);
				}
			}
		}
		
		/**********************************************************************/
		// routines to add more lexicons, change flags
		/**********************************************************************/
	
		/** add lexicon at beginning of list (is searched first)
		 * @param lex
		 */
		public function addInitialLexicon(lex:Lexicon):void
		{
			lexiconList.addAt(0, lex);
		}
	
		/** add lexicon at end of list (is searched last)
		 * @param lex
		 */
		public function addFinalLexicon(lex:Lexicon):void
		{
			lexiconList.addAt(lexiconList.length, lex);
		}
	
		/**
		 * @return the alwaysSearchAll
		 */
		public function isAlwaysSearchAll():Boolean
		{
			return alwaysSearchAll;
		}
	
		/**
		 * @param alwaysSearchAll the alwaysSearchAll to set
		 */
		public function setAlwaysSearchAll(alwaysSearchAll:Boolean):void
		{
			this.alwaysSearchAll = alwaysSearchAll;
		}
	
		/**********************************************************************/
		// main methods
		/**********************************************************************/
	
		/* (non-Javadoc)
		 * @see simpleasnlg.lexicon.Lexicon#getWords(java.lang.String, simpleasnlg.features.LexicalCategory)
		 */
		override public function getWords(baseForm:String, category:LexicalCategory = null):Array
		{
			var result:Array = new Array();
			var len:int = lexiconList.length;
			for (var i:int = 0; i < len; i++)
			{
				var lex:Lexicon = lexiconList[i];
				var lexResult:Array = lex.getWords(baseForm, category);
				
				if (lexResult != null && lexResult.length > 0)
				{
					result = result.concat(lexResult);
					if (!alwaysSearchAll)
						return result;
				}
			}
			return result;
		}

		/* (non-Javadoc)
		 * @see simpleasnlg.lexicon.Lexicon#getWordsByID(java.lang.String)
		 */
		override public function getWordsByID(id:String):Array
		{
			var result:Array = new Array();
			var len:int = lexiconList.length;
			for (var i:int = 0; i < len; i++)
			{
				var lex:Lexicon = lexiconList[i];
				var lexResult:Array = lex.getWordsByID(id);
				if (lexResult != null && lexResult.length > 0)
				{
					result = result.concat(lexResult);
					if (!alwaysSearchAll)
						return result;
				}
			}
			return result;
		}
	
		/* (non-Javadoc)
		 * @see simpleasnlg.lexicon.Lexicon#getWordsFromVariant(java.lang.String, simpleasnlg.features.LexicalCategory)
		 */
		override public function getWordsFromVariant(variant:String, category:LexicalCategory = null):Array
		{
			var result:Array = new Array();
			var len:int = lexiconList.length;
			for (var i:int = 0; i < len; i++)
			{
				var lex:Lexicon = lexiconList[i];
				var lexResult:Array = lex.getWordsFromVariant(variant, category);
				if (lexResult != null && lexResult.length > 0)
				{
					result = result.concat(lexResult);
					if (!alwaysSearchAll)
						return result;
				}
			}
			return result;
		}
	
	
		/**********************************************************************/
		// other methods
		/**********************************************************************/
	
		/* (non-Javadoc)
		 * @see simpleasnlg.lexicon.Lexicon#close()
		 */
		override public function close():void
		{
			// close component lexicons
			var len:int = lexiconList.length;
			for (var i:int = 0; i < len; i++)
			{
				var lex:Lexicon = lexiconList[i];
				lex.close();
			}
		}
	}
}
