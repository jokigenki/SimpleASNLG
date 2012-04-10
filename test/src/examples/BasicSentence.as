package examples
{
	import simpleasnlg.phrasespec.NPPhraseSpec;
	import simpleasnlg.phrasespec.SPhraseSpec;

	public class BasicSentence extends TutorialBase
	{
		public function BasicSentence()
		{
			super();
			
			// verb 1
			var phrase2:SPhraseSpec = factory.createClause();
			phrase2.setSubject("Tony");
			phrase2.setVerb("say");
			phrase2.setObject("hello");
			//phrase2.setTense(Tense.PAST);
			trace(realiser.realiseSentence(phrase2));
		}
	}
}