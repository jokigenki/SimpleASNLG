package examples
{
	import simpleasnlg.framework.NLGFactory;
	import simpleasnlg.lexicon.XMLLexicon;
	import simpleasnlg.realiser.english.Realiser;

	public class TutorialBase
	{
		public var lexicon:XMLLexicon;
		public var factory:NLGFactory;
		public var realiser:Realiser;
		
		public function TutorialBase()
		{
			lexicon = new XMLLexicon();
			factory = new NLGFactory(lexicon);
			realiser = new Realiser(lexicon);
		}
	}
}