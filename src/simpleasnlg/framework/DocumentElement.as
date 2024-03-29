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
	

	/**
	 * <p>
	 * <code>DocumentElement</code> is a convenient extension of the base
	 * <code>NLGElement</code> class. It used to define elements that form part of
	 * the textual structure (documents, sections, paragraphs, sentences, lists). It
	 * essentially operates as the base class with the addition of some convenience
	 * methods for getting and setting features specific to this type of element.
	 * </p>
	 * <p>
	 * <code>TextElements</code> can be structured in a tree-like structure where
	 * elements can contain child components. These child components can in turn
	 * contain other child components and so on. There are restrictions on the type
	 * of child components a particular element type can have. These are explained
	 * under the <code>DocumentCategory</code> enumeration.
	 * <p>
	 * Instances of this class can be created through the static create methods in
	 * the <code>OrthographyProcessor</code>.
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class DocumentElement extends NLGElement
	{
		/** The feature relating to the title or heading of this element. */
		private static const FEATURE_TITLE:String = "textTitle"; //$NON-NLS-1$
	
		/** The feature relating to the components (or child nodes) of this element. */
		private static const FEATURE_COMPONENTS:String = "textComponents"; //$NON-NLS-1$
	
		/**
		 * Creates a new DocumentElement with the given category and title.
		 * 
		 * @param category
		 *            the category for this element.
		 * @param textTitle
		 *            the title of this element, predominantly used with DOCUMENT
		 *            and SECTION types.
		 */
		public function DocumentElement(category:DocumentCategory = null, textTitle:String = null)
		{
			if (category) this.setCategory(category);
			if (textTitle) setTitle(textTitle);
		}
	
		/**
		 * Sets the title of this element. Titles are specifically used with
		 * documents (the document name) and sections (headings).
		 * 
		 * @param textTitle
		 *            the new title for this element.
		 */
		public function setTitle(textTitle:String):void
		{
			this.setFeatureByName(FEATURE_TITLE, textTitle);
		}
	
		/**
		 * Retrieves the title of this element.
		 * 
		 * @return the title of this element as a string.
		 */
		public function getTitle():String
		{
			return this.getFeatureByNameAsString(FEATURE_TITLE);
		}
	
		/**
		 * Retrieves the child components of this element.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s representing the
		 *         child components.
		 */
		public function getComponents():Array
		{
			return this.getFeatureByNameAsElementList(FEATURE_COMPONENTS);
		}
	
		/**
		 * <p>
		 * Add a single child component to the current list of child components. If
		 * there are no existing child components a new list is created.
		 * </p>
		 * <p>
		 * Note that there are restrictions on which child types can be added to
		 * which parent types.  Intermediate nodes are added if necessary; eg,
		 * if a sentence is added to a document, the sentence will be embedded
		 * in a paragraph before it is added
		 * See <code>
		 * DocumentCategory</code> for further information.
		 * </p>
		 * 
		 * @param element
		 *            the <code>NLGElement</code> to be added. If this is
		 *            <code>NULL</code> the method does nothing.
		 */
		public function addComponent(element:NLGElement):void
		{
			if (element != null)
			{
				var thisCategory:ElementCategory = this.getCategory();
				var category:ElementCategory = element.getCategory();
				
				if (category != null && thisCategory is DocumentCategory)
				{
					if (DocumentCategory(thisCategory).hasSubPart(category))
					{
						addElementToComponents(element);
					} else {
						var promotedElement:NLGElement = promote(element);
						if (promotedElement != null)
						{
							addElementToComponents (promotedElement);
						} else {// error condition - add original element so something is visible
							addElementToComponents (element);
						}
					}
				} else {
					addElementToComponents(element);
				}
			}
		}
	
		/** add an element to a components list
		 * @param element
		 */
		private function addElementToComponents(element:NLGElement):void
		{
			var components:Array = getComponents();
			components.push(element);
			element.setParent(this);
			setComponents(components);
		}
		
	
		/** promote an NLGElement so that it is at the right level to be added to a DocumentElement/
		 * Promotion means adding surrounding nodes at higher doc levels
		 * @param element
		 * @return
		 */
		private function promote(element:NLGElement):NLGElement
		{
			// check if promotion needed
			if ( DocumentCategory(this.getCategory()).hasSubPart(element.getCategory()) )
			{
				return element;
			}
			// if element is not a DocumentElement, embed it in a sentence and recurse
			if (!(element is DocumentElement))
			{
				var sentence:DocumentElement = new DocumentElement(DocumentCategory.SENTENCE, null);
				sentence.addElementToComponents(element);
				return promote(sentence);
			}
			
			// if element is a Sentence, promote it to a paragraph
			if (element.getCategory() == DocumentCategory.SENTENCE)
			{
				var paragraph:DocumentElement = new DocumentElement(DocumentCategory.PARAGRAPH, null);
				paragraph.addElementToComponents(element);
				return promote(paragraph);			
			}
			
			// otherwise can't do anything
			return null;
		}
	
		/**
		 * <p>
		 * Adds a collection of <code>NLGElements</code> to the list of child
		 * components. If there are no existing child components, then a new list is
		 * created.
		 * </p>
		 * <p>
		 * As with <code>addComponents(...)</code> only legitimate child types are
		 * added to the list.
		 * </p>
		 * 
		 * @param textComponents
		 *            the <code>List</code> of <code>NLGElement</code>s to be added.
		 *            If this is <code>NULL</code> the method does nothing.
		 */
		public function addComponents(textComponents:Array):void
		{
			if (textComponents != null)
			{
				var thisCategory:ElementCategory = this.getCategory();
				var elementsToAdd:Array = new Array();
				var category:ElementCategory = null;
	
				var len:int = textComponents.length;
				for (var i:int = 0; i < len; i++)
				{
					var eachElement:Object = textComponents[i];
					if (eachElement is NLGElement)
					{
						category = (NLGElement(eachElement)).getCategory();
						
						if (category != null && thisCategory is DocumentCategory)
						{
							if (DocumentCategory(thisCategory).hasSubPart(category))
							{
								elementsToAdd.push(NLGElement(eachElement));
								NLGElement(eachElement).setParent(this);
							}
						}
					}
				}
				if (elementsToAdd.length > 0)
				{
					var components:Array = getComponents();
					if (components == null)
					{
						components = new Array();
					}
					components = components.concat(elementsToAdd);
					this.setFeatureByName(FEATURE_COMPONENTS, components);
				}
			}
		}
	
		/**
		 * Removes the specified component from the list of child components.
		 * 
		 * @param textComponent
		 *            the component to be removed.
		 * @return <code>true</code> if the element was removed, or
		 *         <code>false</code> if the element did not exist, there is no
		 *         component list or the the given component to remove is
		 *         <code>NULL</code>.
		 */
		public function removeComponent(textComponent:NLGElement):Boolean
		{
			var removed:Boolean = false;
	
			if (textComponent != null)
			{
				var components:Array = getComponents();
				if (components != null)
				{
					removed = ArrayUtils.remove(components, textComponent);
				}
			}
			return removed;
		}
	
		/**
		 * Removes all the child components from this element.
		 */
		public function clearComponents():void 
		{
			var components:Array = getComponents();
			if (components != null)
			{
				components.splice(0);
			}
		}
	
		/**
		 * Child elements of a <code>DocumentElement</code> are the components. This
		 * method is the same as calling <code>getComponents()</code>.
		 */
		override public function getChildren():Array
		{
			return getComponents();
		}
	
		/**
		 * Replaces the existing components with the supplied list of components.
		 * This is identical to calling:<br>
		 * <code><pre>
		 *     clearComponents();
		 *     addComponents(components);
		 * </pre></code>
		 * 
		 * @param components
		 */
		public function setComponents(components:Array):void
		{
			this.setFeatureByName(FEATURE_COMPONENTS, components);
		}
	
		override public function printTree(indent:String):String
		{
			var thisIndent:String = indent == null ? " |-" : indent + " |-"; //$NON-NLS-1$ //$NON-NLS-2$
			var childIndent:String = indent == null ? " | " : indent + " | "; //$NON-NLS-1$ //$NON-NLS-2$
			var lastIndent:String = indent == null ? " \\-" : indent + " \\-"; //$NON-NLS-1$ //$NON-NLS-2$
			var lastChildIndent:String = indent == null ? "   " : indent + "   "; //$NON-NLS-1$ //$NON-NLS-2$
			
			var print:String = "";
			print += "DocumentElement: category=" + getCategory().toString();
	
			var realisation:String = getRealisation();
			if (realisation != null)
			{
				print += " realisation=" + realisation; //$NON-NLS-1$
			}
			print += '\n';
	
			var children:Array = getChildren();
			var length:int = children.length - 1;
	
			if (children.length > 0)
			{
				for (var index:int = 0; index < length; index++)
				{
					print += thisIndent + children[index].printTree(childIndent);
				}
				print += lastIndent + children[index].printTree(lastChildIndent);
			}
			
			return print;
		}
	}
}
