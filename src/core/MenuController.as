package core
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import mx.events.MenuEvent;
	import manager.EventManager;


	public class MenuController
	{
		private static var instance : MenuController;

		public static function getInstance() : MenuController
		{
			if (instance == null)
			{
				instance = new MenuController();
				instance.init();
			}
			return instance;
		}

		private function init() : void
		{
			Config.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
		}

		public static function onKeyDownHandler(evt : KeyboardEvent) : void
		{
			if (evt.ctrlKey && evt.shiftKey)
			{
				switch (evt.keyCode)
				{
					case Keyboard.N:
						dispatch(EventManager.CREATE_PROJECT);
						break;
					case Keyboard.O:
						dispatch(EventManager.IMPORT_PROJECT);
						break;
					case Keyboard.ENTER:
						dispatch(EventManager.CREATE_ALL_CODE, true);
						break;
				}
			}
			else if (evt.ctrlKey)
			{

				switch (evt.keyCode)
				{
					case Keyboard.N:
						dispatch(EventManager.CREATE_VIEW);
						break;
					case Keyboard.O:
						dispatch(EventManager.IMPORT_RES);
						break;
					case Keyboard.S:
						dispatch(EventManager.SAVE_VIEW);
						break;
					case Keyboard.ENTER:
						dispatch(EventManager.CREATE_ALL_CODE, false);
						break;
				}
			}
		}
		[Binable]
		public var menubarXML : XMLList =
			<>
				<menuitem label="项目" data="top">
					<menuitem label="新建项目(Ctrl+Shift+N)" data="createProject"/>
					<menuitem label="导入项目(Ctrl+Shift+O)" data="improtProject"/>
				</menuitem>
				<menuitem label="界面" data="top">
					<menuitem label="新建界面(Ctrl+N)" data="createView"/>
					<menuitem label="导入资源(Ctrl+O)" data="improtView"/>
					<menuitem label="保存(Ctrl+S)" data="saveFile"/>
				</menuitem>
				<menuitem label="生成" data="top">
					<menuitem label="生成代码" data="create"/>
					<menuitem label="批量生成代码" data="bath_create"/>
				</menuitem>
				<menuitem label="其他" data="top">
					<menuitem label="设置" data="setting"/>
				</menuitem>
			</>;

		public function itemClickHandler(event : MenuEvent) : void
		{

			switch (String(event.item.@data))
			{
				case "createProject":
					dispatch(EventManager.CREATE_PROJECT);
					break;
				case "improtProject":
					dispatch(EventManager.IMPORT_PROJECT);
					break;
				case "createView":
					dispatch(EventManager.CREATE_VIEW);
					break;
				case "improtView":
					dispatch(EventManager.IMPORT_RES);
					break;
				case "saveFile":
					dispatch(EventManager.SAVE_VIEW);
					break;
				case "setting":
					dispatch(EventManager.SETTING_VIEW);
					break;
				case "create":
					dispatch(EventManager.CREATE_ALL_CODE, false);
					break;
				case "bath_create":
					dispatch(EventManager.CREATE_ALL_CODE, true);
					break;
			}
		}

		private static function dispatch(evt : String, obj : Object = null) : void
		{
			EventManager.getInstance().dispatch(evt, obj);
		}
	}
}