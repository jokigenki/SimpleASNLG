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
	 * An enumeration representing the gender of the subject of a noun phrase, or
	 * the object or subject of a verb phrase. It is most commonly used with
	 * personal pronouns. The gender is recorded in the {@code Feature.GENDER}
	 * feature and applies to nouns and pronouns.
	 * </p>
	 * 
	 * @author A. Gatt and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class Gender extends StringEnum
	{
		private static var _locked:Boolean = false;
		
		public function Gender (key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		/**
		 * A word or phrase pertaining to a male topic. For example, <em>he</em>,
		 * <em>him</em>, <em>his</em>.
		 */
		public static const MASCULINE:Gender		= new Gender("masculine");
		
		/**
		 * A word or phrase pertaining to a female topic. For example, <em>she</em>,
		 * <em>her</em>, <em>hers</em>.
		 */
		public static const FEMININE:Gender			= new Gender("feminine");
		
		/**
		 * A word or phrase pertaining to a neutral or gender-less topic. For
		 * example, <em>it</em>, <em>its</em>.
		 */
		public static const NEUTER:Gender			= new Gender("neuter");
		
		{
			_locked = true;
		}
	}
}
