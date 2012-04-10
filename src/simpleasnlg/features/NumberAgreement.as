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

package simpleasnlg.features
{	
	import com.steamshift.datatypes.StringEnum;

	/**
	 * <p>
	 * An enumeration representing the different types of number agreement. The
	 * number agreement is recorded in the {@code Feature.NUMBER} feature and
	 * applies to nouns and verbs, and their associated phrases.
	 * </p>
	 * 
	 * 
	 * @author A. Gatt and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public final class NumberAgreement extends StringEnum
	{
		private static var _locked:Boolean = false;
		
		public function NumberAgreement(key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		/**
		 * This represents words that have the same form regardless of whether they 
		 * are singular or plural. For example, <em>sheep</em>, <em>fish</em>.
		 */
		public static const BOTH:NumberAgreement			= new NumberAgreement("both");
		
		/**
		 * This represents verbs and nouns that are written in the plural. For
		 * example, <em>dogs</em> as opposed to <em>dog</em>, and
		 * <em>John and Simon <b>kiss</b> Mary</em>.
		 */
		public static const PLURAL:NumberAgreement			= new NumberAgreement("plural");
		
		/**
		 * This represents verbs and nouns that are written in the singular. For
		 * example, <em>dog</em> as opposed to <em>dogs</em>, and
		 * <em>John <b>kisses</b> Mary</em>.
		 */
		public static const SINGULAR:NumberAgreement		= new NumberAgreement("singular");
		
		{
			_locked = true;
		}
	}
}
