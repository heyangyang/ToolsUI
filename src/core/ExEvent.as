package core
{
	import flash.events.Event;

	public class ExEvent extends Event
	{
		public var data : Object;

		public function ExEvent(type : String, data : Object = null, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}

		override public function clone() : Event
		{
			return new ExEvent(type, data, bubbles, cancelable);
		}
	}
}