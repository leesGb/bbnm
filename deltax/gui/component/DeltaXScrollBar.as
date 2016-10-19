//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.*;
    import deltax.gui.component.event.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.common.math.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;
    import com.stimuli.string.*;
	
	/**
	 * 滚动条<br>
	 * 滚动事件：DXWndEvent.STATE_CHANGED
	 * @author admin
	 */
    public class DeltaXScrollBar extends DeltaXWindow {

        public static const VERTICAL:uint = 0;
        public static const HORIZONTAL:uint = 1;
		
		/** 拖动块按钮 */
        private var m_thumbBtn:DeltaXButton;
		
		/** 向下按钮 */
        private var m_incrementBtn:DeltaXButton;
		
		/** 向上按钮 */
        private var m_decrementBtn:DeltaXButton;
        private var m_range:uint = 100;
        private var m_pageSize:uint = 10;
        private var m_value:Number = 0;
        private var m_scrollStep:uint = 5;
        private var m_holdTime:uint = 4294967295;
        private var m_thumbBtnToolTipStr:String;

		public function get decrementBtn():DeltaXButton
		{
			return m_decrementBtn;
		}

		public function get incrementBtn():DeltaXButton
		{
			return m_incrementBtn;
		}

		public function get thumbBtn():DeltaXButton
		{
			return m_thumbBtn;
		}

        public function get scrollStep():uint{
            return (this.m_scrollStep);
        }
        public function set scrollStep(value:uint):void{
            this.m_scrollStep = value;
        }
		
		/**
		 * 滚动条类型
		 */
        public function get orient():uint{
            return (((style & ScrollStyle.HORIZON)) ? HORIZONTAL : VERTICAL);
        }
		
		/**
		 * 滚动条最大值
		 */
        public function get range():uint{
            return (this.m_range);
        }
        public function set range(value:uint):void{
            if (this.m_range == value){
                return;
            };
            this.m_range = value;
            invalidate();
            this._processMove(true);
        }
        public function get pageSize():uint{
            return (this.m_pageSize);
        }
        public function set pageSize(value:uint):void{
            if (this.m_pageSize == value){
                return;
            };
            this.m_pageSize = value;
            invalidate();
            this._processMove(true);
        }
		
		/**
		 * 滚动值
		 */
        public function get value():uint{
            return this.m_value;
        }
        public function set value(valuePostion:uint):void{
            if (this.m_value == valuePostion){
                return;
            };
            this.m_value = valuePostion;
            invalidate();
            this._processMove(true);
            this.setThumbBtnToolTipChangeByValue(this.m_thumbBtnToolTipStr);
        }
		
		/**
		 * 是否是垂直滚动条
		 */
        public function get isVertical():Boolean{
            return this.orient == VERTICAL;
        }
		
		/**
		 * 初始化向上、向下、拖动块按钮
		 */
        override protected function _onWndCreatedInternal():void{
            var _local1:uint = (WindowStyle.CHILD | WindowStyle.NO_MOUSEWHEEL);
            var _local2:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            _local2[0] = m_properties.getSubCtrlInfo(ScrollBarSubCtrlType.UP_BUTTON);
            this.m_incrementBtn = new DeltaXButton();
            this.m_incrementBtn.createFromDispItemInfo("", _local2, _local1, this);
            this.m_incrementBtn.lockFlag = (LockFlag.RIGHT | LockFlag.BOTTOM);
            _local2[0] = m_properties.getSubCtrlInfo(ScrollBarSubCtrlType.DOWN_BUTTON);
            this.m_decrementBtn = new DeltaXButton();
            this.m_decrementBtn.createFromDispItemInfo("", _local2, _local1, this);
            this.m_decrementBtn.lockFlag = (LockFlag.LEFT | LockFlag.TOP);
            _local2[0] = m_properties.getSubCtrlInfo(ScrollBarSubCtrlType.THUMB);
            this.m_thumbBtn = new DeltaXButton();
            this.m_thumbBtn.createFromDispItemInfo("", _local2, _local1, this);
            this.m_thumbBtn.setToolTipText(this.m_thumbBtnToolTipStr);
            this.installListeners();
            super._onWndCreatedInternal();
        }
		
		/**
		 * 初始化事件
		 */
        protected function installListeners():void{
            this.m_incrementBtn.addEventListener(DXWndEvent.ACTION, this._incrButtonPress);
            this.m_decrementBtn.addEventListener(DXWndEvent.ACTION, this._decrButtonPress);
            this.m_thumbBtn.addEventListener(DXWndMouseEvent.DRAG, this._thumbButtonDrag);
            this.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this._onMouseWheelFromChild);
        }
		
		/**
		 * 设置拖动块tip
		 */
        public function setThumbBtnToolTip(value:String):void{
            this.m_thumbBtnToolTipStr = value;
            if (this.m_thumbBtn){
                this.m_thumbBtn.setToolTipText(value);
            };
        }
        public function setThumbBtnToolTipChangeByValue(value:String):void{
            this.m_thumbBtnToolTipStr = value;
            if (this.m_thumbBtn){
                this.m_thumbBtn.setToolTipText(printf(value, this.value));
            };
        }
		
		/**
		 * 背景渲染。<br>
		 * 如果按住向上、向下、当前滚动条则每隔500毫秒一次自动触发点击。<br>
		 * 按住向下按钮，会自动每个500毫秒滚动下来一次.
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        override protected function renderBackground(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
            var _local4:DeltaXWindow = m_guiManager.holdWnd;
            if (this.m_holdTime == 4294967295){
                if ((((((_local4 == this)) || ((_local4 == this.m_incrementBtn)))) || ((_local4 == this.m_decrementBtn)))){
                    this.m_holdTime = (valueGetTimer + 500);
                };
            } else {
                if (valueGetTimer > this.m_holdTime){
                    this.m_holdTime = (this.m_holdTime + 100);
                    if (_local4 == this){
                        this._onMouseDown((mouseX - globalX), (mouseY - globalY));
                    } else {
                        if (_local4 == this.m_incrementBtn){
                            this._incrButtonPress(null);
                        } else {
                            if (_local4 == this.m_decrementBtn){
                                this._decrButtonPress(null);
                            } else {
                                this.m_holdTime = 4294967295;
                            };
                        };
                    };
                };
            };
            super.renderBackground(context3D, valueGetTimer, fpsTime);
        }
		
		/**
		 * 鼠标滚轮事件
		 */
        private function _onMouseWheelFromChild(event:DXWndMouseEvent):void{
            this.mouseWheelManually(event.delta);
        }
		
		/**
		 * 鼠标滚动
		 */
        public function mouseWheelManually(delta:Number):void{
            this.m_value = MathUtl.limit((this.m_value - (delta * this.m_scrollStep)), 0, this.m_range);
            this._processMove(true);
        }
		
        override protected function onMouseDown(mousePoint:Point, ctrlKey:Boolean, shiftKey:Boolean, altKey:Boolean):void{
            this._onMouseDown(mousePoint.x, mousePoint.y);
        }
		
		/**
		 * 鼠标按下
		 * @param	mousex		按下的x坐标
		 * @param	mousey		按下的y坐标
		 */
        private function _onMouseDown(mousex:uint, mousey:uint):void{
            var t_value:Number = this.m_value;
            if (this.isVertical){
                if (mousey < this.m_thumbBtn.y){
                    t_value = (t_value - this.m_pageSize);
                } else {
                    if (mousey > (this.m_thumbBtn.y + this.m_thumbBtn.height)){
                        t_value = (t_value + this.m_pageSize);
                    };
                };
            } else {
                if (mousex < this.m_thumbBtn.x){
                    t_value = (t_value - this.m_pageSize);
                } else {
                    if (mousex > (this.m_thumbBtn.x + this.m_thumbBtn.width)){
                        t_value = (t_value + this.m_pageSize);
                    };
                };
            };
            if (t_value != this.m_value){
                this.m_value = MathUtl.limit(t_value, 0, this.m_range);
                this._processMove(true);
            };
        }
		/**
		 * 向下滚动
		 */
        private function _incrButtonPress(event:DXWndEvent):void{
            this.m_value = MathUtl.limit((this.m_value + this.m_scrollStep), 0, this.m_range);
            this._processMove(true);
        }
		
		/**
		 * 向上滚动
		 */
        private function _decrButtonPress(event:DXWndEvent):void{
            this.m_value = MathUtl.limit((this.m_value - this.m_scrollStep), 0, this.m_range);
            this._processMove(true);
        }
		
		/**
		 * 拖动块拖动
		 */
        private function _thumbButtonDrag(event:DXWndMouseEvent):void{
            var _local2:Number;
            var _local3:Number;
            var _local4:Number;
            if (this.isVertical){
                _local2 = ((event.point.y + this.m_thumbBtn.y) - this.m_thumbBtn.holdPos.y);
                _local3 = (this.m_decrementBtn.y + this.m_decrementBtn.height);
                _local4 = (this.m_incrementBtn.y - this.m_thumbBtn.height);
            } else {
                _local2 = ((event.point.x + this.m_thumbBtn.x) - this.m_thumbBtn.holdPos.x);
                _local3 = (this.m_decrementBtn.x + this.m_decrementBtn.width);
                _local4 = (this.m_incrementBtn.x - this.m_thumbBtn.width);
            };
            _local2 = MathUtl.limit(_local2, _local3, _local4);
            this.m_value = (((_local2 - _local3) * (this.m_range - this.m_pageSize)) / (_local4 - _local3));
            this._processMove(true);
        }
		
		/**
		 * 拖动块位置变化
		 * @param	isDispatchEvent		是否派发DXWndEvent.STATE_CHANGED事件
		 */
        private function _processMove(isDispatchEvent:Boolean):void{
            var _local3:Number;
            var _local4:Number;
            var _local5:Number;
            var _local6:Number;
            this.m_range = Math.max(1, this.m_range);
            var _local2:uint = MathUtl.limit(this.m_pageSize, 1, this.m_range);
            this.m_value = MathUtl.limit(this.m_value, 0, (this.m_range - _local2));
            if (this.isVertical){
                _local3 = (this.m_decrementBtn.x + (this.m_decrementBtn.width / 2));
                _local5 = (this.m_incrementBtn.x + (this.m_incrementBtn.width / 2));
                _local4 = ((this.m_decrementBtn.y + this.m_decrementBtn.height) + (this.m_thumbBtn.height / 2));
                _local6 = (this.m_incrementBtn.y - (this.m_thumbBtn.height / 2));
            } else {
                _local3 = ((this.m_decrementBtn.x + this.m_decrementBtn.width) + (this.m_thumbBtn.width / 2));
                _local5 = (this.m_incrementBtn.x - (this.m_thumbBtn.width / 2));
                _local4 = (this.m_decrementBtn.y + (this.m_decrementBtn.height / 2));
                _local6 = (this.m_incrementBtn.y + (this.m_incrementBtn.height / 2));
            };
            var _local7:Number = ((this.m_range)>_local2) ? (this.m_value / (this.m_range - _local2)) : 0;
            var _local8:int = (((_local3 + ((_local5 - _local3) * _local7)) + 0.5) - (this.m_thumbBtn.width / 2));
            var _local9:int = (((_local4 + ((_local6 - _local4) * _local7)) + 0.5) - (this.m_thumbBtn.height / 2));
            this.m_thumbBtn.setLocation(_local8, _local9);
            if (isDispatchEvent){
                dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED, this.m_value));
            };
        }
        public function get isReachEnd():Boolean{
            var _local1:uint = MathUtl.limit(this.m_pageSize, 1, this.m_range);
            return ((this.m_value >= (this.m_range - this.m_pageSize)));
        }

    }
}//package deltax.gui.component 
