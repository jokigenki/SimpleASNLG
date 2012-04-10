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
	import com.steamshift.datatypes.StringEnum;

	/**
	 * <p>
	 * This enumeration defines the different lexical components. The categories
	 * define the well understood role each word takes in language. For example,
	 * <em>dog</em> is a noun, <em>chase</em> is a verb, <em>the</em> is a
	 * determiner, and so on.
	 * </p>
	 * 
	 * 
	 * @author A. Gatt and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public final class LexicalCategory extends StringEnum implements ElementCategory
	{
		private static var _locked:Boolean = false;
		
		public function LexicalCategory (key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		
		/** A default value, indicating an unspecified category. */
		public static const ANY:LexicalCategory				= new LexicalCategory("any");
	
		/** The element represents a symbol. */
		public static const SYMBOL:LexicalCategory			= new LexicalCategory("symbol");
	
		/** A noun element. */
		public static const NOUN:LexicalCategory			= new LexicalCategory("noun");
	
		/** An adjective element. */
		public static const ADJECTIVE:LexicalCategory		= new LexicalCategory("adjective");
	
		/** An adverb element. */
		public static const ADVERB:LexicalCategory			= new LexicalCategory("adverb");
	
		/** A verb element. */
		public static const VERB:LexicalCategory			= new LexicalCategory("verb");
	
		/** A determiner element often referred to as a specifier. */
		public static const DETERMINER:LexicalCategory		= new LexicalCategory("determiner");
	
		/** A pronoun element. */
		public static const PRONOUN:LexicalCategory			= new LexicalCategory("pronoun");
	
		/** A conjunction element. */
		public static const CONJUNCTION:LexicalCategory		= new LexicalCategory("conjunction");
	
		/** A preposition element. */
		public static const PREPOSITION:LexicalCategory		= new LexicalCategory("preposition");
	
		/** A complementiser element. */
		public static const COMPLEMENTISER:LexicalCategory	= new LexicalCategory("complementiser");
	
		/** A modal element. */
		public static const MODAL:LexicalCategory			= new LexicalCategory("modal");
	
		/** An auxiliary verb element. */
		public static const AUXILIARY:LexicalCategory		= new LexicalCategory("auxiliary");
	
		/**
		 * <p>
		 * Checks to see if the given object is equal to this lexical category.
		 * This is done by checking the enumeration if the object is of the type
		 * <code>LexicalCategory</code> or by converting the object and this
		 * category to strings and comparing the strings.
		 * </p>
		 * <p>
		 * For example, <code>LexicalCategory.NOUN</code> will match another
		 * <code>LexicalCategory.NOUN</code> but will also match the string
		 * <em>"noun"</em> as well.
		 */
		public function equalTo(checkObject:Object):Boolean
		{
			var match:Boolean = false;
	
			if (checkObject != null)
			{
				if (checkObject is DocumentCategory) 
				{
					match = this == checkObject;
				} else {
					match = this.toString().toLowerCase() ==  checkObject.toString().toLowerCase();
				}
			}
			return match;
		}
		
		{
			_locked = true;
		}
	}
}
