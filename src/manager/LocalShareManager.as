package manager
{

	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;

	/**
	 * 本地緩存管理
	 * @author yangyang
	 *
	 */
	public class LocalShareManager
	{
		/**
		 * 程序地址
		 */
		public static const PROGRAM : String = "program";
		/**
		 * 项目地址
		 */
		public static const PROJECT : String = "project_url";
		private static var instance : LocalShareManager;


		public static function get(property : String) : *
		{
			if (!instance)
			{
				instance = new LocalShareManager();
				instance.init();
			}
			return instance.get(property);
		}

		public static function save(property : String, data : *) : void
		{
			if (!instance)
			{
				instance = new LocalShareManager();
				instance.init();
			}
			instance.save(property, data);
		}


		protected var local_data : Object;
		protected var PATH : String;

		public function LocalShareManager(path : String = "ToolsUI")
		{
			PATH = path;
		}

		/**
		 * 需要初始化兩次，一次請求賬號ID
		 * 第二次初始化賬號信息
		 *
		 */
		public function init() : void
		{
			var bytes : ByteArray = EncryptedLocalStore.getItem(PATH);

			if (bytes == null)
				local_data = {};
			else
				local_data = bytes.readObject();
		}

		public function get(property : String) : *
		{
			return local_data[property];
		}

		public function save(property : String, data : *) : void
		{
			try
			{
				local_data[property] = data;
				flush();
			}
			catch (e : Error)
			{
				trace(e);
			}
		}

		public function clear(property : String) : Boolean
		{
			try
			{
				delete local_data[property];
				flush();
			}
			catch (e : Error)
			{
				trace(e);
			}
			return true;
		}

		public function clearAll() : void
		{
			instance = null;
			local_data = {};
		}

		public function flush() : void
		{
			var bytes : ByteArray = new ByteArray();
			bytes.writeObject(local_data);
			EncryptedLocalStore.setItem(PATH, bytes);
		}

	}
}