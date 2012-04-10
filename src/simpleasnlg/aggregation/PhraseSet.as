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
	import simpleasnlg.framework.NLGElement;
	
	/**
	 * This class wraps an ordered list of phrases which are constituents of two or
	 * more (different) clauses and have the same discourse function in their parent
	 * clause. FunctionPairs are used by {@link AggregationRule}s to collect candidate
	 * phrase for elision.
	 * 
	 * @author agatt
	 * 
	 */
	public class PhraseSet {
	
		private var func:DiscourseFunction;
		private var phrases:Array;
	
		/**
		 * Construct a set of compatible phrases and their function
		 * 
		 * @param function
		 *            their function
		 * @param phrases
		 *            the list of constituent phrases for the function.
		 */
		public function PhraseSet(func:DiscourseFunction, ... phrases):void
		{
			this.func = func;
			this.phrases = phrases;
		}
	
		/**
		 * Add a phrase
		 * 
		 * @param phrase
		 *            the phrase to add
		 */
		public function addPhrase(phrase:NLGElement):void
		{
			this.phrases.push(phrase);
		}
	
		/**
		 * Add a collection of phrases.
		 * 
		 * @param phrases
		 *            the phrases to add
		 */
		public function addPhrases(phrases:Array):void
		{
			this.phrases = this.phrases.concat(phrases);
		}
	
		/**
		 * 
		 * @return the function the pair of phrases have in their respective clauses
		 */
		public function getFunction():DiscourseFunction
		{
			return this.func;
		}
	
		/**
		 * Elide the rightmost constituents in the phrase list, that is, all phrases
		 * except the first.
		 */
		public function elideRightmost():void
		{
			for (var i:int = 1; i < this.phrases.length; i++)
			{
				var phrase:NLGElement = this.phrases[i];
	
				if (phrase != null)
				{
					phrase.setFeature(Feature.ELIDED, true);
				}
			}
		}
	
		/**
		 * Elide the leftmost consitutents in the phrase list, that is, all phrases
		 * except the rightmost.
		 */
		public function elideLeftmost():void
		{
			for (var i:int = this.phrases.length - 2; i >= 0; i--)
			{
				var phrase:NLGElement = this.phrases[i];
	
				if (phrase != null)
				{
					phrase.setFeature(Feature.ELIDED, true);
				}
			}
		}
	
		/**
		 * Check whether the phrases are lemma identical. This method returns
		 * <code>true</code> in the following cases:
		 * 
		 * <OL>
		 * <LI>All phrases are {@link simpleasnlg.framework.NLGElement}s and they
		 * have the same lexical head, irrespective of inflectional variations.</LI>
		 * </OL>
		 * 
		 * @return <code>true</code> if the pair is lemma identical
		 */
		public function lemmaIdentical():Boolean
		{
			var ident:Boolean = this.phrases.length > 0;
	
			for (var i:int = 1; i < this.phrases.length && ident; i++)
			{
				var left:NLGElement = this.phrases[i - 1];
				var right:NLGElement = this.phrases[i];
				
				if (left != null && right != null)
				{				
					var leftHead:NLGElement = left.getFeatureAsElement(InternalFeature.HEAD);
					var rightHead:NLGElement = right.getFeatureAsElement(InternalFeature.HEAD);				
					ident = (leftHead.equals(rightHead) || leftHead.equals(rightHead));
				}
			}
	
			return ident;
		}
	
		/**
		 * Check whether the phrases in this set are identical in form. This method
		 * returns true if for every pair of phrases <code>p1</code> and <p2>,
		 * <code>p1.equals(p2)</code>.
		 * 
		 * @return <code>true</code> if all phrases in the set are form-identical
		 */
		public function formIdentical():Boolean
		{
			var len:int = this.phrases.length;
			var ident:Boolean = len > 0;
	
			for (var i:int = 1; i < len && ident; i++)
			{
				var left:NLGElement = this.phrases[i - 1];
				var right:NLGElement = this.phrases[i];
	
				if (left != null && right != null) {
					ident = left.equals(right);
				}
			}
	
			return ident;
		}
	}
}
