package core.data
{
	import manager.SEventManager;

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
				SEventManager.dispatch(SEventManager.CHANGE_COMPONENT, this);
			}
		}
	}
}