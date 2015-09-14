package core.data
{
	import flash.display.Sprite;
	
	import core.Config;
	
	import view.component.CSprite;

	public class SLayerData
	{
		private var _index : int;
		private var _visible : Boolean;
		public var lock : Boolean;
		public var name : String = "";
		public var layer : Sprite;

		public function set index(value : int) : void
		{
			_index = value;
		}

		public function get index() : int
		{
			return layer && layer.parent ? layer.parent.getChildIndex(layer) : _index;
		}

		public function get visible() : Boolean
		{
			return _visible;
		}

		public function set visible(value : Boolean) : void
		{
			_visible = value;
			layer.visible = value;
		}

//		public function addChild(child : CSprite) : void
//		{
//			layer.addChild(child);
//		}

		public function addChildAt(child : CSprite, index : int) : void
		{
			layer.addChildAt(child, index);
		}

		public function parse(data : Object) : void
		{
			visible = data.visible;
			lock = data.lock;
			name = data.name;
		}

		public function get saveData() : Object
		{
			var data : Object = {};
			data.index = index;
			data.visible = visible;
			data.lock = lock;
			data.name = name;
			return data;
		}

		public function updateIndex() : void
		{
			var child : CSprite;
			for (var i : int = 0; i < layer.numChildren; i++)
			{
				child = layer.getChildAt(i) as CSprite;
				child.data.layer_index = index;
			}
		}

		public function dispose() : void
		{
			for (var i : int = 0; i < layer.numChildren; i++)
			{
				Config.current.deleteTarget(layer.getChildAt(i) as CSprite);
			}
			layer && layer.parent && layer.parent.removeChild(layer);
		}
	}
}