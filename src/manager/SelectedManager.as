package manager
{
	import view.component.SDisplay;

	public class SelectedManager
	{
		private static var sList : Vector.<SDisplay> = new Vector.<SDisplay>();
		private static var sNumChildren : int;

		public static function push(child : SDisplay) : void
		{
			if (sList.indexOf(child) != -1)
				return;
			sList.push(child);
			child.selected = true;
			sNumChildren++;
		}

		public static function clear() : void
		{
			for each (var child : SDisplay in sList)
			{
				child.selected = false;
			}
			sList.length = 0;
			sNumChildren = 0;
		}

		/**
		 * 移除
		 *
		 */
		public static function removeAll() : void
		{
			for each (var child : SDisplay in sList)
			{
				child.removeFromParent();
			}
			clear();
		}

		public static function move(addX : int, addY : int) : void
		{
			for each (var child : SDisplay in sList)
			{
				child.x += addX;
				child.y += addY;
			}
		}

		public static function setList(list : Vector.<SDisplay>) : void
		{
			for each (var child : SDisplay in list)
			{
				push(child);
			}
		}

		public static function get numChildren() : int
		{
			return sNumChildren;
		}

		public static function get list() : Vector.<SDisplay>
		{
			return sList;
		}
	}
}