package com.steamshift.datatypes
{
	public class StringEnum extends Enum
	{
		private var _key:String;
		
		public function StringEnum(key:String)
		{
			_key = key;
		}
		
		public function toString ():String
		{
			return _key;
		}
	}
}