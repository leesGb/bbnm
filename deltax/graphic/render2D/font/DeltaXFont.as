//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.render2D.font {
    import flash.display3D.*;
    import deltax.common.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import flash.utils.*;
    import deltax.common.error.*;
	
	/**
	 * 文本渲染<br>
	 * 将文本逐个字符通过DeltaXFontRenderer渲染成位图二进制<br>
	 * 保存渲染好的二进制数据DeltaXFontInfo
	 * @author admin
	 */
    public class DeltaXFont implements ReferencedObject {

        private static var ms_calcSize:Size = new Size();
		
		/** 引用数量 */
        private var m_refCount:uint = 1;
		
		/** 字体名 */
		private var m_fontName:String;
		
		/** 保存DeltaXFontInfo，字符的Unicode作为key  */
        private var m_textInfos:Dictionary;

        public function DeltaXFont(font:String=""){
            this.m_textInfos = new Dictionary();
            super();
            this.m_fontName = font;
        }
		
		/**
		 * @get
		 * 获取字体
		 */
        public function get name():String{
            return this.m_fontName;
        }
		
		/**
		 * 清理
		 */
        public function dispose():void{
            var info:DeltaXFontInfo;
            for each (info in this.m_textInfos) {
				info.dispose();
            };
            this.m_textInfos = null;
            DeltaXFontRenderer.Instance.unregisterDeltaXSubGeometry(this);
        }
		
		/**
		 * stage失去焦点，清理
		 */
        public function onLostDevice():void{
            var info:DeltaXFontInfo;
            for each (info in this.m_textInfos) {
				info.onLostDevice();
            };
        }
		
		/**
		 * @get
		 * 获取引用数量
		 */
        public function get refCount():uint{
            return this.m_refCount;
        }
		
		/**
		 * 添加引用次数
		 */
        public function reference():void{
            this.m_refCount++;
        }
		
		/**
		 * 释放引用次数
		 */
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this.m_refCount)));
				return;
            };
        }
		
		/**
		 * 根据Unicode获取DeltaXFontInfo
		 */
        private function getFontTextureInfo(valueUnicode:uint):DeltaXFontInfo{
            var info:DeltaXFontInfo = this.m_textInfos[valueUnicode];
            if (info == null){
                info = new DeltaXFontInfo(valueUnicode);
                this.m_textInfos[valueUnicode] = info;
            };
            return info;
        }
		
		/**
		 * 文本渲染
		 * @param	context3D			3D容器
		 * @param	value				文本
		 * @param	fontSize			字体大小
		 * @param	fontColor			字体颜色
		 * @param	fontEdgeColor		边框颜色
		 * @param	xborder				x偏移坐标
		 * @param	yborder				y偏移坐标
		 * @param	rect				渲染矩形
		 * @param	startIndex			渲染开始索引，0从第一个字符串开始渲染
		 * @param	endIndex			渲染结束索引，-1渲染到最后一个字符串
		 * @param	multiline			表示字段是否为多行文本字段。
		 * @param	valueZ				z坐标
		 * @param	textHorzDistance	文本字与字间隔
		 * @param	textVertDistance	文本行与行间隔
		 * @param	shadow				是否有黑色阴影。false：有
		 */
        public function drawText(context3D:Context3D, 
								 value:String, 
								 fontSize:Number, 
								 fontColor:uint,
								 fontEdgeColor:uint, 
								 xborder:Number=0, 
								 yborder:Number=0, 
								 rect:Rectangle=null,
								 startIndex:int=0, 
								 endIndex:int=-1, 
								 multiline:Boolean=true,
								 valueZ:Number=0.999999,
								 textHorzDistance:Number=0, 
								 textVertDistance:Number=0, 
								 shadow:Boolean=false):void{
            var _local19:Number;
            var _local20:Number;
            var _local21:Number;
            var _local22:Number;
            var _local27:Number;
            var _local28:int;
            var _local29:uint;
            var _local30:uint;
            var _local31:Number;
            if (endIndex == 0 || !value || fontSize < 1 || fontSize > DeltaXFontInfo.FONT_SIZE_LIMIT || rect.right <= 0 || rect.bottom <= 0){
                return;
            };
            if (((fontColor & 0xf0000000) == 0) && ((fontEdgeColor & 0xf0000000) == 0)){
                return;
            };
            var _local16:DeltaXFontRenderer = DeltaXFontRenderer.Instance;
            if (rect == null){
                rect = _local16.viewPort;
            };
            if ((rect.left + xborder) >= rect.right){
                return;
            };
            if (rect.left < 0){
                xborder = (xborder + rect.left);
                rect.left = 0;
            };
            if (rect.top < 0){
                yborder = (yborder + rect.top);
                rect.top = 0;
            };
            var _local17:DeltaXFontInfo = this.getFontTextureInfo(fontSize);
            var _local18:uint = _local17.fontEdgeSize;
            xborder = (xborder - _local18);
            yborder = (yborder - _local18);
            _local19 = (((uint(rect.left) << 8) | ((fontColor >>> 16) & 240)) | ((fontEdgeColor >>> 20) & 15));
            _local20 = (((uint(rect.top) << 8) | ((fontColor >>> 8) & 240)) | ((fontEdgeColor >>> 12) & 15));
            _local21 = (((uint(rect.right) << 8) | (fontColor & 240)) | ((fontEdgeColor >>> 4) & 15));
            _local22 = (((uint(rect.bottom) << 8) | ((fontColor >>> 24) & 240)) | ((fontEdgeColor >>> 28) & 15));
            if (shadow){
                _local22 = -(_local22);
            };
            _local16.beginFontRender(context3D, _local17, valueZ);
            var _local23:uint = Math.min(value.length, (uint(endIndex) + startIndex));
            var _local24:uint = startIndex;
            var _local25:Number = (rect.top + yborder);
            var _local26:int;
            while (_local24 < _local23) {
                _local27 = (rect.left + xborder);
                _local28 = 0;
                while (_local24 < _local23) {
                    _local29 = value.charCodeAt(_local24);
                    if (_local29 == 10){
                        _local24++;
                        break;
                    };
                    if (_local27 >= rect.right){
                        break;
                    };
                    _local30 = _local17.getCharInfo(_local29);
                    _local31 = (_local30 >>> 24);
                    if (((multiline) && ((((_local27 + _local31) - (fontEdgeColor ? 0 : 1)) >= rect.right)))){
                        break;
                    };
                    if ((((_local29 == 32)) || ((_local29 == 9)))){
                        _local27 = (_local27 + (_local31 + textHorzDistance));
                        _local24++;
                    } else {
                        _local24++;
                        _local16.renderFont(context3D, _local27, _local25, (_local30 & 0xFFFF), (_local30 >>> 16), _local19, _local20, _local21, _local22);
                        _local27 = (_local27 + (_local31 + textHorzDistance));
                    };
                    _local28++;
                };
                _local25 = (_local25 + (fontSize + textVertDistance));
                if (_local24 >= _local23){
                    break;
                };
                if (((!(multiline)) || ((_local25 >= rect.bottom)))){
                    break;
                };
                _local26++;
            };
        }
        public function calTextBounds(_arg1:String, _arg2:Number, _arg3:int=0, _arg4:int=-1, _arg5:Boolean=true, _arg6:Number=0, _arg7:Number=0):Size{
            var _local13:Number;
            var _local14:int;
            var _local15:uint;
            var _local16:uint;
            var _local17:Number;
            if ((((((((_arg4 == 0)) || (!(_arg1)))) || ((_arg2 < 1)))) || ((_arg2 > DeltaXFontInfo.FONT_SIZE_LIMIT)))){
                return (null);
            };
            var _local8:DeltaXFontInfo = this.getFontTextureInfo(_arg2);
            var _local9:uint = Math.min(_arg1.length, (uint(_arg4) + _arg3));
            var _local10:uint = _arg3;
            var _local11:Number = 0;
            var _local12:int;
            while (_local10 < _local9) {
                _local13 = 0;
                _local14 = 0;
                while (_local10 < _local9) {
                    _local15 = _arg1.charCodeAt(_local10);
                    if (_local15 == 10){
                        _local10++;
                        break;
                    };
                    _local16 = _local8.getCharInfo(_local15);
                    _local17 = (_local16 >>> 24);
                    if ((((_local15 == 32)) || ((_local15 == 9)))){
                        _local13 = (_local13 + (_local17 + _arg6));
                        _local10++;
                    } else {
                        _local10++;
                        _local13 = (_local13 + (_local17 + _arg6));
                    };
                    _local14++;
                };
                _local11 = (_local11 + (_arg2 + _arg7));
                if (_local10 >= _local9){
                    break;
                };
                if (!_arg5){
                    break;
                };
                _local12++;
            };
            ms_calcSize.x = _local13;
            ms_calcSize.y = _local11;
            return (ms_calcSize);
        }
        public function getCharWidth(_arg1:String, _arg2:Number, _arg3:int=0):uint{
            return ((this.getFontTextureInfo(_arg2).getCharInfo(_arg1.charCodeAt(_arg3)) >>> 24));
        }
        public function getEdgeSize(_arg1:Number):uint{
            return (this.getFontTextureInfo(_arg1).fontEdgeSize);
        }

    }
}//package deltax.graphic.render2D.font 
