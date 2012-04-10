package simpleasnlg.framework
{
	import flash.utils.Dictionary;
	
	import simpleasnlg.features.Inflection;

	public class InflectionSet 
	{
		// the infl type
		//@SuppressWarnings("unused")
		public var infl:Inflection;
		
		// the forms, mapping values of LexicalFeature to actual word forms
		public var forms:Dictionary;
		
		public function InflectionSet(infl:Inflection)
		{
			this.infl = infl;
			this.forms = new Dictionary();
		}
		
		/*
		* set an inflectional form
		* 
		* @param feature
		* 
		* @param form
		*/
		public function addForm(feature:String, form:String):void
		{
			this.forms.push(feature, form);
		}
		
		/*
		* get an inflectional form
		*/
		public function getForm(featureName:String):String
		{
			return this.forms[featureName];
		}
	}
}