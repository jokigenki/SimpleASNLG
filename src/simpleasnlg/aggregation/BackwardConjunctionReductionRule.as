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
	import simpleasnlg.framework.PhraseCategory;
	
	/**
	 * Implementation of the backward conjunction reduction rule. Given two
	 * sentences <code>s1</code> and <code>s2</code>, this rule elides any
	 * constituent in the right periphery of <code>s1</code> which is
	 * <I>form-identical</I> to a constituent with the same function in
	 * <code>s2</code>, that is, the two constituents are essentially identical in
	 * their final, realised, form.
	 * 
	 * <P>
	 * The current implementation is loosely based on the algorithm in Harbusch and
	 * Kempen (2009), which is described here:
	 * 
	 * <a href="http://aclweb.org/anthology-new/W/W09/W09-0624.pdf">
	 * http://aclweb.org/anthology-new/W/W09/W09-0624.pdf</a>
	 * </P>
	 * 
	 * <P>
	 * <strong>Implementation note:</strong> The current implementation only applies
	 * ellipsis to phrasal constituents (i.e. not to their component lexical items).
	 * </P>
	 * 
	 * *
	 * <P>
	 * <STRONG>Note:</STRONG>: this rule can be used in conjunction with the
	 * {@link ForwardConjunctionReductionRule} in {@link Aggregator}.
	 * </P>
	 * 
	 * @author Albert Gatt, University of Malta and University of Aberdeen
	 * 
	 */
	public class BackwardConjunctionReductionRule extends AggregationRule
	{
	
		//private SyntaxProcessor _syntaxProcessor;
	
		/**
		 * Creates a new <code>BackwardConjunctionReduction</code>.
		 */
		public function BackwardConjunctionReductionRule()
		{
			super();
			//this._syntaxProcessor = new SyntaxProcessor();
		}
	
		/**
		 * Applies backward conjunction reduction to two NLGElements e1 and e2,
		 * succeeding only if they are clauses (that is, e1.getCategory() ==
		 * e2.getCategory == {@link simpleasnlg.framework.PhraseCategory#CLAUSE}).
		 * 
		 * @param previous
		 *            the first phrase
		 * @param next
		 *            the second phrase
		 * @return a coordinate phrase if aggregation is successful,
		 *         <code>null</code> otherwise
		 */
		override public function applyElements(previous:NLGElement, next:NLGElement):NLGElement
		{
			var success:Boolean = false;
	
			if (previous.getCategory() == PhraseCategory.CLAUSE
					&& next.getCategory() == PhraseCategory.CLAUSE
					&& PhraseChecker.nonePassive(previous, next))
			{
				
				var rightPeriphery:Array = PhraseChecker.rightPeriphery(previous, next);
				var len:int = rightPeriphery.length;
				for (var i:int = 0; i < len; i++)
				{
					var pair:PhraseSet = rightPeriphery[i];
					if (pair.lemmaIdentical())
					{
						pair.elideLeftmost();
						success = true;
					}
				}
			}
	
			return success ? this.factory.createCoordinatedPhrase(previous, next)
					: null;
		}
	}
}
