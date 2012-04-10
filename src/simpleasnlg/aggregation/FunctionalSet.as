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
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.framework.ElementCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	
	public class FunctionalSet
	{
		private var components:Array;
		private var func:DiscourseFunction;
		private var category:ElementCategory;
		private var periphery:Periphery;
	
		public static function newInstance(func:DiscourseFunction,
				category:ElementCategory, periphery:Periphery,
				...components):FunctionalSet
		{
	
			var pair:FunctionalSet = null;
	
			if (components.length >= 2) {
				pair = new FunctionalSet(func, category, periphery, components);
			}
	
			return pair;
	
		}
	
		public function FunctionalSet(func:DiscourseFunction, category:ElementCategory,
				periphery:Periphery, ...components)
		{
			this.func = func;
			this.category = category;
			this.periphery = periphery;
			this.components = [components];
		}
	
		public function formIdentical():Boolean
		{
			var ident:Boolean = true;
			var firstElement:NLGElement = this.components[0];
	
			var len:int = this.components.length;
			for (var i:int = 1; i < len && ident; i++)
			{
				ident = firstElement.equals(components[i]);
			}
	
			return ident;
		}
	
		public function lemmaIdentical():Boolean
		{
			return false;
		}
	
		public function elideLeftMost():void
		{
			var len:int = this.components.length - 1;
			for(var i:int = 0; i < len; i++)
			{
				recursiveElide(components[i]);		
			}
		}
	
		public function elideRightMost():void
		{
			var len:int = this.components.length - 1;
			for(var i:int = len; i > 0; i--)
			{
				recursiveElide( components[i] );	
			}
		}
		
		private function recursiveElide(component:NLGElement):void
		{
			if (component is ListElement)
			{
				var componentList:Array = component.getFeatureAsElementList(InternalFeature.COMPONENTS);
				var len:int = componentList.length;
				for (var i:int = 0; i < len; i++)
				{
					var subcomponent:NLGElement = componentList[i];
					recursiveElide(subcomponent);
				}
			} else {
				component.setFeature(Feature.ELIDED, true);
			}
		}
	
		public function getFunction():DiscourseFunction
		{
			return func;
		}
	
		public function getCategory():ElementCategory 
		{
			return category;
		}
	
		public function getPeriphery():Periphery
		{
			return periphery;
		}
		
		public function getComponents():Array
		{
			return this.components;
		}
	
		public function toString():String
		{
			var buffer:String = "";
			
			var len:int = components.length;
			for (var i:int = 0; i < len; i++)
			{
				var elem:NLGElement = components[i];
				buffer += "ELEMENT: " + elem.toString() + "\n";
			}
			
			return buffer;
		}
	}
}
