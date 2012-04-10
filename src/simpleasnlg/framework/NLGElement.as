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
	
	import com.steamshift.utils.ArrayUtils;
	import com.steamshift.utils.Cloner;
	import com.steamshift.utils.StringUtils;
	
	import flash.utils.Dictionary;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.IFeature;
	import simpleasnlg.features.NumberAgreement;
	import simpleasnlg.features.Tense;
	
	/**
	 * <p>
	 * <code>NLGElement</code> is the base class that all elements extend from. This
	 * is abstract and cannot therefore be instantiated itself. The additional
	 * element classes should be used to correctly identify the type of element
	 * required.
	 * </p>
	 * 
	 * <p>
	 * Realisation in SimpleNLG revolves around a tree structure. Each node in the
	 * tree is represented by a <code>NLGElement</code>, which in turn may have
	 * child nodes. The job of the processors is to replace various types of
	 * elements with other elements. The eventual goal, once all the processors have
	 * been run, is to produce a single string element representing the final
	 * realisation.
	 * </p>
	 * 
	 * <p>
	 * The features are stored in a <code>Dictionary</code> of <code>String</code> (the
	 * feature name) and <code>Object</code> (the value of the feature).
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class NLGElement
	{
		/** The category of this element. */
		protected var category:ElementCategory;
	
		/** The features of this element. */
		protected var features:Dictionary = new Dictionary();
	
		/** The parent of this element. */
		protected var parent:NLGElement;
	
		/** The realisation of this element. */
		protected var realisation:String;
	
		/** The NLGFactory which created this element */
		protected var factory:NLGFactory;
	
		/**
		 * Sets the category of this element.
		 * 
		 * @param newCategory
		 *            the new <code>ElementCategory</code> for this element.
		 */
		public function setCategory(newCategory:ElementCategory):void
		{
			this.category = newCategory;
		}
	
		/**
		 * Retrieves the category for this element.
		 * 
		 * @return the category as a <code>ElementCategory</code>.
		 */
		public function getCategory():ElementCategory
		{
			return this.category;
		}
	
		/**
		 * Adds a feature to the feature map. If the feature already exists then it
		 * is given the new value. If the value provided is <code>null</code> the
		 * feature is removed from the map.
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @param featureValue
		 *            the new value of the feature or <code>null</code> if the
		 *            feature is to be removed.
		 */
		public function setFeature(feature:IFeature, featureValue:*):void
		{
			setFeatureByName(feature.toString(), featureValue);
		}
		
		public function setFeatureByName(featureName:String, featureValue:*):void
		{
			if (featureName != null)
			{
				if (featureValue == null)
				{
					delete this.features[featureName];
				} else {
					this.features[featureName] = featureValue;
				}
			}
		}
	
	
		/**
		 * Retrieves the value of the feature.
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>Object</code> value of the feature.
		 */
		public function getFeature(feature:IFeature):*
		{
			return feature != null ? this.features[feature.toString()] : null;
		}
		
		public function getFeatureByName(featureName:String):*
		{
			return featureName != null ? this.features[featureName] : null;
		}
	
		/**
		 * Retrieves the value of the feature as a string. If the feature doesn't
		 * exist then <code>null</code> is returned.
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>String</code> representation of the value. This is
		 *         taken by calling the object's <code>toString()</code> method.
		 */
		public function getFeatureAsString(feature:IFeature):String
		{
			var value:* = this.features[feature.toString()];
			
			if (value != null) {
				return value.toString();
			}
			return null;
		}
		
		public function getFeatureByNameAsString(featureName:String):String
		{
			var value:* = this.features[featureName];
			
			if (value != null) {
				return value.toString();
			}
			return null;
		}
	
		/**
		 * <p>
		 * Retrieves the value of the feature as a list of elements. If the feature
		 * is a single <code>NLGElement</code> then it is wrapped in a list. If the
		 * feature is a <code>Collection</code> then each object in the collection
		 * is checked and only <code>NLGElement</code>s are returned in the list.
		 * </p>
		 * <p>
		 * If the feature does not exist then an empty list is returned.
		 * </p>
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>List</code> of <code>NLGElement</code>s
		 */
		public function getFeatureAsElementList (feature:IFeature):Array
		{
			var nextObject:Object;
			var list:Array = new Array();
	
			var value:* = this.features[feature.toString()];
			if (value is NLGElement)
			{
				list.push(value);
			}
			else if (value is Array || value is Dictionary)
			{
				for each (nextObject in value)
				{
					if (nextObject is NLGElement)
					{
						list.push(nextObject);
					}
				}
			}
			
			return list;
		}
		
		public function getFeatureByNameAsElementList (featureName:String):Array
		{
			var nextObject:Object;
			var list:Array = new Array();
			
			var value:* = this.features[featureName];
			if (value is NLGElement)
			{
				list.push(value);
			}
			else if (value is Array || value is Dictionary)
			{
				for each (nextObject in value)
				{
					if (nextObject is NLGElement)
					{
						list.push(nextObject);
					}
				}
			}
			
			return list;
		}
		
		/**
		 * <p>
		 * Retrieves the value of the feature as a list of java objects. If the feature
		 * is a single element, the list contains only this element.
		 * If the feature is a <code>Collection</code> each object in the collection is
		 * returned in the list.
		 * </p>
		 * <p>
		 * If the feature does not exist then an empty list is returned.
		 * </p>
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>List</code> of <code>Object</code>s
		 */
		public function getFeatureAsList(featureName:String):Array
		{
			var nextObject:Object;
			var values:Array = new Array();
			var value:Object = this.features[featureName];
			
			if (value != null)
			{
				if (value is Array || value is Dictionary)
				{
					{
						for each (nextObject in value)
						{
							if (nextObject is NLGElement)
							{
								values.push(nextObject);
							}
						}
					}
				} else {
					values.push(value);
				}
			}
			
			return values;
		}
	
		/**
		 * <p>
		 * Retrieves the value of the feature as a list of strings. If the feature
		 * is a single element, then its <code>toString()</code> value is wrapped in
		 * a list. If the feature is a <code>Collection</code> then the
		 * <code>toString()</code> value of each object in the collection is
		 * returned in the list.
		 * </p>
		 * <p>
		 * If the feature does not exist then an empty list is returned.
		 * </p>
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>List</code> of <code>String</code>s
		 */
		public function getFeatureAsStringList(featureName:String):Array
		{
			var nextObject:Object;
			var values:Array = new Array();
			var value:Object = this.features[featureName];
	
			if (value != null)
			{
				if (value is Array || value is Dictionary)
				{
					for each (nextObject in value)
					{
						if (nextObject is NLGElement)
						{
							values.push(nextObject.toString());
						}
					}
				} else {
					values.push(value.toString());
				}
			}
			
			return values;
		}
	
		/**
		 * Retrieves the value of the feature as an <code>Integer</code>. If the
		 * feature does not exist or cannot be converted to an integer then
		 * <code>null</code> is returned.
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>Integer</code> representation of the value. Numbers are
		 *         converted to integers while Strings are parsed for integer
		 *         values. Any other type will return <code>null</code>.
		 */
		public function getFeatureAsInteger(featureName:String):int
		{
			var value:Object = this.features[featureName];
			var intValue:int = -1;
			try
			{
				intValue = int(value);
			}
			catch (error:Error)
			{
				intValue = -1;
			}
			
			return intValue;
		}
	
		/**
		 * Retrieves the value of the feature as a <code>Long</code>. If the feature
		 * does not exist or cannot be converted to a long then <code>null</code> is
		 * returned.
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>Long</code> representation of the value. Numbers are
		 *         converted to longs while Strings are parsed for long values. Any
		 *         other type will return <code>null</code>.
		 */
		public function getFeatureAsNumber(featureName:String):Number
		{
			var value:Object = this.features[featureName];
			
			var longValue:Number = -1;
			try
			{
				longValue = Number(value);
			}
			catch (error:Error)
			{
				longValue = -1;
			}

			return longValue;
		}
	
		/**
		 * Retrieves the value of the feature as a <code>Boolean</code>. If the
		 * feature does not exist or is not a boolean then
		 * <code>Boolean.FALSE</code> is returned.
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>Boolean</code> representation of the value. Any
		 *         non-Boolean type will return <code>Boolean.FALSE</code>.
		 */
		public function getFeatureAsBoolean(feature:IFeature):Boolean
		{
			var value:* = this.features[feature.toString()];
			var boolValue:Boolean = false;
			if (value is Boolean)
			{
				boolValue = value;
			}
			return boolValue;
		}
	
		public function getFeatureByNameAsBoolean(featureName:String):Boolean
		{
			var value:* = this.features[featureName];
			var boolValue:Boolean = false;
			if (value is Boolean)
			{
				boolValue = value;
			}
			return boolValue;
		}
		
		/**
		 * Retrieves the value of the feature as a <code>NLGElement</code>. If the
		 * value is a string then it is wrapped in a <code>StringElement</code>. If
		 * the feature does not exist or is of any other type then <code>null</code>
		 * is returned.
		 * 
		 * @param featureName
		 *            the name of the feature.
		 * @return the <code>NLGElement</code>.
		 */
		public function getFeatureAsElement(feature:IFeature):NLGElement
		{
			var value:* = this.features[feature.toString()];
			var elementValue:NLGElement = null;
	
			if (value is NLGElement)
			{
				elementValue = NLGElement(value);
			}
			else if (value is String)
			{
				elementValue = new StringElement(value);
			}
			return elementValue;
		}
		
		public function getFeatureByNameAsElement(featureName:String):NLGElement
		{
			var value:* = this.features[featureName];
			var elementValue:NLGElement = null;
			
			if (value is NLGElement)
			{
				elementValue = NLGElement(value);
			}
			else if (value is String)
			{
				elementValue = new StringElement(value);
			}
			return elementValue;
		}
	
		/**
		 * Retrieves the map containing all the features for this element.
		 * 
		 * @return a <code>Dictionary</code> of <code>String</code>, <code>Object</code>.
		 */
		public function getAllFeatures():Dictionary
		{
			return this.features;
		}
	
		/**
		 * Checks the feature map to see if the named feature is present in the map.
		 * 
		 * @param featureName
		 *            the name of the feature to look for.
		 * @return <code>true</code> if the feature exists, <code>false</code>
		 *         otherwise.
		 */
		public function hasFeature(feature:IFeature):Boolean
		{
			var featureValue:* = this.features[feature.toString()];
			return feature != null ? featureValue != null : false;
		}
	
		public function hasFeatureByName(featureName:String):Boolean
		{
			var featureValue:* = this.features[featureName];
			return featureName != null ? featureValue != null : false;
		}
		
		/**
		 * Deletes the named feature from the map.
		 * 
		 * @param featureName
		 *            the name of the feature to be removed.
		 */
		public function removeFeature(feature:IFeature):void
		{
			delete this.features[feature.toString()];
		}
		
		public function removeFeatureByName(featureName:String):void
		{
			delete this.features[featureName];
		}
	
		/**
		 * Deletes all the features in the map.
		 */
		public function clearAllFeatures():void
		{
			this.features = new Dictionary();
		}
	
		/**
		 * Sets the parent element of this element.
		 * 
		 * @param newParent
		 *            the <code>NLGElement</code> that is the parent of this
		 *            element.
		 */
		public function setParent(newParent:NLGElement):void
		{
			this.parent = newParent;
		}
	
		/**
		 * Retrieves the parent of this element.
		 * 
		 * @return the <code>NLGElement</code> that is the parent of this element.
		 */
		public function getParent():NLGElement
		{
			return this.parent;
		}
	
		/**
		 * Sets the realisation of this element.
		 * 
		 * @param realised
		 *            the <code>String</code> representing the final realisation for
		 *            this element.
		 */
		public function setRealisation(realised:String):void
		{
			this.realisation = realised;
		}
	
		/**
		 * Retrieves the final realisation of this element.
		 * 
		 * @return the <code>String</code> representing the final realisation for
		 *         this element.
		 */
		public function getRealisation():String
		{
			var start:int = 0;
			var end:int = 0;
			if (null != this.realisation)
			{
				end = this.realisation.length;
	
				while (start < this.realisation.length && ' ' == this.realisation.charAt(start))
				{
					start++;
				}
				if (start == this.realisation.length)
				{
					this.realisation = null;
				} else {
					while (end > 0 && ' ' == this.realisation.charAt(end - 1)) {
						end--;
					}
				}
			}
	
			
			// AG: changed this to return the empty string if the realisation is
			// null
			// avoids spurious nulls appearing in output for empty phrases.
			
			return this.realisation == null ? "" : this.realisation.substring(start, end);
		}
	
		public function toString():String
		{
			var buffer:String = "{realisation=" + this.realisation; //$NON-NLS-1$
			if (this.category != null)
			{
				buffer += ", category=" + this.category.toString(); //$NON-NLS-1$
			}
			if (this.features != null) {
				buffer += ", features=" + StringUtils.mapToString(this.features); //$NON-NLS-1$
			}
			buffer += '}';
			
			return buffer.toString();
		}
		
		public function isA(checkCategory:ElementCategory):Boolean
		{
			var isA:Boolean = false;
	
			if (this.category != null)
			{
				isA = this.category.equalTo(checkCategory);
			} else if (checkCategory == null) {
				isA = true;
			}
			return isA;
		}
	
		/**
		 * Retrieves the children for this element. This method needs to be
		 * overridden for each specific type of element. Each type of element will
		 * have its own way of determining the child elements.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s representing the
		 *         children of this element.
		 */
		public function getChildren():Array
		{
			throw new Error ("NLGElement.getChildren must be overridden");
		};
	
		/**
		 * Retrieves the set of features currently contained in the feature map.
		 * 
		 * @return a <code>Set</code> of <code>String</code>s representing the
		 *         feature names. The set is unordered.
		 */
		public function getAllFeatureNames():Array
		{
			var names:Array = [];
			
			for (var key:String in features)
			{
				names.push(key);
			}
			return names;
		}
	
		public function printTree(indent:String):String
		{
			var thisIndent:String = indent == null ? " |-" : indent + " |-"; //$NON-NLS-1$ //$NON-NLS-2$
			var childIndent:String = indent == null ? " |-" : indent + " |-"; //$NON-NLS-1$ //$NON-NLS-2$
			var print:String = "";
			print += "NLGElement: " + toString() + '\n'; //$NON-NLS-1$
	
			var children:Array = getChildren();
	
			if (children != null)
			{
				var len:int = children.length;
				for (var i:int = 0; i < len; i++)
				{
					var eachChild:NLGElement = children[i];
					print += thisIndent + eachChild.printTree(childIndent);
				}
			}
			return print.toString();
		}
	
		/**
		 * Sets the number agreement on this element. This method is added for
		 * convenience and not all element types will make use of the number
		 * agreement feature. The method is identical to calling {@code
		 * setFeature(Feature.NUMBER, NumberAgreement.PLURAL)} for plurals or
		 * {@code setFeature(Feature.NUMBER, NumberAgreement.SINGULAR)} for the
		 * singular.
		 * 
		 * @param isPlural
		 *            <code>true</code> if this element is to be treated as a
		 *            plural, <code>false</code> otherwise.
		 */
		public function setPlural(isPlural:Boolean):void
		{
			if (isPlural)
			{
				setFeature(Feature.NUMBER, NumberAgreement.PLURAL);
			} else {
				setFeature(Feature.NUMBER, NumberAgreement.SINGULAR);
			}
		}
	
		/**
		 * Determines if this element is to be treated as a plural. This is a
		 * convenience method and not all element types make use of number
		 * agreement.
		 * 
		 * @return <code>true</code> if the <code>Feature.NUMBER</code> feature has
		 *         the value <code>NumberAgreement.PLURAL</code>, <code>false</code>
		 *         otherwise.
		 */
		public function isPlural():Boolean
		{
			return NumberAgreement.PLURAL == getFeature(Feature.NUMBER);
		}
	
		// Following should be deleted at some point, as it makes more sense to have
		// them in SPhraseSpec
		/**
		 * Retrieves the tense for this element. The method is identical to calling
		 * {@code getFeature(Feature.TENSE)} and casting the result as
		 * <code>Tense<code>.
		 * *
		 * WARNING: You should use getFeature(Feature.TENSE)
		 * getTense will be dropped from simplenlg at some point
		 * 
		 * @return the <code>Tense</code> of this element.
		 */
		//@Deprecated
		public function getTense():Tense
		{
			var tense:Tense = Tense.PRESENT;
			var tenseValue:Object = getFeature(Feature.TENSE);
			if (tenseValue is Tense)
			{
				tense = Tense(tenseValue);
			}
			return tense;
		}
	
		/**
		 * Sets the tense on this element. The method is identical to calling
		 * {@code setFeature(Feature.TENSE, newTense)}.
		 * 
		 * WARNING: You should use setTense(Feature.TENSE, tense) setTense will be
		 * dropped from simplenlg at some point
		 * 
		 * @param newTense
		 *            the new tense for this element.
		 */
		//@Deprecated
		public function setTense(newTense:Tense):void
		{
			setFeature(Feature.TENSE, newTense);
		}
	
		/**
		 * Sets the negation on this element. The method is identical to calling
		 * {@code setFeature(Feature.NEGATED, isNegated)}.
		 * 
		 * WARNING: You should use setFeature(Feature.NEGATED, isNegated) setNegated
		 * will be dropped from simplenlg at some point
		 * 
		 * @param isNegated
		 *            <code>true</code> if the element is to be negated,
		 *            <code>false</code> otherwise.
		 */
		//@Deprecated
		public function setNegated(isNegated:Boolean):void
		{
			setFeature(Feature.NEGATED, isNegated);
		}
	
		/**
		 * Determines if this element is to be treated as a negation. This method
		 * just examines the value of the NEGATED feature
		 * 
		 * WARNING: You should use getFeature(Feature.NEGATED) getNegated will be
		 * dropped from simplenlg at some point
		 * 
		 * @return <code>true</code> if the <code>Feature.NEGATED</code> feature
		 *         exists and has the value <code>Boolean.TRUE</code>,
		 *         <code>false</code> is returned otherwise.
		 */
		//@Deprecated
		public function isNegated():Boolean
		{
			return getFeatureAsBoolean(Feature.NEGATED);
		}
	
		/**
		 * @return the NLG factory
		 */
		public function getFactory():NLGFactory
		{
			return factory;
		}
	
		/**
		 * @param factory
		 *            the NLG factory to set
		 */
		public function setFactory(factory:NLGFactory):void
		{
			this.factory = factory;
		}
	
		/**
		 * Determines if this element has its realisation equal to the given string.
		 * or An NLG element is equal to some object if the object is an NLGElement,
		 * they have the same category and the same features.
		 * 
		 * @param elementRealisation
		 *            the string to check against, or the NLGElement.
		 * @return <code>true</code> if the string matches the element's
		 *         realisation, <code>false</code> otherwise.
		 */
		public function equals(o:Object):Boolean
		{
			var match:Boolean = false;
			
			if (o is String)
			{
				var elementRealisation:String = String(o);
			
				if (elementRealisation == null && this.realisation == null)
				{
					match = true;
				}
				else if (elementRealisation != null && this.realisation != null)
				{
					match = elementRealisation == this.realisation;
				}
			}
			else if (o is NLGElement)
			{
				var element:NLGElement = NLGElement(o);
				match = this.category.equalTo(element.category) && 
					    Cloner.compare(this.features, element.features);
			}
	
			return match;
		}
		
		public function clone ():NLGElement
		{
			var newElement:NLGElement = new NLGElement();
			
			// assign these, do not clone
			newElement.category = this.category;
			newElement.parent = this.parent;
			newElement.factory = this.factory;
			newElement.realisation = this.realisation;
			
			// clone features
			for (var key:String in features)
			{
				var feature:* = features[key];
				newElement.features[key] = Cloner.clone(feature);
			}
			
			return newElement;
		}
	}
}
