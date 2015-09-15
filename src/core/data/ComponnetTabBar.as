package core.data
{
	import manager.SEventManager;
	
	import view.component.CTabBar;

	public class ComponnetTabBar extends SViewBase
	{
		public var normal_res : String;
		public var select_res : String;
		public var labelNames : Array = [];
		public var gap : int;
		public var align : String;
		public var fontColor : String;
		public var fontSize : int;
		public var bold : Boolean;
		
		public function ComponnetTabBar()
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
			tmp.normal_res = normal_res;
			tmp.select_res = select_res;
			tmp.labelNames = labelNames;
			tmp.gap = gap;
			tmp.align = align;
			tmp.fontSize = fontSize;
			tmp.fontColor = fontColor;
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
			normal_res = obj.normal_res;
			select_res = obj.select_res;
			labelNames = obj.labelNames;
			gap = obj.gap;
			align = obj.align;
			fontSize = obj.fontSize;
			fontColor = obj.fontColor;
			bold = obj.bold;
		}

		override public function updateView() : void
		{
			super.updateView();
			if (normal_res && normal_res.indexOf("img_") == -1)
			{
//				Config.alert("TabBar_normal必须是图片");
				normal_res = "";
			}

			if (select_res && select_res.indexOf("img_") == -1)
			{
//				Config.alert("TabBar_select必须是图片");
				select_res = "";
			}
			try
			{
//				var xml : Object = SEventManager.getInstance().all_xml.node.(@id == "img")[0].node.(@label == normal_res)[0];
//				swf = xml.@swf;
			}
			catch (e : Error)
			{
//				Config.alert("找不到该资源");
			}

			CTabBar(display).updateView();
		}
	}
}