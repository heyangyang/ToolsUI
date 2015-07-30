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
		protected var local_data : Object;
		protected var PATH : String = "toolsUi";
		public static var USER : String = "user_pwd";
		private static var instance : LocalShareManager;

		public static function getInstance() : LocalShareManager
		{
			if (instance == null)
			{
				instance = new LocalShareManager();
				instance.init();
			}
			return instance;
		}

		public function LocalShareManager(path : String = "tjzh_data")
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

		public var m_pwd : String;
		public var m_username : String;
		public var m_area : String;
		public var m_rangeArea : String;

		public function getUserPwd() : void
		{
			var str : String = getInstance().get(USER);
			if (str)
			{
				m_pwd = str.split("|")[0];
				m_username = str.split("|")[1];
				m_area = str.split("|")[2];
				m_rangeArea = str.split("|")[3];
			}
		}

		public function get(property : String, isAddMd5 : Boolean = true) : *
		{
			return local_data[property];
		}

		public function save(property : String, data : *, isAddMd5 : Boolean = true) : Boolean
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
			return true;
		}

		public function clear(property : String, isAddMd5 : Boolean = true) : Boolean
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

		/**
		 * 存儲信息
		 *
		 */
		public function cacheSaveData() : void
		{
			this.flush();
		}

	}
}