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
	 * An enumeration representing the different forms a verb and its associated
	 * phrase can take. The form is recorded under the {@code Feature.FORM} feature
	 * and applies to verbs and verb phrases.
	 * </p>
	 * @author A. Gatt and D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class Form extends StringEnum
	{
		private static var _locked:Boolean = false;
		
		public function Form(key:String)
		{
			super(key);
			if (_locked) throw new Error("You can't instantiate " + this);
		}
		/**
		 * The bare infinitive is the base form of the verb.
		 */
		public static const BARE_INFINITIVE:Form		= new Form("bareInfinitive");
		
		/**
		 * In English, the gerund form refers to the usage of a verb as a noun. For
		 * example, <em>I like <b>swimming</b></em>. In more general terms, gerunds
		 * are usually formed from the base word with <em>-ing</em> added to the
		 * end.
		 */
		public static const GERUND:Form					= new Form("gerund");
		
		/**
		 * The imperative form of a verb is the one used when the grammatical 
		 * mood is one of expressing a command or giving a direct request. For example, 
		 * <em><b>Close</b> the door.</em>
		 */
		public static const IMPERATIVE:Form				= new Form("imperative"); 
		
		/**
		 * The infinitive form represents the base form of the verb, with our
		 * without the particle <em>to</em>. For example, <em>do</em> and
		 * <em>to do</em> are both infinitive forms of <em>do</em>.
		 */
		public static const INFINITIVE:Form				= new Form("infinitive");
		
		/**
		 * Normal form represents the base verb. For example, <em>kiss</em>,
		 * <em>walk</em>, <em>bark</em>, <em>eat</em>.
		 */
		public static const NORMAL:Form					= new Form("normal");
		
		/**
		 * Most verbs will have only a single form for the past tense. However, some
		 * verbs will have two forms, one for the simple past tense and one for the
		 * past participle (also knowns as passive participle or perfect
		 * participle). The part participle represents the second of these two
		 * forms. For example, the verb <em>eat</em> has the simple past form of
		 * <em>ate</em> and also the past participle form of <em>eaten</em>. Another
		 * example, is <em>write</em>, <em>wrote</em> and <em>written</em>.
		 */
		public static const PAST_PARTICIPLE:Form		= new Form("pastParticiple");
		
		/**
		 * The present participle is identical in form to the gerund and is normally
		 * used in the active voice. However, the gerund is meant to highlight a
		 * verb being used as a noun. The present participle remains as a verb. For 
		 * example, <em>Jim was <b>sleeping</b></em>.
		 */
		public static const PRESENT_PARTICIPLE:Form	= new Form("presentParticiple"); 
		
		{
			_locked = true;
		}
	}
}
