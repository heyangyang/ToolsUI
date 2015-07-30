package core
{
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	import mx.controls.Alert;

	import spark.components.WindowedApplication;

	import core.data.ViewConfig;

	import manager.EventManager;
	import manager.LocalShareManager;

	import utils.FilesUtil;

	import view.component.CButton;
	import view.component.CList;
	import view.component.CSprite;
	import view.component.CTabBar;
	import view.component.CTextDisplay;
	import view.component.CView;

	public class Config
	{
		public static var stage : Stage;
		public static var layer : WindowedApplication;
		public static var appDomain : ApplicationDomain;
		public static var name : String;
		public static var _url_project : String;
		public static var res_url : String;
		/**
		 * 当前界面数据
		 */
		public static var view : ViewConfig = new ViewConfig();

		private static var xml : XML;

		public static function getOtrXmlByType(type_ : String) : XML
		{
			return Config.xml.com.(@type == type_)[0];
		}

		public static function getXmlByType(type : String) : XMLList
		{
			return Config.xml[type];
		}

		/**
		 * 项目目录地址
		 */
		public static function get url_project() : String
		{
			return _url_project;
		}

		/**
		 * @private
		 */
		public static function set url_project(value : String) : void
		{
			var file : File = new File(value);
			if (!file.exists)
			{
				Alert.show("没有找到可用项目");
				return;
			}
			var list : Array = file.getDirectoryListing();
			var len : int = list.length;
			var tmp_file : File;
			for (var i : int = 0; i < len; i++)
			{
				tmp_file = list[i];

				if (tmp_file.name.indexOf(".uiproject") > 0)
				{
					var bytes : ByteArray = FilesUtil.getBytesFromeFile(tmp_file.nativePath, true);
					name = bytes.readUTF();
					bytes.readUTF();
					res_url = bytes.readUTF() + "\\";
					_url_project = value;
					LocalShareManager.getInstance().save("project_url", value)
					dispatch(EventManager.SHOW_VIEW_TREE);
					return;
				}
			}
			Alert.show("没有找到可用项目");
		}

		public static function init() : void
		{
			xml = new XML(FilesUtil.getBytesFromeFile(File.applicationDirectory.resolvePath("config.xml").nativePath));
			Config.url_project = LocalShareManager.getInstance().get("project_url");
			stage.frameRate = 30;
			EventManager.getInstance();
			MenuController.getInstance();
		}

		/**
		 * 根据类名创建出对象
		 * @param name
		 * @return
		 *
		 */
		public static function createComponetByName(res_name : String) : CSprite
		{
			var child : CSprite;
			try
			{
				if (res_name == "TextField")
					child = new CTextDisplay();
				else if (res_name == "TabBar")
					child = new CTabBar();
				else if (res_name == "List")
					child = new CList();
				else if (res_name == "View")
					child = new CView();
				else
				{
					var class_res : Class = Config.appDomain.getDefinition(res_name) as Class;
					child = new CSprite(new class_res());
				}

				if (res_name.indexOf("btn_") >= 0 || res_name.indexOf("img_") >= 0)
				{
					var btn : CButton = new CButton(child);
					return btn;
				}
			}
			catch (e : Error)
			{
				Config.alert("丢失资源:" + res_name);
				trace(e);
				child = new CTextDisplay();
				child.isLostRes = true;
			}
			return child;
		}

		private static var _alert : Alert;

		public static function alert(msg : String, isError : Boolean = false) : void
		{
			_alert = Alert.show(msg, isError ? "出错" : "提示");
		}

		private static function dispatch(evt : String, obj : Object = null) : void
		{
			EventManager.getInstance().dispatch(evt, obj);
		}

		public static function saveProject() : void
		{
			var byte : ByteArray = new ByteArray();
			byte.writeUTF(name);
			byte.writeUTF(_url_project);
			byte.writeUTF(res_url);
			FilesUtil.saveToFile(_url_project + "\\" + name + ".uiproject", byte, true, true);
		}
	}
}