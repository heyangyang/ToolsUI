package view.component
{
	import flash.display.Sprite;
	import flash.utils.setTimeout;

	import core.data.SLayerData;
	import core.data.SViewBase;

	import manager.EventManager;

	/**
	 * 图层管理
	 * @author Administrator
	 *
	 */
	public class SLayerView extends Sprite
	{
		private var tab_index : int = 0;
		public var list_layer : Array = [];
		public var cur_layer : SLayerData;

		public function SLayerView()
		{
			super();
		}

		/**
		 * 当前图层的原件数量
		 * @return
		 *
		 */
		public function get comNumChildren() : int
		{
			if (cur_layer == null)
				return 0;
			return cur_layer.layer.numChildren;
		}

		/**
		 * 添加原件到图层
		 * @param child
		 *
		 */
		public function addComponent(child : CSprite, layer_index : int = -1) : void
		{
			if (cur_layer == null)
				return;
			var tmp_layer : SLayerData;
			if (layer_index == -1)
				tmp_layer = cur_layer;
			else
				tmp_layer = getLayerByIndex(layer_index);
			addComponentAt(child, tmp_layer.layer.numChildren, layer_index);
		}

		public function addComponentAt(child : CSprite, index : int, layer_index : int = -1) : void
		{
			if (cur_layer == null)
				return;
			if (child.data == null)
				child.data = new SViewBase();
			var tmp_layer : SLayerData;
			if (layer_index == -1)
				tmp_layer = cur_layer;
			else
				tmp_layer = getLayerByIndex(layer_index);
			tmp_layer.addChildAt(child, index);
			child.data.layer_index = tmp_layer.index;
			notifyUpdate();
		}

		/**
		 * 根据图层获得索引
		 * @param child
		 * @return
		 *
		 */
		public function getComponentIndex(child : CSprite) : int
		{
			if (cur_layer == null)
				return -1;
			return cur_layer.layer.getChildIndex(child);
		}

		/**
		 * 根据索引，获得图层
		 * @param index
		 * @return
		 *
		 */
		public function getLayerByIndex(index : int) : SLayerData
		{
//			if (index >= list_layer.length)
//				return list_layer[list_layer.length - 1];
			return list_layer[index];
		}

		/**
		 * 添加图层
		 * @param name
		 * @return
		 *
		 */
		public function addLayer(name : String = null) : SLayerData
		{
			var layer : SLayerData = new SLayerData();
			layer.name = name == null ? "图层 " + list_layer.length : name;
			layer.layer = new Sprite();
			layer.visible = true;
			addChild(layer.layer);
			list_layer.push(layer);
			notifyUpdate();
			return layer;
		}

		/**
		 * 移除图层
		 * @param layer
		 *
		 */
		public function removeLayer(layer : SLayerData = null) : void
		{
			if (layer == null)
				layer = cur_layer;
			var index : int = list_layer.indexOf(layer);
			if (index != -1 && list_layer.length > 1)
			{
				list_layer.splice(index, 1);
				layer.dispose();
				selectIndex = list_layer.length - 1;
				notifyUpdate();
			}
			updateLayerIndex();
		}

		public function updateLayerIndex() : void
		{
			var layer : SLayerData;
			var len : int = list_layer.length;
			for (var i : int = 0; i < len; i++)
			{
				layer = list_layer[i];
				layer.updateIndex();
			}
		}

		public function set selectItem(value : SLayerData) : void
		{
			selectIndex = list_layer.indexOf(value);
		}
 
		public function set selectIndex(value : int) : void
		{
			if (value < 0)
				return;
			if (value >= list_layer.length)
				value = list_layer.length - 1;
			cur_layer = list_layer[value];
			notifyUpdate();
		}

		/**
		 * 清理所有图层
		 *
		 */
		public function removeAll() : void
		{
			list_layer.length = 0;
			while (numChildren > 0)
				removeChildAt(0);
			notifyUpdate();
		}

		/**
		 * 获得所有图层原件列表
		 * @return
		 *
		 */
		public function getComList() : Array
		{
			var len : int = list_layer.length;
			var return_list : Array = [];
			var layer : SLayerData;
			for (var i : int = 0; i < len; i++)
			{
				layer = list_layer[i];
				if (layer.lock || !layer.visible)
					continue;
				for (var j : int = 0; j < layer.layer.numChildren; j++)
				{
					return_list.push(layer.layer.getChildAt(j));
				}
			}
			return return_list;
		}

		public function getTabComponent() : CSprite
		{
			var tmp_list : Array = getComList();
			if (tab_index >= tmp_list.length)
				tab_index = 0;
			return tmp_list[tab_index++];
		}

		public function parse(list : Array) : void
		{
			var len : int = list.length;
			var layer : SLayerData;
			for (var i : int = 0; i < len; i++)
			{
				layer = addLayer();
				layer.parse(list[i]);
			}
			notifyUpdate();
		}

		public function get saveData() : Object
		{
			var list : Array = [];
			var layer : SLayerData;
			var len : int = list_layer.length;
			for (var i : int = 0; i < len; i++)
			{
				layer = list_layer[i];
				list.push(layer.saveData);
			}
			return list;
		}

		public function notifyUpdate() : void
		{
			setTimeout(EventManager.dispatch, 0, EventManager.UPDATE_LAYER);
		}

		private static var instance : SLayerView;

		public static function getInstance() : SLayerView
		{
			if (instance == null)
				instance = new SLayerView();
			return instance;
		}
	}
}