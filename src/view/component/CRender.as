package view.component
{
	import flash.display.Sprite;
	
	import core.Config;
	import core.data.SViewBase;
	import core.data.SUiObject;


	public class CRender extends CDisplayContainer
	{
		private var container : Sprite;

		public function CRender(data : SUiObject)
		{
			container = new Sprite();
			super(container);
			createUi(data);
		}

		public function createUi(data : SUiObject) : void
		{
			if (data == null)
				return;
			while (container.numChildren > 0)
				container.removeChildAt(0);
			var len : int = data.viewList.length;
			var viewData : SViewBase;
			var child : CSprite;
			for (var i : int = 0; i < len; i++)
			{
				viewData = data.viewList[i];
				child = Config.createComponetByName(viewData.res);
				child.data = viewData;
				container.addChild(child);
				viewData.display = child;
			}
		}
	}
}