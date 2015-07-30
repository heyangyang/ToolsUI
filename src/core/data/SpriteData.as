package core.data
{
	

	public class SpriteData extends ViewBase
	{
		public function SpriteData()
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