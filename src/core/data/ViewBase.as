package core.data
{
	import core.CodeUtils;
	import core.Config;

	import view.component.CSprite;
	import view.component.CTextDisplay;

	public class ViewBase extends Object
	{
		private static const BASE_VIEW : String = "btn,s9,img,txt,spr,mc";
		public var index : int = 0;
		public var layer_index : int;
		/**
		 * 包名
		 */
		public var package_name : String;
		/**
		 * 类名
		 */
		public var clss_name : String;
		/**
		 * 函数名
		 */
		public var fun_name : String;
		/**
		 * 函数需要的参数
		 */
		public var fun_params : Array;

		protected var _display : CSprite;
		public var name : String = "";
		public var parent : String = "";
		public var res : String = "";
		public var swf : String;
		public var type : String;

		public var x : int;
		public var y : int;

		public var width : int;
		public var height : int;
		public var touchable : Boolean;

		/**
		 * 暂时没用到
		 */
		public var rotation : Number;
		public var scaleX : Number;
		public var scaleY : Number;

		public function ViewBase()
		{

		}

		/**
		 * 根据配置文件生成默认属性
		 *
		 */
		public function parseXml() : void
		{
			paserBaseXml(type);
			var tmp : XML = Config.getOtrXmlByType(type);
			var xmlList : XMLList = tmp.field;
			for each (var xml : XML in xmlList)
			{
				if (this[xml.@name] is Boolean)
					this[xml.@name] = xml.@value == "true";
				else if (this[xml.@name] is Array)
					this[xml.@name] = xml.@value.toString().split(",");
				else
					this[xml.@name] = xml.@value;
			}
		}

		/**
		 * 解析xml基础属性
		 * @param tmp_type
		 *
		 */
		protected function paserBaseXml(tmp_type : String) : void
		{
			var tmp : XML = Config.getOtrXmlByType(tmp_type);
			type = tmp_type;
			package_name = tmp.@pkgName;
			clss_name = tmp.@classType;
			fun_name = tmp.@fun;
			fun_params = (tmp.@funParams).toString().split(",");
		}

		public function get dataXml() : XML
		{
			return Config.getOtrXmlByType(type);
		}

		public function get display() : CSprite
		{
			return _display;
		}

		public function set display(value : CSprite) : void
		{
			_display = value;
			updateView();
		}

		/**
		 * 转换成生成数据
		 * @return
		 *
		 */
		public function get data() : Object
		{
			var tmp : Object = {};
			tmp.name = name;
			tmp.parent = parent;
			tmp.res = res;
			tmp.swf = swf;
			tmp.type = type;

			tmp.x = x;
			tmp.y = y;

			tmp.width = width;
			tmp.height = height;
			tmp.touchable = touchable.toString();

			tmp.rotation = rotation;
			tmp.scaleX = scaleX;
			tmp.scaleY = scaleY;
			tmp.layer_index = layer_index;
			return tmp;
		}

		/**
		 * 解析数据
		 * @param obj
		 *
		 */
		public function parse(obj : Object) : void
		{
			type = obj.type;
			parseXml();

			name = obj.name;
			parent = obj.parent;
			res = obj.res;
			swf = obj.swf;

			x = obj.x;
			y = obj.y;

			width = obj.width;
			height = obj.height;
			touchable = obj.touchable == "true";

			rotation = obj.rotation;
			scaleX = obj.scaleX;
			scaleY = obj.scaleY;
			layer_index = obj.layer_index;
		}

		public function updateView() : void
		{
			_display.x = x;
			_display.y = y;

			//目前组件不可旋转，不可缩放，强制设为0
			rotation = 0;
			scaleX = scaleY = 1;

			if (rotation != 0)
				_display.rotation = rotation;

			if (scaleX != 0)
				_display.scaleX = scaleX;
			if (scaleY != 0)
				_display.scaleY = scaleY;

			if (width > 0)
				_display.width = width;
			if (height > 0)
				_display.height = height;

			if (_display.isLostRes)
			{
				CTextDisplay(_display).text = "丢失资源 : " + res;
				CTextDisplay(_display).fontSize = 16;
				CTextDisplay(_display).align = "left";
				CTextDisplay(_display).fontColor = "0xff0000";
				_display.width = 160;
			}
		}

		public function updateData() : void
		{
			//目前组件不可旋转，不可缩放，强制设为0
			display.rotation = 0;
			display.scaleX = display.scaleY = 1;

			x = display.x;
			y = display.y;
			width = display.width;
			height = display.height;

			rotation = display.rotation;
			scaleX = display.scaleX;
			scaleY = display.scaleY;

			index = display.parent.getChildIndex(display);
		}

		/**
		 * 获得历史记录数据
		 * @return
		 *
		 */
		public function get historyData() : Object
		{
			var obj : Object = data;
			obj.display = display;
			obj.dis_index = display.parent.getChildIndex(display);
			obj.data = this;
			return obj;
		}

		public function dispose() : void
		{
			_display && _display.parent && _display.parent.removeChild(_display);
		}

		public function getAsCode(code_util : CodeUtils) : String
		{
			var oldName : String = name;
			var code : String = "";
			var otr_code : String = getOtrAsCode(code_util);
			//生成变量名，和导入的名字,如果没有名字，则用类名小写代替
			getVarCode(code_util);
			code += name + "=" + fun_name + "(" + getParseFunctionParams(fun_params) + ") as " + clss_name + END;
			code += createXmlCode(Config.getXmlByType("component")[0].field);
			code += createXmlCode(Config.getOtrXmlByType(type).field);
			code += addChild();
			code += otr_code;
			name = oldName;

			return code;
		}

		/**
		 * 除了基本类型，其他类型的转换
		 * @param code_util
		 * @return
		 *
		 */
		protected function getOtrAsCode(code_util : CodeUtils) : String
		{
			var code : String = "";
			var type_otr : String = "";
			if (name.indexOf("_") >= 0)
				type_otr = name.split("_").shift();
			if (type_otr != "" && BASE_VIEW.indexOf(type_otr) == -1)
			{
				var xml : XML = Config.getOtrXmlByType(type_otr);
				if (xml && String(xml.@isChange) == "true")
				{
					var old_Type : String = type;
					paserBaseXml(type_otr);
					getVarCode(code_util);
					code += name + "=" + fun_name + "(" + getParseFunctionParams(fun_params) + ") as " + clss_name + END;
					code += addChild();
					name = "";
					paserBaseXml(old_Type);
				}
			}
			return code;
		}

		private function getParseFunctionParams(tmp_params : Array) : String
		{
			var code : String = "";
			var filedName : String;
			var len : int = tmp_params.length;
			for (var i : int = 0; i < len; i++)
			{
				filedName = tmp_params[i];
				if (!hasOwnProperty(filedName))
				{
					code += filedName
				}
				else
				{
					if (this[filedName] is Boolean)
						code += this[filedName];
					else if (this[filedName] is Array)
						code += "'" + this[filedName] + "'.split(',')";
					else if (this[filedName] is String && this[filedName].indexOf("0x") == -1)
						code += "'" + filter(this[filedName]) + "'";
					else
						code += this[filedName];
				}
				if (i < len - 1)
					code += ",";
			}
			return code;
		}

		protected function filter(str : *) : String
		{
			if (str is String && str.indexOf(".ui") >= 0)
				str = str.replace(".ui", "");
			return str;
		}

		protected function createXmlCode(xmlList : XMLList) : String
		{
			var code : String = "";
			var filedName : String;
			var label : String;
			for each (var xml : XML in xmlList)
			{
				if (xml.@label.toString() == "")
					continue;
				filedName = xml.@name;
				label = xml.@label;
				if (this[filedName] is Boolean)
					code += addField(label, this[filedName]);
				else if (this[filedName] is String && this[filedName].indexOf("0x") == -1)
					code += addField(label, "'" + this[filedName] + "'");
				else
					code += addField(label, this[filedName]);
			}
			return code;
		}

		protected function addChild() : String
		{
			return (parent == "" ? "mPanel" : parent) + ".addChild(" + name + ")" + END;
		}

		protected function addField(field : String, value : *) : String
		{
			return name + "." + field + "=" + value + END;
		}

		protected function get code_public() : String
		{
			return "public var " + name + ":" + clss_name + END;
		}

		protected function get code_var() : String
		{
			return "var " + name + ":" + clss_name + END;
		}

		protected function get code_import() : String
		{
			if (package_name.indexOf(",") == -1)
				return "import " + package_name + END;
			var tmpList : Array = package_name.split(",");
			var str : String = "";
			var len : int = tmpList.length;
			for (var i : int = 0; i < len; i++)
			{
				str += "import " + tmpList[i] + END;
			}
			return str;
		}

		protected function getVarCode(code_util : CodeUtils) : void
		{
			if (name == "")
			{
				name = clss_name.toLocaleLowerCase();
				if (code_util.code_var.indexOf(code_var) == -1)
					code_util.code_var += code_var;
			}
			else
			{
				if (code_util.code_public_var.indexOf(code_public) == -1)
					code_util.code_public_var += code_public;
			}
			if (code_util.code_import.indexOf(code_import) == -1)
				code_util.code_import += code_import;
		}

		protected function get END() : String
		{
			return ";\n";
		}
	}
}