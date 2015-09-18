package manager
{
	import view.component.SDisplay;

	public class SHistoryManager
	{
		public static const ADD : String = "add";
		public static const MOVE : String = "move";
		public static const DEL : String = "del";
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

			for each (var history : SHistory in list)
			{
				switch (type)
				{
					case ADD:
						history.display.removeFromParent();
						break;
					case MOVE:
						history.display.parseObject(history.data);
						SelectedManager.push(history.display);
						break;
					case DEL:
						history.layer.addDisplay(history.display);
						SelectedManager.push(history.display);
						break;
				}
				history.dispose();
			}
			if (type == ADD && mList.length >= 1)
			{
				data = mList[mList.length - 1];
				SelectedManager.clear();
				for each (history in data.list)
				{
					SelectedManager.push(history.display);
				}
			}
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

