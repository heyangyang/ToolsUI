package manager
{
	import view.component.SDisplay;
	import view.component.SLayer;

	public class SelectedManager
	{
		public static const DOWN : String = "下";
		public static const UP : String = "上";
		public static const LEFT : String = "左";
		public static const RIGHT : String = "右";
		private static var sList : Vector.<SDisplay> = new Vector.<SDisplay>();
		private static var sNumChildren : int;
		private static var mTmpTarget : SDisplay;

		public static function setTmpTarget(child : SDisplay) : void
		{
			mTmpTarget = child;
		}

		public static function get tmpTarget() : SDisplay
		{
			return mTmpTarget;
		}

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
			if (mTmpTarget)
			{
				mTmpTarget.x += addX;
				mTmpTarget.y += addY;
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

		/**
		 * 排序对齐
		 * @param type
		 *
		 */
		public static function sortOn(type : String) : void
		{
			switch (type)
			{
				case DOWN:
					componentSort("y", true, "height");
					break;
				case UP:
					componentSort("y", false);
					break;
				case LEFT:
					componentSort("x", false);
					break;
				case RIGHT:
					componentSort("x", true, "width");
					break;
				default:
					return;
					break;
			}

			function componentSort(field : String, isMax : Boolean, other : String = "") : void
			{
				var len : int, i : int;
				var value : int = isMax ? int.MIN_VALUE : int.MAX_VALUE;
				var display : SDisplay;
				len = list.length;
				for (i = 0; i < len; i++)
				{
					display = list[i];
					if (isMax && display[field] + display[other] > value)
						value = display[field] + display[other];
					else if (!isMax && display[field] < value)
						value = display[field];
				}

				for (i = 0; i < len; i++)
				{
					display = list[i];
					display[field] = isMax ? value - display[other] : value;
				}
			}
		}

		public static function set gapX(value : int) : void
		{
			componentGap("x", value);
		}

		public static function set gapY(value : int) : void
		{
			componentGap("y", value);
		}

		/**
		 * 组件之间的间隔
		 * @param field
		 * @param gap
		 *
		 */
		private static function componentGap(field : String, gap : int) : void
		{
			var len : int = list.length;
			if (len == 0)
				return;
			list.sort(sort);

			function sort(a : SDisplay, b : SDisplay) : int
			{
				if (a[field] > b[field])
					return 1;
				if (a[field] < b[field])
					return -1;
				return 0;
			}
			var display : SDisplay;
			var value : int = list[0][field];
			for (var i : int = 0; i < len; i++)
			{
				display = list[i];
				display[field] = value;
				value += (field == "x" ? display.width : display.height) + gap;
			}
		}

		public static function get list() : Vector.<SDisplay>
		{
			return sList;
		}

	}
}