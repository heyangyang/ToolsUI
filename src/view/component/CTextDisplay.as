package view.component
{
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class CTextDisplay extends CSprite
	{
		private var native_txt : TextField;
		private var textFormat : TextFormat;
		private var m_text : String;
		private var _border : Boolean;

		public function CTextDisplay()
		{
			native_txt = new TextField();
			_border = true;
			native_txt.mouseEnabled = false;
			native_txt.multiline = true;
			native_txt.selectable = false;
			native_txt.wordWrap = true;
			native_txt.border = true;
			native_txt.borderColor = 0x00ffff;
			native_txt.width = 80;
			native_txt.height = 30;
			native_txt.antiAliasType = AntiAliasType.ADVANCED;
//			native_txt.filters = [new GlowFilter(0xffffff, 1, 2, 2)];
			textFormat = new TextFormat("Microsoft YaHei", 12, 0xffffff, false, false, false, null, null, TextFormatAlign.CENTER);
			textFormat.kerning = true;
			super(native_txt);
		}

		public function get text() : String
		{
			return m_text
		}

		public function set text(value : String) : void
		{
			if (value == null)
				value = "";
			m_text = value;
			native_txt.text = value;
			native_txt.border = _border ? value == "" : _border;
			autoSize();
		}

		public function set bold(value : Object) : void
		{
			textFormat.bold = value;
			autoSize();
		}

		public function set border(value : Object) : void
		{
			_border = value;
			native_txt.border = value;
		}

		public function set fontColor(value : Object) : void
		{
			textFormat.color = value;
			autoSize();
		}

		public function set fontSize(value : Object) : void
		{
			textFormat.size = value;
			autoSize();
		}

		public function set align(value : String) : void
		{
			textFormat.align = value;
			autoSize();
		}

		private function autoSize() : void
		{
			native_txt.defaultTextFormat = textFormat;
			native_txt.text = m_text ? m_text : "";
//			var tmp_width : int = native_txt.textWidth + int(textFormat.size) * 0.8;
			var tmp_height : int = native_txt.textHeight + int(textFormat.size) * 0.3;
//			native_txt.width = tmp_width > 80 ? tmp_width : 80;
			native_txt.height = tmp_height > 30 ? tmp_height : 30;
//			width = native_txt.width;
			height = native_txt.height;
		}
	}
}