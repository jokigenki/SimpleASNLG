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
package simpleasnlg.aggregation
{
	import com.steamshift.datatypes.StringEnum;

	public final class Periphery extends StringEnum
	{
		private static var _locked:Boolean = false;
		
		public function Periphery(key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		public static const LEFT:Periphery = new Periphery("left");
		public static const RIGHT:Periphery = new Periphery("right");
		
		{
			_locked = true;
		}
	}		
}
