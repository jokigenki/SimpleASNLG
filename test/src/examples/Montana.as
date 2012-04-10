package examples
{
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.Form;
	import simpleasnlg.framework.NLGElement;
	import simpleasnlg.phrasespec.SPhraseSpec;

	public class Montana extends TutorialBase
	{
		public function Montana()
		{
			super();
			
			// phrase 1
			var phrase2:SPhraseSpec = factory.createClause();
			phrase2.setSubject("Tony");
			phrase2.setVerb("say");
			
			// phrase 2
			var phrase3:SPhraseSpec = factory.createClause();
			phrase3.setVerb("say");
			phrase3.setObject("hello");
			phrase3.setComplementAsString("to my leettle friend");
			phrase3.setFeature(Feature.FORM, Form.IMPERATIVE);
			var quote:NLGElement = realiser.realise(phrase3);
			var sayHello:String = realiser.realise(phrase3).toString();
			sayHello = "'" + sayHello + "'";
			
			phrase2.setObject(sayHello);
			trace(realiser.realiseSentence(phrase2));
		}
	}
}