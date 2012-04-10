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
	
	
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.framework.NLGModule;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.PhraseElement;
	import simpleasnlg.syntax.english.SyntaxProcessor;
	
	public class NewAggregator extends NLGModule
	{
		private var _syntax:SyntaxProcessor;
		private var _factory:NLGFactory;
	
		public function NewAggregator()
		{
	
		}
	
		override public function initialise():void
		{
			this._syntax = new SyntaxProcessor();
			this._factory = new NLGFactory();
		}
	
		override public function realise(elements:NLGElement):NLGElement
		{
			// TODO Auto-generated method stub
			return null;
		}
	
		public function realiseElements(phrase1:NLGElement, phrase2:NLGElement):NLGElement
		{
			var result:NLGElement = null;
	
			if (phrase1 is PhraseElement
					&& phrase2 is PhraseElement
					&& phrase1.getCategory() == PhraseCategory.CLAUSE
					&& phrase2.getCategory() == PhraseCategory.CLAUSE)
			{
	
				var funcSets:Array = AggregationHelper.collectFunctionalPairs(this._syntax.realise(phrase1),this._syntax.realise(phrase2));
	
				applyForwardConjunctionReduction(funcSets);
				applyBackwardConjunctionReduction(funcSets);
				result = this._factory.createCoordinatedPhrase(phrase1, phrase2);
			}
	
			return result;
		}
	
		// private function applyGapping(List<FunctionalSet> funcPairs) {
		//
		// }
	
		private function applyForwardConjunctionReduction(funcSets:Array):void
		{
			var len:int = funcSets.length;
			for (var i:int = 0; i < len; i++)
			{
				var pair:FunctionalSet = funcSets[i];
				if (pair.getPeriphery() == Periphery.LEFT && pair.formIdentical()) {
					pair.elideRightMost();
				}
			}
	
		}
	
		private function applyBackwardConjunctionReduction(funcSets:Array):void
		{
			var len:int = funcSets.length;
			for (var i:int = 0; i < len; i++)
			{
				var pair:FunctionalSet = funcSets[i];
				if (pair.getPeriphery() == Periphery.RIGHT && pair.formIdentical()) {
					pair.elideLeftMost();
				}
			}
		}
	}
}
