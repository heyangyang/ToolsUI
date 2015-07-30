package manager
{
	import core.Config;
	import core.data.LayerData;
	import core.data.ViewBase;

	import view.component.CLayerView;
	import view.component.CSprite;

	/**
	 * 元件管理器
	 * @author Administrator
	 *
	 */
	public class ComponentManager
	{
		public static const DOWN : int = 0;
		public static const UP : int = 1;
		public static const LEFT : int = 2;
		public static const RIGHT : int = 3;
		private static var instance : ComponentManager;

		public static function Ins() : ComponentManager
		{
			if (instance == null)
				instance = new ComponentManager();
			return instance;
		}

		public var list : Vector.<CSprite> = new Vector.<CSprite>();
		private var copy_list : Vector.<CSprite> = new Vector.<CSprite>();
		private var cut_list : Vector.<CSprite> = new Vector.<CSprite>();
		private var copy_count : int;
		public var isChange : Boolean;

		/**
		 * 删除所选组件
		 */
		public function deleteSelect() : void
		{
			//记录历史记录
			addHistory(HistoryManager.CHANGE);
			var len : int = length, i : int;
			for (i = 0; i < len; i++)
				Config.view.deleteTarget(getIndex(i));
			removeAll();
			CLayerView.getInstance().notifyUpdate();
		}

		/**
		 * 选择所有组件
		 */
		public function selectAllComponent() : void
		{
			removeAll();
			var len : int, i : int;
			var display : CSprite, viewDate : ViewBase, layData : LayerData;
			var layer : CLayerView = CLayerView.getInstance();
			len = Config.view.comList.length;
			for (i = 0; i < len; i++)
			{
				viewDate = Config.view.comList[i];
				layData = layer.getLayerByIndex(viewDate.layer_index);
				if (!layData.visible || layData.lock)
					continue;
				push(viewDate.display);
			}
		}

		/**
		 * 剪贴原件
		 *
		 */
		public function cutComponent() : void
		{
			cut_list.length = 0;
			copy_list.length = 0;
			cut_list = cut_list.concat(list);
		}

		/**
		 * 复制
		 *
		 */
		public function copyComponent() : void
		{
			cut_list.length = 0;
			copy_list.length = 0;
			copy_count = 1;
			copy_list = copy_list.concat(list);
		}

		/**
		 * 剪贴
		 *
		 */
		public function pasteComponent(createComponent : Function) : void
		{
			var isCopy : Boolean = copy_list.length > 0;
			var tmp_list : Vector.<CSprite> = copy_list.length > 0 ? copy_list : (cut_list.length > 0 ? cut_list : null);
			if (tmp_list == null)
				return;
			isChange = true;
			removeAll()
			var len : int = tmp_list.length;
			var display : CSprite, viewDate : ViewBase, child : CSprite;
			var layer : CLayerView = CLayerView.getInstance();
			var offsetX : int = tmp_list[0].width * 0.5 * copy_count;
			var offsetY : int = tmp_list[0].height * 0.5 * copy_count;
			for (var i : int = 0; i < len; i++)
			{
				display = tmp_list[i];
				viewDate = display.data;
				child = createComponent(viewDate.res);
				if (child == null)
					continue;
				Config.view.create(viewDate.res, child, viewDate.swf, viewDate.type, 1, 1, 1, 1);
				child.data.parse(viewDate.data);
				child.data.updateView();
				//复制到当前图层上
				layer.addComponent(child);
				if (isCopy)
				{
					child.x += offsetX;
					child.y += offsetY;
				}
				push(child);
			}
			layer.notifyUpdate();
			if (!isCopy)
				cut_list.length = 0;
			copy_count++;
			//记录历史记录
			addHistory(HistoryManager.ADD);
		}

		public function updateLayIndex(index : int) : void
		{
			if (list.length == 0)
				return;
			isChange = true;
			//记录历史记录
			addHistory(HistoryManager.CHANGE);
			var tmp_list : Vector.<CSprite> = new Vector.<CSprite>();
			tmp_list = tmp_list.concat(list);
			tmp_list.sort(sort);
			var len : int = tmp_list.length, comIndex : int;
			var display : CSprite, viewDate : ViewBase, child : CSprite;
			var layer : CLayerView = CLayerView.getInstance();

			for (var i : int = 0; i < len; i++)
			{
				display = tmp_list[i];
				comIndex = layer.getComponentIndex(display) - index;
				if (comIndex < 0)
					comIndex = 0
				if (comIndex > layer.comNumChildren)
					comIndex = layer.comNumChildren;
				layer.addComponentAt(display, index == int.MIN_VALUE ? 0 : (index == int.MAX_VALUE ? layer.comNumChildren : comIndex));
			}

			function sort(a : CSprite, b : CSprite) : int
			{
				if (a.data.layer_index > b.data.layer_index)
					return 1;
				if (a.data.layer_index < b.data.layer_index)
					return -1;
				return 0;
			}
		}

		public function get length() : int
		{
			return list.length;
		}

		public function push(child : CSprite) : void
		{
			var index : int = list.indexOf(child);
			if (index == -1 && child)
			{
				list.push(child);
				isChange = true;
			}
		}

		public function getIndex(index : int) : CSprite
		{
			return list[index];
		}

		/**
		 * 清理已经选中组件
		 */
		public function removeAll() : void
		{
			isChange = true;
			var len : int = list.length;
			var display : CSprite;
			for (var i : int = 0; i < len; i++)
			{
				display = list[i]
				display.target = null;
			}
			list.length = 0;
		}

		/**
		 * 更新所有选择对象的属性值
		 * @param field
		 * @param value
		 *
		 */
		public function updateAllComponent(field : String, value : int) : void
		{
			//记录历史记录
			addHistory(HistoryManager.CHANGE);
			var len : int, i : int;
			len = list.length;

			for (i = 0; i < len; i++)
			{
				list[i][field] += value;
				list[i].data.updateData();
			}
			isChange = true;
		}

		public function selectedTarget(value : Boolean) : void
		{
			var len : int, i : int;
			len = list.length;

			for (i = 0; i < len; i++)
			{
				list[i].target = value;
			}
		}

		/**
		 * 排序对齐
		 * @param type
		 *
		 */
		public function sortOn(type : int) : void
		{
			//记录历史记录
			addHistory(HistoryManager.CHANGE);
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
			}

			function componentSort(field : String, isMax : Boolean, other : String = "") : void
			{
				var len : int, i : int;
				var value : int = isMax ? int.MIN_VALUE : int.MAX_VALUE;
				var display : CSprite;
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
					display.data.updateData();
				}
				isChange = true;
			}
		}

		/**
		 * 组件之间的间隔
		 * @param field
		 * @param gap
		 *
		 */
		public function componentGap(field : String, gap : int) : void
		{
			var len : int, i : int;
			len = list.length;
			if (len == 0)
				return;
			list.sort(sort);

			function sort(a : CSprite, b : CSprite) : int
			{
				if (a[field] > b[field])
					return 1;
				if (a[field] < b[field])
					return -1;
				return 0;
			}
			var display : CSprite;
			var value : int = list[0][field];
			for (i = 0; i < len; i++)
			{
				display = list[i];
				display[field] = value;
				value += (field == "x" ? display.width : display.height) + gap;
				display.data.updateData();
			}
			isChange = true;
		}

		public function addHistory(type : int) : void
		{
			HistoryManager.Ins().addHistoryByList(list, type);
		}
	}
}