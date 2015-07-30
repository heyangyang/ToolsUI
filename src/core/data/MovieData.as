package core.data
{
	public class MovieData extends ViewBase
	{
		public function MovieData()
		{
			super();
		}
		
		/**
		 * 解析数据
		 * @param obj
		 *
		 */
		override public function parse(obj : Object) : void
		{
			super.parse(obj);
			touchable = true;
		}
	}
}