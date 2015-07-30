package core.data
{
	import manager.EventManager;

	public class ImageData extends ViewBase
	{
		public var button : Boolean;

		public function ImageData()
		{
			super();
		}

		override public function updateView() : void
		{
			super.updateView();
			if (button)
			{
				type = "btn";
				EventManager.dispatch(EventManager.CHANGE_COMPONENT, this);
			}
		}
	}
}