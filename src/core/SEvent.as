package core
{
	import flash.events.Event;

	public class SEvent extends Event
	{
		public var data : Object;

		public function SEvent(type : String, data : Object = null, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}

		override public function clone() : Event
		{
			return new SEvent(type, data, bubbles, cancelable);
		}
	}
}