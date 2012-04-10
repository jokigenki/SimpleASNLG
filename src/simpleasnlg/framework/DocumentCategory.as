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
	import com.steamshift.datatypes.StringEnum;

	/**
	 * <p>
	 * This enumerated type defines the different <i>types</i> of components found
	 * in the structure of text. This deals exclusively with the structural format
	 * of the text and not of the syntax of the language. Therefore, this
	 * enumeration deals with documents, sections, paragraphs, sentences and lists.
	 * </p>
	 * <p>
	 * The enumeration implements the <code>ElementCategory</code> interface, thus
	 * making it compatible the SimpleNLG framework.
	 * </p>
	 * 
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public final class DocumentCategory extends StringEnum implements ElementCategory
	{
		private static var _locked:Boolean = false;
		
		public function DocumentCategory (key:String):void
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		
		/** Definition for a document. */
		public static const DOCUMENT:DocumentCategory 	= new DocumentCategory("document");
	
		/** Definition for a section within a document. */
		public static const SECTION:DocumentCategory 	= new DocumentCategory("section");
	
		/** Definition for a paragraph. */
		public static const PARAGRAPH:DocumentCategory 	= new DocumentCategory("paragraph");
	
		/** Definition for a sentence. */
		public static const SENTENCE:DocumentCategory 	= new DocumentCategory("sentence");
	
		/** Definition for creating a list of items. */
		public static const LIST:DocumentCategory 		= new DocumentCategory("list");
	
		/** Definition for an item in a list. */
		public static const LIST_ITEM:DocumentCategory 	= new DocumentCategory("list_item");
	
		/**
		 * <p>
		 * Checks to see if the given object is equal to this document category.
		 * This is done by checking the enumeration if the object is of the type
		 * <code>DocumentCategory</code> or by converting the object and the this
		 * category to strings and comparing the strings.
		 * </p>
		 * <p>
		 * For example, <code>DocumentCategory.LIST</code> will match another
		 * <code>DocumentCategory.LIST</code> but will also match the string
		 * <em>"list"</em> as well.
		 */
		public function equalTo(checkObject:Object):Boolean
		{
			var match:Boolean = false;
	
			if (checkObject != null)
			{
				if (checkObject is DocumentCategory)
				{
					match = this == checkObject;
				} else {
					match = this.toString().toLowerCase() == checkObject.toString().toLowerCase();
				}
			}
			return match;
		}
	
		/**
		 * <p>
		 * This method determines if the supplied elementCategory forms an immediate
		 * sub-part of <code>this</code> category. The allowed sub-parts for each
		 * <code>this</code> type are outlined below:
		 * </p>
		 * 
		 * <ul>
		 * <li><b>DOCUMENT</b>: can contain SECTIONs, PARAGRAPHs, SENTENCEs and
		 * LISTs. It cannot contain other DOCUMENTs or LIST_ITEMs.</li>
		 * <li><b>SECTION</b>: can contain SECTIONs (referred to as subsections),
		 * PARAGRAPHs, SENTENCEs and LISTs. It cannot contain DOCUMENTs or
		 * LIST_ITEMs.</li>
		 * <li><b>PARAGRAPH</b>: can contain SENTENCEs or LISTs. It cannot contain
		 * DOCUMENTs, SECTIONs, other PARAGRAPHs or LIST_ITEMs.</li>
		 * <li><b>SENTENCE</b>: can only contain other forms of
		 * <code>NLGElement</code>s. It cannot contain DOCUMENTs, SECTIONs,
		 * PARAGRAPHs, other SENTENCEs, LISTs or LIST_ITEMs.</li>
		 * <li><b>LIST</b>: can only contain LIST_ITEMs. It cannot contain
		 * DOCUMENTs, SECTIONs, PARAGRAPHs, SENTENCEs or other LISTs.</li>
		 * <li><b>LIST_ITEMs</b>: can contain PARAGRAPHs, SENTENCEs, LISTs or other
		 * forms of <code>NLGElement</code>s. It cannot contain DOCUMENTs, SECTIONs,
		 * or LIST_ITEMs.</li>
		 * </ul>
		 * 
		 * <p>
		 * For structuring text, this effectively becomes the test for relevant
		 * child types affecting the immediate children. For instance, it is
		 * possible for a DOCUMENT to contains LIST_ITEMs but only if the LIST_ITEMs
		 * are children of LISTs.
		 * </p>
		 * 
		 * <p>
		 * A more precise definition of SENTENCE would be that it only contains
		 * PHRASEs. However, this DocumentCategory does not consider these options
		 * as this crosses the boundary between orthographic structure and syntactic
		 * structure.
		 * </p>
		 * 
		 * <p>
		 * In pseudo-BNF this can be written as:
		 * </p>
		 * 
		 * <pre>
		 *    DOCUMENT 		 ::= DOCUMENT_PART*
		 *    DOCUMENT_PART  ::= SECTION | PARAGRAPH
		 *    SECTION 		 ::= DOCUMENT_PART*
		 *    PARAGRAPH 	 ::= PARAPGRAPH_PART*
		 *    PARAGRAPH_PART ::= SENTENCE | LIST
		 *    SENTENCE 	 	 ::= &lt;NLGElement&gt;*
		 *    LIST 			 ::= LIST_ITEM*
		 *    LIST_ITEM 	 ::= PARAGRAPH | PARAGRAPH_PART | &lt;NLGElement&gt;
		 * </pre>
		 * <p>
		 * Ideally the '*' should be replaced with '+' to represent that one or more
		 * of the components must exist rather than 0 or more. However, the
		 * implementation permits creation of the <code>DocumentElement</code>s with
		 * no children or sub-parts added.
		 * </p>
		 * 
		 * @param elementCategory
		 *            the category we are checking against. If this is
		 *            <code>NULL</code> the method will return <code>false</code>.
		 * @return <code>true</code> if the supplied elementCategory is a sub-part
		 *         of <code>this</code> type of category, <code>false</code>
		 *         otherwise.
		 */
		public function hasSubPart(elementCategory:ElementCategory):Boolean
		{
			var subPart:Boolean = false;
			if (elementCategory != null)
			{
				if (elementCategory is DocumentCategory)
				{
					switch (this)
					{
						case DOCUMENT:
							subPart = !(elementCategory == DOCUMENT || elementCategory == LIST_ITEM);
							break;
							
						case SECTION:
							subPart = elementCategory == PARAGRAPH || elementCategory == SECTION;
							break;
		
						case PARAGRAPH:
							subPart = elementCategory == SENTENCE || elementCategory == LIST;
							break;
		
						case LIST:
							subPart = elementCategory == LIST_ITEM;
							break;
		
						default:
							break;
					}
				} else {
					subPart = this == SENTENCE || this == LIST_ITEM;
				}
			}
			return subPart;
		}
		
		{
			_locked = true;
		}
	}
}
