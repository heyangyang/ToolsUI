package view.component
{
	import flash.display.DisplayObject;

	public class CButton extends CSprite
	{
		private var m_text : CTextDisplay;
		private var disObj : DisplayObject;

		public function CButton(disObj : DisplayObject)
		{
			m_text = new CTextDisplay();
			m_text.border = false;
			m_text.visible = false;
			m_text.width = disObj.width;
			this.disObj = disObj;
			super(disObj);
			addChild(m_text);
			addChildAt(disObj, 0);
		}

		override public function set target(value : Boolean) : void
		{
			super.target = value;
			addChild(m_text);
		}

		public function set text(value : String) : void
		{
			if (value == null)
				value = "";
			m_text.visible = true;
			m_text.text = value;
			autoSize();
		}

		public function set fontColor(value : Object) : void
		{
			m_text.fontColor = value;
			autoSize();
		}

		public function set bold(value : Object) : void
		{
			m_text.bold = value;
			autoSize();
		}

		public function set fontSize(value : Object) : void
		{
			m_text.fontSize = value;
			autoSize();
		}

		private function autoSize() : void
		{
			m_text.x = (disObj.width - m_text.width) * .5;
			m_text.y = (disObj.height - m_text.height) * .5;
		}

	}
}