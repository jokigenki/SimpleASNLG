package
{
	import flash.display.Sprite;
	
	import flexunit.flexui.FlexUnitTestRunnerUIAS;
	
	import simpleasnlg.test.lexicon.XMLLexiconTest;
	import simpleasnlg.test.syntax.AdjectivePhraseTest;
	import simpleasnlg.test.syntax.ClauseAggregationTest;
	import simpleasnlg.test.syntax.ClauseTest;
	import simpleasnlg.test.syntax.CoordinationTest;
	import simpleasnlg.test.syntax.DocumentElementTest;
	import simpleasnlg.test.syntax.ExternalTest;
	import simpleasnlg.test.syntax.ExternalTests2;
	import simpleasnlg.test.syntax.FPTest;
	import simpleasnlg.test.syntax.InterrogativeTest;
	import simpleasnlg.test.syntax.NounPhraseTest;
	import simpleasnlg.test.syntax.OrthographyFormatTests;
	import simpleasnlg.test.syntax.PhraseSpecTest;
	import simpleasnlg.test.syntax.PrepositionalPhraseTest;
	import simpleasnlg.test.syntax.TutorialTest;
	import simpleasnlg.test.syntax.VerbPhraseTest;
	
	public class FlexUnitApplication extends Sprite
	{
		public function FlexUnitApplication()
		{
			onCreationComplete();
		}
		
		private function onCreationComplete():void
		{
			var testRunner:FlexUnitTestRunnerUIAS=new FlexUnitTestRunnerUIAS();
			testRunner.portNumber=8765; 
			this.addChild(testRunner); 
			testRunner.runWithFlexUnit4Runner(currentRunTestSuite(), "SimpleASNLGTests");
		}
		
		public function currentRunTestSuite():Array
		{
			var testsToRun:Array = new Array();
			//testsToRun.push(simpleasnlg.test.lexicon.LexicalVariantsTests);
			//testsToRun.push(simpleasnlg.test.lexicon.MultipleLexiconTest);
			//testsToRun.push(simpleasnlg.test.lexicon.NIHDBLexiconTest);
			testsToRun.push(simpleasnlg.test.lexicon.XMLLexiconTest);
			testsToRun.push(simpleasnlg.test.syntax.AdjectivePhraseTest);
			testsToRun.push(simpleasnlg.test.syntax.ClauseAggregationTest);
			//testsToRun.push(simpleasnlg.test.syntax.ClauseAggregationTest2);
			testsToRun.push(simpleasnlg.test.syntax.ClauseTest);
			testsToRun.push(simpleasnlg.test.syntax.CoordinationTest);
			testsToRun.push(simpleasnlg.test.syntax.DocumentElementTest);
			//testsToRun.push(simpleasnlg.test.syntax.ElisionTests);
			testsToRun.push(simpleasnlg.test.syntax.ExternalTest);
			testsToRun.push(simpleasnlg.test.syntax.ExternalTests2);
			testsToRun.push(simpleasnlg.test.syntax.FPTest);
			testsToRun.push(simpleasnlg.test.syntax.InterrogativeTest);
			testsToRun.push(simpleasnlg.test.syntax.NounPhraseTest);
			testsToRun.push(simpleasnlg.test.syntax.OrthographyFormatTests);
			testsToRun.push(simpleasnlg.test.syntax.PhraseSpecTest);
			testsToRun.push(simpleasnlg.test.syntax.PrepositionalPhraseTest);
			//testsToRun.push(simpleasnlg.test.syntax.SimpleNLG4Test);
			testsToRun.push(simpleasnlg.test.syntax.TutorialTest);
			testsToRun.push(simpleasnlg.test.syntax.VerbPhraseTest);
			return testsToRun;
		}
	}
}