package view.component
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import core.Config;

	public class SLoading extends Sprite
	{
		private static var instance : SLoading;

		public static function getInstance() : SLoading
		{
			if (instance == null)
				instance = new SLoading();
			return instance;
		}
		private const COUNT : int = 3;
		private const CLOSE_TIME : int = 600;
		private var text : TextField;
		private var runTime : int;
		private var delayTime : int;
		private var index : int = 0;
		private var mTxtArray : Array = [];

		public function SLoading()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}

		private function onAddToStage(evt : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			var shape : Shape = new Shape();
			shape.graphics.beginFill(0x00000, 0.5);
			shape.graphics.drawRect(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			shape.graphics.endFill();
			addChild(shape);
			text = new TextField();
			text.width = 150;
			text.defaultTextFormat = new TextFormat("SimSun", 20, 0xffffff, false, false, false, null, null, TextFormatAlign.LEFT);
			text.x = (stage.fullScreenWidth - 150) * .5;
			text.y = stage.fullScreenHeight * .5;
			addChild(text);

			var tText : String;
			for (var i : int = 0; i < COUNT; i++)
			{
				tText = "";
				while (tText.length <= i)
					tText += ".";
				tText = "正在加载中" + tText;
				mTxtArray.push(tText);
			}
		}

		public function show() : void
		{
			if (parent)
				return;
			index = 0;
			if (mTxtArray.length > 0)
				text.text = mTxtArray[index];
			delayTime = runTime = getTimer();
			Config.stage.addChild(this);
			addEventListener(Event.ENTER_FRAME, onUpdate);
		}

		private function onUpdate(evt : Event) : void
		{
			if (getTimer() - delayTime < 200)
				return;
			delayTime = getTimer();
			text.text = mTxtArray[index];
			if (++index > 3)
				index = 0;
		}

		public function hide(fun : Function = null) : void
		{
			if (getTimer() - runTime < CLOSE_TIME)
			{
				setTimeout(hide, CLOSE_TIME - (getTimer() - runTime), fun);
				return;
			}
			fun != null && fun.apply(this);
			removeEventListener(Event.ENTER_FRAME, onUpdate);
			parent && parent.removeChild(this);
		}
	}
}