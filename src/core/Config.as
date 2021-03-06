package core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

	import mx.controls.Alert;

	import spark.components.WindowedApplication;

	import managers.LocalShareManager;
	import managers.SEventManager;

	import utils.FilesUtil;

	import view.component.SView;

	public class Config
	{
		/**
		 * 项目后缀
		 */
		public static const PROJECT_EXTENSION : String = ".uiproject";
		/**
		 * ui后缀
		 */
		public static const VIEW_EXTENSION : String = ".ui";

		public static const OTHER : String = "other";
		private static var sStage : Stage;
		public static var layer : WindowedApplication;
		public static var appDomain : ApplicationDomain;
		private static var sProjectName : String;
		private static var sProjectUrl : String;
		private static var sProjectResourceUrl : String;
		private static var sProjectCodeUrl : String;
		/**
		 * 当前界面数据
		 */
		private static var sCurrent : SView;

		public static function get current() : SView
		{
			return sCurrent;
		}

		/**
		 * 设置当前ui
		 * @param data
		 *
		 */
		public static function setCurrentUI(data : SView) : void
		{
			sCurrent = data;
			SEventManager.dispatch(SEventManager.SHOW_VIEW, sCurrent);
			SEventManager.dispatch(SEventManager.UPDATE_VIEW, sCurrent);
		}

		private static var sRootXml : XML;
		private static var sAlert : Alert;

		/**
		 * 初始化配置文件
		 *
		 */
		public static function init(stage : Stage) : void
		{
			sStage = stage;
			sStage.addEventListener(Event.RESIZE, onResizeHandler);
			sStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
			var configFile : File = File.applicationDirectory.resolvePath("config.xml");
			if (!configFile.exists)
			{
				alert("配置文件config.xml丢失!");
				return;
			}
			sRootXml = new XML(FilesUtil.getBytesFromeFile(configFile.nativePath));
			updateProject(LocalShareManager.get(LocalShareManager.PROJECT));
		}

		private static function onKeyUpHandler(evt : KeyboardEvent) : void
		{
			if (evt.keyCode == Keyboard.ESCAPE)
				dispatch(SEventManager.EXIT_WINODW);
		}

		private static function onResizeHandler(evt : Event) : void
		{
			dispatch(Event.RESIZE);
		}

		public static function getOtrXmlByType(type_ : String) : XML
		{
			return Config.sRootXml.com.(@type == type_)[0];
		}

		public static function getXmlByType(type : String) : XMLList
		{
			return Config.sRootXml[type];
		}


		public static function updateProject(value : String) : void
		{
			var rootFile : File = new File(value);
			if (value == null || !rootFile.exists)
			{
				alert("没有找到可用项目");
				return;
			}
			var list : Array = rootFile.getDirectoryListing();
			var bytes : ByteArray;
			for each (var tFile : File in list)
			{
				if (PROJECT_EXTENSION.substring(1) != tFile.extension)
					continue;
				//读取文件
				bytes = FilesUtil.getBytesFromeFile(tFile.nativePath, true);
				//获取名字
				sProjectName = bytes.readUTF();
				//获取项目地址
				sProjectUrl = bytes.readUTF();
				//获取资源路径
				sProjectResourceUrl = bytes.readUTF();
				//获取保存地址
				sProjectCodeUrl = bytes.readUTF();
				//保存项目地址
				LocalShareManager.save(LocalShareManager.PROJECT, sProjectUrl);
				//派发显示事件					
				dispatch(SEventManager.SHOW_VIEW_TREE);
				return;
			}
			alert("没有找到可用项目");
		}

		/**
		 * 根据类名创建出对象
		 * @param name
		 * @return
		 *
		 */
		public static function createDisplayByName(name : String) : Sprite
		{
			var child : Sprite;
			try
			{
				var class_res : Class = Config.appDomain.getDefinition(name) as Class;
				child = new Sprite();
				var data : * = new class_res();
				if (data is BitmapData)
					data = new Bitmap(data);
				child.addChild(data);
				child.name = name;
			}
			catch (e : Error)
			{
				child.name = "";
				Config.alert("丢失资源:" + name);
			}
			return child;
		}

		public static function alert(... args) : void
		{
			sAlert = Alert.show(args.join(""), "提示");
		}

		public static function error(... args) : void
		{
			sAlert = Alert.show(args.join(""), "出错");
		}

		private static function dispatch(evt : String, obj : Object = null) : void
		{
			SEventManager.dispatch(evt, obj);
		}

		public static function saveProjectData(projectName : String, projectUrl : String, projectResourceUrl : String, projectCodeUrl : String) : void
		{
			sProjectName = projectName + PROJECT_EXTENSION;
			sProjectUrl = projectUrl + File.separator;
			sProjectResourceUrl = projectResourceUrl + File.separator;
			sProjectCodeUrl = projectCodeUrl + File.separator;
			var byte : ByteArray = new ByteArray();
			byte.writeUTF(sProjectName);
			byte.writeUTF(sProjectUrl);
			byte.writeUTF(sProjectResourceUrl);
			byte.writeUTF(sProjectCodeUrl);
			FilesUtil.saveToFile(sProjectUrl + sProjectName, byte, true, true);
			LocalShareManager.save(LocalShareManager.PROJECT, sProjectUrl);
		}

		/**
		 * 舞台
		 * @return
		 *
		 */
		public static function get stage() : Stage
		{
			return sStage;
		}

		/**
		 * 项目名称
		 * @return
		 *
		 */
		public static function get projectName() : String
		{
			return sProjectName;
		}

		/**
		 * 项目目录地址
		 */
		public static function get projectUrl() : String
		{
			return sProjectUrl;
		}

		/**
		 * 项目资源目录
		 * @return
		 *
		 */
		public static function get projectResourceUrl() : String
		{
			return sProjectResourceUrl;
		}

		public static function get projectCodeUrl() : String
		{
			return sProjectCodeUrl;
		}
	}
}