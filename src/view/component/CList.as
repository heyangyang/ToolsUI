package view.component
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	import core.Config;
	import manager.EventManager;
	import core.data.ComponnetList;
	import core.data.SUiObject;

	import utils.CLoader;
	import utils.FilesUtil;

	public class CList extends CSprite
	{
		private var container : Sprite = new Sprite();
		private var text : CTextDisplay;
		private var m_mask : Shape;

		public function CList()
		{
			text = new CTextDisplay();
			super(container);
			container.addChild(text);
			text.fontSize = 20;
			text.text = "List";
			m_mask = new Shape();
		}

		public function updateView() : void
		{
			var mList : CSprite = this;
			while (container.numChildren > 2)
				container.removeChildAt(2);
			var listData : ComponnetList = ComponnetList(data);
			var dataXml : XML = listData.dataXml;
			var nativePath : String = Config.projectUrl + "\\" + dataXml.field.(@name == "render")[0].@typeValue + "\\" + listData.render;
			var file : File = new File(nativePath);
			var loadIndex : int = 0;

			if (file.exists && listData.render != "")
			{
				var viewConfig : SUiObject = SUiObject.parseByteArray(FilesUtil.getBytesFromeFile(nativePath, true));
				var loadCount : int = viewConfig.resourceList.length;

				for (var i : int = 0; i < loadCount; i++)
				{
					new CLoader(Config.projectResourceUrl + viewConfig.resourceList[i], complement, viewConfig);
				}
			}

			function complement(bytes : ByteArray, viewConfig : SUiObject) : void
			{
				if (++loadIndex < loadCount)
					return;
				var render : CRender = new CRender(viewConfig);
				var rows : int = Math.floor((listData.height + listData.vGap) / (render.height + listData.vGap));
				var cols : int = Math.floor((listData.width + listData.hGap) / (render.width + listData.hGap));
				rows = Math.max(rows, 1);
				cols = Math.max(cols, 1);
				text.visible = false;

				for (var row : int = 0; row < rows; row++)
				{
					for (var col : int = 0; col < cols; col++)
					{
						render = new CRender(viewConfig);
						render.x = (render.width + listData.hGap) * col;
						render.y = (render.height + listData.vGap) * row;
						container.addChild(render);
					}
				}
				if (container.numChildren == 2 || data.width < render.width || data.height < render.height)
				{
					data.width = render.width;
					data.height = render.height;
					updateMask();
					dispatch(EventManager.UPDATE_FIELD, Vector.<CSprite>([mList]));
				}
				transformTool.draw();
			}
		}

		override public function set width(value : Number) : void
		{
			data.width = value;
			updateMask();
		}

		override public function set height(value : Number) : void
		{
			data.height = value;
			updateMask();
		}

		override public function get width() : Number
		{
			return data ? data.width : super.width;
		}

		override public function get height() : Number
		{
			return data ? data.height : super.height;
		}

		private function updateMask() : void
		{
			m_mask.graphics.clear();
			m_mask.graphics.beginFill(0);
			m_mask.graphics.drawRect(0, 0, data.width, data.height);
			m_mask.graphics.endFill();
			container.addChildAt(m_mask, 0);
			container.mask = m_mask;
		}

	}
}