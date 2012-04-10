package com.steamshift.utils
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.Dictionary;

	public class ArrayUtils
	{
		public static function remove(array:Array, item:*):Boolean
		{
			var index:int = array.indexOf(item);
			if (index == -1) return false;
			
			array.splice(index, 1);
			
			return true;
		}
		
		public static function has(array:Array, item:*):Boolean
		{
			return array.indexOf(item) > -1;
		}
	}
}