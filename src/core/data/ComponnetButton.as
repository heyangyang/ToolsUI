package core.data
{
	import view.component.CButton;

	public class ComponnetButton extends SViewBase
	{
		public var text : String = "";
		public var fontColor : String;
		public var fontSize : int;
		public var bold : Boolean;

		public function ComponnetButton()
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
			tmp.bold = bold;
			tmp.touchable = true;
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
			bold = obj.bold;
			touchable = true;
		}

		override public function updateView() : void
		{
			super.updateView();
			var btn : CButton = display as CButton;
			if (btn == null)
				return;
			btn.text = text;
			btn.fontSize = fontSize;
			btn.fontColor = fontColor;
			btn.bold = bold;
			touchable = true;
		}

	}
}