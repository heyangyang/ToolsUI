package core.data
{
	import flash.display.DisplayObject;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	import core.Config;

	import view.component.CSprite;

	public class SUiObject
	{
		private static function parseViewData(data : Object) : SViewBase
		{
			var child : SViewBase = getViewByType(data.type);
			child.parse(data);
			return child;
		}

		/**
		 * 根据类型获得数据
		 * @param type
		 * @return
		 *
		 */
		private static function getViewByType(type : String) : SViewBase
		{
			var com_data : SViewBase;
			switch (type)
			{
				case "btn":
					com_data = new ComponnetButton();
					break
				case "img":
					com_data = new ComponnetImage();
					break
				case "spr":
					com_data = new ComponnetSprite();
					break
				case "txt":
					com_data = new ComponnetText();
					break;
				case "tab":
					com_data = new ComponnetTabBar();
					break;
				case "list":
					com_data = new ComponnetList();
					break;
				case "view":
					com_data = new SViewData();
					break;
				default:
					com_data = new SViewBase();
					break;
			}
			return com_data
		}

		/**
		 * 解析ui
		 * @param bytes
		 * @return
		 *
		 */
		public static function parseByteArray(bytes : ByteArray) : SUiObject
		{
			var data : SUiObject = new SUiObject();
			data.parseUiData(bytes);
			return data;
		}

		/**
		 * 把对象转换成ByteArray
		 * @param data
		 * @return
		 *
		 */
		public static function toByteArray(data : SUiObject) : ByteArray
		{
			var len : int, i : int;
			var bytes : ByteArray = new ByteArray();
			bytes.writeUTF(data.className);
			bytes.writeUTF(data.extendsName);
			bytes.writeUTF(data.packageName);
			bytes.writeInt(data.width);
			bytes.writeInt(data.height);
			len = data.resourceList.length;
			bytes.writeByte(len);
			for (i = 0; i < len; i++)
				bytes.writeUTF(data.resourceList[i]);
			len = data.mViewList.length;
			data.refreshUiData();
			data.sortLayer();
			bytes.writeByte(len);
			for (i = 0; i < len; i++)
				bytes.writeObject(data.mViewList[i].data);
			bytes.writeObject(data.mLayerData);
			return bytes;
		}

		private var mWidth : int;
		private var mHeight : int;
		private var mClassName : String = "";
		private var mExtendsName : String = "";
		private var mPackageName : String = "";
		private var mResourceList : Array = [];
		private var mViewList : Vector.<SViewBase> = new Vector.<SViewBase>();
		private var mLayerData : Array;


		/**
		 * 创建组件
		 * @param name
		 * @param display
		 * @param x
		 * @param y
		 *
		 */
		public function create(name : String, display : CSprite, swfName : String, type : String, x : int = 0, y : int = 0, width : int = 0, height : int = 0) : SViewBase
		{
			var com_data : SViewBase = getViewByType(type);
			com_data.type = type;
			com_data.parseXml();
			com_data.swf = swfName;
			com_data.x = x;
			com_data.y = y;
			com_data.width = width > 0 ? width : display.width;
			com_data.height = height > 0 ? height : display.height;
			com_data.rotation = 0;
			com_data.scaleX = 1;
			com_data.scaleY = 1;
			com_data.res = name;
			display.data = com_data;
			com_data.display = display;
			mViewList.push(com_data);
			return com_data;
		}

		/**
		 * 更新组件信息
		 * @param target
		 * @param data
		 *
		 */
		public function update(target : DisplayObject, data : SViewBase = null) : void
		{
			if (data == null)
				data = getTargetData(target);
			if (data == null)
				return;
			data.refresh();
		}

		/**
		 * 删除组件
		 * @param target
		 * @param data
		 *
		 */
		public function deleteTarget(target : CSprite) : void
		{
			var data : SViewBase = getTargetData(target);
			deleteData(data);
		}

		public function deleteData(data : SViewBase = null) : void
		{
			var index : int = mViewList.indexOf(data);
			if (index != -1)
			{
				mViewList.splice(index, 1);
				data.dispose();
			}
		}

		/**
		 * 根据组件获得组件数据
		 * @param target
		 * @return
		 *
		 */
		public function getTargetData(target : DisplayObject) : SViewBase
		{
			if (target)
			{
				var len : int = mViewList.length;
				var tmp : SViewBase;
				for (var i : int = 0; i < len; i++)
				{
					tmp = mViewList[i];
					if (tmp.display == target)
						return tmp;
				}
			}
			return null;
		}

		/**
		 * 刷新ui数据
		 *
		 */
		public function refreshUiData() : void
		{
			var len : int = mViewList.length;
			for (var i : int = 0; i < len; i++)
				mViewList[i].refresh();
		}

		/**
		 * 根据层级排序
		 *
		 */
		public function sortLayer() : void
		{
			mViewList = mViewList.sort(onSort);
			function onSort(a : SViewBase, b : SViewBase) : int
			{
				if (a.layer_index * 10000 + a.index > b.layer_index * 10000 + b.index)
					return 1;
				if (a.layer_index * 10000 + a.index < b.layer_index * 10000 + b.index)
					return -1;
				return 0;
			}
		}

		public function parseUiData(bytes : ByteArray) : void
		{
			var len : int, i : int;
			className = bytes.readUTF();
			extendsName = bytes.readUTF();
			packageName = bytes.readUTF();
			width = bytes.readInt();
			height = bytes.readInt();
			len = bytes.readByte();
			resourceList.length = 0;
			for (i = 0; i < len; i++)
				resourceList.push(bytes.readUTF());
			len = bytes.readByte();
			mViewList.length = 0;
			for (i = 0; i < len; i++)
				mViewList.push(parseViewData(bytes.readObject()));
			if (bytes.bytesAvailable > 0)
				mLayerData = bytes.readObject() as Array;
		}

		/**
		 * 文件地址
		 * @return
		 *
		 */
		public function get nativeUrl() : String
		{
			if (packageName)
				return Config.projectUrl + packageName + File.separator + className + Config.VIEW_EXTENSION;
			else
				return Config.projectUrl + className + Config.VIEW_EXTENSION;
		}

		public function clone(data : SUiObject) : void
		{
			mWidth = data.width;
			mHeight = data.height;
			mClassName = data.className;
			mExtendsName = data.extendsName;
			mPackageName = data.packageName;
			mResourceList = data.resourceList;
			mViewList = data.mViewList;
			mLayerData = data.mLayerData;
		}

		public function get viewList() : Vector.<SViewBase>
		{
			return mViewList;
		}

		public function get width() : int
		{
			return mWidth;
		}

		public function set width(value : int) : void
		{
			mWidth = value;
		}

		public function get height() : int
		{
			return mHeight;
		}

		public function set height(value : int) : void
		{
			mHeight = value;
		}

		/**
		 * 类名
		 */
		public function get className() : String
		{
			return mClassName;
		}

		/**
		 * @private
		 */
		public function set className(value : String) : void
		{
			mClassName = value;
		}

		/**
		 * 继承类名
		 */
		public function get extendsName() : String
		{
			return mExtendsName;
		}

		/**
		 * @private
		 */
		public function set extendsName(value : String) : void
		{
			mExtendsName = value;
		}

		/**
		 * 包名
		 */
		public function get packageName() : String
		{
			return mPackageName;
		}

		/**
		 * @private
		 */
		public function set packageName(value : String) : void
		{
			mPackageName = value;
		}

		/**
		 * 需要用到的资源列表
		 */
		public function get resourceList() : Array
		{
			return mResourceList;
		}

		/**
		 * 图层数据
		 */
		public function get LayerData() : Array
		{
			return mLayerData;
		}


	}
}