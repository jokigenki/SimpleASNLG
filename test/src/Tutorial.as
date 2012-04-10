package
{
	import examples.BasicSentence;
	import examples.CannedSentence;
	import examples.Montana;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.features.Tense;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.lexicon.XMLLexicon;
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;
	import simpleasnlg.realiser.english.Realiser;
	
	public class Tutorial extends Sprite
	{
		public function Tutorial()
		{
			super();
			
			var canned:CannedSentence = new CannedSentence();
			var basic:BasicSentence = new BasicSentence();
			var montana:Montana = new Montana();
		}
	}
}