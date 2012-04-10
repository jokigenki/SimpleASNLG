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
package simpleasnlg.format.english
{
	
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.DocumentCategory;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.ElementCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGModule;
	import simpleasnlg.framework.StringElement;
	
	/**
	 * <p>
	 * This processing module adds some simple plain text formatting to the
	 * SimpleNLG output. This includes the following:
	 * <ul>
	 * <li>Adding the document title to the beginning of the text.</li>
	 * <li>Adding section titles in the relevant places.</li>
	 * <li>Adding appropriate new line breaks for ease-of-reading.</li>
	 * <li>Indenting list items with ' * '.</li>
	 * </ul>
	 * </p>
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class TextFormatter extends NLGModule
	{
		public function TextFormatter ()
		{
			
		}
		
		override public function initialise():void
		{
			// Do nothing
		}
	
		override public function realise(element:NLGElement):NLGElement
		{
			var realisedComponent:NLGElement = null;
			var realisation:String = "";
			var eachComponent:NLGElement;
			var i:int;
			var len:int;
			
			if (element != null)
			{
				var category:ElementCategory = element.getCategory();
				var components:Array = element.getChildren();
	
				//NB: The order of the if-statements below is important!
				
				// check if this is a canned text first
				if (element is StringElement)
				{
					realisation += element.getRealisation();
	
				}
				else if (category is DocumentCategory)
				{
					// && element is DocumentElement
					var title:String = element is DocumentElement ? DocumentElement(element).getTitle() : null;
					// String title = ((DocumentElement) element).getTitle();
	
					switch (category)
					{
						case DocumentCategory.DOCUMENT:
						case DocumentCategory.SECTION:
						case DocumentCategory.LIST:
							if (title != null)
							{
								realisation += title + '\n';
							}
							len = components.length;
							for (i = 0; i < len; i++)
							{
								eachComponent = components[i];
								realisedComponent = realise(eachComponent);
								if (realisedComponent != null)
								{
									realisation += realisedComponent.getRealisation();
								}
							}
							break;
		
						case DocumentCategory.PARAGRAPH:
							if (null != components && 0 < components.length)
							{
								realisedComponent = realise(components[0]);
								if (realisedComponent != null)
								{
									realisation += realisedComponent.getRealisation();
								}
								len = components.length;
								for (i = 1; i < len; i++)
								{
									if (realisedComponent != null)
									{
										realisation += ' ';
									}
									realisedComponent = realise(components[i]);
									if (realisedComponent != null)
									{
										realisation += realisedComponent.getRealisation();
									}
								}
							}
							realisation += "\n\n";
							break;
		
						case DocumentCategory.SENTENCE:
							realisation += element.getRealisation();
							break;
		
						case DocumentCategory.LIST_ITEM:
							// cch fix
							//realisation.append(" * ").append(element.getRealisation()); //$NON-NLS-1$
							realisation += " * "; //$NON-NLS-1$
		
							len = components.length;
							for (i = 0; i < len; i++)
							{
								eachComponent = components[i];
								realisedComponent = realise(eachComponent);
								
								if (realisedComponent != null)
								{
									realisation += realisedComponent.getRealisation();	
									
									if(components.indexOf(eachComponent) < components.length - 1) {
										realisation += ' ';
									}
								}
							}
							//finally, append newline
							realisation += "\n";
							break;
					}
	
					// also need to check if element is a listelement (items can
					// have embedded lists post-orthography) or a coordinate
				}
				else if (element is ListElement || element is CoordinatedPhraseElement)
				{
					len = components.length;
					for (i = 0; i < len; i++)
					{
						eachComponent = components[i];
						realisedComponent = realise(eachComponent);
						if (realisedComponent != null)
						{
							realisation += realisedComponent.getRealisation() + ' ';
						}
					}				
				} 
			}
			
			return new StringElement(realisation.toString());
		}
	
		override public function realiseList(elements:Array):Array
		{
			var realisedList:Array = new Array();
	
			if (elements != null)
			{
				var len:int = elements.length;
				for (var i:int = 0; i < len; i++)
				{
					var eachElement:NLGElement = elements[i];
					realisedList.push(realise(eachElement));
				}
			}
			return realisedList;
		}
	}
}
