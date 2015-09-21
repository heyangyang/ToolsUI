package manager
{
	import view.component.SDisplay;
	import view.component.SLayer;

	public class SelectedManager
	{
		private static var sList : Vector.<SDisplay> = new Vector.<SDisplay>();
		private static var sNumChildren : int;

		public static function push(child : SDisplay) : void
		{
			if (!child)
				return;
			if (sList.indexOf(child) != -1)
				return;
			sList.push(child);
			child.selected = true;
			sList.sort(onSort);
			sNumChildren++;
		}

		private static function onSort(a : SDisplay, b : SDisplay) : int
		{
			if (a.index > b.index)
				return 1;
			if (a.index < b.index)
				return -1;
			return 0;
		}

		public static function getChildAt(index : int) : SDisplay
		{
			return sList[index];
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

		public static function setChlidIndex(type : int) : void
		{
			var layer : SLayer;
			var index : int;
			for each (var child : SDisplay in list)
			{
				layer = child.getParent();
				index = child.index + type;
				if (index >= layer.numChildren)
					index = layer.numChildren - 1;
				if (index < 0)
					index = 0;
				layer.setDisplayIndex(child, index);
			}
		}

		public static function checkChlidIndex(type : int) : Boolean
		{
			var layer : SLayer;
			var index : int;
			var tag : Boolean = false;
			for each (var child : SDisplay in list)
			{
				layer = child.getParent();
				index = child.index + type;
				if (index >= layer.numChildren)
					index = layer.numChildren - 1;
				if (index < 0)
					index = 0;
				if (child.index != index)
					tag = true;
			}
			tag && sList.sort(onSort);
			return tag;
		}

		public static function get list() : Vector.<SDisplay>
		{
			return sList;
		}

	}
}