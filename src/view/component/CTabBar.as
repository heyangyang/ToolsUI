package view.component
{
	import flash.display.Sprite;
	import flash.utils.setTimeout;

	import core.Config;
	import core.data.ComponnetTabBar;

	public class CTabBar extends CSprite
	{
		private var container : Sprite = new Sprite();
		private var text : CTextDisplay;
		private var m_width : int;
		private var m_height : int;

		public function CTabBar()
		{
			text = new CTextDisplay();
			super(container);
			container.addChild(text);
			text.fontSize = 20;
			text.text = "TabBar";
		}


		public function updateView() : void
		{
			while (container.numChildren > 1)
				container.removeChildAt(1);
			var tmp_data : ComponnetTabBar = data as ComponnetTabBar;
			if (data == null || tmp_data == null || !tmp_data.labelNames || !tmp_data.normal_res)
				return;

			var list : Array = tmp_data.labelNames;
			var len : int = list.length;
			var btn : CButton;
			text.visible = len == 0;
			for (var i : int = 0; i < len; i++)
			{
				btn = Config.createComponetByName(tmp_data.normal_res) as CButton;
				if (btn == null)
					break;
//				if (m_width > 0)
//					btn.width = m_width;
//				if (m_height > 0)
//					btn.height = m_height;
				m_width = btn.width;
				m_height = btn.height;
				if (tmp_data.align == "col")
					btn.x = (btn.width + tmp_data.gap) * i;
				else
					btn.y = (btn.height + tmp_data.gap) * i;
				btn.text = list[i];
				btn.fontColor = tmp_data.fontColor;
				btn.fontSize = tmp_data.fontSize;
				btn.bold = tmp_data.bold;
				container.addChild(btn);
			}
		}

		override public function set width(value : Number) : void
		{
			m_width = value;
			setTimeout(updateView, 0);
		}

		override public function set height(value : Number) : void
		{
			m_height = value;
			setTimeout(updateView, 0);
		}

		override public function get width() : Number
		{
			return m_width > 0 ? m_width : super.width;
		}

		override public function get height() : Number
		{
			return m_height > 0 ? m_height : super.height;
		}

	}
}