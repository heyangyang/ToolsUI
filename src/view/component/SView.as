package view.component
{
	import flash.display.DisplayObject;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import core.Config;
	
	import manager.SCodeManager;

	public class SView extends SLayer
	{
		public var className : String;
		public var extendsName : String;
		public var packageName : String;
		private var mWidth : int;
		private var mHeight : int;
		private var mResourceList : Array;

		private var mLayers : Vector.<SLayer>;
		private var mNumChildren : int;
		private var mCurLayer : SLayer;

		public function SView()
		{
			mLayers = new Vector.<SLayer>();
			addLayer();
			selectLayerIndex = 0;
		}

		public function setResource(... args) : void
		{
			if (args.length == 1 && args[0] is Array)
				mResourceList = args[0];
			else
				mResourceList = args;
		}

		/**
		 * ui所用到的资源
		 * @return
		 *
		 */
		public function getResource() : Array
		{
			return mResourceList;
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
			var len : int, i : int;
			var bytes : ByteArray = new ByteArray();
			bytes.writeUTF(className);
			bytes.writeUTF(extendsName);
			bytes.writeUTF(packageName);
			bytes.writeInt(width);
			bytes.writeInt(height);
			len = mResourceList ? mResourceList.length : 0;
			bytes.writeByte(len);
			for (i = 0; i < len; i++)
				bytes.writeUTF(mResourceList[i]);
			var data : ByteArray = new ByteArray();
			data.writeInt(mNumChildren);
			for (i = 0; i < mNumChildren; i++)
				data.writeObject(mLayers[i].toByteArray());
			bytes.writeObject(data);
			return bytes;
		}

		public override function parserByteArray(bytes : ByteArray) : void
		{
			var len : int, i : int;
			className = bytes.readUTF();
			extendsName = bytes.readUTF();
			packageName = bytes.readUTF();
			width = bytes.readInt();
			height = bytes.readInt();
			len = bytes.readByte();
			var resourceList : Array = [];
			for (i = 0; i < len; i++)
				resourceList.push(bytes.readUTF());
			setResource(resourceList);
			bytes = bytes.readObject();
			len = bytes.readInt();
			for (i = 0; i < len; i++)
			{
				if (i >= mNumChildren)
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

		/**
		 * 检测碰撞
		 * @param rect
		 * @param list 如果碰撞了，则添加到列表
		 *
		 */
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

		/**
		 * 所有图层的原件。
		 * @return
		 *
		 */
		public override function getChilds() : Vector.<SDisplay>
		{
			var childs : Vector.<SDisplay> = new Vector.<SDisplay>();
			var child : SDisplay;
			for each (var layer : SLayer in mLayers)
			{
				for each (child in layer.getChilds())
				{
					childs.push(child);
				}
			}
			return childs;
		}

		public override function removeFromParent() : void
		{
			if (!parent)
				return;
			parent.removeChild(this);
		}

		override public function set width(value : Number) : void
		{
			mWidth = value;
		}

		override public function set height(value : Number) : void
		{
			mHeight = value;
		}

		override public function get width() : Number
		{
			return mWidth;
		}

		override public function get height() : Number
		{
			return mHeight;
		}

		public override function getAsCode(manager : SCodeManager) : String
		{
			var code : String = "";
			for each (var child : SLayer in mLayers)
			{
				code += child.getAsCode(manager);
			}
			return code;
		}
		/**
		 * 地址
		 * @return
		 *
		 */
		public function get nativeUrl() : String
		{
			return Config.projectUrl + File.separator + packageName + File.separator + className + Config.VIEW_EXTENSION;
		}
	}
}