package com.steamshift.datatypes
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class Enum extends Object
	{
		protected var _ordinal:int;
		private static var _ordinalCounters:Dictionary = new Dictionary();
		
		public function Enum()	
		{
			var name:String = getQualifiedClassName(this);
			_ordinal = Enum._ordinalCounters[name];
			Enum._ordinalCounters[name] = _ordinal + 1;
		}
		
		public function get ordinal ():int { return _ordinal; }
	}
}