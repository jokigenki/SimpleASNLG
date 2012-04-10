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

package simpleasnlg.test.syntax
{
	import flexunit.framework.Assert;
	
	import simpleasnlg.features.Feature;
	import simpleasnlg.framework.CoordinatedPhraseElement;
	
	// TODO: Auto-generated Javadoc
	/**
	 * This class groups together some tests for prepositional phrases and
	 * coordinate prepositional phrases.
	 * @author agatt
	 */
	public class PrepositionalPhraseTest extends SimpleNLG4Test
	{
		/**
		 * Instantiates a new pP test.
		 * 
		 * @param name
		 *            the name
		 */
		public function PrepositionalPhraseTest(name:String = null)
		{
			super(name);
		}
import simpleasnlg.framework.CoordinatedPhraseElement;
	
		/**
		 * Basic test for the pre-set PP fixtures.
		 */
		[Test]
		public function testBasic():void
		{
			Assert.assertEquals("in the room", this.realiser.realise(this.inTheRoom).getRealisation());
			Assert.assertEquals("behind the curtain", this.realiser.realise(this.behindTheCurtain).getRealisation());
			Assert.assertEquals("on the rock", this.realiser.realise(this.onTheRock).getRealisation());
		}
	
		/**
		 * Test for coordinate NP complements of PPs.
		 */
		[Test]
		public function testComplementation():void
		{
			this.inTheRoom.clearComplements();
			this.inTheRoom.addComplement(new CoordinatedPhraseElement(
					this.phraseFactory.createNounPhrase("room", "the"), //$NON-NLS-1$ //$NON-NLS-2$
					this.phraseFactory.createNounPhrase("car", "a"))); //$NON-NLS-1$//$NON-NLS-2$
			Assert.assertEquals("in the room and a car", this.realiser.realise(this.inTheRoom).getRealisation());
		}
	
		/**
		 * Test for PP coordination.
		 */
		public function testCoordination():void
		{
			// simple coordination
			var coord1:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.inTheRoom, this.behindTheCurtain);
			Assert.assertEquals("in the room and behind the curtain", this.realiser.realise(coord1).getRealisation());
	
			// change the conjunction
			coord1.setFeature(Feature.CONJUNCTION, "or"); //$NON-NLS-1$
			Assert.assertEquals("in the room or behind the curtain", this.realiser.realise(coord1).getRealisation());
	
			// new coordinate
			var coord2:CoordinatedPhraseElement = new CoordinatedPhraseElement(this.onTheRock, this.underTheTable);
			coord2.setFeature(Feature.CONJUNCTION, "or"); //$NON-NLS-1$
			Assert.assertEquals("on the rock or under the table", this.realiser.realise(coord2).getRealisation());
	
			// coordinate two coordinates
			var coord3:CoordinatedPhraseElement = new CoordinatedPhraseElement(coord1, coord2);
	
			var text:String = this.realiser.realise(coord3).getRealisation();
			Assert.assertEquals("in the room or behind the curtain and on the rock or under the table", text);
		}
	}
}
