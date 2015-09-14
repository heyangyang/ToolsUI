package utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import core.Config;
	
	import manager.EventManager;
	import manager.LocalShareManager;

	public class CLoader
	{
		private static var list : Array = [];

		public function CLoader(url : String, complement : Function, ... params)
		{
			var bytes : ByteArray = FilesUtil.getBytesFromeFile(url);
			params.splice(0, 0, bytes);
			if (bytes.bytesAvailable == 0)
			{
//				Config.alert("资源丢失 : " + url);
				saveResUrlClick();
				return;
			}
			if (list.indexOf(url) != -1)
			{
				onResComplete();
				return;
			}
			var loader : Loader = new Loader();
			var lc : LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			Config.appDomain = ApplicationDomain.currentDomain;
			lc.allowCodeImport = true;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onResComplete);
			loader.contentLoaderInfo.addEventListener("securityError", onSecurityError);
			loader.loadBytes(bytes, lc);

			function onResComplete(evt : Event = null) : void
			{
				list.push(url);
				complement != null && complement.apply(this, params);
			}
		}

		protected function saveResUrlClick() : void
		{
			try
			{
				var file : File = new File();
				if (LocalShareManager.get(LocalShareManager.PROGRAM))
					file.nativePath = LocalShareManager.get(LocalShareManager.PROGRAM);
				file.browseForDirectory("重新选择资源目录");
				file.addEventListener(Event.SELECT, onSelect);
			}
			catch (e : Error)
			{
				Config.alert("资源目录出错 ！");
			}

			function onSelect(evt : Event) : void
			{
				Config.saveProjectData("", "",  file.nativePath);
				EventManager.dispatch(EventManager.SHOW_VIEW);
			}
		}

		private function onSecurityError(evt : Event) : void
		{
			Alert.show("加载swf出错!");
		}
	}
}