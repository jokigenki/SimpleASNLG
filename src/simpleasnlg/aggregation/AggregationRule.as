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
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	
	/**
	 * This class represents an aggregation rule. All such rules need to implement
	 * an {@link #apply(NLGElement, NLGElement)} which takes an arbitrary number of
	 * {@link simpleasnlg.framework.NLGElement}s and perform some form of aggregation
	 * on them, returning an <code>SPhraseSpec</code> as a result, or
	 * <code>null</code> if the operation fails.
	 * 
	 * @author Albert Gatt, University of Malta and University of Aberdeen
	 * 
	 */
	public class AggregationRule
	{
	
		protected var factory:NLGFactory;
	
		/**
		 * Creates a new instance of AggregationRule
		 */
		public function AggregationRule()
		{
			this.factory = new NLGFactory();
		}
	
		/**
		 * Set the factory that the rule should use to create phrases.
		 * 
		 * @param factory
		 *            the factory
		 */
		public function setFactory(factory:NLGFactory):void
		{
			this.factory = factory;
		}
	
		/**
		 * 
		 * @return the factory being used by this rule to create phrases
		 */
		public function getFactory():NLGFactory
		{
			return this.factory;
		}
	
		/**
		 * Performs aggregation on an arbitrary number of elements in a list. This
		 * method calls {{@link #apply(NLGElement, NLGElement)} on all pairs of
		 * elements in the list, recursively aggregating whenever it can.
		 * 
		 * @param phrases
		 *            the sentences
		 * @return a list containing the phrases, such that, for any two phrases s1
		 *         and s2, if {@link #apply(NLGElement, NLGElement)} succeeds on s1
		 *         and s2, the list contains the result; otherwise, the list
		 *         contains s1 and s2.
		 */
		public function applyArray (phrases:Array):Array
		{
			var results:Array  = new Array();
			
			var len:int = phrases.length;
			if (len > 1)
			{
				var removed:Array = new Array();
				
				for (var i:int = 0; i < len; i++)
				{
					var current:NLGElement = phrases[i];
					
					if (removed.indexOf(current) > -1) continue;
					
					for (var j:int = i + 1; j < len; j++)
					{
						var next:NLGElement = phrases[j];
						var aggregated:NLGElement = applyElements(current, next);
						
						if (aggregated != null)
						{
							current = aggregated;
							removed.push(next);
						}
					}
					
					results.push(current);
				}
				
			}
			else if(len == 1)
			{
				results.push(applyNLGElement(phrases[0]));
			}
			
			return results;
		}
		
		/**
		 * Perform aggregation on a single phrase. This method only works on a
		 * {@link simpleasnlg.framework.CoordinatedPhraseElement}, in which case it
		 * calls {@link #apply(List)} on the children of the coordinated phrase,
		 * returning a coordinated phrase whose children are the result.
		 * 
		 * @param phrase
		 * @return aggregated result
		 */
		public function applyNLGElement(phrase:NLGElement):NLGElement
		{
			var result:NLGElement = null;
			var cpElement:CoordinatedPhraseElement;
			
			if (phrase is CoordinatedPhraseElement)
			{			
				cpElement = CoordinatedPhraseElement(phrase);
				var children:Array = cpElement.getChildren();
				var aggregated:Array = applyArray(children);
	
				if (aggregated.length == 1)
				{
					result = aggregated[0];
				} else {
					result = this.factory.createCoordinatedPhrase();
	
					var len:int = aggregated.length;
					for (var i:int = 0; i < len; i++)
					{
						var agg:NLGElement = aggregated[i];
						cpElement = CoordinatedPhraseElement(result);
						cpElement.addCoordinate(agg);
					}
				}			
			}
	
			if (result != null)
			{
				var featureNames:Array = phrase.getAllFeatureNames();
				for each (var featureName:String in featureNames)
				{
					result.setFeatureByName(featureName, phrase.getFeatureByName(featureName));
				}
			}
			
			return result;
		}
	
		/**
		 * Performs aggregation on a pair of sentences. This is the only method that
		 * extensions of <code>AggregationRule</code> need to implement.
		 * 
		 * @param sentence1
		 *            the first sentence
		 * @param sentence2
		 *            the second sentence
		 * @return an aggregated sentence, if the method succeeds, <code>null</code>
		 *         otherwise
		 */
		public function applyElements(sentence1:NLGElement, sentence2:NLGElement):NLGElement
		{
			throw new Error("AggregationRule.apply(sentence1:NLGElement, sentence2:NLGElement):NLGElement must be overridden");
		}
	}
}
