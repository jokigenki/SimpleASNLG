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
package simpleasnlg.realiser.english
{
	
	
	
	import simpleasnlg.format.english.TextFormatter;
	import simpleasnlg.framework.DocumentCategory;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGModule;
	import simpleasnlg.lexicon.Lexicon;
	import simpleasnlg.morphology.english.MorphologyProcessor;
	import simpleasnlg.orthography.english.OrthographyProcessor;
	import simpleasnlg.syntax.english.SyntaxProcessor;
	
	/**
	 * @author D. Westwater, Data2Text Ltd
	 *
	 */
	public class Realiser extends NLGModule
	{
		private var morphology:MorphologyProcessor;
		private var orthography:OrthographyProcessor;
		private var syntax:SyntaxProcessor;
		private var formatter:NLGModule = null;
		private var debug:Boolean = false;
		
		/** Create a realiser with a lexicon (should match lexicon used for NLGFactory)
		 * @param lexicon
		 */
		public function Realiser(lexicon:Lexicon = null)
		{
			super();
			
			initialise();
			if (lexicon) setLexicon(lexicon);
		}
	
		override public function initialise():void
		{
			this.morphology = new MorphologyProcessor();
			this.morphology.initialise();
			this.orthography = new OrthographyProcessor();
			this.orthography.initialise();
			this.syntax = new SyntaxProcessor();
			this.syntax.initialise();
			this.formatter = new TextFormatter();
			//AG: added call to initialise for formatter
			this.formatter.initialise();
		}
	
		override public function realise(element:NLGElement):NLGElement
		{
			if (!element)
			{
				if (this.debug) trace("NULL ELEMENT");
				return null;
			}
			
			if (this.debug)
			{
				trace("INITIAL TREE\n"); //$NON-NLS-1$
				trace(element.printTree(null));
			}
			var postSyntax:NLGElement = this.syntax.realise(element);
			if (this.debug) {
				trace("\nPOST-SYNTAX TREE\n"); //$NON-NLS-1$
				trace(postSyntax.printTree(null));
			}
			var postMorphology:NLGElement = this.morphology.realise(postSyntax);
			if (this.debug) {
				trace("\nPOST-MORPHOLOGY TREE\n"); //$NON-NLS-1$
				trace(postMorphology.printTree(null));
			}			
					
			var postOrthography:NLGElement = this.orthography.realise(postMorphology);
			if (this.debug)
			{
				trace("\nPOST-ORTHOGRAPHY TREE\n"); //$NON-NLS-1$
				trace(postOrthography.printTree(null));
			}
			
			var postFormatter:NLGElement = null;
			if (this.formatter != null)
			{
				postFormatter = this.formatter.realise(postOrthography);
				if (this.debug)
				{
					trace("\nPOST-FORMATTER TREE\n"); //$NON-NLS-1$
					trace(postFormatter.printTree(null));
				}
			} else {
				postFormatter = postOrthography;
			}
			
			
			return postFormatter;
		}
		
		/** Convenience class to realise any NLGElement as a sentence
		 * @param element
		 * @return String realisation of the NLGElement
		 */
		public function realiseSentence(element:NLGElement):String
		{
			var realised:NLGElement = null;
			if (element is DocumentElement)
				realised = realise(element);
			else {
				var sentence:DocumentElement = new DocumentElement(DocumentCategory.SENTENCE, null);
				sentence.addComponent(element);
				realised = realise(sentence);
			}
			
			if (realised == null)
				return null;
			else
				return realised.getRealisation();
		}
	
		override public function realiseList(elements:Array):Array
		{
			return null;
		}
	
		override public function setLexicon(newLexicon:Lexicon):void
		{
			this.syntax.setLexicon(newLexicon);
			this.morphology.setLexicon(newLexicon);
			this.orthography.setLexicon(newLexicon);
		}
	
		public function setFormatter(formatter:NLGModule):void
		{
			this.formatter = formatter;
		}
		
		public function setDebugMode(debugOn:Boolean):void
		{
			this.debug = debugOn;
		}
	}
}
