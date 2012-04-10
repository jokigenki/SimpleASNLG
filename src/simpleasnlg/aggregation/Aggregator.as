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
	
	/**
	 * An Aggregator performs aggregation on clauses, by applying a set of
	 * prespecified rules on them and returning the result.
	 * 
	 * @author Albert Gatt, University of Malya & University of Aberdeen
	 * 
	 */
	public class Aggregator extends NLGModule
	{
		private var _rules:Array;
		private var _factory:NLGFactory;
	
		/**
		 * Creates an instance of Aggregator
		 */
		public function Aggregator()
		{
			super();
		}
	
		/**
		 * {@inheritDoc}
		 */
		override public function initialise():void
		{
			this._rules = new Array();
			this._factory = new NLGFactory();
		}
	
		/**
		 * Set the factory that this aggregator should use to create phrases. The
		 * factory will be passed on to all the component rules.
		 * 
		 * @param factory
		 *            the phrase factory
		 */
		public function setFactory(factory:NLGFactory):void
		{
			this._factory = factory;
	
			var len:int = _rules.length;
			for (var i:int = 0; i < len; i++)
			{
				var rule:AggregationRule = _rules[i];
				rule.setFactory(this._factory);
			}
		}
	
		/**
		 * Add a rule to this aggregator. Aggregation rules are applied in the order
		 * in which they are supplied.
		 * 
		 * @param rule
		 *            the rule
		 */
		public function addRule(rule:AggregationRule):void
		{
			rule.setFactory(this._factory);
			this._rules.push(rule);
		}
	
		/**
		 * Get the rules in this aggregator.
		 * 
		 * @return the rules
		 */
		public function getRules():Array
		{
			return this._rules;
		}
	
		/**
		 * Apply aggregation to a single phrase. This will only work if the phrase
		 * is a coordinated phrase, whose children can be further aggregated.
		 * 
		 */
		override public function realise(element:NLGElement):NLGElement
		{
			var result:NLGElement = element;
	
			var len:int = _rules.length;
			for (var i:int = 0; i < len; i++)
			{
				var rule:AggregationRule = _rules[i];
				var intermediate:NLGElement = rule.applyNLGElement(result);
	
				if (intermediate != null) {
					result = intermediate;
				}
			}
			
			return result;
		}
		
		/**
		 * Apply aggregation to a list of elements. This method iterates through the
		 * rules supplied via {@link #addRule(AggregationRule)} and applies them to
		 * the elements.
		 * 
		 * @param elements
		 *            the list of elements to aggregate
		 * @return a list of the elements that remain after the aggregation rules
		 *         have been applied
		 */
		override public function realiseList(elements:Array):Array
		{
			var len:int = _rules.length;
			for (var i:int = 0; i < len; i++)
			{
				var rule:AggregationRule = _rules[i];
				elements = rule.applyArray(elements);
			}
	
			return elements;
		}
	}
}
