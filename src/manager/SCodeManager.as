package manager
{
	import flash.utils.Dictionary;

	import core.Config;

	import view.component.SView;


	public class SCodeManager
	{

		public static function getAsCode(tView : SView) : String
		{
			var code : SCodeManager = new SCodeManager(tView);
			return code.getCode();
		}
		private var mSpaceDictionary : Dictionary = new Dictionary();
		private const CODE_END : String = ";\n";
		private const ENTER : String = "\n";
		private var mView : SView;
		private var mPublicVariableCode : String = "";
		private var mPartVariableCode : String = "";
		private var mImportPackageCode : String = "";

		public function SCodeManager(tView : SView)
		{
			this.mView = tView;
		}

		private function getCode() : String
		{
			//项目不同，以后需要修改
			mImportPackageCode += "import " + mView.extendsName + CODE_END;
			var code : String = "";
			var tmp_view_code : String = getViewCode();
			code += "package " + Config.getXmlByType("package")[0].@pkgName + "." + mView.packageName + ENTER;
			code += "{" + ENTER;
			code += getSpace(1) + mImportPackageCode.split(CODE_END).join(CODE_END + getSpace(1)) + ENTER;
			code += getSpace(1) + "public class " + mView.className + (" extends " + mView.extendsName.split(".").pop()) + ENTER;
			code += getSpace(1) + "{" + ENTER;
			code += getSpace(2) + mPublicVariableCode.split(CODE_END).join(CODE_END + getSpace(2)) + ENTER;
			code += getSpace(2) + "public function " + mView.className + "()" + ENTER;
			code += getSpace(2) + "{" + ENTER;
			code += getSpace(3) + "super()" + ENTER;
			code += getSpace(2) + "}" + ENTER;
			code += tmp_view_code + ENTER;
			code += getSpace(1) + "}" + ENTER;
			code += "}" + ENTER;
			return code;
		}

		/**
		 * 界面代码
		 * @return
		 *
		 */
		private function getViewCode() : String
		{
			var space_num : int = 2;
			var code : String = "";
			code += ENTER;
			code += getSpace(space_num) + "override protected function init() : void" + ENTER;
			code += getSpace(space_num) + "{" + ENTER;
			//优先解析出代码
			var content : String = mView.getAsCode(this);
			//局部函数声明
			code += getSpace(space_num) + mPartVariableCode.split(CODE_END).join(CODE_END + getSpace(space_num));
			code += ENTER;
			code += content;
			space_num = 2
			code += getSpace(space_num) + "}" + ENTER;
			return code;
		}

		/**
		 * 获取空格的数量
		 * @param num
		 * @return
		 *
		 */
		private function getSpace(num : int) : String
		{
			if (mSpaceDictionary[num])
				return mSpaceDictionary[num];
			var str : String = "";
			for (var i : int = 0; i < num; i++)
				str += "	";
			mSpaceDictionary[num] = str;
			return str;
		}

		/**
		 * 公共变量
		 */
		public function addPublicVariable(name : String, type : String) : void
		{
			if (mPublicVariableCode.indexOf(name) != -1)
				return;
			mPublicVariableCode += getSpace(2) + "public var " + name + " : " + type + CODE_END;
		}

		/**
		 * 局部变量
		 */
		public function addPartVariable(name : String, type : String) : void
		{
			if (mPartVariableCode.indexOf(name) != -1)
				return;
			mPartVariableCode += getSpace(2) + "var " + name + " : " + type + CODE_END;
		}

		/**
		 * 需要导入的类
		 */
		public function importPackage(name : String) : void
		{
			if (mImportPackageCode.indexOf(name) != -1)
				return;
			mImportPackageCode += getSpace(1) + "import  " + name + CODE_END;
		}
	}
}