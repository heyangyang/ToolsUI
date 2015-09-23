package view.component
{
	import com.senocular.display.TransformTool;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class SDisPlayBase extends Sprite
	{
		internal var mDisplay : DisplayObject;
		private var transformTool : TransformTool;
		private var mSelected : Boolean;

		public function SDisPlayBase()
		{
			super();
			transformTool = new TransformTool();
			transformTool.registrationEnabled = false;
			transformTool.skewEnabled = false;
			transformTool.rotationEnabled = false;
			transformTool.moveEnabled = false;
			transformTool.scaleEnabled = false;
		}

		public function setDisplay(child : DisplayObject) : void
		{
			mDisplay && removeChild(mDisplay);
			mDisplay = child;
			addChild(mDisplay);
			if (mDisplay is MovieClip)
				MovieClip(mDisplay).gotoAndStop(0);
			if (mDisplay is InteractiveObject)
				InteractiveObject(mDisplay).mouseEnabled = false;
		}

		public function set selected(value : Boolean) : void
		{
			if (mSelected == value)
				return;
			mSelected = value;
			value ? addChild(transformTool) : removeChild(transformTool);
			transformTool.target = value ? mDisplay : null;
		}

		override public function set width(value : Number) : void
		{
			mDisplay.width = value;
		}

		override public function set height(value : Number) : void
		{
			mDisplay.height = value;
		}

		override public function get width() : Number
		{
			return mDisplay.width;
		}

		override public function get height() : Number
		{
			return mDisplay.height;
		}
	}
}