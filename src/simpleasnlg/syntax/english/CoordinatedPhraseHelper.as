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
package simpleasnlg.syntax.english
{
	import simpleasnlg.features.DiscourseFunction;
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.LexicalFeature;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	import simpleasnlg.framework.InflectedWordElement;
	import simpleasnlg.framework.LexicalCategory;
	import simpleasnlg.framework.ListElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.PhraseCategory;
	import simpleasnlg.framework.WordElement;
	
	/**
	 * <p>
	 * This class contains static methods to help the syntax processor realise
	 * coordinated phrases.
	 * </p>
	 * 
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 */
	public class CoordinatedPhraseHelper
	{
		/**
		 * The main method for realising coordinated phrases.
		 * 
		 * @param parent
		 *            the <code>SyntaxProcessor</code> that called this method.
		 * @param phrase
		 *            the <code>CoordinatedPhrase</code> to be realised.
		 * @return the realised <code>NLGElement</code>.
		 */
		public static function realise(parent:SyntaxProcessor, phrase:CoordinatedPhraseElement):NLGElement
		{
			var realisedElement:ListElement = null;
	
			if (phrase != null) 
			{
				realisedElement = new ListElement();
				PhraseHelper.realiseList(parent, realisedElement, phrase.getPreModifiers(), DiscourseFunction.PRE_MODIFIER);
	
				var coordinated:CoordinatedPhraseElement = new CoordinatedPhraseElement();
	
				var children:Array = phrase.getChildren();
				var conjunction:String = phrase.getFeatureAsString(Feature.CONJUNCTION);
				coordinated.setFeature(Feature.CONJUNCTION, conjunction);
				coordinated.setFeature(Feature.CONJUNCTION_TYPE, phrase.getFeature(Feature.CONJUNCTION_TYPE));
	
				var conjunctionElement:InflectedWordElement = null;
	
				if (children != null && children.length > 0)
				{	
					if (phrase.getFeatureAsBoolean(Feature.RAISE_SPECIFIER))
					{
						raiseSpecifier(children);
					}
	
					var child:NLGElement = phrase.getLastCoordinate();
					child.setFeature(Feature.POSSESSIVE, phrase.getFeature(Feature.POSSESSIVE));
	
					child = children[0];
	
					setChildFeatures(phrase, child);
	
					coordinated.addCoordinate(parent.realise(child));
					for (var index:int = 1; index < children.length; index++)
					{
						child = children[index];
						setChildFeatures(phrase, child);
						if (phrase.getFeatureAsBoolean(Feature.AGGREGATE_AUXILIARY)) 
						{
							child.setFeature(InternalFeature.REALISE_AUXILIARY, false);
						}
	
						if (child.isA(PhraseCategory.CLAUSE))
						{
							child.setFeature(Feature.SUPRESSED_COMPLEMENTISER, phrase.getFeature(Feature.SUPRESSED_COMPLEMENTISER));
						}
	
						//skip conjunction if it's null or empty string
						if (conjunction != null && conjunction.length > 0)
						{
							conjunctionElement = new InflectedWordElement(conjunction, LexicalCategory.CONJUNCTION);
							conjunctionElement.setFeature(InternalFeature.DISCOURSE_FUNCTION, DiscourseFunction.CONJUNCTION);
							coordinated.addCoordinate(conjunctionElement);
						}
	
						coordinated.addCoordinate(parent.realise(child));
					}
					realisedElement.addComponent(coordinated);
				}
	
				PhraseHelper.realiseList(parent, realisedElement, phrase.getPostModifiers(), DiscourseFunction.POST_MODIFIER);
				PhraseHelper.realiseList(parent, realisedElement, phrase.getComplements(), DiscourseFunction.COMPLEMENT);
			}
			return realisedElement;
		}
	
		/**
		 * Sets the common features from the phrase to the child element.
		 * 
		 * @param phrase
		 *            the <code>CoordinatedPhraseElement</code>
		 * @param child
		 *            a single coordinated <code>NLGElement</code> within the
		 *            coordination.
		 */
		private static function setChildFeatures(phrase:CoordinatedPhraseElement, child:NLGElement):void {
	
			if (phrase.hasFeature(Feature.PROGRESSIVE)) {
				child.setFeature(Feature.PROGRESSIVE, phrase
						.getFeature(Feature.PROGRESSIVE));
			}
			if (phrase.hasFeature(Feature.PERFECT)) {
				child.setFeature(Feature.PERFECT, phrase.getFeature(Feature.PERFECT));
			}
			if (phrase.hasFeature(InternalFeature.SPECIFIER))
			{
				child.setFeature(InternalFeature.SPECIFIER, phrase.getFeature(InternalFeature.SPECIFIER));
			}
			if (phrase.hasFeature(LexicalFeature.GENDER))
			{
				child.setFeature(LexicalFeature.GENDER, phrase.getFeature(LexicalFeature.GENDER));
			}
			if (phrase.hasFeature(Feature.NUMBER)) {
				child.setFeature(Feature.NUMBER, phrase.getFeature(Feature.NUMBER));
			}
			if (phrase.hasFeature(Feature.TENSE)) {
				child.setFeature(Feature.TENSE, phrase.getFeature(Feature.TENSE));
			}
			if (phrase.hasFeature(Feature.PERSON)) {
				child.setFeature(Feature.PERSON, phrase.getFeature(Feature.PERSON));
			}
			if (phrase.hasFeature(Feature.NEGATED)) {
				child.setFeature(Feature.NEGATED, phrase.getFeature(Feature.NEGATED));
			}
			if (phrase.hasFeature(Feature.MODAL)) {
				child.setFeature(Feature.MODAL, phrase.getFeature(Feature.MODAL));
			}
			if (phrase.hasFeature(InternalFeature.DISCOURSE_FUNCTION)) {
				child.setFeature(InternalFeature.DISCOURSE_FUNCTION, phrase
						.getFeature(InternalFeature.DISCOURSE_FUNCTION));
			}
			if (phrase.hasFeature(Feature.FORM)) {
				child.setFeature(Feature.FORM, phrase.getFeature(Feature.FORM));
			}
			if (phrase.hasFeature(InternalFeature.CLAUSE_STATUS)) {
				child.setFeature(InternalFeature.CLAUSE_STATUS, phrase
						.getFeature(InternalFeature.CLAUSE_STATUS));
			}
			if (phrase.hasFeature(Feature.INTERROGATIVE_TYPE)) {
				child.setFeature(InternalFeature.IGNORE_MODAL, true);
			}
		}
	
		/**
		 * Checks to see if the specifier can be raised and then raises it. In order
		 * to be raised the specifier must be the same on all coordinates. For
		 * example, <em>the cat and the dog</em> will be realised as
		 * <em>the cat and dog</em> while <em>the cat and any dog</em> will remain
		 * <em>the cat and any dog</em>.
		 * 
		 * @param children
		 *            the <code>List</code> of coordinates in the
		 *            <code>CoordinatedPhraseElement</code>
		 */
		private static function raiseSpecifier(children:Array):void
		{
			var allMatch:Boolean = true;
			var child:NLGElement = children[0];
			var specifier:NLGElement  = null;
			var test:String = null;
	
			if (child != null)
			{
				specifier = child.getFeatureAsElement(InternalFeature.SPECIFIER);
	
				if (specifier != null)
				{
					// AG: this assumes the specifier is an InflectedWordElement or
					// phrase.
					// it could be a Wordelement, in which case, we want the
					// baseform
					test = (specifier is WordElement) ? WordElement(specifier).getBaseForm() : specifier.getFeatureAsString(LexicalFeature.BASE_FORM);
				}
	
				if (test != null)
				{
					var index:int = 1;
	
					while (index < children.length && allMatch)
					{
						child = children[index];
	
						if (child == null)
						{
							allMatch = false;
						} else {
							specifier = child.getFeatureAsElement(InternalFeature.SPECIFIER);
							var childForm:String = (specifier is WordElement) ? WordElement(specifier).getBaseForm() : specifier.getFeatureAsString(LexicalFeature.BASE_FORM);
	
							if (test != childForm)
							{
								allMatch = false;
							}
						}
						index++;
					}
					if (allMatch)
					{
						var len:int = children.length;
						for (var eachChild:int = 1; eachChild < children.length; eachChild++)
						{
							child = children[eachChild];
							child.setFeature(InternalFeature.RAISED, true);
						}
					}
				}
			}
		}
	}
}
