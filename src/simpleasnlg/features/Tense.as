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
	 * An enumeration representing the different types of temporal sense that can be
	 * applied to a verb. The tense is recorded in the {@code Feature.TENSE} feature
	 * and applies to verbs and their associated phrases.
	 * </p>
	 * 
	 * 
	 * @author A. Gatt and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	
	public final class Tense extends StringEnum
	{
		private static var _locked:Boolean;
		
		public function Tense (key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		/**
		 * The action described by the verb will happen in the future. For example,
		 * <em>John will kiss Mary</em>, <em>the dog will eat a bone</em>.
		 */
		public static const FUTURE:Tense			= new Tense("future");
		
		/**
		 * The action described by the verb happened in the past. For example,
		 * <em>John kissed Mary</em>, <em>the dog ate a bone</em>.
		 */
		public static const PAST:Tense				= new Tense("past");
		
		/**
		 * The action described by the verb is happening in the present time. For
		 * example, <em>John kisses Mary</em>, <em>the dog eats a bone</em>.
		 */
		public static const PRESENT:Tense			= new Tense("present");
		
		{
			_locked = true;
		}
	}
}
