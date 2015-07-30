package view.component
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import core.Config;

	public class CLoading extends Sprite
	{
		private static var instance : CLoading;

		public static function getInstance() : CLoading
		{
			if (instance == null)
				instance = new CLoading();
			return instance;
		}
		private var text : CTextDisplay;
		private var runTime : int;
		private var delayTime : int;
		private var index : int = 0;

		public function CLoading()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}

		private function onAddToStage(evt : Event) : void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			var shape : Shape = new Shape();
			shape.graphics.beginFill(0x00000, 0.5);
			shape.graphics.drawRect(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			shape.graphics.endFill();
			addChild(shape);
			text = new CTextDisplay();
			text.fontSize = 20;
			text.width = 150;
			text.align = "left";
			text.x = (stage.fullScreenWidth - 150) * .5;
			text.y = stage.fullScreenHeight * .5;
			addChild(text);
		}

		public function show() : void
		{
			index = 0;
			delayTime = runTime = getTimer();
			Config.stage.addChild(this);
			this.addEventListener(Event.ENTER_FRAME, onUpdate);
		}

		private function onUpdate(evt : Event) : void
		{
			if (getTimer() - delayTime < 200)
				return;
			delayTime = getTimer();
			text.text = "正在加载中";
			for (var i : int = 0; i < index; i++)
				text.text += ".";
			index++;
			if (index > 3)
				index = 0;
		}

		public function hide(fun : Function = null) : void
		{
			if (getTimer() - runTime < 600)
			{
				setTimeout(hide, 600 - (getTimer() - runTime), fun);
				return;
			}
			fun != null && fun.apply(this);
			this.removeEventListener(Event.ENTER_FRAME, onUpdate);
			parent && parent.removeChild(this);
		}
	}
}