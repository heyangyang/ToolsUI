package core.data
{
	import view.component.CView;

	public class SViewData extends SViewBase
	{
		public var view : String;

		public function SViewData()
		{
			super();
		}

		/**
		 * 转换成生成数据
		 * @return
		 *
		 */
		override public function get data() : Object
		{
			var tmp : Object = super.data;
			tmp.view = view;
			return tmp;
		}

		/**
		 * 解析数据
		 * @param obj
		 *
		 */
		override public function parse(obj : Object) : void
		{
			super.parse(obj);
			view = obj.view;
		}

		override public function updateView() : void
		{
			super.updateView();
			CView(display).updateView();
		}

//		override public function getAsCode(code_util : CodeUtils) : String
//		{
//			var oldName : String = name;
//			var code : String = "";
//			var nativePath : String = Config.url_project + "\\" + dataXml.field.(@name == "view")[0].@typeValue + "\\" + view;
//			var viewConfig : ViewConfig = ViewConfig.parse(FilesUtil.getBytesFromeFile(nativePath, true));
//			paserBaseXml(type);
//			clss_name = viewConfig.class_name;
//			package_name = package_name + "." + String(viewConfig.extends_name.split(".").pop()).toLocaleLowerCase() + "." + clss_name;
//			//生成变量名，和导入的名字,如果没有名字，则用类名小写代替
//			getVarCode(code_util);
//			code += name + "=new " + viewConfig.class_name + "()" + END;
//			code += addChild();
//			name = oldName;
//			return code;
//		}
	}
}