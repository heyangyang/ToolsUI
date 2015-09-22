package manager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.managers.PopUpManager;
	
	import core.Config;
	import core.SEvent;
	
	import utils.CLoader;
	import utils.FilesUtil;
	import utils.GetSwfAllClass;
	
	import view.component.SLoading;
	import view.component.SView;
	import view.window.SWindowCreateProject;
	import view.window.SWindowCreateUi;
	import view.window.SWindowEditProject;
	import view.window.SWindowSetting;

	public class SEventManager extends EventDispatcher
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
		 * 编辑属性
		 */
		public static const EDIT_PROJECT : String = "EDIT_PROJECT";
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
		public static const UPDATE_VIEW : String = "UPDATE_VIEW";
		/**
		 * 退出程序
		 */
		public static const EXIT_WINODW : String = "exit_window";

		private static var instance : SEventManager;

		public function SEventManager(target : IEventDispatcher = null)
		{
			super(target);
		}

		public static function getInstance() : SEventManager
		{
			if (instance == null)
				instance = new SEventManager();
			return instance;
		}

		private var mCurrent : SView;

		public function init() : void
		{
			addListener(CREATE_PROJECT, onCreateProtect);
			addListener(EDIT_PROJECT, onEditProtect);
			addListener(IMPORT_PROJECT, onImportProtect);
			addListener(CREATE_VIEW, onCreateView);
			addListener(IMPORT_RES, onImprotRes);
			addListener(SAVE_VIEW, onSaveView);
			addListener(SETTING_VIEW, onSettingView);

			addListener(SHOW_VIEW, onStartLoaderResSwf);
			addListener(CREATE_CODE, onCreateViewCodeHanlder);
			addListener(CREATE_ALL_CODE, onCreateViewCodeHanlder);
		}

		/**
		 * 生成代码
		 * @param evt
		 *
		 */
		private function onCreateViewCodeHanlder(evt : SEvent) : void
		{
			SLoading.getInstance().show();
			//是否批量生成
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
				SLoading.getInstance().hide();
				LocalShareManager.save("save_code", saveFile.nativePath);
				//dispatch(SAVE_VIEW);
			}

			function onExit(evt : Event) : void
			{
				SLoading.getInstance().hide();
			}

			function saveCode(data : SView) : void
			{
				//var code : String = CodeUtils.getAsCode(data);
				var saveDirectory : String = saveFile.nativePath + "\\" + String(data.extendsName.split(".").pop()).toLocaleLowerCase();
				var file : File = new File(saveDirectory);
				!file.exists && file.createDirectory();
//				FilesUtil.saveUTFBytesToFile(saveDirectory + "\\" + data.className + ".as", code);
			}

			function seachDirectoryList(url : String) : void
			{
				var file : File = new File(url);
				var file_list : Array = file.getDirectoryListing();
				var len : int = file_list.length;
				var tmp_file : File;
				var bytes : ByteArray;
				var viewData : SView;
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
		 * 编辑项目
		 * @param evt
		 *
		 */
		private function onEditProtect(evt : Event) : void
		{
			PopUpManager.createPopUp(Config.layer, SWindowEditProject, true);
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
		private var mAllXml : XML;

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
			var swfFile : File = new File();
			var txtFilter : FileFilter = new FileFilter("swf文件(.swf)", "*.swf");
			swfFile.nativePath = Config.projectResourceUrl;
			swfFile.browseForOpenMultiple("选择要导入的文件", [txtFilter]);
			swfFile.addEventListener(FileListEvent.SELECT_MULTIPLE, swfFileSelectedHandler);

			function swfFileSelectedHandler(evt : FileListEvent) : void
			{
				var tmpList : Array = []
				for each (var tmp_swfFile : File in evt.files)
					tmpList.push(tmp_swfFile.name);
				mCurrent.setResource(tmpList);
				onStartLoaderResSwf();
			}
		}

		public function onStartLoaderResSwf(evt : SEvent = null) : void
		{
			if (evt)
				mCurrent = evt.data as SView;
			var nativePath : String, name : String;
			var resourceList : Array = mCurrent.getResource();
			loadCount = resourceList ? resourceList.length : 0;
			loadIndex = 0;

			if (loadCount == 0)
			{
				SLoading.getInstance().hide(onSwfComplete);
				return;
			}

			mAllXml = <root/>;

			for (var i : int = 0; i < loadCount; i++)
			{
				name = resourceList[i].split(".").shift();
				nativePath = Config.projectResourceUrl + resourceList[i];
				new CLoader(nativePath, onResComplete, name);
			}
		}


		private function onResComplete(bytes : ByteArray, name : String) : void
		{
			loadIndex++;
			parseSwf(bytes, name);
		}


		private function parseSwf(bytes : ByteArray, swfName : String) : void
		{
			var classArray : Array = GetSwfAllClass.getSWFClassName(bytes);
			var len : int = classArray.length;
			var child_xml : XMLList;
			var name : String;
			var type : String;
			for (var i : int = 0; i < len; i++)
			{
				name = classArray[i];
				if (name.indexOf("_") >= 0)
					type = name.split("_")[0];
				else
					type = Config.OTHER;

				child_xml = mAllXml.node.(@id == type);
				if (child_xml.length() == 0)
				{
					mAllXml.appendChild(<node id={type} label={type}/>);
					child_xml = mAllXml.node.(@id == type);
				}
				child_xml.appendChild(<node label={name} swf={swfName} type={type}/>)
			}


			if (loadIndex >= loadCount)
				SLoading.getInstance().hide(onSwfComplete);
		}

		private function onSwfComplete() : void
		{
			dispatch(SEventManager.EVENT_RES_COMPLETE, mAllXml);
		}

		/**
		 * 保存ui数据
		 * @param evt
		 *
		 */
		private function onSaveView(evt : SEvent) : void
		{
			var data : SView = Config.current;
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
			FilesUtil.saveToFile(data.nativeUrl, data.toByteArray(), true, true);
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