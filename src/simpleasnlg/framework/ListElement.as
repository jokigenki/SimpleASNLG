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
	
	
	
	import com.steamshift.utils.StringUtils;
	
	import flash.utils.Dictionary;
	
	import mx.core.ComponentDescriptor;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	
	/**
	 * <p>
	 * <code>ListElement</code> is used to define elements that can be grouped
	 * together and treated in a similar manner. The list element itself adds no
	 * additional meaning to the realisation. For example, the syntax processor
	 * takes a phrase element and produces a list element containing inflected word
	 * elements. Phrase elements only have meaning within the syntax processing
	 * while the morphology processor (the next in the sequence) needs to work with
	 * inflected words. Using the list element helps to keep the inflected word
	 * elements together.
	 * </p>
	 * 
	 * <p>
	 * There is no sorting within the list element and components are added in the
	 * order they are given.
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class ListElement extends NLGElement {
	
		
		
		/**
		 * Creates a new list element containing the given components, or with an NLGElement.
		 * 
		 * @param components
		 *            the initial components for this list element.
		 * 
		 * @param newComponent
		 *            the initial component for this list element.
		 */
		public function ListElement(components:* = null)
		{
			if (components)
			{
				if (components is Array)
				{
					this.addComponents(components);
				}
				else if (components is NLGElement)
				{
					this.addComponent(components);
				}
			}
		}
	
		override public function getChildren():Array
		{
			return getFeatureAsElementList(InternalFeature.COMPONENTS);
		}
	
		/**
		 * Adds the given component to the list element.
		 * 
		 * @param newComponent
		 *            the <code>NLGElement</code> component to be added.
		 */
		public function addComponent(newComponent:NLGElement, atIndex:int = -1):void 
		{
			var components:Array = getFeatureAsElementList(InternalFeature.COMPONENTS);
			if (components == null)
			{
				components = new Array();
			}
			setFeature(InternalFeature.COMPONENTS, components);
			
			if (atIndex == -1) atIndex = components.length;
			components.splice(atIndex, 0, newComponent);
		}
	
		/**
		 * Adds the given components to the list element.
		 * 
		 * @param newComponents
		 *            a <code>List</code> of <code>NLGElement</code>s to be added.
		 */
		public function addComponents(newComponents:Array):void
		{
			var components:Array = getFeatureAsElementList(InternalFeature.COMPONENTS);
			if (components == null)
			{
				components = new Array();
			}
			components = components.concat(newComponents);
			setFeature(InternalFeature.COMPONENTS, components);
		}
	
		/**
		 * Replaces the current components in the list element with the given list.
		 * 
		 * @param newComponents
		 *            a <code>List</code> of <code>NLGElement</code>s to be used as
		 *            the components.
		 */
		public function setComponents(newComponents:Array):void
		{
			setFeature(InternalFeature.COMPONENTS, newComponents);
		}
	
		public function getComponent (atIndex:int):NLGElement
		{
			var components:Array = getFeature(InternalFeature.COMPONENTS);
			if (atIndex < components.length) return components[atIndex];
			
			return null;
		}
		
		override public function toString():String
		{
			return StringUtils.arrayToString(getChildren());
		}
	
		override public function printTree(indent:String):String
		{
			var thisIndent:String = indent == null ? " |-" : indent + " |-"; //$NON-NLS-1$ //$NON-NLS-2$
			var childIndent:String = indent == null ? " | " : indent + " | "; //$NON-NLS-1$ //$NON-NLS-2$
			var lastIndent:String = indent == null ? " \\-" : indent + " \\-"; //$NON-NLS-1$ //$NON-NLS-2$
			var lastChildIndent:String = indent == null ? "   " : indent + "   "; //$NON-NLS-1$ //$NON-NLS-2$
			var print:String = "";
			print += "ListElement: features="; //$NON-NLS-1$
	
			var features:Dictionary = getAllFeatures();
			print += StringUtils.mapToString(features);

			print += "\n"; //$NON-NLS-1$
	
			var children:Array = getChildren();
			var length:int = children.length - 1;
	
			for (var index:int = 0; index < length; index++) {
				print += thisIndent + children[index].printTree(childIndent);
			}
			if (length >= 0)
			{
				print += lastIndent + children[length].printTree(lastChildIndent);
			}
			return print.toString();
		}
	
		/**
		 * Retrieves the number of components in this list element.
		 * @return the number of components.
		 */
		public function get size():int
		{
			return getChildren().length;
		}
	
		/**
		 * Retrieves the first component in the list.
		 * @return the <code>NLGElement</code> at the top of the list.
		 */
		public function getFirst():NLGElement
		{
			var children:Array = getChildren();
			return children == null ? null : children[0];
		}
	}
}
