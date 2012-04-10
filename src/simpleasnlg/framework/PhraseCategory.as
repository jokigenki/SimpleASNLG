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
	 * This enumeration defines the different syntactical phrases. The categories
	 * define the well understood roles for each typue of phrase in language. For
	 * example, <em>the dog</em> is a noun phrase, <em>the dog chases Mary</em> is a
	 * clause, <em>beautiful</em> is an adjective phrase, and so on.
	 * </p>
	 * 
	 * 
	 * @author A. Gatt and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public final class PhraseCategory extends StringEnum implements ElementCategory
	{
		private static var _locked:Boolean = false;
		
		public function PhraseCategory(key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		
		/**
		 * A grammatical clause, the simplest form of which consists of a subject
		 * (noun or noun phrase) and a verb (or verb phrase).
		 */
		public static const CLAUSE:PhraseCategory			 	= new PhraseCategory("clause");
	
		/** A phrase relating to an adjective. */
		public static const ADJECTIVE_PHRASE:PhraseCategory		= new PhraseCategory("adjectivePhrase");
	
		/** A phrase relating to an adverb. */
		public static const ADVERB_PHRASE:PhraseCategory		= new PhraseCategory("adverbPhrase");
	
		/** A phrase relating to a noun. */
		public static const NOUN_PHRASE:PhraseCategory			= new PhraseCategory("nounPhrase");
	
		/** A phrase relating to a preposition. */
		public static const PREPOSITIONAL_PHRASE:PhraseCategory	= new PhraseCategory("prepositionalPhrase");
	
		/** A phrase relating to a verb. */
		public static const VERB_PHRASE:PhraseCategory			 = new PhraseCategory("verbPhrase");
	
		/** A phrase relating to a pre-formed string that is not altered in anyway. */
		public static const CANNED_TEXT:PhraseCategory			 = new PhraseCategory("cannedText");
	
		/**
		 * <p>
		 * Checks to see if the given object is equal to this phrase category. This
		 * is done by checking the enumeration if the object is of the type
		 * <code>PhraseCategory</code> or by converting the object and this category
		 * to strings and comparing the strings.
		 * </p>
		 * <p>
		 * For example, <code>PhraseCategory.CLAUSE</code> will match another
		 * <code>PhraseCategory.CLAUSE</code> but will also match the string
		 * <em>"clause"</em> as well.
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
		
		{
			_locked = true;
		}
	}
}
