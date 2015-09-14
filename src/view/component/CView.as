package view.component
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	import core.Config;
	import core.data.SUiObject;
	import core.data.SViewData;

	import utils.CLoader;
	import utils.FilesUtil;

	public class CView extends CDisplayContainer
	{
		private var text : CTextDisplay;
		private var render : CRender;
		private var container : Sprite;

		public function CView()
		{
			container = new Sprite();
			text = new CTextDisplay();
			render = new CRender(null);
			super(container);
			container.addChild(render);
			container.addChild(text);
			text.fontSize = 20;
			text.text = "View";
		}

		public function updateView() : void
		{
			if (data == null)
				return;
			var viewData : SViewData = SViewData(data);
			var dataXml : XML = viewData.dataXml;
			var nativePath : String = Config.projectUrl + "\\" + dataXml.field.(@name == "view")[0].@typeValue + "\\" + viewData.view;
			var file : File = new File(nativePath);
			var loadIndex : int = 0;

			if (file.exists && viewData.view != "")
			{
				var viewConfig : SUiObject = SUiObject.parseByteArray(FilesUtil.getBytesFromeFile(nativePath, true));
				var loadCount : int = viewConfig.resourceList.length;

				for (var i : int = 0; i < loadCount; i++)
				{
					new CLoader(Config.projectResourceUrl + viewConfig.resourceList[i], complement, viewConfig);
				}
			}
			else
			{
				container.addChild(text);
			}

			function complement(bytes : ByteArray, viewConfig : SUiObject) : void
			{
				if (++loadIndex < loadCount)
					return;
				render.createUi(viewConfig);
				text.parent && text.parent.removeChild(text);
			}
		}

		override public function get width() : Number
		{
			return render.width == 0 ? 100 : render.width;
		}

		override public function get height() : Number
		{
			return render.height == 0 ? 100 : render.height;
		}
	}
}