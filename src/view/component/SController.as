package view.component
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	import core.Config;
	import core.SUi;

	import manager.SHistoryManager;
	import manager.SelectedManager;

	public class SController extends Sprite
	{
		/**
		 * 纯色背景
		 */
		private var mBg : Shape = new Shape();
		/**
		 * 背景图片
		 */
		private var mBgImage : Bitmap = new Bitmap();

		private var mGroup : Sprite = new Sprite();
		/**
		 * 拖动的形状
		 */
		private var mDragAnimation : Shape = new Shape();

		private var mWidth : int;
		private var mHeight : int;
		private var mScale : Number;
		private var mLastMouseX : Number;
		private var mLastMouseY : Number;
		/**
		 * 是否按下了shift
		 */
		private var isDownShiftKey : Boolean;
		/**
		 * 是否按下了空格
		 */
		private var isDownSpaceKey : Boolean;
		/**
		 * 当前ui界面
		 */
		private var mView : SView;
		/**
		 * 碰撞列表
		 */
		private var mHitTestList : Vector.<SDisplay> = new Vector.<SDisplay>();
		/**
		 * 剪贴列表
		 */
		private var mCopyList : Vector.<SDisplay> = new Vector.<SDisplay>();

		public function SController()
		{
			super();
			init();
		}

		private function init() : void
		{
			mScale = 1;
			addChild(mGroup);
			mGroup.addChild(mBg);
			mGroup.addChild(mBgImage);
			addChild(mDragAnimation);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			Config.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoveHandler);
			Config.stage.addEventListener(MouseEvent.MOUSE_DOWN, onDownHandler);
			Config.stage.addEventListener(MouseEvent.MOUSE_UP, onUpHandler);
		}

		public function initUi(value : SUi) : void
		{
			mView && mView.removeFromParent();
			mView = value.view;
			mGroup.addChild(mView);
			mBg.graphics.beginFill(0x333333);
			mBg.graphics.drawRect(0, 0, value.width, value.height);
			mBg.graphics.endFill();
		}

		/**
		 * 鼠标弹起
		 * @param evt
		 *
		 */
		private function onUpHandler(evt : MouseEvent) : void
		{
			if (!mView)
				return;
			if (!(evt.target is SDisplay))
				SelectedManager.clear();
			mHitTestList.length = 0;
			mView.hitTestRectangle(mDragAnimation, mHitTestList);
			if (mHitTestList.length > 0)
			{
				SelectedManager.clear();
				SelectedManager.setList(mHitTestList);
			}
			mDragAnimation.graphics.clear();
		}

		/**
		 * 鼠标按下
		 * @param evt
		 *
		 */
		private function onDownHandler(evt : MouseEvent) : void
		{
			mLastMouseX = mouseX;
			mLastMouseY = mouseY;

			var child : SDisplay = evt.target as SDisplay;
			if (child)
			{
				onComponentDownHandler(child);
			}
			else
			{
				SelectedManager.clear();
			}
		}

		private function onComponentDownHandler(child : SDisplay) : void
		{
			var layer : SLayer = child.getParent();
			if (layer.isLock || !layer.visible)
				return;
			if (isDownSpaceKey)
				return;

			if (!isDownShiftKey && SelectedManager.numChildren == 1)
			{
				SelectedManager.clear();
			}
			SelectedManager.push(child);
			SHistoryManager.push(SelectedManager.list, SHistoryManager.MOVE);
		}

		/**
		 * 鼠标移动
		 */
		private function onMoveHandler(evt : MouseEvent) : void
		{
			//是否按下了鼠标主键
			if (!evt.buttonDown)
				return;
			//如果按下了空格，则移动画布
			if (isDownSpaceKey)
			{
				mGroup.x += mouseX - mLastMouseX;
				mGroup.y += mouseY - mLastMouseY;
				mLastMouseX = mouseX;
				mLastMouseY = mouseY;
				return;
			}
			//如果有选中的组件，则移动组件
			if (SelectedManager.numChildren > 0)
			{
				SelectedManager.move((mouseX - mLastMouseX) / mScale, (mouseY - mLastMouseY) / mScale);
				mLastMouseX = mouseX;
				mLastMouseY = mouseY;
				return;
			}
			//画选择框
			drawDragAnimation();
		}

		public function setScale(value : Number) : void
		{
			if (mScale == value)
				return;
			//原来的点
			var tox : Number = (mWidth - mBg.width * mScale) * .5;
			var toy : Number = (mHeight - mBg.height * mScale) * .5;
			//应该移动的点
			var tx : Number = (mWidth - mBg.width * value) * .5;
			var ty : Number = (mHeight - mBg.height * value) * .5;

			mGroup.x += tx - tox;
			mGroup.y += ty - toy;
			mScale = value;
			mGroup.scaleX = mGroup.scaleY = value;
		}

		/**
		 * 容器大小，不是画布大小
		 * @param w
		 * @param h
		 *
		 */
		public function setSize(w : int, h : int) : void
		{
			mWidth = w;
			mHeight = h;
			//需要移动的点
			mGroup.x = (mWidth - mBg.width * mScale) * .5;
			mGroup.y = (mHeight - mBg.height * mScale) * .5;
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, mWidth, mHeight);
			graphics.endFill();
			setScale(mScale);
		}

		public function push(value : XML) : void
		{
			var res_name : String = value.@label;
			var swf_name : String = value.@swf;
			var type : String = value.@type;
			var child : Sprite = Config.createDisplayByName(res_name);
			if (child)
			{
				var display : SDisplay = SLayer.getDataType(type);
				display.setDisplay(child);
				display.x = mGroup.mouseX - child.width * .5;
				display.y = mGroup.mouseY - child.height * .5;
				display.res = res_name;
				display.swf = swf_name;
				display.type = type;
				mView.curLayer.addDisplay(display);
				SelectedManager.push(display);
				SHistoryManager.push(SelectedManager.list, SHistoryManager.ADD);
			}
		}

		public function setBgImage(value : BitmapData) : void
		{
			mBgImage.bitmapData = value;
		}


		private function onRollOver(evt : Event) : void
		{
			stage.focus = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
		}

		private function onRollOut(evt : Event) : void
		{
			isDownShiftKey = isDownSpaceKey = false;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
		}

		/**
		 * 响应键盘事件
		 */
		protected function onKeyDownHandler(evt : KeyboardEvent) : void
		{
			if (evt.ctrlKey)
			{
				switch (evt.keyCode)
				{
					case Keyboard.Z:
						SHistoryManager.rollBackHistory();
						break;
					case Keyboard.C:
						mCopyList.length = 0;
						mCopyList = mCopyList.concat(SelectedManager.list);
						break;
					case Keyboard.V:
						cutChildList(mCopyList, 10, 10);
						break;
				}
			}
			else
			{
				switch (evt.keyCode)
				{
					case Keyboard.SPACE:
						isDownSpaceKey = true;
						break;
					case Keyboard.BACKSPACE:
					case Keyboard.DELETE:
						SHistoryManager.push(SelectedManager.list, SHistoryManager.DEL);
						SelectedManager.removeAll();
						break;
				}
			}
			if (!evt.altKey && evt.shiftKey)
			{
				isDownShiftKey = true;
			}
		}

		/**
		 * 粘贴
		 * @param list
		 * @param offsetX
		 * @param offsetY
		 *
		 */
		private function cutChildList(list : Vector.<SDisplay>, offsetX : int = 0, offsetY : int = 0) : void
		{
			SelectedManager.clear();
			var newChild : SDisplay;
			for each (var child : SDisplay in list)
			{
				newChild = SLayer.getDataType(child.type);
				newChild.parseObject(child.toObject());
				mView.curLayer.addDisplay(newChild);
				newChild.x += offsetX;
				newChild.y += offsetY;
				newChild.loadResourceComplete();
				SelectedManager.push(newChild);
			}
			SHistoryManager.push(SelectedManager.list, SHistoryManager.ADD);
		}

		protected function onKeyUpHandler(evt : KeyboardEvent) : void
		{
			isDownShiftKey = false;
			switch (evt.keyCode)
			{
				case Keyboard.SPACE:
					isDownSpaceKey = false;
					break;
			}
		}

		/**
		 *  选择框
		 *
		 */
		private function drawDragAnimation() : void
		{
			mDragAnimation.graphics.clear();
			mDragAnimation.graphics.lineStyle(0, 0x00ffff, 1);
			mDragAnimation.graphics.moveTo(mLastMouseX, mLastMouseY);
			mDragAnimation.graphics.lineTo(mouseX, mLastMouseY);
			mDragAnimation.graphics.lineTo(mouseX, mouseY);
			mDragAnimation.graphics.lineTo(mLastMouseX, mouseY);
			mDragAnimation.graphics.lineTo(mLastMouseX, mLastMouseY);
			mDragAnimation.graphics.endFill();
		}
	}
}