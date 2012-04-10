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
	
	
	import com.steamshift.utils.ArrayUtils;
	import com.steamshift.utils.Cloner;
	
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.phrasespec.SPhraseSpec;
	
	/**
	 * This class contains a number of utility methods for checking and collecting
	 * sentence components during the process of aggregation.
	 * 
	 * @author agatt
	 * 
	 */
	public class PhraseChecker
	{
		/**
		 * Check that the sentences supplied are identical
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every pair of sentences <code>s1</code>
		 *         and <code>s2</code>, <code>s1.equals(s2)</code>.
		 */
		public static function sameSentences(...sentences):Boolean
		{
			var equal:Boolean = false;
	
			var len:int = sentences.length;
			if (len >= 2)
			{
				for (var i:int = 1; i < len; i++)
				{
					equal = sentences[i - 1].equals(sentences[i]);
				}
			}
	
			return equal;
		}
	
		/**
		 * Check whether these sentences have expletive subjects (there, it etc)
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if all the sentences have expletive subjects
		 */
		public static function expletiveSubjects(...sentences):Boolean
		{
			var expl:Boolean = true;
			var len:int = sentences.length;
			for (var i:int = 1; i < len && expl; i++)
			{
				expl = sentences[i] is SPhraseSpec ? SPhraseSpec(sentences[i]).getFeatureAsBoolean(LexicalFeature.EXPLETIVE_SUBJECT) : false;
			}
	
			return expl;
		}
	
		/**
		 * Check that the sentences supplied have identical front modifiers
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every pair of sentences <code>s1</code>
		 *         and <code>s2</code>,
		 *         <code>s1.getFrontModifiers().equals(s2.getFrontModifiers())</code>
		 *         .
		 */
		public static function sameFrontMods(...sentences):Boolean
		{
			var equal:Boolean = true;
			var len:int = sentences.length;
			if (len >= 2)
			{
				for (var i:int = 1; i < len && equal; i++)
				{
					if (!sentences[i - 1].hasFeature(Feature.CUE_PHRASE)
							&& !sentences[i].hasFeature(Feature.CUE_PHRASE))
					{
						equal = Cloner.compare(sentences[i - 1].getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS),
								sentences[i].getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS));
					}
					else if (sentences[i - 1].hasFeature(Feature.CUE_PHRASE)
							&& sentences[i].hasFeature(Feature.CUE_PHRASE))
					{
						equal = Cloner.compare(sentences[i - 1].getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS),
								sentences[i].getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS)) &&
								Cloner.compare(sentences[i].getFeatureAsElementList(Feature.CUE_PHRASE),
								sentences[i - 1].getFeatureAsElementList(Feature.CUE_PHRASE));
	
					} else {
						equal = false;
					}
				}
			}
	
			return equal;
		}
	
		/**
		 * Check that some phrases have the same postmodifiers
		 * 
		 * @param sentences
		 *            the phrases
		 * @return true if they have the same postmodifiers
		 */
		public static function samePostMods(...sentences):Boolean
		{
			var equal:Boolean = true;
			var len:int = sentences.length;
			if (len >= 2)
			{
				for (var i:int = 1; i < len && equal; i++)
				{
					equal = Cloner.compare(sentences[i - 1].getFeatureAsElementList(InternalFeature.POSTMODIFIERS),
							sentences[i].getFeatureAsElementList(InternalFeature.POSTMODIFIERS));
				}
			}
	
			return equal;
		}
	
		/**
		 * Check that the sentences supplied have identical subjects
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every pair of sentences <code>s1</code>
		 *         and <code>s2</code>
		 *         <code>s1.getSubjects().equals(s2.getSubjects())</code>.
		 */
		public static function sameSubjects(...sentences):Boolean
		{
			var len:int = sentences.length;
			var equal:Boolean = len >= 2;
	
			for (var i:int = 1; i < len && equal; i++)
			{
				equal = Cloner.compare(sentences[i - 1].getFeatureAsElementList(InternalFeature.SUBJECTS),
						sentences[i].getFeatureAsElementList(InternalFeature.SUBJECTS));
			}
	
			return equal;
		}
	
		// /**
		// * Check that the sentences have the same complemts raised to subject
		// * position in the passive
		// *
		// * @param sentences
		// * the sentences
		// * @return <code>true</code> if the passive raising complements are the
		// same
		// */
		// public static boolean samePassiveRaisingSubjects(SPhraseSpec...
		// sentences) {
		// boolean samePassiveSubjects = sentences.length >= 2;
		//
		// for (int i = 1; i < sentences.length && samePassiveSubjects; i++) {
		// VPPhraseSpec vp1 = (VPPhraseSpec) sentences[i - 1].getVerbPhrase();
		// VPPhraseSpec vp2 = (VPPhraseSpec) sentences[i].getVerbPhrase();
		// samePassiveSubjects = vp1.getPassiveRaisingComplements().equals(
		// vp2.getPassiveRaisingComplements());
		//
		// }
		//
		// return samePassiveSubjects;
		// }
	
		/**
		 * Check whether all sentences are passive
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every sentence <code>s</code>,
		 *         <code>s.isPassive() == true</code>.
		 */
		public static function allPassive(...sentences):Boolean
		{
			var len:int = sentences.length;
			var passive:Boolean = true;
	
			for (var i:int = 0; i < len && passive; i++)
			{
				passive = sentences[i].getFeatureAsBoolean(Feature.PASSIVE);
			}
	
			return passive;
		}
	
		/**
		 * Check whether all sentences are active
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every sentence <code>s</code>,
		 *         <code>s.isPassive() == false</code>.
		 */
		public static function allActive(...sentences):Boolean
		{
			var len:int = sentences.length;
			var active:Boolean = true;
	
			for (var i:int = 0; i < len && active; i++)
			{
				active = !sentences[i].getFeatureAsBoolean(Feature.PASSIVE);
			}
	
			return active;
		}
	
		/**
		 * Check whether the sentences have the same <I>surface</I> subjects, that
		 * is, they are either all active and have the same subjects, or all passive
		 * and have the same passive raising subjects.
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if the sentences have the same surface subjects
		 */
		public static function sameSurfaceSubjects(...sentences):Boolean
		{
			return PhraseChecker.allActive(sentences)
					&& PhraseChecker.sameSubjects(sentences)
					|| PhraseChecker.allPassive(sentences);
			// && PhraseChecker.samePassiveRaisingSubjects(sentences);
		}
	
		/**
		 * Check that a list of sentences have the same verb
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every pair of sentences <code>s1</code>
		 *         and <code>s2</code>
		 *         <code>s1.getVerbPhrase().getHead().equals(s2.getVerbPhrase().getHead())</code>
		 */
		public static function sameVPHead(...sentences):Boolean
		{
			var len:int = sentences.length;
			var equal:Boolean = len >= 2;
	
			for (var i:int = 1; i < len && equal; i++) {
				var vp1:NLGElement = sentences[i - 1].getFeatureAsElement(InternalFeature.VERB_PHRASE);
				var vp2:NLGElement = sentences[i].getFeatureAsElement(InternalFeature.VERB_PHRASE);
	
				if (vp1 != null && vp2 != null)
				{
					var h1:NLGElement = vp1.getFeatureAsElement(InternalFeature.HEAD);
					var h2:NLGElement = vp2.getFeatureAsElement(InternalFeature.HEAD);
					equal = h1 != null && h2 != null ? h1.equals(h2) : false;
	
				} else {
					equal = false;
				}
			}
	
			return equal;
		}
	
		/**
		 * Check that the sentences supplied are either all active or all passive.
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if the sentences have the same voice
		 */
		public static function haveSameVoice(...sentences):Boolean
		{
			var samePassive:Boolean = true;
			var prevIsPassive:Boolean = false;
	
			if (sentences.length > 1)
			{
				prevIsPassive = sentences[0].getFeatureAsBoolean(Feature.PASSIVE);
	
				var len:int = sentences.length;
				for (var i:int = 1; i < len && samePassive; i++) {
					samePassive = sentences[i].getFeatureAsBoolean(Feature.PASSIVE) == prevIsPassive;
				}
			}
	
			return samePassive;
		}
	
		// /**
		// * Check that the sentences supplied are not existential sentences (i.e.
		// of
		// * the form <I>there be...</I>)
		// *
		// * @param sentences
		// * the sentences
		// * @return <code>true</code> if none of the sentences is existential
		// */
		// public static boolean areNotExistential(SPhraseSpec... sentences) {
		// boolean notex = true;
		//
		// for (int i = 0; i < sentences.length && notex; i++) {
		// notex = !sentences[i].isExistential();
		// }
		//
		// return notex;
		// }
	
		/**
		 * Check that the sentences supplied have identical verb phrases
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every pair of sentences <code>s1</code>
		 *         and <code>s2</code>,
		 *         <code>s1.getVerbPhrase().equals(s2.getVerbPhrase())</code>.
		 */
		public static function sameVP(...sentences):Boolean
		{
			var len:int = sentences.length;
			var equal:Boolean = len >= 2;
	
			for (var i:int = 1; i < len && equal; i++)
			{
				equal = Cloner.compare(sentences[i - 1].getFeatureAsElement(InternalFeature.VERB_PHRASE), 
						sentences[i].getFeatureAsElement(InternalFeature.VERB_PHRASE));
			}
	
			return equal;
		}
	
		/**
		 * Check that the sentences supplied have the same complements at VP level.
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if for every pair of sentences <code>s1</code>
		 *         and <code>s2</code>, their VPs have the same pre- and
		 *         post-modifiers and complements.
		 */
		public static function sameVPArgs(...sentences):Boolean
		{
			var len:int = sentences.length;
			var equal:Boolean = len >= 2;
	
			for (var i:int = 1; i < len && equal; i++)
			{
				var vp1:NLGElement = sentences[i - 1].getFeatureAsElement(InternalFeature.VERB_PHRASE);
				var vp2:NLGElement = sentences[i].getFeatureAsElement(InternalFeature.VERB_PHRASE);
	
				equal = Cloner.compare(vp1.getFeatureAsElementList(InternalFeature.COMPLEMENTS),
						vp2.getFeatureAsElementList(InternalFeature.COMPLEMENTS));
			}
	
			return equal;
		}
	
		/**
		 * check that the phrases supplied are sentences and have the same VP
		 * premodifiers and postmodifiers
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if all pairs of sentences have VPs with the
		 *         same pre and postmodifiers
		 */
		public static function sameVPModifiers(...sentences):Boolean
		{
			var len:int = sentences.length;
			var equal:Boolean = len >= 2;
	
			for (var i:int = 1; i < sentences.length && equal; i++) {
				var vp1:NLGElement = sentences[i - 1].getFeatureAsElement(InternalFeature.VERB_PHRASE);
				var vp2:NLGElement = sentences[i].getFeatureAsElement(InternalFeature.VERB_PHRASE);
	
				equal = Cloner.compare(vp1.getFeatureAsElementList(InternalFeature.POSTMODIFIERS),
						vp2.getFeatureAsElementList(InternalFeature.POSTMODIFIERS)) &&
						Cloner.compare(vp1.getFeatureAsElementList(InternalFeature.PREMODIFIERS),
						vp2.getFeatureAsElementList(InternalFeature.PREMODIFIERS));
			}
	
			return equal;
		}
	
		/**
		 * Collect a list of pairs of constituents with the same syntactic function
		 * from the left periphery of two sentences. The left periphery encompasses
		 * the subjects, front modifiers and cue phrases of the sentences.
		 * 
		 * @param sentences
		 *            the list of sentences
		 * @return a list of pairs of constituents with the same function, if any
		 *         are found
		 */
		public static function leftPeriphery(...sentences):Array
		{
			var funcsets:Array = new Array();
			var cue:PhraseSet = new PhraseSet(DiscourseFunction.CUE_PHRASE);
			var front:PhraseSet = new PhraseSet(DiscourseFunction.FRONT_MODIFIER);
			var subj:PhraseSet = new PhraseSet(DiscourseFunction.SUBJECT);
	
			for each (var s:NLGElement in sentences)
			{
				if (s.hasFeature(Feature.CUE_PHRASE))
				{
					cue.addPhrases(s.getFeatureAsElementList(Feature.CUE_PHRASE));
				}
	
				if (s.hasFeature(InternalFeature.FRONT_MODIFIERS))
				{
					front.addPhrases(s.getFeatureAsElementList(InternalFeature.FRONT_MODIFIERS));
				}
	
				if (s.hasFeature(InternalFeature.SUBJECTS))
				{
					subj.addPhrases(s.getFeatureAsElementList(InternalFeature.SUBJECTS));
				}
			}
	
			funcsets.push(cue);
			funcsets.push(front);
			funcsets.push(subj);
			return funcsets;
		}
	
		/**
		 * Collect a list of pairs of constituents with the same syntactic function
		 * from the right periphery of two sentences. The right periphery
		 * encompasses the complements of the main verb, and its postmodifiers.
		 * 
		 * @param sentences
		 *            the list of sentences
		 * @return a list of pairs of constituents with the same function, if any
		 *         are found
		 */
		public static function rightPeriphery(...sentences):Array
		{
			var funcsets:Array = new Array();
			var comps:PhraseSet = new PhraseSet(DiscourseFunction.OBJECT);
			// new PhraseSet(DiscourseFunction.INDIRECT_OBJECT);
			var pmods:PhraseSet = new PhraseSet(DiscourseFunction.POST_MODIFIER);		
			
			for each (var s:NLGElement in sentences)
			{
				var vp:NLGElement = s.getFeatureAsElement(InternalFeature.VERB_PHRASE);
	
				if (vp != null)
				{
					if (vp.hasFeature(InternalFeature.COMPLEMENTS))
					{
						comps.addPhrases(vp.getFeatureAsElementList(InternalFeature.COMPLEMENTS));
					}
	
					if (vp.hasFeature(InternalFeature.POSTMODIFIERS))
					{
						pmods.addPhrases(vp.getFeatureAsElementList(InternalFeature.POSTMODIFIERS));
					}
				}
				
				if (s.hasFeature(InternalFeature.POSTMODIFIERS))
				{
					pmods.addPhrases(s.getFeatureAsElementList(InternalFeature.POSTMODIFIERS));
				}
			}
	
			funcsets.push(comps);
			funcsets.push(pmods);
			return funcsets;
		}
	
		/**
		 * Check that no element of a give array of sentences is passive.
		 * 
		 * @param sentences
		 *            the sentences
		 * @return <code>true</code> if none of the sentences is passive
		 */
		public static function nonePassive(...sentences):Boolean
		{
			var nopass:Boolean = true;
			var len:int = sentences.length;
			for (var i:int = 0; i < len && nopass; i++)
			{
				nopass = !sentences[i].getFeatureAsBoolean(Feature.PASSIVE);
			}
	
			return nopass;
		}
	}
}
