package view.component
{
	import flash.display.Sprite;
	
	import core.Config;
	import core.data.ViewBase;
	import core.data.ViewConfig;


	public class CRender extends CDisplayContainer
	{
		private var container : Sprite;

		public function CRender(data : ViewConfig)
		{
			container = new Sprite();
			super(container);
			createUi(data);
		}

		public function createUi(data : ViewConfig) : void
		{
			if (data == null)
				return;
			while (container.numChildren > 0)
				container.removeChildAt(0);
			var len : int = data.comList.length;
			var viewData : ViewBase;
			var child : CSprite;
			for (var i : int = 0; i < len; i++)
			{
				viewData = data.comList[i];
				child = Config.createComponetByName(viewData.res);
				child.data = viewData;
				container.addChild(child);
				viewData.display = child;
			}
		}
	}
}