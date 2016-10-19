//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import deltax.gui.util.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
	
	/**
	 * 带滚动条的基础容器<br>
	 * @author admin
	 */
    public class DeltaXScrollPane extends DeltaXWindow {
		
		/** 垂直滚动条 */
        protected var m_verticalScrollbar:DeltaXScrollBar;
		
		/** 水平滚动条 */
        protected var m_horizonScrollbar:DeltaXScrollBar;
        private var m_selfVerticalScrollPos:Number = 0;
        private var m_selfHorizonScrollPos:Number = 0;
		
		/**
		 * 初始化，显示垂直水平滚动条
		 */
        override protected function _onWndCreatedInternal():void{
            this.enableHorizontalScrollBar(true);
            this.enableVerticalScrollBar(true);
        }
		
		/**
		 * 获取垂直滚动条的样式位图数据
		 */
        protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
		
		/**
		 * 获取水平滚动条的样式位图数据
		 */
        protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
		
		/**
		 * 鼠标滚轮事件
		 */
        private function _onMouseWheelFromChild(event:DXWndMouseEvent):void{
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.mouseWheelManually(event.delta);
            };
        }
		
		/**
		 * 垂直滚动条是否可用
		 */
        public function enableVerticalScrollBar(enable:Boolean):void{
            var _local3:uint;
            if (enable == false){
                if (this.m_verticalScrollbar){
                    this.m_verticalScrollbar.dispose();
                };
                this.m_verticalScrollbar = null;
                this.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this._onMouseWheelFromChild);
                return;
            };
            if (this.m_verticalScrollbar){
                return;
            };
            var _local2:Vector.<ComponentDisplayItem> = this.getVerticalScrollBarDisplayItems();
            if (_local2){
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(-(_local2[0].rect.x), -(_local2[0].rect.y));
                    _local3++;
                };
                this.m_verticalScrollbar = new DeltaXScrollBar();
                this.m_verticalScrollbar.createFromDispItemInfo("", _local2, WindowStyle.CHILD, this);
                this.m_verticalScrollbar.lockFlag = ((LockFlag.TOP | LockFlag.RIGHT) | LockFlag.BOTTOM);
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(_local2[0].rect.x, _local2[0].rect.y);
                    _local3++;
                };
                this.m_verticalScrollbar.addEventListener(DXWndEvent.STATE_CHANGED, this.onScrollbar);
                this.m_verticalScrollbar.range = (height - (yBorder * 2));
                this.m_verticalScrollbar.pageSize = (height - (yBorder * 2));
                this.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this._onMouseWheelFromChild);
            };
        }
		
		/**
		 * 水平滚动条是否可用
		 */
        public function enableHorizontalScrollBar(enable:Boolean):void{
            var _local3:uint;
            if (enable == false){
                if (this.m_horizonScrollbar){
                    this.m_horizonScrollbar.dispose();
                };
                this.m_horizonScrollbar = null;
                return;
            };
            if (this.m_horizonScrollbar){
                return;
            };
            var _local2:Vector.<ComponentDisplayItem> = this.getHorticalScrollBarDisplayItems();
            if (_local2){
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(-(_local2[0].rect.x), -(_local2[0].rect.y));
                    _local3++;
                };
                this.m_horizonScrollbar = new DeltaXScrollBar();
                this.m_horizonScrollbar.createFromDispItemInfo("", _local2, (WindowStyle.CHILD | ScrollStyle.HORIZON), this);
                this.m_horizonScrollbar.lockFlag = ((LockFlag.LEFT | LockFlag.RIGHT) | LockFlag.BOTTOM);
                _local3 = 1;
                while (_local3 < _local2.length) {
                    _local2[_local3].rect.offset(_local2[0].rect.x, _local2[0].rect.y);
                    _local3++;
                };
                this.m_horizonScrollbar.addEventListener(DXWndEvent.STATE_CHANGED, this.onScrollbar);
                this.m_horizonScrollbar.range = (width - (xBorder * 2));
                this.m_horizonScrollbar.pageSize = (width - (xBorder * 2));
            };
        }
		
		/**
		 * 获取垂直滚动条
		 */
        public function get verticalScrollBar():DeltaXScrollBar{
            return (this.m_verticalScrollbar);
        }
		
		/**
		 * 获取水平滚动条
		 */
        public function get horizontalScrollBar():DeltaXScrollBar{
            return (this.m_horizonScrollbar);
        }
		
		/**
		 * 初始化滚动条位置。垂直到底部，水平到左边
		 */
        public function scrollToBottomLeft():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = 0;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = this.m_verticalScrollbar.range;
            };
        }
		
		/**
		 * 初始化滚动条位置。垂直到顶部，水平到左边
		 */
        public function scrollToTopLeft():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = 0;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = 0;
            };
        }
		
		/**
		 * 初始化滚动条位置。垂直到底部，水平到右边
		 */
        public function scrollToBottomRight():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = this.m_horizonScrollbar.range;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = this.m_verticalScrollbar.range;
            };
        }
		
		/**
		 * 初始化滚动条位置。垂直到顶部，水平到右边
		 */
        public function scrollToTopRight():void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = this.m_horizonScrollbar.range;
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = 0;
            };
        }
		
		/**
		 * 获取垂直滚动条值
		 */
        public function get scrollVerticalPos():Number{
            return ((this.m_verticalScrollbar) ? this.m_verticalScrollbar.value : this.m_selfVerticalScrollPos);
        }
		
		/**
		 * 获取水平滚动条值
		 */
        public function get scrollHorizonPos():Number{
            return ((this.m_horizonScrollbar) ? this.m_horizonScrollbar.value : this.m_selfHorizonScrollPos);
        }
		
		/**
		 * 设置垂直滚动条值
		 */
        public function set scrollVerticalPos(value:Number):void{
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.value = value;
            } else {
                this.m_selfVerticalScrollPos = value;
            };
        }
		
		/**
		 * 设置水平滚动条值
		 */
        public function set scrollHorizonPos(value:Number):void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.value = value;
            } else {
                this.m_selfHorizonScrollPos = value;
            };
        }
		
		/**
		 * 滚动条滚动事件
		 */
        private function onScrollbar(event:DXWndEvent):void{
            if (event.target == this.m_verticalScrollbar){
                this.onVScroll((event.param as Number));
            } else {
                if (event.target == this.m_horizonScrollbar){
                    this.onHScroll((event.param as Number));
                };
            };
        }
		
		/**
		 * 垂直滚动条事件，子类实现
		 */
        protected function onVScroll(value:Number):void{
        }
		
		/**
		 * 水平滚动条事件，子类实现
		 */
        protected function onHScroll(value:Number):void{
        }
        override protected function onResize(_arg1:Size):void{
            if (this.m_horizonScrollbar){
                this.m_horizonScrollbar.pageSize = (width - (xBorder * 2));
            };
            if (this.m_verticalScrollbar){
                this.m_verticalScrollbar.pageSize = (height - (yBorder * 2));
            };
        }

    }
}//package deltax.gui.component 
