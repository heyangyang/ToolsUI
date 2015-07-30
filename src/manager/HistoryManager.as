package manager
{
	import core.Config;


	import view.component.CSprite;
	import core.data.ViewBase;

	/**
	 * 历史记录处理
	 * @author Administrator
	 *
	 */
	public class HistoryManager
	{
		public static const CHANGE : int = 0;
		public static const ADD : int = 2;
		private static var instance : HistoryManager;

		public static function Ins() : HistoryManager
		{
			if (instance == null)
				instance = new HistoryManager();
			return instance;
		}

		public var history_list : Array = [];

		public function get length() : int
		{
			return history_list.length;
		}

		/**
		 * 获得最后一条
		 * @return
		 *
		 */
		public function pop() : Array
		{
			return history_list.pop();
		}

		/**
		 * 回滚最近一次历史记录
		 */
		public function rollBackHistory(excute : Function) : void
		{
			if (history_list.length == 0)
				return;
			var history_change_list : Object = history_list.pop();
			var tmp_history_list : Array = history_change_list.data;
			var len : int = tmp_history_list.length;
			var history_data : Object;
			for (var i : int = 0; i < len; i++)
			{
				history_data = tmp_history_list[i];
				//历史记录操作的原数据
				var viewData : ViewBase = history_data.data;
				if (history_change_list.type == ADD)
				{
					viewData.dispose();
					continue;
				}
				//还原数据
				viewData.parse(history_data);
				//原件更新数据
				viewData.updateView();
				//外界需要处理函数
				excute != null && excute(viewData, history_data.dis_index);
			}
			EventManager.dispatch(EventManager.UPDATE_HISTORY);
		}

		/**
		 * 根据一个列表，获得数据，并且更新数据
		 * @param list
		 * @param type
		 *
		 */
		public function addHistoryByList(list : Vector.<CSprite>, type : int = CHANGE) : void
		{
			var len : int = list.length;
			var tmp_history : Array = [];
			var viewData : ViewBase;
			var display : CSprite;
			for (var i : int = 0; i < len; i++)
			{
				display = list[i];
				if (display == null)
					continue;
				//获得当前对象
				viewData = Config.view.getTargetData(display);
				//记录数据
				tmp_history.push(viewData.historyData);
				//更新数据
				viewData.updateData();
			}

			if (tmp_history.length > 0)
				addHistory(tmp_history, type);
		}

		/**
		 * 添加历史记录
		 */
		private function addHistory(data : Array, type : int = CHANGE) : void
		{
			history_list.push({"type": type, "data": data});
			EventManager.dispatch(EventManager.UPDATE_HISTORY);
		}

		/**
		 * 移除历史记录
		 * @param data
		 *
		 */
		public function removeHistory(data : Object) : void
		{
			if (data == null)
				history_list.length = 0;
			var index : int = history_list.indexOf(data);
			if (index != -1)
				history_list.splice(index, 1);
			EventManager.dispatch(EventManager.UPDATE_HISTORY);
		}
	}
}