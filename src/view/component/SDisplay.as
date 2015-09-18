package view.component
{
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	
	import core.Config;

	public class SDisplay extends SDisPlayBase
	{
		public var res : String = "";
		public var swf : String;
		public var type : String;
		public var touchable : Boolean;
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
			parseObject( bytes.readObject());
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
			return data;
		}

		public function parseObject(data : Object) : void
		{
			type = data.type;
			res = data.res;
			swf = data.swf;
			x = data.x;
			y = data.y;
			visible = data.visible;
		}

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
	}
}