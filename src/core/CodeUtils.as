package core
{
	import core.data.ComponnetSprite;
	import core.data.SUiObject;

	public class CodeUtils
	{
		private var config_view : SUiObject;
		public var code_public_var : String = "";
		public var code_var : String = "";
		public var code_import : String = "";

		public function CodeUtils(config : SUiObject)
		{
			this.config_view = config;
		}

		/**
		 * 获得代码
		 * @return
		 *
		 */
		public static function getAsCode(config : SUiObject) : String
		{
			var code_utils : CodeUtils = new CodeUtils(config);
			return code_utils.asCode;
		}

		public function get asCode() : String
		{
			//项目不同，以后需要修改
			code_import += "import " + config_view.extendsName + END;
			//项目不同，以后需要修改
			var tmp : ComponnetSprite = new ComponnetSprite();
			tmp.type = "spr";
			tmp.parseXml();
			tmp.getAsCode(this);
			//-----------------
			var code : String = "";
			var tmp_view_code : String = viewCode;
			code += "package " + Config.getXmlByType("package")[0].@pkgName + "." + String(config_view.extendsName.split(".").pop()).toLocaleLowerCase() + enter;
			code += "{" + enter;
			code += getSpace(1) + code_import.split(END).join(END + getSpace(1)) + enter;
			code += getSpace(1) + "public class " + config_view.className + (" extends " + config_view.extendsName.split(".").pop()) + enter;
			code += getSpace(1) + "{" + enter;
			code += getSpace(2) + code_public_var.split(END).join(END + getSpace(2)) + enter;
			code += getSpace(2) + "public function " + config_view.className + "()" + enter;
			code += getSpace(2) + "{" + enter;
			//项目不同，以后需要修改
			code += superRes();
			code += getSpace(2) + "}" + enter;
			code += tmp_view_code + enter;
			code += getSpace(1) + "}" + enter;
			code += "}" + enter;
			return code;
		}

		private function superRes() : String
		{
			var str : String = "";
			var len : int = config_view.resourceList.length;
			for (var i : int = 0; i < len; i++)
			{
				if (config_view.resourceList[i].indexOf("main") == -1)
				{
					str = config_view.resourceList[i];
					str = str.split(".").shift();
					break;
				}
			}
			if (str != "")
				str = getSpace(3) + "super('" + str + "')" + END;
			return str;
		}

		/**
		 * 界面代码
		 * @return
		 *
		 */
		private function get viewCode() : String
		{
			var space_num : int = 2;
			var code : String = "";
			code += enter;
			code += getSpace(space_num) + "override protected function createView() : void" + enter;
			code += getSpace(space_num) + "{" + enter;
			//暂时用到，以后需要修改
			code += getSpace(space_num) + "if (!isInit){" + enter;
			space_num = 3;
			//暂时用到，以后需要修改
			code += getSpace(space_num) + "mPanel = new SwfSprite();" + enter;
			//暂时用到，以后需要修改
			code += getSpace(space_num) + "addChild(mPanel);" + enter;
			//优先解析出代码
			var len : int = config_view.viewList.length;
			var content : String = "";
			for (var i : int = 0; i < len; i++)
			{
				content += getSpace(space_num) + config_view.viewList[i].getAsCode(this).split(END).join(END + getSpace(space_num)) + enter;
			}
			//局部函数声明
			code += getSpace(space_num) + code_var.split(END).join(END + getSpace(space_num));
			code += enter;
			code += content;
			space_num = 2
			//暂时用到，以后需要修改
			code += getSpace(space_num) + "}" + enter;
			code += getSpace(space_num) + "super.createView();" + enter;
			code += getSpace(space_num) + "}" + enter;
			return code;
		}

		private function get END() : String
		{
			return ";\n";
		}

		private function get enter() : String
		{
			return "\n";
		}

		private function getSpace(num : int) : String
		{
			var str : String = "";
			for (var i : int = 0; i < num; i++)
				str += "	";
			return str;
		}
	}
}