package core.data
{
	

	public class ComponnetSprite extends SViewBase
	{
		public function ComponnetSprite()
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