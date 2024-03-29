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
	
	
	
	import flash.utils.Dictionary;
	
	import simpleasnlg.features.Feature;
	import com.steamshift.utils.StringUtils;
	
	/**
	 * <p>
	 * This class defines an element for representing canned text within the
	 * SimpleNLG library. Once assigned a value, the string element should not be
	 * changed by any other processors.
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class StringElement extends NLGElement
	{
	
		/**
		 * Constructs a new string element representing some canned text.
		 * 
		 * @param value
		 *            the text for this string element.
		 */
		public function StringElement(value:String)
		{
			setCategory(PhraseCategory.CANNED_TEXT);
			setFeature(Feature.ELIDED, false);
			setRealisation(value);
		}
	
		/**
		 * The string element contains no children so this method will always return
		 * an empty list.
		 */
		override public function getChildren():Array
		{
			return new Array();
		}
	
		override public function toString():String
		{
			return getRealisation();
		}
	
		/* (non-Javadoc)
		 * @see simpleasnlg.framework.NLGElement#equals(java.lang.Object)
		 */
		override public function equals(o:Object):Boolean
		{
			// TODO Auto-generated method stub
			return super.equals(o) && (o is StringElement) && realisationsMatch(StringElement(o));
		}
	
		private function realisationsMatch(o:StringElement):Boolean
		{
			if  (getRealisation() == null)
			{
				return o.getRealisation() == null;
			} else {
				return getRealisation() == o.getRealisation();
			}
		}
	
		override public function printTree(indent:String):String
		{
			var print:String = "";
			print += "StringElement: content=\"" + getRealisation() + '\"'; //$NON-NLS-1$
			var features:Dictionary = this.getAllFeatures();
	
			if (features != null)
			{
				print += ", features=" + StringUtils.mapToString(features); //$NON-NLS-1$
			}
			print += '\n';
			
			return print;
		}
	}
}
