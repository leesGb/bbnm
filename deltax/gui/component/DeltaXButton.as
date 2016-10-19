//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import __AS3__.vec.*;
    
    import deltax.graphic.render2D.font.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.event.*;
    import deltax.gui.component.subctrl.*;
    import deltax.gui.util.*;
    
    import flash.display3D.*;
    import flash.geom.*;
	
	/**
	 * 按钮<br>
	 * 帧听按钮点击事件DXWndEvent.ACTION
	 * @author admin
	 *
	 */
    public class DeltaXButton extends DeltaXWindow {

        protected var m_flashCircle:uint;
        protected var m_flashStartTime:uint;
        protected var m_flashEndTime:uint;
		
		/** 鼠标点击的位置 */
        protected var m_clickPos:Point;

        override protected function _onWndCreatedInternal():void{
            var _local2:Rectangle;
            var _local3:ComponentDisplayStateInfo;
            var _local4:ComponentDisplayStateInfo;
            var _local1:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            if (_local1.displayStateInfos[SubCtrlStateType.MOUSEOVER] == null){
                _local2 = ((_local2) || (new Rectangle(0, 0, width, height)));
                _local1.displayStateInfos[SubCtrlStateType.MOUSEOVER] = new ComponentDisplayStateInfo();
                _local3 = _local1.displayStateInfos[SubCtrlStateType.MOUSEOVER];
                _local3.imageList.addImage(0, "", new Rectangle(), _local2, 0xffffffff,LockFlag.ALL);
            };
            if (_local1.displayStateInfos[SubCtrlStateType.CLICKDOWN] == null){
                _local2 = ((_local2) || (new Rectangle(0, 0, width, height)));
                _local1.displayStateInfos[SubCtrlStateType.CLICKDOWN] = new ComponentDisplayStateInfo();
                _local4 = _local1.displayStateInfos[SubCtrlStateType.CLICKDOWN];
                _local4.imageList.addImage(0, "", new Rectangle(), _local2, 0xffcccccc,LockFlag.ALL);
            };
            super._onWndCreatedInternal();
            addEventListener(DXWndMouseEvent.MOUSE_DOWN, this._onMouseDown);
            addEventListener(DXWndMouseEvent.MOUSE_UP, this._onMouseUp);
            addEventListener(DXWndMouseEvent.DRAG, this._onDrag);
        }
        private function _onMouseDown(event:DXWndMouseEvent):void{
            this.m_clickPos = event.point.clone();
        }
        private function _onMouseUp(event:DXWndMouseEvent):void{
            if (this.m_clickPos){
                dispatchEvent(new DXWndEvent(DXWndEvent.ACTION, this));
            };
            this.m_clickPos = null;
        }
        private function _onDrag(event:DXWndMouseEvent):void{
            if (!this.m_clickPos){
                return;
            };
            if ((((Math.abs((this.m_clickPos.x - event.point.x)) > 2)) || ((Math.abs((this.m_clickPos.y - event.point.y)) > 2)))){
                this.m_clickPos = null;
            };
        }
		
		/**
		 * 闪烁<br>
		 * 可用样式与鼠标经过样式切换闪烁
		 * @param	context3D		3D容器
		 * @param	gapTime			闪烁间隔时间（毫秒）
		 * @param	countTime		闪烁总时间（毫秒），-1一直闪烁
		 */
        public function setFlashing(gapTime:uint, countTime:int=-1):void{
            this.m_flashCircle = gapTime;
            this.m_flashStartTime = 0;
            this.m_flashEndTime = (this.m_flashStartTime + countTime);
        }
		
		/**
		 * 文本渲染
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        override protected function renderText(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
            var downSkin:ComponentDisplayStateInfo;
            var overSkin:ComponentDisplayStateInfo;
            if (isHeld){
				downSkin = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.CLICKDOWN);
                drawTextWithStyle(context3D, m_text, downSkin.fontColor, downSkin.fontEdgeColor);
            } else {
                if (((enable) && ((m_guiManager.lastMouseOverWnd == this)))){
					overSkin = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.MOUSEOVER);
                    drawTextWithStyle(context3D, m_text, overSkin.fontColor, overSkin.fontEdgeColor);
                } else {
                    super.renderText(context3D, valueGetTimer, fpsTime);
                };
            };
        }
		
		/**
		 * 文本渲染
		 */
        override public function drawText(_arg1:Context3D, _arg2:String, _arg3:Number, _arg4:Number, _arg5:uint, _arg6:uint, _arg7:int, _arg8:int, _arg9:Boolean, _arg10:Rectangle, _arg11:Number, _arg12:Number, _arg13:DeltaXFont=null, _arg14:uint=0, _arg15:int=-1):void{
            if (isHeld){
                _arg3 = (_arg3 + ButtonStyle.offsetXFromStyle(style));
                _arg4 = (_arg4 + ButtonStyle.offsetYFromStyle(style));
            };
            _arg3 = (_arg3 + xBorder);
            _arg4 = (_arg4 + yBorder);
            super.drawText(_arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg9, _arg10, _arg11, _arg12, _arg13, _arg14, _arg15);
        }
		
		/**
		 * 背景渲染
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        override protected function renderBackground(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
            var _local4:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var _local5:Vector.<ComponentDisplayStateInfo> = _local4.displayStateInfos;
            this.drawWithAllImage(context3D, _local5[SubCtrlStateType.ENABLE].imageList, _local5[SubCtrlStateType.DISABLE].imageList, _local5[SubCtrlStateType.MOUSEOVER].imageList, _local5[SubCtrlStateType.CLICKDOWN].imageList, isHeld, valueGetTimer);
        }
		
		/**
		 * 背景渲染<br>
		 * 根据当前状态，渲染对应的背景图
		 * @param	context3D			3D容器
		 * @param	enableImgList		upSkin。可用的皮肤样式列表(多张图片文理，3宫格或者9宫格）	
		 * @param	disableImgList		不可使用皮肤样式列表
		 * @param	overImgList			鼠标经过样式列表
		 * @param	downImgList			鼠标按下样式列表
		 * @param	isHeldValue			当前组件是否鼠标按下
		 * @param	valueGetTimer		当前渲染的getTimer()值
		 */
        public function drawWithAllImage(context3D:Context3D, enableImgList:ImageList, disableImgList:ImageList, overImgList:ImageList, downImgList:ImageList, isHeldValue:Boolean, valueGetTimer:uint):void{
            var _local9:int;
            var _local10:Number;
            if (this.m_flashStartTime == 0){
                this.m_flashStartTime = (this.m_flashStartTime + valueGetTimer);
                if (this.m_flashEndTime < uint.MAX_VALUE){
                    this.m_flashEndTime = (this.m_flashEndTime + valueGetTimer);
                };
            };
            var isEnable:Boolean = this.enable;
            if (isHeldValue){
                renderImageList(context3D, downImgList, null, -1, 1, m_gray);
            } else {
				//trace(_local8 + "," + m_guiManager.lastMouseOverWnd);
                if (isEnable && m_guiManager.lastMouseOverWnd == this){
                    renderImageList(context3D, overImgList, null, -1, 1, m_gray);
                } else {
                    if (!isEnable){
                        renderImageList(context3D, disableImgList, null, -1, 1, m_gray);
                    } else {
                        if (((this.m_flashCircle) && (((this.m_flashEndTime - this.m_flashStartTime) > (valueGetTimer - this.m_flashStartTime))))){
                            _local9 = ((valueGetTimer - this.m_flashStartTime) % (this.m_flashCircle << 1));
                            _local10 = (Math.abs((_local9 - this.m_flashCircle)) / this.m_flashCircle);
                            renderImageList(context3D, overImgList, null, -1, _local10, m_gray);
                        } else {
                            renderImageList(context3D, enableImgList, null, -1, 1, m_gray);
                        };
                    };
                };
            };
        }
		
		/**
		 * get闪烁间隔时间
		 */
        public function get flashCircle():uint{
            return (this.m_flashCircle);
        }
		
		/**
		 * get是否闪烁
		 */
        public function get isFlashing():Boolean{
            return ((this.m_flashCircle > 0));
        }

    }
}//package deltax.gui.component 
