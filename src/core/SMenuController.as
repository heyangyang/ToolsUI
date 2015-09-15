package core
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.ui.Keyboard;

	import manager.SEventManager;


	public class SMenuController
	{
		private static var instance : SMenuController;

		public static function getInstance() : SMenuController
		{
			if (instance == null)
				instance = new SMenuController();
			return instance;
		}


		public function init(nativeWindow : NativeWindow) : void
		{
			nativeWindow.alwaysInFront = false;
			var nativeBaseMenu : NativeMenu = new NativeMenu();
			nativeWindow.menu = nativeBaseMenu;
			var menuList : Array = [];
			var subMenuList : Array;
			var menuItem : Object;
			//-------------------项目--------------------------
			subMenuList = [];
			menuItem = {label: "项目(P)", subMenu: subMenuList};
			menuList.push(menuItem);
			subMenuList.push({label: "新建项目", data: SEventManager.CREATE_PROJECT, key: [Keyboard.CONTROL], keybroad: "N"});
			subMenuList.push({label: "导入项目", data: SEventManager.IMPORT_PROJECT, key: [Keyboard.CONTROL], keybroad: "O"});
			subMenuList.push({label: "属性", data: SEventManager.EDIT_PROJECT});
			//-------------------项目--------------------------

			//-------------------操作--------------------------
			subMenuList = [];
			menuItem = {label: "操作(T)", subMenu: subMenuList};
			menuList.push(menuItem);
			subMenuList.push({label: "新建界面", data: SEventManager.CREATE_VIEW, key: [Keyboard.CONTROL], keybroad: "n"});
			subMenuList.push({label: "导入资源", data: SEventManager.IMPORT_RES, key: [Keyboard.CONTROL], keybroad: "o"});
			subMenuList.push({label: "保存", data: SEventManager.SAVE_VIEW, key: [Keyboard.CONTROL], keybroad: "s", param: Config.current});
			//-------------------操作--------------------------

			//-------------------生成--------------------------
			subMenuList = [];
			menuItem = {label: "生成(S)", subMenu: subMenuList};
			menuList.push(menuItem);
			subMenuList.push({label: "生成代码", data: SEventManager.CREATE_CODE});
			subMenuList.push({label: "批量生成代码", data: SEventManager.CREATE_ALL_CODE, param: true});
			//-------------------生成--------------------------

			//-------------------其他--------------------------
			subMenuList = [];
			menuItem = {label: "其他", subMenu: subMenuList};
			menuList.push(menuItem);
			subMenuList.push({label: "设置", data: SEventManager.SETTING_VIEW});
			//-------------------其他--------------------------

			var len : int = menuList.length;
			var item : NativeMenuItem;
			var subItem : NativeMenu;
			for (var i : int = 0; i < len; i++)
			{
				item = createMenuItem(menuList[i]);
				subItem = new NativeMenu();
				item.submenu = subItem;
				nativeBaseMenu.addItem(item);
				for each (menuItem in menuList[i].subMenu)
				{
					item = createMenuItem(menuItem);
					subItem.addItem(item);
				}
			}
		}

		private function createMenuItem(data : Object) : NativeMenuItem
		{
			var item : NativeMenuItem = new NativeMenuItem(data.label);
			item.checked = false;
			if (data.keybroad)
				item.keyEquivalent = data.keybroad;
			if (data.key)
				item.keyEquivalentModifiers = data.key;
			item.data = data;
			item.addEventListener(Event.SELECT, itemClickHandler);
			return item;
		}

		public function itemClickHandler(evt : Event) : void
		{
			dispatch(evt.target.data.data, evt.target.data.param);
		}

		private static function dispatch(evt : String, obj : Object = null) : void
		{
			SEventManager.dispatch(evt, obj);
		}
	}
}