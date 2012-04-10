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
* Contributor(s): Ehud Reiter, Albert Gatt, Dave Westwater, Roman Kutlak, Margaret Mitchell, Owen Bennett
*/

package simpleasnlg.features
{	
	import com.steamshift.datatypes.StringEnum;

	/**
	 * <p>
	 * An enumeration representing the different types of morphology patterns used
	 * by the basic morphology processor included with simpleasnlg. This enumeration
	 * is a way of informing the morphology processor which set of rules should be
	 * used when inflecting the word.
	 * </p>
	 * <p>
	 * The pattern is recorded in the {@code Feature.PATTERN} feature and applies to
	 * adjectives, nouns and verbs.
	 * </p>
	 * <p>
	 * It should be noted that the morphology processor will use user-defined
	 * inflections or those found in a lexicon first before applying the supplied
	 * rules.
	 * </p>
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	
	public final class Inflection extends StringEnum
	{	
		private static var _locked:Boolean = false;
		
		public function Inflection(key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		/**
		 * The morphology processor has simple rules for pluralising Greek and Latin
		 * nouns. The full list can be found in the explanation of the morphology
		 * processor. An example would be turning <em>focus</em> into <em>foci</em>.
		 * The Greco-Latin rules are generally more complex than the basic rules.
		 */
		public static const GRECO_LATIN_REGULAR:Inflection		= new Inflection("grecoLatinRegular");
		
		/**
		 * A word having an irregular pattern essentially means that none of the
		 * supplied rules can be used to correctly inflect the word. The inflection
		 * should be defined by the user or appear in the lexicon. <em>sheep</em> is
		 * an example of an irregular noun.
		 */
		public static const IRREGULAR:Inflection				= new Inflection("irregular");
		
		/**
		 * Regular patterns represent the default rules when dealing with
		 * inflections. A full list can be found in the explanation of the
		 * morphology processor. An example would be adding <em>-s</em> to the end
		 * of regular nouns to pluralise them.
		 */
		public static const REGULAR:Inflection					= new Inflection("regular");
		
		/**
		 * Regular double patterns apply to verbs where the last consonant is
		 * duplicated before applying the new suffix. For example, the verb
		 * <em>tag</em> has a regular double pattern as its inflected forms include
		 * <em>tagged</em> and <em>tagging</em>.
		 */
		public static const REGULAR_DOUBLE:Inflection			= new Inflection("regularDouble");
		
		/**
		 * The value for uncountable nouns, which are not inflected in their plural
		 * form.
		 */
		public static const UNCOUNT:Inflection					= new Inflection("uncount");
		
		/**
		 * The value for words which are invariant, that is, are never inflected.
		 */
		public static const INVARIANT:Inflection				= new Inflection("invariant");
		
		/**
		 * convenience method: parses an inflectional code such as
		 * "irreg|woman|women" to retrieve the first element, which is the code
		 * itself, then maps it to the value of <code>Inflection</code>.
		 * 
		 * @param code
		 *            -- the string representing the inflection. The strings are
		 *            those defined in the NIH Lexicon.
		 * @return the Inflection
		 */
		public static function getInflCode(code:String):Inflection
		{
			code = code.toLowerCase(); //.trim();
			
			switch (code)
			{
				case "reg":				return Inflection.REGULAR;
				case "irreg":			return Inflection.IRREGULAR;
				case "regd":			return Inflection.REGULAR_DOUBLE;
				case "glreg":			return Inflection.GRECO_LATIN_REGULAR;
				case "uncount":
				case "noncount":
				case "groupuncount":	return Inflection.UNCOUNT;
				case "inv":				return Inflection.INVARIANT;
			}
			
			return null;
		}
		
		{
			_locked = true;
		}
	}
	
}
