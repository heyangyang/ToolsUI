package core.data
{
	import manager.EventManager;

	public class ComponnetImage extends SViewBase
	{
		public var button : Boolean;

		public function ComponnetImage()
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