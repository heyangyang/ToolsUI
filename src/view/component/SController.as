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
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	import core.Config;

	import managers.SEventManager;
	import managers.SHistoryManager;
	import managers.SelectedManager;

	import view.SViewController;

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
		private var mStartMouseX : Number;
		private var mStartMouseY : Number;
		private var mIsClick : Boolean;
		/**
		 * 是否按下了shift
		 */
		private var mIsDownShiftKey : Boolean;
		private var mIsDownSpaceKey : Boolean;

		/**
		 * 是否在绘画
		 */
		private var mIsDrawing : Boolean;
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
			focusRect = false;
			tabChildren = tabEnabled = false;
			mScale = 1;
			addChild(mGroup);
			mGroup.addChild(mBg);
			mGroup.addChild(mBgImage);
			addChild(mDragAnimation);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}

		public function initUi(value : SView) : void
		{
			SelectedManager.clear();
			SHistoryManager.clear();
			mView && mView.removeFromParent();
			mView = value;
			mGroup.addChild(mView);
			mBg.graphics.beginFill(0x333333);
			mBg.graphics.drawRect(0, 0, value.width, value.height);
			mBg.graphics.endFill();
			addEventListener(MouseEvent.MOUSE_MOVE, onMoveHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, onDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, onUpHandler);
		}

		/**
		 * 鼠标按下
		 * @param evt
		 *
		 */
		private function onDownHandler(evt : MouseEvent) : void
		{
			mIsClick = true;
			var child : SDisplay = evt.target as SDisplay;
			mStartMouseX = mLastMouseX = mouseX;
			mStartMouseY = mLastMouseY = mouseY;
			mIsDrawing = !child || child.getParent().isLock;
			if (mIsDrawing)
			{
				SelectedManager.setTmpTarget(null);
				return;
			}
			if (child && SelectedManager.list.indexOf(child) == -1)
			{
				SelectedManager.clear();
				SelectedManager.setTmpTarget(child);
			}
		}

		/**
		 * 鼠标移动
		 */
		private function onMoveHandler(evt : MouseEvent) : void
		{
			//是否按下了鼠标主键
			if (!mIsClick)
				return;
			//如果按下了空格，则移动画布
			if (mIsDownSpaceKey)
			{
				mGroup.x += mouseX - mLastMouseX;
				mGroup.y += mouseY - mLastMouseY;
				mLastMouseX = mouseX;
				mLastMouseY = mouseY;
				return;
			}
			if (!mIsDrawing)
			{
				//如果有选中的组件，则移动组件
				if (SelectedManager.numChildren > 0 || SelectedManager.tmpTarget)
				{
					SelectedManager.move((mouseX - mLastMouseX) / mScale, (mouseY - mLastMouseY) / mScale);
					mLastMouseX = mouseX;
					mLastMouseY = mouseY;
				}
			}
			//画选择框
			else
			{
				drawDragAnimation();
			}
		}


		/**
		 * 鼠标弹起
		 * @param evt
		 *
		 */
		private function onUpHandler(evt : MouseEvent) : void
		{
			mIsClick = false;
			//框选组件
			if (mIsDrawing)
			{
				mIsDrawing = false;
				mHitTestList.length = 0;
				mView.hitTestRectangle(mDragAnimation, mHitTestList);
				if (mHitTestList.length > 0 && !isSameArray(mHitTestList, SelectedManager.list))
					updateSelectedAndUpdateHistory(mHitTestList, SHistoryManager.SELECT);
				if (mHitTestList.length == 0)
				{
					SelectedManager.clear();
					SEventManager.dispatch(SEventManager.UPDATE_FIELD);
				}
				mDragAnimation.graphics.clear();
			}
			else
			{
				if (SelectedManager.tmpTarget)
				{
					if (SelectedManager.tmpTarget.getParent().isLock)
						return;
					onComponentDownHandler(SelectedManager.tmpTarget);
					SelectedManager.setTmpTarget(null);
				}
				if (SelectedManager.numChildren == 0)
					return;
				//没有移动
				if (mStartMouseX == mouseX && mStartMouseY == mouseY)
					return;
				SelectedManager.move(mStartMouseX - mouseX, mStartMouseY - mouseY);
				SHistoryManager.push(SelectedManager.list, SHistoryManager.MOVE);
				SelectedManager.move(mouseX - mStartMouseX, mouseY - mStartMouseY);
			}
		}

		private function onComponentDownHandler(child : SDisplay) : void
		{
			var layer : SLayer = child.getParent();
			if (layer.isLock || !layer.visible)
				return;
			if (mIsDownSpaceKey)
				return;
			//如果已经在选中列表中
			if (SelectedManager.list.indexOf(child) >= 0)
				return;
			//按住shift才能连续选中，没有按住的时候只能选中一个原件
			if (!mIsDownShiftKey && SelectedManager.numChildren == 1)
			{
				SelectedManager.clear();
			}
			SelectedManager.push(child);
			SHistoryManager.push(SelectedManager.list, SHistoryManager.SELECT);
			//切换到当前原件的图层
			mView.selectLayer = child.getParent();
			SEventManager.dispatch(SEventManager.UPDATE_VIEW, mView);
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

		/**
		 * 根据xml创建原件
		 * @param value
		 *
		 */
		public function createDisplayByXml(value : XML) : void
		{
			var resName : String = value.@label;
			var swfName : String = value.@swf;
			var type : String = value.@type;
			var child : Sprite = Config.createDisplayByName(resName);
			if (child)
			{
				var display : SDisplay = SLayer.getDataType(type);
				display.isLostRes = child.name == "";
				display.setDisplay(child);
				display.x = mGroup.mouseX - child.width * .5;
				display.y = mGroup.mouseY - child.height * .5;
				display.res = resName;
				display.swf = swfName;
				display.type = type;
				mView.curLayer.addDisplay(display);
				SelectedManager.clear();
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
			stage.focus = this;
			focusRect = false;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
		}

		private function onRollOut(evt : Event) : void
		{
			mIsClick = mIsDownShiftKey = isDownSpaceKey = false;
			mDragAnimation.graphics.clear();
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
					case Keyboard.A:
						updateSelectedAndUpdateHistory(mView.getChilds(), SHistoryManager.SELECT);
						break;
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
					case Keyboard.UP:
						if (SelectedManager.checkChlidIndex(1))
						{
							SHistoryManager.push(SelectedManager.list, SHistoryManager.INDEX);
							SelectedManager.setChlidIndex(1);
						}
						break;
					case Keyboard.DOWN:
						if (SelectedManager.checkChlidIndex(-1))
						{
							SHistoryManager.push(SelectedManager.list, SHistoryManager.INDEX);
							SelectedManager.setChlidIndex(-1);
						}
						break;
					case Keyboard.EQUAL:
						setScale(mScale + mScale);
						SEventManager.dispatch(SViewController.UPDATE_SCALE, mScale * 100);
						break;
					case Keyboard.MINUS:
						setScale(mScale * 0.5);
						SEventManager.dispatch(SViewController.UPDATE_SCALE, mScale * 100);
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
				mIsDownShiftKey = true;
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
			var newChild : SDisplay;
			var selectedList : Vector.<SDisplay> = new Vector.<SDisplay>();
			for each (var child : SDisplay in list)
			{
				newChild = SLayer.getDataType(child.type);
				newChild.parseObject(child.toObject());
				mView.curLayer.addDisplay(newChild);
				newChild.x += offsetX;
				newChild.y += offsetY;
				newChild.loadResourceComplete();
				selectedList.push(newChild);
			}
			updateSelectedAndUpdateHistory(selectedList, SHistoryManager.ADD);
		}

		protected function onKeyUpHandler(evt : KeyboardEvent) : void
		{
			mIsDownShiftKey = false;
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

		/**
		 * 选中，并且更新历史记录
		 * @param list
		 * @param type
		 *
		 */
		private function updateSelectedAndUpdateHistory(list : Vector.<SDisplay>, type : String) : void
		{
			if (!list || list.length == 0)
				return;
			SelectedManager.clear();
			SelectedManager.setList(list);
			SHistoryManager.push(list, type);
		}

		/**
		 * 数组内容是否一样
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		private function isSameArray(a : Vector.<SDisplay>, b : Vector.<SDisplay>) : Boolean
		{
			if (a.length != b.length)
				return false;
			for each (var child : SDisplay in a)
			{
				if (b.indexOf(child) == -1)
					return false;
			}
			return true;
		}

		/**
		 * 是否按下了空格
		 */
		private function get isDownSpaceKey() : Boolean
		{
			return mIsDownSpaceKey;
		}

		/**
		 * @private
		 */
		private function set isDownSpaceKey(value : Boolean) : void
		{
			mIsDownSpaceKey = value;
			if (value)
				Mouse.cursor = MouseCursor.BUTTON;
			else
				Mouse.cursor = MouseCursor.ARROW;
		}

	}
}