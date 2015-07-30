package core.data
{
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;

	import core.Config;

	import view.component.CLayerView;
	import view.component.CSprite;

	public class ViewConfig
	{
		public var width : int;
		public var height : int;
		/**
		 * 类名
		 */
		public var class_name : String = "";
		/**
		 * 继承类名
		 */
		public var extends_name : String = "";

		/**
		 * 文件保地址
		 * @return
		 *
		 */
		public function get url() : String
		{
			return Config.url_project + "\\" + extends_name.split(".").pop().toLocaleLowerCase() + "\\" + class_name + ".ui";
		}
		/**
		 * 需要用到的资源列表
		 */
		public var res_list : Array = [];
		/**
		 * 组件列表
		 */
		private var com_list : Vector.<ViewBase> = new Vector.<ViewBase>();

		public function get comList() : Vector.<ViewBase>
		{
			return com_list;
		}

		/**
		 * 创建组件
		 * @param name
		 * @param display
		 * @param x
		 * @param y
		 *
		 */
		public function create(name : String, display : CSprite, swfName : String, type : String, x : int = 0, y : int = 0, width : int = 0, height : int = 0) : ViewBase
		{
			var com_data : ViewBase = getDataType(type);
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
			com_list.push(com_data);
			return com_data;
		}

		/**
		 * 更新组件信息
		 * @param target
		 * @param data
		 *
		 */
		public function update(target : DisplayObject, data : ViewBase = null) : void
		{
			if (data == null)
				data = getTargetData(target);
			if (data == null)
				return;
			data.updateData();
		}

		/**
		 * 删除组件
		 * @param target
		 * @param data
		 *
		 */
		public function deleteTarget(target : CSprite) : void
		{
			var data : ViewBase = getTargetData(target);
			deleteData(data);
		}

		public function deleteData(data : ViewBase = null) : void
		{
			var index : int = com_list.indexOf(data);
			if (index != -1)
			{
				com_list.splice(index, 1);
				data.dispose();
			}
		}

		/**
		 * 根据组件获得组件数据
		 * @param target
		 * @return
		 *
		 */
		public function getTargetData(target : DisplayObject) : ViewBase
		{
			if (target)
			{
				var len : int = com_list.length;
				var tmp : ViewBase;
				for (var i : int = 0; i < len; i++)
				{
					tmp = com_list[i];
					if (tmp.display == target)
						return tmp;
				}
			}
			return null;
		}

		public function sort() : void
		{
			com_list = com_list.sort(onSort);
			function onSort(a : ViewBase, b : ViewBase) : int
			{
				if (a.layer_index * 10000 + a.index > b.layer_index * 10000 + b.index)
					return 1;
				if (a.layer_index + a.index < b.layer_index * 10000 + b.index)
					return -1;
				return 0;
			}
		}

		public static function parseObject(obj : Object) : ViewBase
		{
			var data : ViewBase = getDataType(obj.type);
			data.parse(obj);
			return data;
		}

		private static function getDataType(type : String) : ViewBase
		{
			var com_data : ViewBase;
			switch (type)
			{
				case "btn":
					com_data = new ButtonData();
					break
				case "img":
					com_data = new ImageData();
					break
				case "mc":
					com_data = new MovieData();
					break
				case "s9":
					com_data = new S9Data();
					break
				case "spr":
					com_data = new SpriteData();
					break
				case "txt":
					com_data = new TextData();
					break;
				case "tab":
					com_data = new TabBarData();
					break;
				case "list":
					com_data = new ListData();
					break;
				case "view":
					com_data = new ViewData();
					break;
				default:
					com_data = new ViewBase();
					break;
			}
			return com_data
		}

		public static function parse(bytes : ByteArray, isRoot : Boolean = false) : ViewConfig
		{
			var len : int, i : int;
			var data : ViewConfig = new ViewConfig();
			data.class_name = bytes.readUTF();
			data.extends_name = bytes.readUTF();
			data.width = bytes.readInt();
			data.height = bytes.readInt();
			len = bytes.readByte();
			data.res_list.length = 0;
			for (i = 0; i < len; i++)
				data.res_list.push(bytes.readUTF());
			len = bytes.readByte();
			data.com_list.length = 0;
			for (i = 0; i < len; i++)
				data.com_list.push(parseObject(bytes.readObject()));
			if (isRoot)
			{
				//创建图层
				CLayerView.getInstance().removeAll();
				if (bytes.bytesAvailable > 0)
					CLayerView.getInstance().parse(bytes.readObject() as Array);
				else
					CLayerView.getInstance().addLayer();
			}
			return data;
		}

		public static function save(data : ViewConfig) : ByteArray
		{
			var len : int, i : int;
			var bytes : ByteArray = new ByteArray();
			bytes.writeUTF(data.class_name);
			bytes.writeUTF(data.extends_name);
			bytes.writeInt(data.width);
			bytes.writeInt(data.height);
			len = data.res_list.length;
			bytes.writeByte(len);
			for (i = 0; i < len; i++)
				bytes.writeUTF(data.res_list[i]);
			len = data.com_list.length;
			for (i = 0; i < len; i++)
				data.com_list[i].updateData();
			data.sort();
			bytes.writeByte(len);
			for (i = 0; i < len; i++)
				bytes.writeObject(data.com_list[i].data);
			bytes.writeObject(CLayerView.getInstance().saveData);
			return bytes;
		}
	}
}