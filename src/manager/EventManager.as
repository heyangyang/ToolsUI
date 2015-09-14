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
	import core.SEvent;
	import core.data.SUiObject;

	import utils.CLoader;
	import utils.FilesUtil;
	import utils.GetSwfAllClass;

	import view.component.CLoading;
	import view.window.SWindowCreateProject;
	import view.window.SWindowCreateUi;
	import view.window.SWindowSetting;

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
		public static const CREATE_CODE : String = "Create_CODE";
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
		/**
		 * 退出程序
		 */
		public static const EXIT_WINODW : String = "exit_window";

		private static var instance : EventManager;

		public function EventManager(target : IEventDispatcher = null)
		{
			super(target);
		}

		public static function getInstance() : EventManager
		{
			if (instance == null)
				instance = new EventManager();
			return instance;
		}

		private var mCurrent : SUiObject;

		public function init() : void
		{
			mCurrent = Config.current;
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
		private function onCreateViewCodeHanlder(evt : SEvent) : void
		{
			CLoading.getInstance().show();
			var isBath : Boolean = Boolean(evt.data);
			var saveFile : File = new File();
			if (isBath)
			{
				if (Config.projectUrl == null || Config.projectUrl == "")
				{
					Config.alert("请先创建项目!");
					return;
				}
			}
			else
			{
				if (!mCurrent.className)
				{
					Config.alert("请先创建UI!");
					return;
				}
			}

			if (LocalShareManager.get("save_code"))
				saveFile.nativePath = LocalShareManager.get("save_code");
			saveFile.addEventListener(Event.SELECT, onSelect);
			saveFile.addEventListener(Event.CANCEL, onExit);
			saveFile.browseForDirectory("生成");

			function onSelect(evt : Event) : void
			{
				var code : String;
				if (isBath)
					seachDirectoryList(Config.projectUrl);
				else
					saveCode(mCurrent);
				saveFile.openWithDefaultApplication();
				CLoading.getInstance().hide();
				LocalShareManager.save("save_code", saveFile.nativePath);
				//dispatch(SAVE_VIEW);
			}

			function onExit(evt : Event) : void
			{
				CLoading.getInstance().hide();
			}

			function saveCode(data : SUiObject) : void
			{
				var code : String = CodeUtils.getAsCode(data);
				var saveDirectory : String = saveFile.nativePath + "\\" + String(data.extendsName.split(".").pop()).toLocaleLowerCase();
				var file : File = new File(saveDirectory);
				!file.exists && file.createDirectory();
				FilesUtil.saveUTFBytesToFile(saveDirectory + "\\" + data.className + ".as", code);
			}

			function seachDirectoryList(url : String) : void
			{
				var file : File = new File(url);
				var file_list : Array = file.getDirectoryListing();
				var len : int = file_list.length;
				var tmp_file : File;
				var bytes : ByteArray;
				var viewData : SUiObject;
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
//					viewData = SUiObject.parseByteArray(bytes, true);
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
			PopUpManager.createPopUp(Config.layer, SWindowCreateProject, true);
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
				Config.updateProject(file.nativePath);
			}
		}

		/**
		 * 创建界面
		 * @param evt
		 *
		 */
		private function onCreateView(evt : Event) : void
		{
			if (Config.projectUrl == null || Config.projectUrl == "")
			{
				Config.alert("请先创建项目!");
				return;
			}
			PopUpManager.createPopUp(Config.layer, SWindowCreateUi, true);
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
			if (!mCurrent.className)
			{
				Config.alert("请先创建UI!");
				return;
			}
			//清除资源列表
			mCurrent.resourceList.length = 0;
			var swfFile : File = new File();
			var txtFilter : FileFilter = new FileFilter("swf文件(.swf)", "*.swf");
			if (LocalShareManager.get("swf"))
				swfFile.nativePath = LocalShareManager.get("swf");

			swfFile.browseForOpenMultiple("选择要导入的文件", [txtFilter]);
			swfFile.addEventListener(FileListEvent.SELECT_MULTIPLE, swfFileSelectedHandler);

			function swfFileSelectedHandler(evt : FileListEvent) : void
			{
				for each (var tmp_swfFile : File in evt.files)
					mCurrent.resourceList.push(tmp_swfFile.name);
				onStartLoaderResSwf();
			}
		}

		public function onStartLoaderResSwf(evt : Event = null) : void
		{
			var xml : XML;
			var bytes : ByteArray;
			var nativePath : String, name : String;
			loadIndex = 0;
			loadCount = mCurrent.resourceList.length;
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
				name = mCurrent.resourceList[i].split(".").shift();
				nativePath = Config.projectResourceUrl + mCurrent.resourceList[i];
				xml = <swf label={name}/>;
				fileXml.appendChild(xml);
				LocalShareManager.save("swf", nativePath);
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
		 * 保存ui数据
		 * @param evt
		 *
		 */
		private function onSaveView(evt : SEvent) : void
		{
			var data : SUiObject = evt.data as SUiObject;
			if (!data || !data.className)
			{
				Config.alert("请先创建UI!");
				return;
			}
			var file : File = new File(data.nativeUrl);
			if (file.exists)
				Config.alert("保存成功!");
			else
				Config.alert("创建成功!");
			FilesUtil.saveToFile(data.nativeUrl, SUiObject.toByteArray(data), true, true);
		}

		/**
		 * 设置界面
		 * @param evt
		 *
		 */
		private function onSettingView(evt : Event) : void
		{
			if (!mCurrent.className)
			{
				Config.alert("请先创建UI!");
				return;
			}
			PopUpManager.createPopUp(Config.layer, SWindowSetting, true);
		}

		private function onSecurityError(evt : Event) : void
		{
			Config.alert("加载swf出错!");
		}

		public function dispatch(evt : String, data : Object = null) : void
		{
			this.dispatchEvent(new SEvent(evt, data));
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