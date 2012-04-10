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
	import simpleasnlg.features.Feature;
	import simpleasnlg.features.InternalFeature;
	import simpleasnlg.features.NumberAgreement;
	
	/**
	 * <p>
	 * This class defines coordination between two or more phrases. Coordination
	 * involves the linking of phrases together through the use of key words such as
	 * <em>and</em> or <em>but</em>.
	 * </p>
	 * 
	 * <p>
	 * The class does not perform any ordering on the coordinates and when realised
	 * they appear in the same order they were added to the coordination.
	 * </p>
	 * 
	 * <p>
	 * As this class appears similar to the <code>PhraseElement</code> class from an
	 * API point of view, it could have extended from the <code>PhraseElement</code>
	 * class. However, they are fundamentally different in their nature and thus
	 * form two distinct classes with similar APIs.
	 * </p>
	 * @author D. Westwater, University of Aberdeen.
	 * @version 4.0
	 * 
	 */
	public class CoordinatedPhraseElement extends NLGElement
	{
		/** Coordinators which make the coordinate plural (eg, "and" but not "or")*/
		private static const PLURAL_COORDINATORS:Vector.<String> = new <String>["and"];
		
		/**
		 * Creates a coordinated phrase linking the two phrase together. The default
		 * conjunction used is <em>and</em>.
		 * 
		 * @param coordinate1 (optional)
		 *            the first coordinate.
		 * @param coordinate2 (optional)
		 *            the second coordinate.
		 */
		public function CoordinatedPhraseElement(...coordinates):void
		{
			for each (var coord:Object in coordinates)
			{
				if (coord is Array)
				{
					for each (var subcoord:Object in coord)
					{
						this.addCoordinate(subcoord);
					}
				} else {
					this.addCoordinate(coord);
				}
			}
			this.setFeature(Feature.CONJUNCTION, "and"); //$NON-NLS-1$
		}
	
		/**
		 * Adds a new coordinate to this coordination. If the new coordinate is a
		 * <code>NLGElement</code> then it is added directly to the coordination. If
		 * the new coordinate is a <code>String</code> a <code>StringElement</code>
		 * is created and added to the coordination. <code>StringElement</code>s
		 * will have their complementisers suppressed by default. In the case of
		 * clauses, complementisers will be suppressed if the clause is not the
		 * first element in the coordination.
		 * 
		 * @param newCoordinate
		 *            the new coordinate to be added.
		 */
		public function addCoordinate(newCoordinate:Object):void
		{
			var coordinates:Array = getFeatureAsElementList(InternalFeature.COORDINATES);
			if (coordinates == null)
			{
				coordinates = new Array();
				setFeature(InternalFeature.COORDINATES, coordinates);
			}
			else if (coordinates.length == 0)
			{
				setFeature(InternalFeature.COORDINATES, coordinates);
			}
			
			if (newCoordinate is NLGElement)
			{
				if (NLGElement(newCoordinate).isA(PhraseCategory.CLAUSE) && coordinates.length > 0)
				{
					NLGElement(newCoordinate).setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
				}
				coordinates.push(NLGElement(newCoordinate));
			}
			else if (newCoordinate is String)
			{
				var coordElement:NLGElement = new StringElement(String(newCoordinate));
				coordElement.setFeature(Feature.SUPRESSED_COMPLEMENTISER, true);
				coordinates.push(coordElement);
			}
			setFeature(InternalFeature.COORDINATES, coordinates);
		}
	
		override public function getChildren():Array
		{
			return this.getFeatureAsElementList(InternalFeature.COORDINATES);
		}
	
		/**
		 * Clears the existing coordinates in this coordination. It performs exactly
		 * the same as <code>removeFeature(Feature.COORDINATES)</code>.
		 */
		public function clearCoordinates():void
		{
			removeFeature(InternalFeature.COORDINATES);
		}
	
		/**
		 * Adds a new pre-modifier to the phrase element. Pre-modifiers will be
		 * realised in the syntax before the coordinates.
		 * 
		 * @param newPreModifier
		 *            the new pre-modifier as an <code>NLGElement</code>.
		 */
		public function addPreModifier(newPreModifier:NLGElement):void
		{
			var preModifiers:Array = getFeatureAsElementList(InternalFeature.PREMODIFIERS);
			if (preModifiers == null) preModifiers = [];
			
			preModifiers.push(newPreModifier);
			setFeature(InternalFeature.PREMODIFIERS, preModifiers);
		}
		
		/**
		 * Adds a new pre-modifier to the phrase element. Pre-modifiers will be
		 * realised in the syntax before the coordinates.
		 * 
		 * @param newPreModifier
		 *            the new pre-modifier as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */
		public function addPreModifierAsString(newPreModifier:String):void
		{
			addPreModifier(new StringElement(newPreModifier));
		}
	
		/**
		 * Retrieves the list of pre-modifiers currently associated with this
		 * coordination.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s.
		 */
		public function getPreModifiers():Array
		{
			return getFeatureAsElementList(InternalFeature.PREMODIFIERS);
		}
	
		/**
		 * Retrieves the list of complements currently associated with this
		 * coordination.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s.
		 */
		public function getComplements():Array
		{
			return getFeatureAsElementList(InternalFeature.COMPLEMENTS);
		}
	
		/**
		 * Adds a new post-modifier to the phrase element. Post-modifiers will be
		 * realised in the syntax after the coordinates.
		 * 
		 * @param newPostModifier
		 *            the new post-modifier as an <code>NLGElement</code>.
		 */
		public function addPostModifier(newPostModifier:NLGElement):void
		{
			var postModifiers:Array = getFeatureAsElementList(InternalFeature.POSTMODIFIERS);
			if (postModifiers == null) postModifiers = [];

			postModifiers.push(newPostModifier);
			setFeature(InternalFeature.POSTMODIFIERS, postModifiers);
		}
	
		/**
		 * Adds a new post-modifier to the phrase element. Post-modifiers will be
		 * realised in the syntax after the coordinates.
		 * 
		 * @param newPostModifier
		 *            the new post-modifier as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */
		public function addPostModifierAsString(newPostModifier:String):void
		{
			addPostModifier(new StringElement(newPostModifier));
		}
		
		/**
		 * Retrieves the list of post-modifiers currently associated with this
		 * coordination.
		 * 
		 * @return a <code>List</code> of <code>NLGElement</code>s.
		 */
		public function getPostModifiers():Array
		{
			return getFeatureAsElementList(InternalFeature.POSTMODIFIERS);
		}
	
		override public function printTree(indent:String):String
		{
			var thisIndent:String = indent == null ? " |-" : indent + " |-"; //$NON-NLS-1$ //$NON-NLS-2$
			var childIndent:String = indent == null ? " | " : indent + " | "; //$NON-NLS-1$ //$NON-NLS-2$
			var lastIndent:String = indent == null ? " \\-" : indent + " \\-"; //$NON-NLS-1$ //$NON-NLS-2$
			var lastChildIndent:String = indent == null ? "   " : indent + "   "; //$NON-NLS-1$ //$NON-NLS-2$
			var print:String = "";
			print += "CoordinatedPhraseElement:\n"; //$NON-NLS-1$
	
			var children:Array = getChildren();
			var length:int = children.length - 1;
	
			for (var index:int = 0; index < length; index++)
			{
				print += thisIndent + children[index].printTree(childIndent);
			}
			if (length >= 0)
			{
				print += lastIndent + children[length].printTree(lastChildIndent);
			}
			return print;
		}
	
		/**
		 * Adds a new complement to the phrase element. Complements will be realised
		 * in the syntax after the coordinates. Complements differ from
		 * post-modifiers in that complements are crucial to the understanding of a
		 * phrase whereas post-modifiers are optional.
		 * 
		 * @param newComplement
		 *            the new complement as an <code>NLGElement</code>.
		 */
		public function addComplement(newComplement:NLGElement):void
		{
			var complements:Array = getFeatureAsElementList(InternalFeature.COMPLEMENTS);
			if (complements == null) complements = [];

			complements.push(newComplement);
			setFeature(InternalFeature.COMPLEMENTS, complements);
		}
	
		/**
		 * Adds a new complement to the phrase element. Complements will be realised
		 * in the syntax after the coordinates. Complements differ from
		 * post-modifiers in that complements are crucial to the understanding of a
		 * phrase whereas post-modifiers are optional.
		 * 
		 * @param newComplement
		 *            the new complement as a <code>String</code>. It is used to
		 *            create a <code>StringElement</code>.
		 */
		public function addComplementAsString(newComplement:String):void
		{
			addComplement(new StringElement(newComplement));
		}
		
		/**
		 * A convenience method for retrieving the last coordinate in this
		 * coordination.
		 * 
		 * @return the last coordinate as represented by a <code>NLGElement</code>
		 */
		public function getLastCoordinate():NLGElement
		{
			var children:Array = getChildren();
			return children != null && children.length > 0 ? children[children.length - 1] : null;
		}
		
		/** set the conjunction to be used in a coordinatedphraseelement
		 * @param conjunction
		 */
		public function setConjunction(conjunction:String):void
		{
			setFeature(Feature.CONJUNCTION, conjunction);
		}
		
		/**
		 * @return  conjunction used in coordinatedPhraseElement
		 */
		public function getConjunction():String
		{
			return getFeatureAsString(Feature.CONJUNCTION);
		}
		
		/**
		 * @return true if this coordinate is plural in a syntactic sense
		 */
		public function checkIfPlural():Boolean
		{
			// doing this right is quite complex, take simple approach for now
			var size:int = getChildren().length;
			if (size == 1)
				return (NumberAgreement.PLURAL == getLastCoordinate().getFeature(Feature.NUMBER));
			else
				return PLURAL_COORDINATORS.indexOf(getConjunction()) > -1;
		}
	}
}
