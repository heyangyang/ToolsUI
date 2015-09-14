package core.data
{
	import view.component.CList;

	public class ComponnetList extends SViewBase
	{
		public var render : String;
		public var layout : String;
		public var vGap : int;
		public var hGap : int;

		public function ComponnetList()
		{
			super();
		}

		/**
		 * 转换成生成数据
		 * @return
		 *
		 */
		override public function get data() : Object
		{
			var tmp : Object = super.data;
			tmp.render = render;
			tmp.layout = layout;
			tmp.vGap = vGap;
			tmp.hGap = hGap;
			return tmp;
		}

		/**
		 * 解析数据
		 * @param obj
		 *
		 */
		override public function parse(obj : Object) : void
		{
			super.parse(obj);
			render = obj.render;
			layout = obj.layout;
			vGap = obj.vGap;
			hGap = obj.hGap;
		}

		override public function updateView() : void
		{
			super.updateView();
			CList(display).updateView();
		}

	}
}