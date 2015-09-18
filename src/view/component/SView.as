package view.component
{
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;

	public class SView extends SLayer
	{
		private var mLayers : Vector.<SLayer>;
		private var mNumChildren : int;
		private var mCurLayer : SLayer;

		public function SView()
		{
			mLayers = new Vector.<SLayer>();
			addLayer();
			selectLayerIndex = 0;
		}

		public function set selectLayer(value : SLayer) : void
		{
			selectLayerIndex = mLayers.indexOf(value);
		}

		public function set selectLayerIndex(value : int) : void
		{
			mCurLayer = mLayers[value];
		}

		public override function get numChildren() : int
		{
			return mNumChildren;
		}

		public function addLayer(name : String = null) : SLayer
		{
			mNumChildren++;
			if (name == null)
				name = "图层" + mNumChildren;
			var tLayer : SLayer = new SLayer();
			tLayer.name = name;
			tLayer.setParent(this);
			mLayers.push(tLayer);
			addChild(tLayer);
			return tLayer;
		}

		public function removeLayer(layer : SLayer) : void
		{
			var index : int = mLayers.indexOf(layer);
			if (index == -1)
				return;
			var tLayer : SLayer = mLayers.splice(index, 1)[0];
			tLayer.setParent(null);
			removeChild(tLayer);
			mNumChildren--;
		}

		public function get curLayer() : SLayer
		{
			return mCurLayer;
		}

		public override function toByteArray() : ByteArray
		{
			var bytes : ByteArray = new ByteArray();
			bytes.writeInt(mNumChildren);
			for (var i : int = 0; i < mNumChildren; i++)
				bytes.writeObject(mLayers[i].toByteArray());
			return bytes;
		}

		public override function parserByteArray(bytes : ByteArray) : void
		{
			var len : int = bytes.readInt();
			for (var i : int = 0; i < len; i++)
			{
				if (mLayers[i] == null)
					addLayer();
				mLayers[i].parserByteArray(bytes.readObject());
			}
		}

		public override function loadResourceComplete() : void
		{
			for each (var child : SLayer in mLayers)
			{
				child.loadResourceComplete();
			}
		}

		public override function hitTestRectangle(rect : DisplayObject, list : Vector.<SDisplay>) : void
		{
			for each (var child : SLayer in mLayers)
			{
				child.hitTestRectangle(rect, list);
			}
		}

		public function getLayers() : Vector.<SLayer>
		{
			return mLayers;
		}

		public override function removeFromParent() : void
		{
			if (!parent)
				return;
			parent.removeChild(this);
		}
	}
}