//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display3D.*;
    import deltax.gui.component.event.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;
	
	/**
	 * 复选框,单选框<br>
	 * isSingleCheckStype为true,为单选框。选中时，groupID相同的别的组件selected = false
	 * @author admin
	 *
	 */
    public class DeltaXCheckBox extends DeltaXButton {

        private var m_selected:Boolean;

        public function DeltaXCheckBox(){
            this.addSelectionListener(this.onSelected);
        }
        public function addSelectionListener(value:Function):void{
            addEventListener(DXWndEvent.SELECTED, value);
        }
        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
            addEventListener(DXWndEvent.ACTION, this._onAction);
        }
        private function _onAction(value:DXWndEvent):void{
            if (((this.isSingleCheckStype) && (this.selected))){
                return;
            };
            this.selected = !(this.selected);
        }
        public function get isSingleCheckStype():Boolean{
            return (!(((m_properties.style & CheckButtonStyle.SINGLE_CHECK_IN_GROUP) == 0)));
        }
		
		/**
		 * 选中事件<br>
		 * 如果是单选框，则同groupID的别的组件selected设为false
		 */
        protected function onSelected(event:DXWndEvent):void{
            var _local3:DeltaXWindow;
            var _local2:int = properties.groupID;
            if ((((((((_local2 >= 0)) && (this.selected))) && (this.isSingleCheckStype))) && (parent))){
                _local3 = parent.childTopMost;
                while (_local3) {
                    if ((((((_local3 is DeltaXCheckBox)) && (!((_local3 == this))))) && ((_local3.properties.groupID == _local2)))){
                        DeltaXCheckBox(_local3).selected = false;
                    };
                    _local3 = _local3.brotherBelow;
                };
            };
        }
        public function get selected():Boolean{
            return (this.m_selected);
        }
		
		/**
		 * @set
		 * 设置是否选中状态
		 */
        public function set selected(value:Boolean):void{
            if (this.m_selected != value){
                this.m_selected = value;
                dispatchEvent(new DXWndEvent(DXWndEvent.SELECTED, value));
            };
        }
        public function isSelected():Boolean{
            return (this.selected);
        }
        public function setSelected(value:Boolean):void{
            this.selected = value;
        }
		
		/**
		 * 背景渲染
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        override protected function renderBackground(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
            var displayItem:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            if (this.m_selected){
                drawWithAllImage(context3D, displayItem.displayStateInfos[SubCtrlStateType.ENABLE].imageList, displayItem.displayStateInfos[SubCtrlStateType.DISABLE].imageList, displayItem.displayStateInfos[SubCtrlStateType.MOUSEOVER].imageList, displayItem.displayStateInfos[SubCtrlStateType.CLICKDOWN].imageList, isHeld, valueGetTimer);
            } else {
                drawWithAllImage(context3D, displayItem.displayStateInfos[SubCtrlStateType.UNCHECK_ENABLE].imageList, displayItem.displayStateInfos[SubCtrlStateType.UNCHECK_DISABLE].imageList, displayItem.displayStateInfos[SubCtrlStateType.UNCHECK_MOUSEOVER].imageList, displayItem.displayStateInfos[SubCtrlStateType.UNCHECK_CLICKDOWN].imageList, isHeld, valueGetTimer);
            };
        }
		
		/**
		 * 文本渲染
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        override protected function renderText(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
            var _local4:ComponentDisplayStateInfo;
            var _local5:ComponentDisplayStateInfo;
            var _local6:ComponentDisplayStateInfo;
            var _local7:ComponentDisplayStateInfo;
            if (this.m_selected){
                return (super.renderText(context3D, valueGetTimer, fpsTime));
            };
            if (isHeld){
                _local4 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_CLICKDOWN);
                drawTextWithStyle(context3D, m_text, _local4.fontColor, _local4.fontEdgeColor);
            } else {
                if (((enable) && ((m_guiManager.lastMouseOverWnd == this)))){
                    _local5 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_MOUSEOVER);
                    drawTextWithStyle(context3D, m_text, _local5.fontColor, _local5.fontEdgeColor);
                } else {
                    if (enable){
                        _local6 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_ENABLE);
                        drawTextWithStyle(context3D, m_text, _local6.fontColor, _local6.fontEdgeColor);
                    } else {
                        _local7 = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.UNCHECK_DISABLE);
                        drawTextWithStyle(context3D, m_text, _local7.fontColor, _local7.fontEdgeColor);
                    };
                };
            };
        }

    }
}//package deltax.gui.component 
