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
 * Contributor(s): Ehud Reiter, Albert Gatt, Dave Wewstwater, Roman Kutlak, Margaret Mitchell, Owen Bennett.
 */
package simpleasnlg.aggregation
{
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.framework.ElementCategory;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseCategory;
	
	public class AggregationHelper
	{
		public static var FUNCTIONS:Array = [
				DiscourseFunction.SUBJECT, DiscourseFunction.HEAD,
				DiscourseFunction.COMPLEMENT, DiscourseFunction.PRE_MODIFIER,
				DiscourseFunction.POST_MODIFIER, DiscourseFunction.VERB_PHRASE];
	
		public static var RECURSIVE:Array = [DiscourseFunction.VERB_PHRASE];
	
		public static function collectFunctionalPairs(phrase1:NLGElement, phrase2:NLGElement):Array
		{
			var children1:Array = getAllChildren(phrase1);
			var children2:Array = getAllChildren(phrase2);
			var pairs:Array = new Array();
	
			if (children1.length == children2.length)
			{
				var periph:Periphery = Periphery.LEFT;
	
				var len:int = children1.length;
				for (var i:int = 0; i < len; i++)
				{
					var child1:NLGElement = children1[i];
					var child2:NLGElement = children2[i];
					var cat1:ElementCategory = child1.getCategory();
					var cat2:ElementCategory = child2.getCategory();
					var func1:DiscourseFunction = child1.getFeature(InternalFeature.DISCOURSE_FUNCTION) as DiscourseFunction;
					var func2:DiscourseFunction = child2.getFeature(InternalFeature.DISCOURSE_FUNCTION) as DiscourseFunction;
	
					if (cat1 == cat2 && func1 == func2)
					{
						pairs.push(FunctionalSet.newInstance(func1, cat1, periph,
								child1, child2));
	
						if (cat1 == LexicalCategory.VERB) {
							periph = Periphery.RIGHT;
						}
	
					} else {
						pairs.splice(0);
						break;
					}
				}
			}
	
			return pairs;
		}
	
		private static function getAllChildren(element:NLGElement):Array
		{
			var children:Array = new Array();
			var components:Array =
				element is ListElement 
				? element.getFeatureAsElementList(InternalFeature.COMPONENTS)
				: element.getChildren();
	
			var len:int = components.length;
			for (var i:int = 0; i < len; i++)
			{
				var child:NLGElement = components[i];
				children.push(child);
	
				if (child.getCategory() == PhraseCategory.VERB_PHRASE
						|| child.getFeature(InternalFeature.DISCOURSE_FUNCTION) == DiscourseFunction.VERB_PHRASE)
				{
					var arr:Array = getAllChildren(child);
					children = children.concat(arr);
				}
			}
	
			return children;
		}
	}
}
