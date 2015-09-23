package view.component
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.ByteArray;

	import managers.SCodeManager;

	public class SLayer extends SDisplay
	{
		public static function getDataType(type : String) : SDisplay
		{
			var view : SDisplay;
			switch (type)
			{
				//				case "btn":
				//					com_data = new ButtonData();
				//					break
				//				case "img":
				//					com_data = new ImageData();
				//					break
				default:
					view = new SDisplay();
					break;
			}
			return view;
		}

		private var mChilds : Vector.<SDisplay> = new Vector.<SDisplay>();
		private var mNumChildren : int;
		private var mIsLock : Boolean;

		public function SLayer()
		{
		}


		public function get isLock() : Boolean
		{
			return mIsLock;
		}

		public function set isLock(value : Boolean) : void
		{
			mIsLock = value;
		}

		public override function removeFromParent() : void
		{
			if (!mParent)
				return;
			SView(mParent).removeLayer(this);
			mParent = null;
		}

		public override function get numChildren() : int
		{
			return mNumChildren;
		}

		public function addDisplay(child : SDisplay) : void
		{
			addDisplayAt(child, mNumChildren);
		}

		public function addDisplayAt(child : SDisplay, index : int) : void
		{
			if (mChilds.indexOf(child) != -1)
				return;
			child.setParent(this);
			child.mIndex = index;
			mChilds.splice(index, 0, child);
			addChildAt(child, index);
			mNumChildren++;
			dispatchEvent(new Event(Event.CHANGE));
		}

		public function setDisplayIndex(child : SDisplay, index : int) : void
		{
			setChildIndex(child, index);
			mChilds[index].mIndex = child.mIndex;
			mChilds.splice(child.mIndex, 1);
			mChilds.splice(child.mIndex > index ? index : index + 1, 0, child);
			child.mIndex = index;
		}

		public function removeDisplay(child : SDisplay) : void
		{
			removeDisplayAt(mChilds.indexOf(child));
		}

		public function removeDisplayAt(index : int) : void
		{
			var child : SDisplay = mChilds.splice(index, 1)[0];
			removeChild(child);
			child.setParent(null);
			mNumChildren--;
			dispatchEvent(new Event(Event.CHANGE));
		}

		public override function parserByteArray(bytes : ByteArray) : void
		{
			name = bytes.readUTF();
			visible = bytes.readBoolean();
			mIsLock = bytes.readBoolean();
			var len : int = bytes.readInt();
			var data : ByteArray;
			var child : SDisplay;
			var childData : Object;
			for (var i : int = 0; i < len; i++)
			{
				data = bytes.readObject();
				childData = data.readObject();
				child = getDataType(childData.type);
				data.position = 0;
				child.parserByteArray(data);
				addDisplay(child);
			}
		}

		public override function toByteArray() : ByteArray
		{
			var bytes : ByteArray = new ByteArray();
			bytes.writeUTF(name);
			bytes.writeBoolean(visible);
			bytes.writeBoolean(mIsLock);
			bytes.writeInt(mNumChildren);
			for (var i : int = 0; i < mNumChildren; i++)
				bytes.writeObject(mChilds[i].toByteArray());
			return bytes;
		}

		public override function loadResourceComplete() : void
		{
			for each (var child : SDisplay in mChilds)
			{
				child.loadResourceComplete();
			}
		}

		/**
		 * 检测碰撞
		 * @param rect
		 * @param list 如果碰撞了，则添加到列表
		 *
		 */
		public override function hitTestRectangle(rect : DisplayObject, list : Vector.<SDisplay>) : void
		{
			if (isLock)
				return;
			for each (var child : SDisplay in mChilds)
			{
				child.hitTestRectangle(rect, list);
			}
		}

		public function getChilds() : Vector.<SDisplay>
		{
			if (isLock)
				return null;
			return mChilds;
		}

		public override function getAsCode(manager : SCodeManager) : String
		{
			var code : String = "";
			for each (var child : SDisplay in mChilds)
			{
				code += child.getAsCode(manager);
			}
			return code;
		}

	}
}