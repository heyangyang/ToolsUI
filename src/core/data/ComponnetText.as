package core.data
{
	import view.component.CTextDisplay;

	public class ComponnetText extends SViewBase
	{
		public var text : String = "";
		public var fontSize : int;
		public var fontColor : String = "";
		public var align : String;
		public var bold : Boolean;

		public function ComponnetText()
		{
			super();
		}

		/**
		 * 转换成生成数据
		 * @return
		 *
		 */
		override public function get data() : Object
		{
			var tmp : Object = super.data;
			tmp.text = text;
			tmp.fontSize = fontSize;
			tmp.fontColor = fontColor;
			tmp.align = align;
			tmp.bold = bold;
			return tmp;
		}

		/**
		 * 解析数据
		 * @param obj
		 *
		 */
		override public function parse(obj : Object) : void
		{
			super.parse(obj);
			text = obj.text;
			fontSize = obj.fontSize;
			fontColor = obj.fontColor;
			align = obj.align;
			bold = obj.bold;
		}

		override public function updateView() : void
		{
			super.updateView();
			var txt_dis : CTextDisplay = display as CTextDisplay;
			txt_dis.text = text;
			txt_dis.fontSize = fontSize;
			txt_dis.fontColor = fontColor;
			txt_dis.bold = bold;
			txt_dis.align = align;
		}

	}
}