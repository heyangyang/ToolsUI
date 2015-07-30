package manager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	
	import core.CodeUtils;
	import core.Config;
	import core.ExEvent;
	import core.data.ViewConfig;
	
	import utils.CLoader;
	import utils.FilesUtil;
	import utils.GetSwfAllClass;
	
	import view.CreateProjectWindow;
	import view.CreateViewWindow;
	import view.SettingWindow;
	import view.component.CLoading;

	public class EventManager extends EventDispatcher
	{
		/**
		 * 创建项目
		 */
		public static const CREATE_PROJECT : String = "CREATE_PROJECT";
		/**
		 * 导入项目
		 */
		public static const IMPORT_PROJECT : String = "IMPORT_PROJECT";
		/**
		 * 创建ui
		 */
		public static const CREATE_VIEW : String = "CREATE_VIEW";
		/**
		 * 导入资源
		 */
		public static const IMPORT_RES : String = "IMPORT_RES";
		/**
		 * 显示UI tree
		 */
		public static const SHOW_VIEW_TREE : String = "SHOW_VIEW_TREE";
		/**
		 * 显示UI
		 */
		public static const SHOW_VIEW : String = "SHOW_VIEW";
		/**
		 * 保存界面
		 */
		public static const SAVE_VIEW : String = "SAVE_VIEW";
		/**
		 * 设置
		 */
		public static const SETTING_VIEW : String = "SETTING_VIEW";
		/**
		 * 批量生成所有代码
		 */
		public static const CREATE_ALL_CODE : String = "Create_ALL_CODE";
		/**
		 * 显示某个组件
		 */
		public static const SHOW_COMPONENT : String = "showComponetEvent";
		public static const EVENT_RES_COMPLETE : String = "EVENT_RES_COMPLETE";
		/**
		 * 更新右边面板的属性
		 */
		public static const UPDATE_FIELD : String = "update_filed";
		/**
		 * 更新历史记录
		 */
		public static const UPDATE_HISTORY : String = "UPDATE_HISTORY";
		/**
		 * 转换组件
		 */
		public static const CHANGE_COMPONENT : String = "CHANGE_COMPONENT";
		/**
		 * 更新图层
		 */
		public static const UPDATE_LAYER : String = "update_layer";
		private static var instance : EventManager;

		public function EventManager(target : IEventDispatcher = null)
		{
			super(target);
		}

		public static function getInstance() : EventManager
		{
			if (instance == null)
			{
				instance = new EventManager();
				instance.init();
			}
			return instance;
		}

		private function init() : void
		{
			addListener(CREATE_PROJECT, onCreateProtect);
			addListener(IMPORT_PROJECT, onImportProtect);
			addListener(CREATE_VIEW, onCreateView);
			addListener(IMPORT_RES, onImprotRes);
			addListener(SAVE_VIEW, onSaveView);
			addListener(SETTING_VIEW, onSettingView);

			addListener(SHOW_VIEW, onStartLoaderResSwf);
			addListener(CREATE_ALL_CODE, onCreateViewCodeHanlder);
		}

		/**
		 * 生成代码
		 * @param evt
		 *
		 */
		private function onCreateViewCodeHanlder(evt : ExEvent) : void
		{
			CLoading.getInstance().show();
			var isBath : Boolean = Boolean(evt.data);
			var saveFile : File = new File();
			if (isBath)
			{
				if (Config.url_project == null || Config.url_project == "")
				{
					Alert.show("请先创建项目!", "提示");
					return;
				}
			}
			else
			{
				if (!Config.view.class_name)
				{
					Alert.show("请先创建UI!", "提示");
					return;
				}
			}

			if (LocalShareManager.getInstance().get("save_code"))
				saveFile.nativePath = LocalShareManager.getInstance().get("save_code");
			saveFile.addEventListener(Event.SELECT, onSelect);
			saveFile.addEventListener(Event.CANCEL, onExit);
			saveFile.browseForDirectory("生成");

			function onSelect(evt : Event) : void
			{
				var code : String;
				if (isBath)
					seachDirectoryList(Config.url_project);
				else
					saveCode(Config.view);
				saveFile.openWithDefaultApplication();
				CLoading.getInstance().hide();
				LocalShareManager.getInstance().save("save_code", saveFile.nativePath);
				dispatch(SAVE_VIEW);
			}

			function onExit(evt : Event) : void
			{
				CLoading.getInstance().hide();
			}
			
			function saveCode(data : ViewConfig) : void
			{
				var code : String = CodeUtils.getAsCode(data);
				var saveDirectory : String = saveFile.nativePath + "\\" + String(data.extends_name.split(".").pop()).toLocaleLowerCase();
				var file : File = new File(saveDirectory);
				!file.exists && file.createDirectory();
				FilesUtil.saveUTFBytesToFile(saveDirectory + "\\" + data.class_name + ".as", code);
			}

			function seachDirectoryList(url : String) : void
			{
				var file : File = new File(url);
				var file_list : Array = file.getDirectoryListing();
				var len : int = file_list.length;
				var tmp_file : File;
				var bytes : ByteArray;
				var viewData : ViewConfig;
				for (var i : int = 0; i < len; i++)
				{
					tmp_file = file_list[i];
					if (tmp_file.isDirectory)
					{
						seachDirectoryList(tmp_file.nativePath);
						continue;
					}
					if (tmp_file.name.indexOf(".ui") == -1 || tmp_file.name.indexOf(".uip") >= 0)
						continue;
					bytes = FilesUtil.getBytesFromeFile(tmp_file.nativePath, true);
					viewData = ViewConfig.parse(bytes, true);
					saveCode(viewData);
				}
			}
		}

		/**
		 * 创建项目
		 * @param evt
		 *
		 */
		private function onCreateProtect(evt : Event) : void
		{
			PopUpManager.createPopUp(Config.layer, CreateProjectWindow, true);
		}

		/**
		 * 导入项目
		 * @param evt
		 *
		 */
		private function onImportProtect(evt : Event) : void
		{
			var file : File = new File();
			file.browseForDirectory("选择项目");
			file.addEventListener(Event.SELECT, fileSelectedHandler);

			function fileSelectedHandler(evt : Event) : void
			{
				Config.url_project = file.nativePath;
			}
		}

		/**
		 * 创建界面
		 * @param evt
		 *
		 */
		private function onCreateView(evt : Event) : void
		{
			if (Config.url_project == null || Config.url_project == "")
			{
				Alert.show("请先创建项目!", "提示");
				return;
			}
			PopUpManager.createPopUp(Config.layer, CreateViewWindow, true);
		}

		private var loadIndex : int;
		private var loadCount : int;
		private var fileXml : XML;
		public var all_xml : XML;

		/**
		 * 导入资源
		 * @param evt
		 *
		 */
		private function onImprotRes(evt : Event) : void
		{
			if (!Config.view.class_name)
			{
				Alert.show("请先创建UI!", "提示");
				return;
			}
			//清除资源列表
			Config.view.res_list.length = 0;
			var swfFile : File = new File();
			var txtFilter : FileFilter = new FileFilter("swf文件(.swf)", "*.swf");
			if (LocalShareManager.getInstance().get("swf"))
				swfFile.nativePath = LocalShareManager.getInstance().get("swf");

			swfFile.browseForOpenMultiple("选择要导入的文件", [txtFilter]);
			swfFile.addEventListener(FileListEvent.SELECT_MULTIPLE, swfFileSelectedHandler);

			function swfFileSelectedHandler(evt : FileListEvent) : void
			{
				for each (var tmp_swfFile : File in evt.files)
					Config.view.res_list.push(tmp_swfFile.name);
				onStartLoaderResSwf();
			}
		}

		public function onStartLoaderResSwf(evt : Event = null) : void
		{
			var xml : XML;
			var bytes : ByteArray;
			var nativePath : String, name : String;
			loadIndex = 0;
			loadCount = Config.view.res_list.length;
			//分类
			fileXml = <root label="root"/>;
			//整合
			all_xml = <root label="root"/>;

			if (loadCount == 0)
			{
				CLoading.getInstance().hide();
				dispatch(EventManager.EVENT_RES_COMPLETE);
			}

			for (var i : int = 0; i < loadCount; i++)
			{
				name = Config.view.res_list[i].split(".").shift();
				nativePath = Config.res_url + Config.view.res_list[i];
				xml = <swf label={name}/>;
				fileXml.appendChild(xml);
				LocalShareManager.getInstance().save("swf", nativePath);
				new CLoader(nativePath, onResComplete, name, xml);
			}
		}


		private function onResComplete(bytes : ByteArray, name : String, xml : XML) : void
		{
			loadIndex++;
			parseSwf(bytes, name, xml);
		}


		private function parseSwf(bytes : ByteArray, swfName : String, xml : XML) : void
		{
			var classArray : Array = GetSwfAllClass.getSWFClassName(bytes);
			var len : int = classArray.length;
			var child_xml : XMLList;
			var name : String;
			var type : String;
			for (var i : int = 0; i < len; i++)
			{
				name = classArray[i];
				if (name.indexOf("btn_") == 0)
					type = "btn";
				else if (name.indexOf("img_") == 0)
					type = "img";
				else if (name.indexOf("mc_") == 0)
					type = "mc";
				else if (name.indexOf("s9_") == 0)
					type = "s9";
				else if (name.indexOf("spr_") == 0)
					type = "spr";
				else
					type = "otr";

				createXml(xml);
				createXml(all_xml);
				function createXml(tmp_xm : XML) : void
				{
					child_xml = tmp_xm.node.(@id == type);
					if (child_xml.length() == 0)
						tmp_xm.appendChild(<node id={type} label={type}/>);
					child_xml = tmp_xm.node.(@id == type);
					child_xml.appendChild(<node label={name} swf={swfName} type={type}/>);
				}
			}
			if (loadIndex >= loadCount)
			{
				all_xml.appendChild(<node id="otr" label="otr"/>);
				for each (xml in Config.getXmlByType("com"))
				{
					if (xml.@isOther == "true")
						all_xml.node.(@id == "otr")[0].appendChild(<node label={xml.@label} swf="public" type={xml.@type}/>);
				}
				CLoading.getInstance().hide(complement);
				function complement() : void
				{
					dispatch(EventManager.EVENT_RES_COMPLETE, {"t1": fileXml, "t2": all_xml});
				}
			}
		}

		/**
		 * 保存资源
		 * @param evt
		 *
		 */
		private function onSaveView(evt : Event) : void
		{
			if (!Config.view.class_name)
			{
				Alert.show("请先创建UI!", "提示");
				return;
			}
			var extends_name : String = Config.view.extends_name.split(".").pop();
			extends_name = extends_name.toLocaleLowerCase();
			FilesUtil.saveToFile(Config.view.url, ViewConfig.save(Config.view), true, true);
			Alert.show("保存成功!", "提示");
		}

		/**
		 * 设置界面
		 * @param evt
		 *
		 */
		private function onSettingView(evt : Event) : void
		{
			if (!Config.view.class_name)
			{
				Alert.show("请先创建UI!", "提示");
				return;
			}
			PopUpManager.createPopUp(Config.layer, SettingWindow, true);
		}

		private function onSecurityError(evt : Event) : void
		{
			Alert.show("加载swf出错!");
		}

		public function dispatch(evt : String, data : Object = null) : void
		{
			this.dispatchEvent(new ExEvent(evt, data));
		}

		public static function dispatch(evt : String, data : Object = null) : void
		{
			getInstance().dispatch(evt, data);
		}

		public function addListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			this.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function addListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			getInstance().addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
	}
}