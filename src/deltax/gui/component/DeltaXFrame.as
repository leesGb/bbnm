//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import deltax.gui.base.style.*;
    import flash.ui.*;
	
	/**
	 * 窗口界面<br>
	 * 按ESC键，隐藏。点击close按钮隐藏
	 * @author admin
	 *
	 */
    public class DeltaXFrame extends DeltaXWindow {

        public static const STANDARD_UI_SHEET_WIDTH:uint = 1280;//0x0400;
        public static const STANDARD_UI_SHEET_HEIGHT:uint = 600;//0x0300;

        private var m_setFocusOnVisible:Boolean = true;
        private var m_hideOnEscape:Boolean = true;
		
		/**
		 *构造函数 
		 * @param res			资源url
		 * @param parentValue	parent
		 * 
		 */		
        public function DeltaXFrame(res:String=null, parentValue:DeltaXWindow=null){
            m_visible = false;
            if (res){
                createFromRes(res, parentValue ? parentValue : rootWnd);
            };
        }
		
		/**
		 * 创建 DeltaXFrame
		 * @param parentValue	parent
		 * @param widthValue	宽
		 * @param heightValue	高
		 * 
		 */		
        public function creatAsEmptyContain(parentValue:DeltaXWindow, widthValue:uint=0, heightValue:uint=0):void{
            widthValue = (((widthValue) || (!(parentValue)))) ? widthValue : parentValue.width;
            heightValue = (((heightValue) || (!(parentValue)))) ? heightValue : parentValue.height;
            create("", WindowStyle.CHILD, 0, 0, widthValue, heightValue, parentValue);
            m_properties.lockFlag = LockFlag.ALL;
            //m_properties.width = STANDARD_UI_SHEET_WIDTH;
            //m_properties.height = STANDARD_UI_SHEET_HEIGHT;
            this.m_hideOnEscape = false;
            alpha = 0;
        }
        override protected function _onWndCreatedInternal():void{
            this.addEventListener(DXWndKeyEvent.KEY_DOWN, this._onKeyDown);
        }
        private function _onKeyDown(event:DXWndKeyEvent):void{
            if (!this.hideOnEscape){
                return;
            };
            if (event.keyCode != Keyboard.ESCAPE){
                return;
            };
            if (((((!(event.altKey)) && (!(event.ctrlKey)))) && (!(event.shiftKey)))){
                return;
            };
            this.visible = false;
        }
		
		/**
		 * 子对象 DeltaXCheckBox 设置选中
		 * @param childName		子对象DeltaXCheckBox名字
		 * 
		 */		
        protected function defaultSelected(childName:String):void{
            var gui:DeltaXCheckBox = (this.getChildByName(childName) as DeltaXCheckBox);
            if (gui){
				gui.setSelected(true);
            };
        }
		
		/**
		 * 关闭按钮添加关闭事件 
		 * @param childName		关闭按钮名字
		 * 
		 */		
        protected function addCloseAction(childName:String="close"):void{
            var gui:DeltaXButton = DeltaXButton(this.getChildByName(childName));
            if (gui){
				gui.addActionListener(this.closeUI);
            };
        }
		
        protected function closeUI(event:DXWndEvent):void{
            toggle();
        }
        public function get hideOnEscape():Boolean{
            return (this.m_hideOnEscape);
        }
        public function set hideOnEscape(_arg1:Boolean):void{
            this.m_hideOnEscape = _arg1;
        }
		
		/**
		 * @set
		 * 设置visible。可见设置焦点 
		 * @param visibleValue
		 * 
		 */		
        override public function set visible(visibleValue:Boolean):void{
            super.visible = visibleValue;
            if (((visibleValue) && (this.m_setFocusOnVisible))){
                this.setFocus();
            };
        }
        public function get setFocusOnVisible():Boolean{
            return (this.m_setFocusOnVisible);
        }
        public function set setFocusOnVisible(_arg1:Boolean):void{
            this.m_setFocusOnVisible = _arg1;
        }

    }
}//package deltax.gui.component 
