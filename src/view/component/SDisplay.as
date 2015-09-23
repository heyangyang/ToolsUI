package view.component
{
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;

	import core.Config;

	import managers.SCodeManager;

	public class SDisplay extends SDisPlayBase
	{
		public var res : String = "";
		public var swf : String;
		public var type : String;
		public var touchable : Boolean;
		public var isLostRes : Boolean;
		internal var mIndex : int;
		protected var mWidth : int;
		protected var mHeight : int;
		protected var mParent : SLayer;

		public function SDisplay()
		{
			super();
		}


		/**
		 * 根据配置文件生成默认属性
		 *
		 */
		public function parseXml(xml : XML) : void
		{
			paserBaseXml(type, xml);
			var xmlList : XMLList = xml.field;
			for each (var child : XML in xmlList)
			{
				if (this[child.@name] is Boolean)
					this[child.@name] = child.@value == "true";
				else if (this[xml.@name] is Array)
					this[child.@name] = child.@value.toString().split(",");
				else
					this[child.@name] = child.@value;
			}
		}

		/**
		 * 解析xml基础属性
		 * @param tmp_type
		 *
		 */
		protected function paserBaseXml(tmp_type : String, xml : XML) : void
		{
			type = tmp_type;
		}

		public function parserByteArray(bytes : ByteArray) : void
		{
			parseObject(bytes.readObject());
			parseXml(Config.getOtrXmlByType(type));
		}

		public function toByteArray() : ByteArray
		{
			var bytes : ByteArray = new ByteArray();
			bytes.writeObject(toObject());
			return bytes;
		}

		public function toObject() : Object
		{
			var data : Object = {};
			data.x = x;
			data.y = y;
			data.res = res;
			data.swf = swf;
			data.type = type;
			data.visible = visible;
			data.index = mIndex;
			data.name = name;
			data.width = width;
			data.height = height;
			return data;
		}

		public function parseObject(data : Object) : void
		{
			type = data.type;
			res = data.res;
			swf = data.swf;
			x = data.x;
			y = data.y;
			mIndex = data.index;
			visible = data.visible;
			if (data.name)
				name = data.name;
			mWidth = data.width;
			mHeight = data.height;
		}

		/**
		 * 检测碰撞
		 * @param rect
		 * @param list 如果碰撞了，则添加到列表
		 *
		 */
		public function hitTestRectangle(rect : DisplayObject, list : Vector.<SDisplay>) : void
		{
			if (rect.hitTestObject(this))
				list.push(this);
		}

		/**
		 * 资源加载完毕
		 *
		 */
		public function loadResourceComplete() : void
		{
			setDisplay(Config.createDisplayByName(res));
		}

		public function removeFromParent() : void
		{
			if (!mParent)
				return;
			mParent.removeDisplay(this);
			mParent = null;
		}

		public function setParent(value : SLayer) : void
		{
			mParent = value;
		}

		public function getParent() : SLayer
		{
			return mParent;
		}

		public function get index() : int
		{
			return mIndex;
		}

		public function getAsCode(manager : SCodeManager) : String
		{
			var code : String = "";
			var xml : XML = Config.getOtrXmlByType(type);
			var packageName : String = xml.@pkgName;
			var className : String = xml.@classType;
			manager.importPackage(packageName);
			//局部变量
			if (name.indexOf("instance") == 0)
				code += "var " + name + ":" + className + " = new " + className + "()" + SCodeManager.CODE_END;
			//全局变量
			else
			{
				manager.addPublicVariable(name, className);
				code += name + " = new " + className + "()" + SCodeManager.CODE_END;
			}
			code += createXmlCode(Config.getXmlByType("component")[0].field);
			code += createXmlCode(Config.getOtrXmlByType(type).field);
			return code;
		}

		protected function createXmlCode(xmlList : XMLList) : String
		{
			var code : String = "";
			var filedName : String;
			var label : String;
			for each (var xml : XML in xmlList)
			{
				label = xml.@label;
				filedName = xml.@name;
				if (label == "")
					continue;
				if (this[filedName] is Boolean)
					code += addChildField(label, this[filedName]);
				else if (this[filedName] is String && this[filedName].indexOf("0x") == -1)
					code += addChildField(label, "'" + this[filedName] + "'");
				else
					code += addChildField(label, this[filedName]);
			}
			return code;
		}


		override public function get width() : Number
		{
			return mDisplay ? mDisplay.width : mWidth;
		}

		override public function get height() : Number
		{
			return mDisplay ? mDisplay.height : mHeight;
		}

		public function addChildField(field : String, value : *) : String
		{
			return name + "." + field + " = " + value + ";\n";
		}
	}
}