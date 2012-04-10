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
* The Initial Developer of the Original Code is Owen Bennett.
*
* Contributor(s): Owen Bennett.
*/
package com.steamshift.collections
{
	public class Stack
	{
		private var _array:Array;
		
		public function Stack()
		{
			_array = [];
		}
		
		public function add (item:*):void
		{
			_array[_array.length] = item;
		}
		
		public function addAll(values:Array):void
		{
			_array.concat(values);
		}
		
		public function itemAt (index:int):*
		{
			return _array[index];
		}
		
		public function get size():uint
		{
			return _array.length;
		}
		
		public function has(item:*):Boolean
		{
			return _array.indexOf(item) > -1;
		}
		
		public function toArray():Array
		{
			return _array.concat();
		}
		
		public function pop ():*
		{
			return _array.pop();	
		}
		
		public function push (item:*):void
		{
			_array.push(item);	
		}
		
		public function remove(item:*):Boolean
		{
			var index:int = _array.indexOf(item);
			if (index == -1) return false;
			_array.splice(index, 1);
			
			return true;
		}
		
		public function clear():Boolean
		{
			if (_array.length == 0) return false;
			_array.splice(0, _array.length);
			
			return true;
		}
	}
}