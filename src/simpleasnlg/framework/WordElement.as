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
	
	import flash.utils.Dictionary;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Inflection;
	import simpleasnlg.features.LexicalFeature;
	
	/**
	 * This is the class for a lexical entry (ie, a word). Words are stored in a
	 * {@link simpleasnlg.lexicon.Lexicon}, and usually the developer retrieves a
	 * WordElement via a lookup method in the lexicon
	 * 
	 * Words always have a base form, and usually have a
	 * {@link simpleasnlg.framework.LexicalCategory}. They may also have a Lexicon ID.
	 * 
	 * Words also have features (which are retrieved from the Lexicon), these are
	 * held in the standard NLGElement feature map
	 * 
	 * @author E. Reiter, University of Aberdeen.
	 * @version 4.0
	 */
	
	public class WordElement extends NLGElement
	{
	
		// Words have baseForm, category, id, and features
		// features are inherited from NLGElement
	
		public var baseForm:String; // base form, eg "dog". currently also in NLG Element, but
		// will be removed from there
	
		public var id:String; // id in lexicon (may be null);
	
		public var inflVars:Dictionary; // the inflectional variants
	
		public var defaultInfl:Inflection; // the default inflectional variant
	
		// LexicalCategory category; // type of word
	
		/**********************************************************/
		// constructors
		/**********************************************************/
	
		/**
		 * Create a WordElement with the specified baseForm, category, ID
		 * 
		 * @param baseForm
		 *            - base form of WordElement
		 * @param category
		 *            - category of WordElement
		 * @param id
		 *            - ID of word in lexicon
		 */
		public function WordElement(baseForm:String = null, category:LexicalCategory = null, id:String = null):void
		{
			if (!category) category = LexicalCategory.ANY;
			
			super();
			this.baseForm = baseForm;
			setCategory(category);
			this.id = id;
			this.inflVars = new Dictionary();
		}
	
		/**********************************************************/
		// getters and setters
		/**********************************************************/
	
		/**
		 * @return the baseForm
		 */
		public function getBaseForm():String
		{
			return this.baseForm;
		}
	
		/**
		 * @return the id
		 */
		public function getId():String {
			return this.id;
		}
	
		/**
		 * @param baseForm
		 *            the baseForm to set
		 */
		public function setBaseForm(baseForm:String):void
		{
			this.baseForm = baseForm;
		}
	
		/**
		 * @param id
		 *            the id to set
		 */
		public function setId(id:String):void
		{
			this.id = id;
		}
	
		/**
		 * Set the default inflectional variant of a word. This is mostly relevant
		 * if the word has more than one possible inflectional variant (for example,
		 * it can be inflected in both a regular and irregular way).
		 * 
		 * <P>
		 * If the default inflectional variant is set, the inflectional forms of the
		 * word may change as a result. This depends on whether inflectional forms
		 * have been specifically associated with this variant, via
		 * {@link #addInflectionalVariant(Inflection, String, String)}.
		 * 
		 * <P>
		 * The <code>NIHDBLexicon</code> associates different inflectional variants
		 * with words, if they are so specified, and adds the correct forms.
		 * 
		 * @param variant
		 *            The variant
		 */
		public function setDefaultInflectionalVariant(variant:Inflection):void
		{
			setFeature(LexicalFeature.DEFAULT_INFL, variant);
			this.defaultInfl = variant;
	
			if (this.inflVars[variant])
			{
				var set:InflectionSet = inflVars[variant];
				var forms:Array = LexicalFeature.getInflectionalFeatures(this.getCategory().toString());
	
				if (forms != null)
				{
					var len:int = forms.length;
					for (var i:int = 0; i < len; i++)
					{
						var f:Feature = forms[i];
						setFeature(f, set.getForm(f.toString()));
					}
				}
			}
		}
	
		/**
		 * @return the default inflectional variant
		 */
		public function getDefaultInflectionalVariant():Object
		{
			// return getFeature(LexicalFeature.DEFAULT_INFL);
			return this.defaultInfl;
		}
	
		/*
		 * Convenience method to get all the inflectional forms of the word.
		 * Equivalent to
		 * <code>getFeatureAsStringList(LexicalFeature.INFLECTIONS)</code>.
		 * 
		 * @return the list of inflectional variants
		 */
		// public List<Object> getInflectionalVariants() {
		// return getFeatureAsList(LexicalFeature.INFLECTIONS);
		// }
	
		/*
		 * Convenience method to get all the spelling variants of the word.
		 * Equivalent to
		 * <code>getFeatureAsStringList(LexicalFeature.SPELL_VARS)</code>.
		 * 
		 * @return the list of spelling variants
		 */
		// public List<String> getSpellingVariants() {
		// return getFeatureAsStringList(LexicalFeature.SPELL_VARS);
		// }
	
		/**
		 * Convenience method to set the default spelling variant of a word.
		 * Equivalent to
		 * <code>setFeature(LexicalFeature.DEFAULT_SPELL, variant)</code>.
		 * 
		 * <P>
		 * By default, the spelling variant used is the base form. If otherwise set,
		 * this forces the realiser to always use the spelling variant specified.
		 * 
		 * @param variant
		 *            The spelling variant
		 */
		public function setDefaultSpellingVariant(variant:String):void
		{
			setFeature(LexicalFeature.DEFAULT_SPELL, variant);
		}
	
		/**
		 * Convenience method, equivalent to
		 * <code>getFeatureAsString(LexicalFeature.DEFAULT_SPELL)</code>. If this
		 * feature is not set, the baseform is returned.
		 * 
		 * @return the default inflectional variant
		 */
		public function getDefaultSpellingVariant():String
		{
			var defSpell:String = getFeatureAsString(LexicalFeature.DEFAULT_SPELL);
			return defSpell == null ? this.getBaseForm() : defSpell;
		}
	
		/*
		 * @param category the category to set
		 */
		// public function setCategory(LexicalCategory category) {
		// this.category = category;
		// }
	
		/**
		 * Add an inflectional variant to this word element. This method is intended
		 * for use by a <code>Lexicon</code>. The idea is that words which have more
		 * than one inflectional variant (for example, a regular and an irregular
		 * form of the past tense), can have a default variant (for example, the
		 * regular), but also store information about the other variants. This comes
		 * in useful in case the default inflectional variant is reset to a new one.
		 * In that case, the stored forms for the new variant are used to inflect
		 * the word.
		 * 
		 * <P>
		 * <strong>An example:</strong> The verb <i>lie</i> has both a regular form
		 * (<I>lies, lied, lying</I>) and an irregular form (<I>lay, lain,</I> etc).
		 * Assume that the <code>Lexicon</code> provides this information and treats
		 * this as variant information of the same word (as does the
		 * <code>NIHDBLexicon</code>, for example). Typically, the default
		 * inflectional variant is the <code>Inflection.REGULAR</code>. This means
		 * that morphology proceeds to inflect the verb as <I>lies, lying</I> and so
		 * on. If the default inflectional variant is reset to
		 * <code>Inflection.IRREGULAR</code>, the stored irregular forms will be
		 * used instead.
		 * 
		 * @param infl
		 *            the Inflection pattern with which this form is associated
		 * @param lexicalFeature
		 *            the actual inflectional feature being set, for example
		 *            <code>LexicalFeature.PRESENT_3S</code>
		 * @param form
		 *            the actual inflected word form
		 */
		public function addInflectionalVariant(infl:Inflection, lexicalFeature:String = null, form:String = null):void
		{
			if (!lexicalFeature)
			{
				this.inflVars[infl] = new InflectionSet(infl);
			}
			else if (this.inflVars[infl])
			{
				this.inflVars[infl].addForm(lexicalFeature, form);
			} else {
				var set:InflectionSet = new InflectionSet(infl);
				set.addForm(lexicalFeature, form);
				this.inflVars.push(infl, set);
			}
		}
		
		/**
		 * Check whether this word has a particular inflectional variant
		 * 
		 * @param infl
		 *            the variant
		 * @return <code>true</code> if this word has the variant
		 */
		public function hasInflectionalVariant(infl:Inflection):Boolean
		{
			return this.inflVars[infl];
		}
	
		/**********************************************************/
		// other methods
		/**********************************************************/
	
		override public function toString():String
		{
			var _category:ElementCategory = getCategory();
			var buffer:String = "WordElement["; //$NON-NLS-1$
			buffer += getBaseForm() + ':';
			if (_category != null)
			{
				buffer += _category.toString();
			} else {
				buffer += "no category"; //$NON-NLS-1$
			}
			buffer += ']';
			
			return buffer;
		}
	
		public function toXML():String
		{
			var xml:String = "<word>%n";
			// [TODO] XML Stuff
			/*
			String xml = String.format("<word>%n"); //$NON-NLS-1$
			if (getBaseForm() != null)
				xml = xml + String.format("  <base>%s</base>%n", getBaseForm()); //$NON-NLS-1$
			if (getCategory() != LexicalCategory.ANY)
				xml = xml + String.format("  <category>%s</category>%n", //$NON-NLS-1$
						getCategory().toString().toLowerCase());
			if (getId() != null)
				xml = xml + String.format("  <id>%s</id>%n", getId()); //$NON-NLS-1$
	
			SortedSet<String> featureNames = new TreeSet<String>(
					getAllFeatureNames()); // list features in alpha order
			for (String feature : featureNames) {
				Object value = getFeature(feature);
				if (value != null) { // ignore null features
					if (value is Boolean) { // booleans ignored if false,
						// shown as <XX/> if true
						boolean bvalue = ((Boolean) value).booleanValue();
						if (bvalue)
							xml = xml + String.format("  <%s/>%n", feature); //$NON-NLS-1$
					} else { // otherwise include feature and value
						xml = xml + String.format("  <%s>%s</%s>%n", feature, value //$NON-NLS-1$
								.toString(), feature);
					}
				}
	
			}
			xml = xml + String.format("</word>%n"); //$NON-NLS-1$
			*/
			
			return xml;
		}
	
		/**
		 * This method returns an empty <code>List</code> as words do not have child
		 * elements.
		 */
		override public function getChildren():Array
		{
			return new Array();
		}
	
		override public function printTree(indent:String):String
		{
			var print:String = "";
			print += "WordElement: base=" + getBaseForm() + ", category=" + getCategory().toString() + ", " + super.toString() + '\n'; //$NON-NLS-1$
			return print;
		}
	
		/**
		 * Check if this WordElement is equal to an object.
		 * 
		 * @param o
		 *            the object
		 * @return <code>true</code> iff the object is a word element with the same
		 *         id and the same baseform and the same features.
		 * 
		 */
		override public function equals(o:Object):Boolean
		{
			if (o is WordElement) {
				var we:WordElement = WordElement(o);
	
				return (this.baseForm == we.baseForm || this.baseForm == we.baseForm)
						&& (this.id == we.id || this.id == we.id)
						&& Cloner.compare(we.features, this.features);
			}
	
			return false;
		}
		
		override public function clone ():NLGElement
		{
			var newElement:WordElement = new WordElement(this.baseForm, this.category as LexicalCategory, this.id);
			
			// assign these, do not clone
			newElement.parent = this.parent;
			newElement.factory = this.factory;
			newElement.realisation = this.realisation;
			
			// clone features
			for (var key:String in this.features)
			{
				var feature:* = features[key];
				newElement.features[key] = Cloner.clone(feature);
			}
			
			for (var inflKey:* in this.inflVars)
			{
				var inflSet:InflectionSet = new InflectionSet(this.inflVars[inflKey].infl);
				inflSet.forms = Cloner.clone(this.inflVars[inflKey].forms);
				newElement.inflVars[inflKey] = inflSet;
			}
			newElement.defaultInfl = this.defaultInfl;
			
			return newElement;
		}
	}
}
