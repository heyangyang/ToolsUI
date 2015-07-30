package view.component
{
	import com.senocular.display.TransformTool;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import manager.EventManager;
	import core.data.ViewBase;

	public class CSprite extends Sprite
	{
		public var isLostRes : Boolean = false;
		public var display : DisplayObject;
		public var transformTool : TransformTool;
		public var data : ViewBase;

		public function CSprite(display : DisplayObject)
		{
			super();
			this.display = display;
			addChild(display);
			if (display is MovieClip)
				MovieClip(display).gotoAndStop(0);
			if (display is InteractiveObject)
				InteractiveObject(display).mouseEnabled = false;
			transformTool = new TransformTool();
			transformTool.registrationEnabled = false;
			transformTool.skewEnabled = false;
			transformTool.rotationEnabled = false;
			transformTool.moveEnabled = false;
			transformTool.scaleEnabled = false;
			addChild(transformTool);
			mouseChildren = false;
		}

		public function set target(value : Boolean) : void
		{
			transformTool.target = value ? display : null;
		}

		override public function set width(value : Number) : void
		{
			display.width = value;
		}

		override public function set height(value : Number) : void
		{
			display.height = value;
		}
		
		override public function get width() : Number
		{
			return display.width;
		}

		override public function get height() : Number
		{
			return display.height;
		}
		
		public function dispatch(evt : String, data : Object = null) : void
		{
			EventManager.getInstance().dispatch(evt, data);
		}
	}
}