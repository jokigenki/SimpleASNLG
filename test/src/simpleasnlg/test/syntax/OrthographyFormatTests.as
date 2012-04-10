package simpleasnlg.test.syntax
{
	import flexunit.framework.Assert;
	
	import simpleasnlg.format.english.TextFormatter;
	import simpleasnlg.framework.DocumentElement;
	import simpleasnlg.framework.NLGElement;
	
	public class OrthographyFormatTests extends SimpleNLG4Test
	{
	
		private var list1:DocumentElement;
		private var list2:DocumentElement;
		private var listItem1:DocumentElement;
		private var listItem2:DocumentElement;
		private var listItem3:DocumentElement;
		private var list1Realisation:String = "* in the room\n* behind the curtain\n";
		private var list2Realisation:String = "* on the rock\n* " + list1Realisation + "\n";
	
		public function OrthographyFormatTests(name:String = null)
		{
			super(name);
		}
	
		//@Before
		override public function setUp():void
		{
			super.setUp();
	
			// need to set formatter for realiser (set to null in the test
			// superclass)
			this.realiser.setFormatter(new TextFormatter());
	
			// a couple phrases as list items
			this.listItem1 = this.phraseFactory.createListItem(this.inTheRoom);
			this.listItem2 = this.phraseFactory.createListItem(this.behindTheCurtain);
			this.listItem3 = this.phraseFactory.createListItem(this.onTheRock);
	
			// a simple depth-1 list of phrases
			this.list1 = this.phraseFactory.createList([this.listItem1, this.listItem2]);
	
			// a list consisting of one phrase (depth-1) + a list )(depth-2)
			this.list2 = this.phraseFactory.createList([this.listItem3, this.phraseFactory.createListItem(this.list1)]);
		}
	
		/**
		 * Test the realisation of a simple list
		 */
		[Test]
		public function testSimpleListOrthography():void
		{
			var realised:NLGElement = this.realiser.realise(this.list1);
			Assert.assertEquals(this.list1Realisation, realised.getRealisation());
			
		}
	
		/**
		 * Test the realisation of a list with an embedded list
		 */
		[Test]
		public function testEmbeddedListOrthography():void
		{
			var realised:NLGElement = this.realiser.realise(this.list2);
			var l1:int = this.list2Realisation.length;
			var l2:int = realised.getRealisation().length;
			Assert.assertEquals(this.list2Realisation, realised.getRealisation());
		
		}
	}
}
