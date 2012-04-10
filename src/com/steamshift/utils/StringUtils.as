package com.steamshift.utils
{	
	import flash.utils.Dictionary;
	
	public class StringUtils
	{
		public static function getFirst (string:String, searchStrings:Array, startIndex:int = 0, ignoreWhiteSpace:Boolean = true):Number
		{
			var lowest:int = string.indexOf(searchStrings[0], startIndex);
			var len:int = searchStrings.length;
			for (var i:int = 1; i < len; i++)
			{
				var val:Number = string.indexOf(searchStrings[i], startIndex);
				if (val == -1) continue;
				if (val < lowest || lowest == -1) lowest = val;	
			}
			
			if (ignoreWhiteSpace)
			{
				while (string.charAt(lowest - 1) == " ")
				{
					lowest--;
				}
			}
			
			return lowest;
		}
		
		public static function trimStringFromString (trim:String, string:String, startIndex:int = 0):String
		{
			var sliceIndex:int = string.indexOf(trim, startIndex);
			if (sliceIndex == -1) return string;
			return string.slice(0, sliceIndex) + string.slice(sliceIndex + trim.length);
		}
		
		// a faster version of String.replace()
		public static function findAndReplace(find:String, replace:String, string:String):Object
		{
			var sIndex:int = string.indexOf(find);
			var changes:int = 0;
			
			while (sIndex > -1)
			{
				changes++;
				string = string.slice(0, sIndex) + replace + string.slice(sIndex + find.length);
				sIndex = string.indexOf(find);
			}
			return {string:string, changes:changes};	
		}
		
		// this method is *much* faster than using a regex
		public static function removeComments (string:String):String
		{
			var index:int = string.indexOf("/*");
			while (index > -1)
			{
				var eIndex:int = string.indexOf("*/", index);
				if (eIndex == -1) break;
				string = string.slice(0, index) + string.slice(eIndex + 2);
				index = string.indexOf("/*");
			}
			
			index = string.indexOf("<!--");
			while (index > -1)
			{
				eIndex = string.indexOf("-->", index);
				if (eIndex == -1) break;
				string = string.slice(0, index) + string.slice(eIndex + 3);
				index = string.indexOf("<!--");
			}
			
			index = string.indexOf("//");
			while (index > -1)
			{
				eIndex = string.indexOf("\n", index);
				if (eIndex == -1) string.indexOf("\r", index);
				if (eIndex == -1) break;
				string = string.slice(0, index) + string.slice(eIndex);
				index = string.indexOf("//");
			}
			
			return string;
		}
		
		public static function isVowel (letter:String, includeY:Boolean = false):Boolean
		{
			switch (letter.toLowerCase())
			{
				case "y":		return includeY;
				case "a":
				case "e":
				case "i":
				case "o":
				case "u":		return true;
			}
			
			return false;
		}
		
		public static function isConsonant (letter:String, includeY:Boolean = true):Boolean
		{
			switch (letter.toLowerCase())
			{
				case "y":		return includeY;
				case "b":
				case "c":
				case "d":
				case "f":
				case "g":
				case "h":
				case "j":
				case "k":
				case "l":
				case "m":
				case "n":
				case "p":
				case "q":
				case "r":
				case "s":
				case "t":
				case "v":
				case "w":
				case "x":
				case "z":		return true;
			}
			
			return false;
		}
		
		public static function isPunctuation (letter:String):Boolean
		{
			switch (letter)
			{
				case ",":
				case ".":
				case ":":
				case ";":
				case "!":
				case "?":		return true;
			}
			
			return false;
		}
		
		public static function camelCase (string:String, separators:Vector.<String>, camelCaseFirstLetter:Boolean = false, forceLowerCase:Boolean = true):String
		{
			if (forceLowerCase) string = string.toLowerCase();
			
			if (!separators || separators.length == 0) separators = new <String>[" ", "_"];
			var words:Array = splitMultiple(string, separators);
			
			var returnString:String = camelCaseFirstLetter ? "" : words.shift();
			
			for each (var word:String in words)
			{
				returnString += word.substr(0, 1).toUpperCase() + word.substr(1);
			}
			
			return returnString;
		}
		
		public static function capitalise (word:String, forceLowerCase:Boolean = true):String
		{
			return word.substr(0, 1).toUpperCase() + (forceLowerCase ? word.substr(1).toLowerCase() : word.substr(1));
		}
		
		public static function splitMultiple (string:String, separators:Vector.<String>):Array
		{
			if (!separators || separators.length == 0) return string.split("");
			var i:int = 0; 
			var len:int = separators.length - 1;
			while (i < len)
			{
				string = string.split(separators[i++]).join(separators[i]);
			}
			
			return string.split(separators[len]);
		}
		
		public static function endsWith(string:String, char:String):Boolean
		{
			return string.lastIndexOf(char) == string.length - char.length;
		}
		
		public static function startsWith(string:String, char:String):Boolean
		{
			return string.indexOf(char) == 0;
		}
		
		public static function isNumeric (string:String):Boolean
		{
			return !isNaN(Number(string));	
		}
		
		/**
		 * converts any string into a numerically valid string
		 * if the decimal places param is passed, it will crop the value to that number, otherwise all places will be used
		 * if there is a period in the string, but no decimal places, then trailing zeroes will be added
		 * strips any non number characters
		 * returns "0" (or "0.0" etc.) if the string cannot be made valid
		 * @param string
		 * @param decimalPlaces
		 * @return 
		 * 
		 */		
		public static function convertToValidNumberString (string:String, decimalPlaces:int = -1):String
		{
			var decimals:String = "00000000000000000000";
			if (!string || string == "")
			{
				if (decimalPlaces > -1) return "0" + decimals.slice(0, decimalPlaces);
				else return "0";
			}
			
			string = string.split(",").join("");
			var comps:Array = string.split(".");
			var validComps:Array = [];
			for each (var comp:String in comps)
			{
				var pointer:int = 0;
				var validComp:String = "";
				if (comp == "") comp = "0";
				while (pointer < comp.length)
				{
					var char:String = comp.charAt(pointer);
					if (!isNaN(Number(char))) validComp += char;
					pointer++;
				}
				if (validComp != "" && !isNaN(Number(validComp))) validComps[validComps.length] = validComp;
				if (validComps.length == 2) break;
			}
			
			var stringValue:String;
			if (validComps.length == 0)
			{
				if (decimalPlaces > -1) return "0" + decimals.slice(0, decimalPlaces);
				else return "0";
			}
			else if (validComps.length == 1 || decimalPlaces == 0) stringValue = validComps[0];
			else
			{
				if (decimalPlaces == -1) stringValue = validComps[0] + "." + validComps[1];
				else stringValue = validComps[0] + "." + validComps[1].slice(0, decimalPlaces);
			}
			
			
			if (!isNaN(Number(stringValue))) return stringValue;
			else
			{
				if (decimalPlaces > -1) return "0" + decimals.slice(0, decimalPlaces);
				else return "0";
			}
		}
		
		public static function mapToString (map:Dictionary):String
		{
			var string:String = "{";
			
			for (var key:* in map)
			{
				var mapString:String;
				if (map[key] is Dictionary) mapString = mapToString(map[key]);
				else if (map[key] is Array) mapString = arrayToString(map[key]);
				else mapString = map[key];
				string += key + ":" + mapString + ", ";
			}
			
			return string.slice(0, string.length - 2) + "}";
		}
		
		public static function arrayToString (list:Array):String
		{
			var string:String = "[";
			
			var len:int = list.length;
			for (var i:int = 0; i < len; i++)
			{
				var item:* = list[i];
				string += item.toString() + ", ";
			}
			
			return string.slice(0, string.length - 2) + "]";
		}
		
		// ok, so it's not unique, but it's pretty close
		public static function getUniqueId ():String
		{
			var date:Date = new Date();
			return String(date.time) + String( int(Math.random() * 10000) );
		}
	}
}