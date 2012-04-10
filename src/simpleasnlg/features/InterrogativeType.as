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

package simpleasnlg.features
{
	import com.steamshift.datatypes.StringEnum;
	
	/**
	 * <p>
	 * An enumeration representing the different types of interrogatives or
	 * questions that SimpleNLG can realise. The interrogative type is recorded in
	 * the {@code Feature.INTERROGATIVE_TYPE} feature and applies to clauses.
	 * </p>
	 * 
	 * @author A. Gatt and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	
	public final class InterrogativeType extends StringEnum
	{
		private static var _locked:Boolean = false;
		
		public function InterrogativeType(key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		/**
		 * The type of interrogative relating to the manner in which an event
		 * happened. For example, <em>John kissed Mary</em> becomes
		 * <em>How did John kiss
		 * Mary?</em>
		 */
		public static const HOW:InterrogativeType					= new InterrogativeType("how");
		
		/**
		 * This type of interrogative is a question pertaining to the object of a
		 * phrase. For example, <em>John bought a horse</em> becomes <em>what did 
		 * John buy?</em> while <em>John gave Mary a flower</em> becomes
		 * <em>What did 
		 * John give Mary?</em>
		 */
		public static const WHAT_OBJECT:InterrogativeType			= new InterrogativeType("whatObject");
		
		/**
		 * This type of interrogative is a question pertaining to the subject of a
		 * phrase. For example, <em>A hurricane destroyed the house</em> becomes
		 * <em>what destroyed the house?</em> 
		 */
		public static const WHAT_SUBJECT:InterrogativeType		= new InterrogativeType("whatSubject");
		
		/**
		 * This type of interrogative concerns the object of a verb that is to do
		 * with location. For example, <em>John went to the beach</em> becomes
		 * <em>Where did John go?</em>
		 */
		public static const WHERE:InterrogativeType				= new InterrogativeType("where");
		
		/**
		 * This type of interrogative is a question pertaining to the indirect
		 * object of a phrase when the indirect object is a person. For example,
		 * <em>John gave Mary a flower</em> becomes
		 * <em>Who did John give a flower to?</em>
		 */
		public static const WHO_INDIRECT_OBJECT:InterrogativeType	= new InterrogativeType("whoIndirectObject");
		
		/**
		 * This type of interrogative is a question pertaining to the object of a
		 * phrase when the object is a person. For example,
		 * <em>John kissed Mary</em> becomes <em>who did John kiss?</em>
		 */
		public static const WHO_OBJECT:InterrogativeType			= new InterrogativeType("whoObject");
		
		/**
		 * This type of interrogative is a question pertaining to the subject of a
		 * phrase when the subject is a person. For example,
		 * <em>John kissed Mary</em> becomes <em>Who kissed Mary?</em> while
		 * <em>John gave Mary a flower</em> becomes <em>Who gave Mary a flower?</em>
		 */
		public static const WHO_SUBJECT:InterrogativeType			= new InterrogativeType("whoSubject");
		
		/**
		 * The type of interrogative relating to the reason for an event happening.
		 * For example, <em>John kissed Mary</em> becomes <em>Why did John kiss
		 * Mary?</em>
		 */
		public static const WHY:InterrogativeType					= new InterrogativeType("why");
		
		/**
		 * This represents a simple yes/no questions. So taking the example phrases
		 * of <em>John is a professor</em> and <em>John kissed Mary</em> we can
		 * construct the questions <em>Is John a professor?</em> and
		 * <em>Did John kiss Mary?</em>
		 */
		public static const YES_NO:InterrogativeType				= new InterrogativeType("yesNo");
		
		/**
		 * This represents a "how many" questions. For example of
		 * <em>dogs chased John/em> becomes <em>How many dogs chased John</em>
		 */
		public static const HOW_MANY:InterrogativeType			= new InterrogativeType("howMany");
		
		/**
		 * A method to determine if the {@code InterrogativeType} is a question
		 * concerning an element with the discourse function of an object.
		 * 
		 * @param type
		 *            the interrogative type to be checked
		 * @return <code>true</code> if the type concerns an object,
		 *         <code>false</code> otherwise.
		 */
		public static function isObject(type:Object):Boolean
		{
			return WHO_OBJECT == type || WHAT_OBJECT == type;
		}
		
		/**
		 * A method to determine if the {@code InterrogativeType} is a question
		 * concerning an element with the discourse function of an indirect object.
		 * 
		 * @param type
		 *            the interrogative type to be checked
		 * @return <code>true</code> if the type concerns an indirect object,
		 *         <code>false</code> otherwise.
		 */
		public static function isIndirectObject(type:Object):Boolean
		{
			return WHO_INDIRECT_OBJECT == type;
		}
		
		{
			_locked = true;
		}
	}
}
