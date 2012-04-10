package simpleasnlg.morphology.english
{
	import com.steamshift.utils.StringUtils;

	/**
	 * This class is used to parse numbers that are passed as figures, to determine
	 * whether they should take "a" or "an" as determiner.
	 * 
	 * @author bertugatt
	 * 
	 */
	public class DeterminerAgrHelper
	{
		/*
		 * An array of strings which are exceptions to the rule that "an" comes
		 * before vowels
		 */
		private static const AN_EXCEPTIONS:Array = ["one", "180", "110"];
	
		/*
		 * Start of string involving vowels, for use of "an"
		 */
		private static const AN_AGREEMENT:String = "^(?i)(e(?!u)|a|i|o|u.(?!a|e|i|o|u))";//"\\A(a|e|i|o|u).*";
	
		/*
		 * Start of string involving numbers, for use of "an" -- courtesy of Chris
		 * Howell, Agfa healthcare corporation
		 */
		// private static final String AN_NUMERAL_AGREEMENT =
		// "^(((8((\\d+)|(\\d+(\\.|,)\\d+))?).*)|((11|18)(\\d{3,}|\\D)).*)$";
	
		/**
		 * Check whether this string starts with a number that needs "an" (e.g.
		 * "an 18% increase")
		 * 
		 * @param string
		 *            the string
		 * @return <code>true</code> if this string starts with 11, 18, or 8,
		 *         excluding strings that start with 180 or 110
		 */
		public static function requiresAn(string:String):Boolean
		{
			var req:Boolean = false;
	
			if (string.match(AN_AGREEMENT) && !isAnException(string))
			{
				req = true;
	
			} else {
				var numPref:String = getNumericPrefix(string);
	
				if (numPref != null && numPref.length > 0
						&& numPref.match("^(8|11|18).*$"))
				{
					var num:int = int(numPref);
					req = checkNum(num);
				}
			}
	
			return req;
		}
	
		/*
		 * check whether a string beginning with a vowel is an exception and doesn't
		 * take "an" (e.g. "a one percent change")
		 * 
		 * @return
		 */
		private static function isAnException(string:String):Boolean
		{
			var len:int = AN_EXCEPTIONS.length;
			for (var i:int = 0; i < len; i++)
			{
				var ex:String = AN_EXCEPTIONS[i];
				if (string.match("^" + ex + ".*"))
				{
					// if (string.equalsIgnoreCase(ex)) {
					return true;
				}
			}
	
			return false;
		}
	
		/*
		 * Returns <code>true</code> if the number starts with 8, 11 or 18 and is
		 * either less than 100 or greater than 1000, but excluding 180,000 etc.
		 */
		private static function checkNum(num:int):Boolean
		{
			var needsAn:Boolean = false;
	
			// eight, eleven, eighty and eighteen
			if (num == 11 || num == 18 || num == 8 || (num >= 80 && num < 90))
			{
				needsAn = true;
	
			} else if (num > 1000) {
				num = Math.round(num / 1000);
				needsAn = checkNum(num);
			}
	
			return needsAn;
		}
	
		/*
		 * Retrieve the numeral prefix of a string.
		 */
		private static function getNumericPrefix(string:String):String 
		{
			var numeric:String = "";
	
			if (string != null)
			{
				//string = string.trim();
	
				if (string.length > 0)
				{
					var buffer:String = string;
					var first:String = buffer.charAt(0);
	
					if (StringUtils.isNumeric(first))
					{
						numeric += first;
	
						for (var i:int = 1; i < buffer.length; i++)
						{
							var next:String = buffer.charAt(i);
	
							if (StringUtils.isNumeric(next))
							{
								numeric += next;
	
								// skip commas within numbers
							}
							else if (next == ',')
							{
								continue;
							} else {
								break;
							}
						}
					}
				}
			}
	
			return numeric.length == 0 ? null : numeric;
		}
	}
}
