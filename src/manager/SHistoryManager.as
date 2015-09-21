package manager
{
	import view.component.SDisplay;

	public class SHistoryManager
	{
		public static const ADD : String = "add";
		public static const MOVE : String = "move";
		public static const DEL : String = "del";
		public static const SELECT : String = "select";
		public static const INDEX : String = "index";
		private static var mList : Array = [];

		public static function push(list : Vector.<SDisplay>, type : String) : void
		{
			var saveList : Array = [];
			var data : SHistory;
			for each (var child : SDisplay in list)
			{
				data = new SHistory();
				data.data = child.toObject();
				data.layer = child.getParent();
				data.display = child;
				saveList.push(data);
			}
			mList.push({"list": saveList, "type": type});
			SEventManager.dispatch(SEventManager.UPDATE_HISTORY, mList);
		}

		/**
		 * 回滚
		 *
		 */
		public static function rollBackHistory() : void
		{
			if (mList.length == 0)
				return;
			var data : Object = mList.pop();
			var list : Array = data.list;
			var type : String = data.type;
			SelectedManager.clear();

			var child : SDisplay;
			for each (var history : SHistory in list)
			{
				child = history.display;
				switch (type)
				{
					case ADD:
						child.removeFromParent();
						break;
					case MOVE:
						child.parseObject(history.data);
						SelectedManager.push(child);
						break;
					case DEL:
						history.layer.addDisplay(child);
						SelectedManager.push(child);
						break;
					case SELECT:
						SelectedManager.push(child);
						break;
					case INDEX:
						child.getParent().setDisplayIndex(child, child.index);
						break;
				}
				history.dispose();
			}
			if (type == SELECT)
			{
				SelectedManager.clear();
				if (mList.length >= 1)
				{
					data = mList[mList.length - 1];
					for each (history in data.list)
					{
						SelectedManager.push(history.display);
					}
				}
			}
			if (mList.length == 0)
				SelectedManager.clear();
			SEventManager.dispatch(SEventManager.UPDATE_HISTORY, mList);
		}

		public static function clear() : void
		{
			mList.length = 0;
			SEventManager.dispatch(SEventManager.UPDATE_HISTORY, mList);
		}
	}
}
import view.component.SDisplay;
import view.component.SLayer;

class SHistory
{
	public var data : Object;
	public var display : SDisplay;
	public var layer : SLayer;

	public function dispose() : void
	{
		data = null;
		display = null;
		layer = null;
	}
}

