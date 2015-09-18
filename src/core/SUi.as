package core
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import view.component.SView;

	public class SUi
	{
		public var className : String;
		public var extendsName : String;
		public var packageName : String;
		public var width : int;
		public var height : int;
		private var mResourceList : Array;
		private var mView : SView = new SView();

		public function SUi()
		{
		}

		public function setResource(... args) : void
		{
			if (args.length == 1 && args[0] is Array)
				mResourceList = args[0];
			else
				mResourceList = args;
		}

		/**
		 * ui所用到的资源
		 * @return
		 *
		 */
		public function getResource() : Array
		{
			return mResourceList;
		}

		public static function parseByteArray(bytes : ByteArray) : SUi
		{
			var data : SUi = new SUi();
			data.parserByteArray(bytes);
			return data;
		}

		public function toByteArray() : ByteArray
		{
			var len : int, i : int;
			var bytes : ByteArray = new ByteArray();
			bytes.writeUTF(className);
			bytes.writeUTF(extendsName);
			bytes.writeUTF(packageName);
			bytes.writeInt(width);
			bytes.writeInt(height);
			len = mResourceList ? mResourceList.length : 0;
			bytes.writeByte(len);
			for (i = 0; i < len; i++)
				bytes.writeUTF(mResourceList[i]);
			bytes.writeObject(mView.toByteArray());
			return bytes;
		}

		public function parserByteArray(bytes : ByteArray) : void
		{
			var len : int, i : int;
			className = bytes.readUTF();
			extendsName = bytes.readUTF();
			packageName = bytes.readUTF();
			width = bytes.readInt();
			height = bytes.readInt();
			len = bytes.readByte();
			var resourceList : Array = [];
			for (i = 0; i < len; i++)
				resourceList.push(bytes.readUTF());
			setResource(resourceList);
			mView.parserByteArray(bytes.readObject());
		}

		public function get view() : SView
		{
			return mView;
		}

		/**
		 * 地址
		 * @return
		 *
		 */
		public function get nativeUrl() : String
		{
			return Config.projectUrl + File.separator + packageName + File.separator + className + Config.VIEW_EXTENSION;
		}

		public function clone(obj : SUi) : void
		{
			className = obj.className;
			extendsName = obj.extendsName;
			packageName = obj.packageName;
			width = obj.width;
			height = obj.height;
			mResourceList = obj.mResourceList;
			mView = obj.mView;
		}
	}
}