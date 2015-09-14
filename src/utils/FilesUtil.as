package utils
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import mx.controls.Alert;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;

	import core.Config;

	public class FilesUtil
	{

		public static const PNG : String = "png";
		public static const JPG : String = "jpg";



		/**
		 * 利用递归来查找在某个文件夹下是否存在fileName为名的文件
		 * @param nativePath:String 要查找 的文件夹路径
		 * @param fileName:String 要查找的文件名称
		 * @return 查找成功则返回true
		 *
		 */
		public static function checkFileIsExit(nativePath : String, fileName : String = null) : Boolean
		{
			var file : File = new File(nativePath);

			if (fileName == null)
			{
				return file.exists;
			}

			//查找文件夹下的文件
			var list : Array = file.getDirectoryListing();
			var len : int = list.length;

			for (var i : int = 0; i < len; i++)
			{
				var cfile : File = list[i] as File;

				if (cfile.isDirectory)
				{
					if (checkFileIsExit(cfile.nativePath, fileName))
						return true;
						//checkFileIsExit(cfile.nativePath,fileName);
				}
				else
				{
					if (cfile.name == fileName)
					{
						trace("找到了", cfile.nativePath);
						return true;
					}
				}
			}
			trace("没找到", nativePath);
			return false;
		}

		/**
		 * 获得最终子文件夹下的内容
		 * @param nativePath:String
		 * @return
		 *
		 */
		public static function getLastDirectoryFiles(nativePath : String) : Array
		{
			var filesArray : Array = new Array();
			var file : File = new File(nativePath);

			//查找文件夹下的文件
			var list : Array = file.getDirectoryListing();
			var len : int = list.length;

			for (var i : int = 0; i < len; i++)
			{
				var cfile : File = list[i] as File;

				if (cfile.isDirectory)
				{
					filesArray = getLastDirectoryFiles(cfile.nativePath);

					if (filesArray != null)
						break;
				}
				else
				{
					if (cfile.name.indexOf(".png") != -1)
					{
						filesArray.push(cfile.name);
					}
				}
			}
			return filesArray;
		}


		/**
		 * 保存切割的位图 为PNG
		 * @param bmd 要保存的BitmapData数据
		 * @param nativePath 要保存的文件完整路径
		 * @param type 要保存的文件类型 Files.PNG || Files.JPG
		 * @param overwrite 是否覆盖已有的文件
		 * @param clear 是否自动清除内存
		 */
		public static function saveBmp(bmd : BitmapData, nativePath : String, type : String = FilesUtil.PNG, overwrite : Boolean = true, clear : Boolean = true) : void
		{

			try
			{
				var file : File = new File(nativePath);

				if (file.exists && !overwrite)
				{
//					trace("已经存在了,不覆盖返回")
					file = null;
					return;
				}

				var bytes : ByteArray;

				switch (type)
				{
					case FilesUtil.PNG:
						var pngEncoder : PNGEncoder = new PNGEncoder();
						bytes = pngEncoder.encode(bmd);
						pngEncoder = null;
						break;
					case FilesUtil.JPG:
						var jpgEncoder : JPEGEncoder = new JPEGEncoder(60);
						bytes = jpgEncoder.encode(bmd);
						jpgEncoder = null;
						break;
					default:
						break;
				}


				//var pngEncoder:AsPngEncoder = new AsPngEncoder();
				//var bytes:ByteArray = pngEncoder.encode(bmd, new Strategy8BitMedianCutAlpha());

				var stream : FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeBytes(bytes, 0, bytes.length);
				stream.close();

				trace("保存完", nativePath);

				if (clear)
					bmd.dispose();
				bmd = null;

				bytes.clear();
				bytes = null;
				file = null;
			}
			catch (e : Error)
			{
				trace("保存出错", e);
			}
		}

		/**
		 * 通用存储函数
		 * @param nativePath
		 * @param value 可以为Array，Object,String,ByteArray
		 * @param overwrite
		 * @param compress
		 *
		 */
		public static function saveToFile(nativePath : String, value : *, overwrite : Boolean = true, compress : Boolean = false) : void
		{
			try
			{
				if (value == "" || value == null || nativePath == "")
				{
					trace("非法传值");
					return;
				}

				var file : File = new File(nativePath);

				if (file.exists && !overwrite)
				{
					//					trace("已经存在了,不覆盖,返回");
					file = null;
					return;
				}

				var stream : FileStream = new FileStream();

				var bytes : ByteArray = new ByteArray();

				if (value is Array)
				{
					bytes.writeObject(value);
				}
				else if (value is String)
				{
					bytes.writeUTFBytes(value);
				}
				else if (value is XML)
				{
					bytes.writeUTFBytes((value as XML).toXMLString());
				}
				else if (value is ByteArray)
				{
					bytes.writeBytes(value, 0, value.length);
						//					bytes = value as ByteArray;
				}
				else if (value is int)
				{
					bytes.writeInt(value);
				}
				else if (value is Number)
				{
					bytes.writeFloat(value);
				}
				else if (value is uint)
				{
					bytes.writeUnsignedInt(value);
				}
				else
				{
					bytes.writeObject(value);
				}

				//				
				if (compress)
				{
					trace("压缩前长度", bytes.length);
					bytes.compress();
					trace("压缩后长度", bytes.length);
				}


				stream.open(file, FileMode.WRITE);
				stream.writeBytes(bytes, 0, bytes.length); //使包括汉字时不会有错 gb2123 为汉字编码
				stream.close();

				bytes.clear();
				bytes = null;

					//trace("保存完", nativePath);
			}
			catch (e : Error)
			{
				trace("保存出错", e);
			}
		}


		/**
		 * 保存一份字符串到硬盘
		 * @param nativePath 包括文件后缀名的完整路径
		 * @param value 要保存的字符串
		 * @param type  表示输出UTF-8 或 gb2123
		 * @param overwrite 是否覆盖已有的文件
		 */
		public static function saveUTFBytesToFile(nativePath : String, value : String, type : String = "UTF-8", overwrite : Boolean = true) : Boolean
		{
			try
			{
				if (value == "" || nativePath == "")
				{
					trace("非法传值");
					return false;
				}

				var file : File = new File(nativePath);

				if (file.exists && !overwrite)
				{
					trace("已经存在了,不覆盖,返回");
					file = null;
					return false;
				}

				var stream : FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeMultiByte(value, type); //使包括汉字时不会有错 gb2123 为汉字编码
				stream.close();

				trace("保存完", nativePath);
			}
			catch (e : Error)
			{
				trace("保存出错", e);
				return false;
			}

			return true;
		}


		/**
		 * 保存一份被压缩的字符串到硬盘
		 * @param nativePath 包括文件后缀名的完整路径
		 * @param str 要保存的字符串
		 * @param overwrite 是否覆盖已有的文件
		 * @param type  表示输出UTF-8 或 gb2123
		 *
		 */
		public static function saveCompressUTFBytesToFile(nativePath : String, value : String, type : String = "utf-8", overwrite : Boolean = true) : Boolean
		{
			try
			{
				if (value == "" || nativePath == "")
				{
					trace("非法传值");
					return false;
				}

				var file : File = new File(nativePath);

				if (file.exists && !overwrite)
				{
					trace("已经存在了,不覆盖,返回");
					file = null;
					return false;
				}

				var stream : FileStream = new FileStream();

				var bytes : ByteArray = new ByteArray();
				bytes.writeMultiByte(value, type);

				trace("压缩前长度", bytes.length);
				bytes.compress();
				trace("压缩后长度", bytes.length);


				stream.open(file, FileMode.WRITE);
				stream.writeBytes(bytes, 0, bytes.length); //使包括汉字时不会有错 gb2123 为汉字编码
				stream.close();

				bytes = null;

				trace("保存完", nativePath);
			}
			catch (e : Error)
			{
				trace("保存出错", e);
				return false;
			}

			return true;
		}


		/**
		 * 读取硬盘某个文件的字符串数据
		 * @param nativePath 文件路径
		 * @param 是否是要解压缩文件
		 * @return 返回字符串
		 *
		 */
		public static function getUTFBytesFromFile(nativePath : String, unCompress : Boolean = false) : String
		{
			var value : String;
			var bytes : ByteArray = new ByteArray();

			var file : File = new File(nativePath);
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			//data = stream.readUTFBytes(stream.bytesAvailable);
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			stream.close();

			if (unCompress)
				bytes.uncompress();

			value = bytes.readUTFBytes(bytes.length);
			return value;
		}


		/**
		 * 从某个文件中读取二制流
		 * @param nativePath
		 * @param unCompress 是否是要解压缩文件
		 * @return 返回二进制流
		 *
		 */
		public static function getBytesFromeFile(nativePath : String, unCompress : Boolean = false) : ByteArray
		{
			var bytes : ByteArray = new ByteArray();
			var file : File = new File(nativePath);
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			stream.close();
			unCompress && bytes.uncompress();
			return bytes;
		}
	}
}