package examples
{
	import simpleasnlg.framework.NLGElement;

	public class CannedSentence extends TutorialBase
	{
		public function CannedSentence()
		{
			super();
			
			// canned sentence
			var phrase1:NLGElement = factory.createCannedSentence("hello, world");
			trace(realiser.realiseSentence(phrase1));
		}
	}
}