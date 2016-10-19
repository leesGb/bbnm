//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.manager {
    import __AS3__.vec.Vector;
    
    import deltax.appframe.BaseApplication;
    import deltax.common.error.Exception;
    import deltax.common.error.SingletonMultiCreateError;
    import deltax.common.math.MathUtl;
    import deltax.graphic.render2D.font.DeltaXFontRenderer;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;
    import deltax.gui.base.style.WindowStyle;
    import deltax.gui.component.DeltaXEdit;
    import deltax.gui.component.DeltaXTooltipWnd;
    import deltax.gui.component.DeltaXWindow;
    import deltax.gui.component.ICustomTooltip;
    import deltax.gui.component.event.DXWndEvent;
    import deltax.gui.component.event.DXWndKeyEvent;
    import deltax.gui.component.event.DXWndMouseEvent;
    
    import flash.display3D.Context3D;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Mouse;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
	
	/**
	 * gui管理器<br>
	 * 鼠标事件处理,gui渲染
	 * @author admin
	 *
	 */
    public class GUIManager {

        private static const ACCEKEY_CTRL:uint = 268435456;
        private static const ACCEKEY_SHIFT:uint = 536870912;
        private static const ACCEKEY_ALT:uint = 1073741824;
        private static const WND_POSITION_MAP_SIZE:uint = 16;

        private static var m_instance:GUIManager;
        public static var CUR_ROOT_WND:DeltaXRootWnd;

        private var m_cursorPos:Point;
        private var m_curMouseEvent:MouseEvent = null;
        private var m_keyIsPress:Boolean = false;
        private var m_ignoreNextKeyup:Boolean = false;
        private var m_rootWnd:DeltaXRootWnd;
        private var m_moduleWnd:DeltaXWindow;
        private var m_holdWnd:DeltaXWindow;
        private var m_lastMouseOverWnd:DeltaXWindow;
        private var m_curTooltipWnd:DeltaXWindow;
        private var m_cursorAttachWnd:DeltaXWindow;
        private var m_commonTooltipsWnd:DeltaXTooltipWnd;
        private var m_globalCursorName:String;
        private var m_guiHandler:IGUIHandler;
        private var m_holdWndMoving:Boolean;
        private var m_preMouseOverTime:uint;
        private var m_attachPos:Point;
		
		/** 鼠标点击组件的，相对于组件的局部坐标  */
        private var m_curHeldPos:Point;
        private var m_preHoldTime:uint;
        private var m_curEvent:Event;
        private var m_preRenderTime:uint;
        private var m_holdingSameWnd:Boolean;
        private var m_continuosMouseDownPassTime:int;
        private var m_mapAcceKey:Dictionary;
        private var m_listModuleWnd:Vector.<DeltaXWindow>;
        private var m_pixelXPerPositionUnit:int = 0;
        private var m_pixelYPerPositionUnit:int = 0;
        private var m_wndPositionMapInvalid:Boolean = true;
        private var m_wndPositionMap:Vector.<Vector.<Vector.<DeltaXWindow>>>;
        private var m_lastMouseUpTime:uint;
        private var m_tempAccelKeysToUnregister:Vector.<Object>;
        private var m_tempAccelKeysToUnregisterCount:uint;
        private var m_curShowingCustomTooltip:DeltaXWindow;
        private var m_componentToTooltipUIMap:Dictionary;

        public function GUIManager(guiHandler:IGUIHandler=null){
            var _local3:uint;
            this.m_cursorPos = new Point();
            this.m_attachPos = new Point();
            this.m_curHeldPos = new Point();
            this.m_mapAcceKey = new Dictionary();
            this.m_listModuleWnd = new Vector.<DeltaXWindow>();
            this.m_tempAccelKeysToUnregister = new Vector.<Object>();
            this.m_componentToTooltipUIMap = new Dictionary(false);
            super();
            if (m_instance){
                throw (new SingletonMultiCreateError(GUIManager));
            };
            m_instance = this;
            this.m_guiHandler = guiHandler;
            this.m_rootWnd = new DeltaXRootWnd();
            CUR_ROOT_WND = this.m_rootWnd;
            this.m_commonTooltipsWnd = new DeltaXTooltipWnd();
            this.m_wndPositionMap = new Vector.<Vector.<Vector.<DeltaXWindow>>>();
            var _local2:uint;
            while (_local2 < WND_POSITION_MAP_SIZE) {
                this.m_wndPositionMap[_local2] = new Vector.<Vector.<DeltaXWindow>>();
                _local3 = 0;
                while (_local3 < WND_POSITION_MAP_SIZE) {
                    this.m_wndPositionMap[_local2][_local3] = new Vector.<DeltaXWindow>();
                    _local3++;
                };
                _local2++;
            };
        }
        public static function get instance():GUIManager{
            return (m_instance);
        }

        public function init(_arg1:uint, _arg2:uint):void{
            this.m_rootWnd.creatAsEmptyContain(null, _arg1, _arg2);
        }
        public function get rootWnd():DeltaXWindow{
            return (this.m_rootWnd);
        }
        public function get width():int{
            return (this.m_rootWnd.width);
        }
        public function get height():int{
            return (this.m_rootWnd.height);
        }
        public function get xCursor():int{
            return (this.m_cursorPos.x);
        }
        public function get yCursor():int{
            return (this.m_cursorPos.y);
        }
        public function get cursorPos():Point{
            return (this.m_cursorPos.clone());
        }
        public function get lastMouseOverWnd():DeltaXWindow{
            var _local1:DeltaXWindow;
            if (this.m_wndPositionMapInvalid){
                _local1 = this.detectTopWnd(this.m_cursorPos, false);
                if (this.m_lastMouseOverWnd != _local1){
                    this.m_preMouseOverTime = getTimer();
                };
                this.m_lastMouseOverWnd = _local1;
            };
            return (this.m_lastMouseOverWnd);
        }
        public function get cursorAttachWnd():DeltaXWindow{
            return (this.m_cursorAttachWnd);
        }
        public function set cursorAttachWnd(_arg1:DeltaXWindow):void{
            if (_arg1){
                this.m_attachPos.x = (this.xCursor - _arg1.globalX);
                this.m_attachPos.y = (this.yCursor - _arg1.globalY);
            };
            this.m_cursorAttachWnd = _arg1;
        }
        public function get holdWnd():DeltaXWindow{
            return (this.m_holdWnd);
        }
        public function get holdPos():Point{
            return (this.m_curHeldPos.clone());
        }
        public function set holdPos(_arg1:Point):void{
            this.m_curHeldPos.copyFrom(_arg1);
        }
        public function set commonTooltipsRes(_arg1:String):void{
            this.m_commonTooltipsWnd.createFromRes(_arg1, this.rootWnd);
        }
        public function get commonTooltipsWnd():DeltaXWindow{
            return (this.m_commonTooltipsWnd);
        }
        public function get curWndSelectable():Boolean{
            return ((((this.m_lastMouseOverWnd is DeltaXEdit)) && (DeltaXEdit(this.m_lastMouseOverWnd).editable)));
        }
        public function get curWndEditable():Boolean{
            return ((((this.m_rootWnd.focusWnd is DeltaXEdit)) && (DeltaXEdit(this.m_rootWnd.focusWnd).editable)));
        }
        private function _resetContinuosMouseDownState():void{
            this.m_holdingSameWnd = false;
            this.m_continuosMouseDownPassTime = 0;
        }
		
		/**
		 *设置鼠标按下的组件
		 * @param	value	按下的gui组件
		 */
        public function setHeldWindow(value:DeltaXWindow):void{
            var _local2:Point;
            if (((value) && (this.m_holdWnd))){
                Exception.CreateException("set held window duplicate!!!");
            };
            if (value){
                _local2 = this.m_cursorPos.clone();
                _local2.x = (_local2.x - value.globalX);
                _local2.y = (_local2.y - value.globalY);
                if (this.m_holdWnd != value){
                    this.m_holdWndMoving = false;
                };
                this.m_holdingSameWnd = ((!(this.m_holdWnd)) || ((this.m_holdWnd == value)));
                this.m_continuosMouseDownPassTime = 0;
                this.m_holdWnd = value;
                this.m_curHeldPos.copyFrom(_local2);
                this.m_preHoldTime = getTimer();
            } else {
                if (this.m_holdWnd){
                    _local2 = this.m_cursorPos.clone();
                    _local2.x = (_local2.x - this.m_holdWnd.globalX);
                    _local2.y = (_local2.y - this.m_holdWnd.globalY);
                    if (this.m_holdWndMoving){
                        this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAGEND, _local2, 0, false, false, false, false));
                        this.m_holdWndMoving = false;
                    };
                    this.m_holdWnd = null;
                    this._resetContinuosMouseDownState();
                };
            };
        }
		
		/**
		 *重新构建gui组件占用的格子位置，包括gui里面所有的子显示对象<br>
		 * 场景按照常量WND_POSITION_MAP_SIZE，分成若干行，列的格子<br>
		 * 组件value的x,y,宽，高。在场景中占用的格子重新计算。<br>
		 * 把占用的所有格子，按照y,x格子坐标，保存组件value<br>
		 * 方便通过格子坐标，可获得当前格子上面所有的组件。<br>
		 * 再通过鼠标位置与组件的碰撞检测就可以获得当前鼠标位置下的所有组件。<br>
		 * @param	value	gui组件
		 */
        private function buildWndPositionMap(value:DeltaXWindow):void{
            var left:int;
            var top:int;
            var right:int;
            var bottom:int;
            var indexY:int;
            var indexX:int;
            if (value.mouseEnabled && value.enable){
				left = (value.globalX / this.m_pixelXPerPositionUnit);
				top = (value.globalY / this.m_pixelYPerPositionUnit);
				right = ((value.globalX + value.width) / this.m_pixelXPerPositionUnit);
				bottom = ((value.globalY + value.height) / this.m_pixelYPerPositionUnit);
				indexY = top;
                while (indexY <= bottom) {
                    if ((((indexY < 0)) || ((indexY >= WND_POSITION_MAP_SIZE)))){
                    } else {
						indexX = left;
                        while (indexX <= right) {
                            if ((((indexX < 0)) || ((indexX >= WND_POSITION_MAP_SIZE)))){
                            } else {
                                this.m_wndPositionMap[indexY][indexX].push(value);
                            };
							indexX++;
                        };
                    };
					indexY++;
                };
            };
            var child:DeltaXWindow = value.visibleChildBottomMost;
            while (child) {
                if ((child.style & WindowStyle.MODAL)){
                } else {
                    this.buildWndPositionMap(child);
                };
				child = child.visibleBrotherAbove;
            };
        }
		
		/**
		 *检测是否重新构建所有组件占用的格子位置<br>
		 */
        private function checkWndPositionMap():void{
            var indexX:uint;
            if (!this.m_wndPositionMapInvalid){
                return;
            };
            this.m_pixelXPerPositionUnit = ((this.m_rootWnd.width / WND_POSITION_MAP_SIZE) + 1);
            this.m_pixelYPerPositionUnit = ((this.m_rootWnd.height / WND_POSITION_MAP_SIZE) + 1);
            var indexY:uint;
            while (indexY < WND_POSITION_MAP_SIZE) {
				indexX = 0;
                while (indexX < WND_POSITION_MAP_SIZE) {
                    this.m_wndPositionMap[indexY][indexX].length = 0;
					indexX++;
                };
                indexY++;
            };
            this.buildWndPositionMap(this.m_rootWnd);
            this.m_wndPositionMapInvalid = false;
        }
		
		/**
		 *m_wndPositionMapInvalid设置成ture<br>
		 * 等执行checkWndPositionMap函数的时候强制所有组件重新计算
		 */
        public function invalidWndPositionMap():void{
            this.m_wndPositionMapInvalid = true;
        }
		
		/**
		 *获取坐标点value最上面的组件
		 * @param	value	点
		 * @param	value2	无效
		 * @return DeltaXWindow
		 */
        public function detectTopWnd(value:Point, value2:Boolean):DeltaXWindow{
            var guiArr:Array = this.getWindowUnderPoint(value, 1);
            return guiArr.length ? guiArr[0] : null;
        }
		
		/**
		 *获取坐标点value下面的所有组件<br>
		 * 与flash.display.DisplayObjectContainer::getObjectsUnderPoint方法功能一致<br>
		 * @param	value				点
		 * @param	count				数量
		 * @return Array
		 */
        public function getWindowUnderPoint(value:Point, count:uint=4294967295):Array{
            var gui:DeltaXWindow;
            if (count == 0){
                return ([]);
            };
            this.checkWndPositionMap();
            var indexX:int = (value.x / this.m_pixelXPerPositionUnit);
            var indexY:int = (value.y / this.m_pixelYPerPositionUnit);
            if (indexX < 0 || indexX >= WND_POSITION_MAP_SIZE){
                return [];
            };
            if (indexY < 0 || indexY >= WND_POSITION_MAP_SIZE){
                return [];
            };
            var arr:Array = [];
            var guiArr:Vector.<DeltaXWindow> = this.m_wndPositionMap[indexY][indexX];
            var i:int = (guiArr.length - 1);
            while (i >= 0) {
				gui = guiArr[i];
                if (gui.isInWndArea(value.x, value.y)){
					arr.push(gui);
                    if (arr.length >= count){
                        return arr;
                    };
                };
                i--;
            };
            return arr;
        }
        public function setModuleWnd(_arg1:DeltaXWindow, _arg2:Boolean):void{
            var _local3:int = this.m_listModuleWnd.indexOf(_arg1);
            if (_local3 >= 0){
                this.m_listModuleWnd.splice(_local3, 1);
            };
            if (_arg2){
                this.setHeldWindow(null);
                this.m_listModuleWnd.push(_arg1);
                this.m_moduleWnd = _arg1;
            } else {
                if (this.m_moduleWnd == _arg1){
                    if (this.m_listModuleWnd.length){
                        this.m_moduleWnd = this.m_listModuleWnd[(this.m_listModuleWnd.length - 1)];
                    } else {
                        this.m_moduleWnd = null;
                    };
                    this.setHeldWindow(null);
                };
            };
        }
		
		/**
		 * 注册组件的按键事件<br>
		 * 接收：用注册的组件侦听事件DXWndEvent.ACCELKEY
		 * @param gui				组件
		 * @param isCtrl			ctrl键
		 * @param isShift			shift键
		 * @param isAlt				alt键
		 * @param keyCode			按键code
		 * @param context			数据
		 * @param allowRepeat		是否重复按键。比如按住A不动，是否不断处理
		 * 
		 */		
        public function registerAccelKeyCommand(gui:DeltaXWindow, isCtrl:Boolean, isShift:Boolean, isAlt:Boolean, keyCode:uint, context:Object, allowRepeat:Boolean=false):void{
            if (isCtrl){
				keyCode = (keyCode | ACCEKEY_CTRL);
            };
            if (isShift){
				keyCode = (keyCode | ACCEKEY_SHIFT);
            };
            if (isAlt){
				keyCode = (keyCode | ACCEKEY_ALT);
            };
            var keyVo:AcceKey = (this.m_mapAcceKey[keyCode] = ((this.m_mapAcceKey[keyCode]) || (new AcceKey())));
			keyVo.m_targetWnd = gui;
			keyVo.m_context = context;
			keyVo.m_allowRepeat = allowRepeat;
        }
		
		/**
		 * 移除用gui组件注册的按键事件 
		 * @param gui		组件
		 * 
		 */		
        public function unRegisterAccelKeyCommandByWnd(gui:DeltaXWindow):void{
            var _local2:*;
            var _local3:uint;
            this.m_tempAccelKeysToUnregisterCount = 0;
            for (_local2 in this.m_mapAcceKey) {
                if (this.m_mapAcceKey[_local2].m_targetWnd == gui){
                    var _local6:uint = this.m_tempAccelKeysToUnregisterCount++;
                    this.m_tempAccelKeysToUnregister[_local6] = _local2;
                };
            };
            _local3 = 0;
            while (_local3 < this.m_tempAccelKeysToUnregisterCount) {
                delete this.m_mapAcceKey[this.m_tempAccelKeysToUnregister[_local3]];
                _local3++;
            };
        }
		
		/**
		 * 根据注册的按键移除按键事件 
		 * @param isCtrl		ctrl键
		 * @param isShift		shift键
		 * @param isAlt			alt键
		 * @param keyCode		按键code
		 * 
		 */		
        public function unRegisterAccelKeyCommand(isCtrl:Boolean, isShift:Boolean, isAlt:Boolean, keyCode:uint):void{
            if (isCtrl){
                keyCode = (keyCode | ACCEKEY_CTRL);
            };
            if (isShift){
                keyCode = (keyCode | ACCEKEY_SHIFT);
            };
            if (isAlt){
                keyCode = (keyCode | ACCEKEY_ALT);
            };
            this.m_mapAcceKey[keyCode] = null;
            delete this.m_mapAcceKey[keyCode];
        }
		
		/**
		 * 按键侦听， 如果组件有注册key事件。则派发DXWndEvent.ACCELKEY事件
		 * @param e
		 * @param target
		 * @return 
		 * 
		 */		
        private function translateAccelKey(e:KeyboardEvent, target:DeltaXWindow):Boolean{
            var _local3:uint = e.keyCode;
            if (e.ctrlKey){
                _local3 = (_local3 | ACCEKEY_CTRL);
            };
            if (e.shiftKey){
                _local3 = (_local3 | ACCEKEY_SHIFT);
            };
            if (e.altKey){
                _local3 = (_local3 | ACCEKEY_ALT);
            };
            var _local4:AcceKey = this.m_mapAcceKey[_local3];
            if (_local4 == null){
                return (false);
            };
            if ((((((e.type == KeyboardEvent.KEY_DOWN)) && (this.m_keyIsPress))) && (!(_local4.m_allowRepeat)))){
                return (false);
            };
            if ((((_local3 == e.keyCode)) && ((target.focusWnd is DeltaXEdit)))){
                return (false);
            };
            var _local5:DeltaXWindow = _local4.m_targetWnd;
            while (_local5) {
                if (target == _local5){
                    _local4.m_targetWnd.dispatchEvent(new DXWndEvent(DXWndEvent.ACCELKEY, _local4.m_context));
                    this.m_ignoreNextKeyup = (e.type == KeyboardEvent.KEY_DOWN);
                    return (true);
                };
                _local5 = _local5.parent;
            };
            return (false);
        }
        public function processEvent(_arg1:Event):void{
            var _local3:MouseEvent;
            var _local4:KeyboardEvent;
            var _local8:Boolean;
            var _local9:Point;
            var _local2:String = _arg1.type;
            if ((_arg1 is MouseEvent)){
                _local3 = MouseEvent(_arg1);
                if (_local3.type == MouseEvent.MOUSE_MOVE){
                    if (this.m_curMouseEvent != _local3){
                        this.m_curMouseEvent = _local3;
                        this.m_cursorPos.x = this.m_curMouseEvent.localX;
                        this.m_cursorPos.y = this.m_curMouseEvent.localY;
                        return;
                    };
                } else {
                    if (this.m_curMouseEvent != null){
                        this.processEvent(this.m_curMouseEvent);
                        this.m_curMouseEvent = null;
                    };
                };
            };
            var _local5:DeltaXWindow = (this.m_moduleWnd) ? this.m_moduleWnd : this.m_rootWnd;
            var _local6:DeltaXWindow;
            if ((_arg1 is KeyboardEvent)){
                _local4 = KeyboardEvent(_arg1);
                this.m_keyIsPress = (_local4.type == KeyboardEvent.KEY_DOWN);
                if (((this.m_ignoreNextKeyup) && ((_local4.type == KeyboardEvent.KEY_UP)))){
                    this.m_ignoreNextKeyup = false;
                    return;
                };
                _local8 = this.translateAccelKey(_local4, _local5);
                if (_local8){
                    return;
                };
            };
            var _local7:DeltaXWindow = this.m_holdWnd;
            if (((_local3) && ((((_local3.type == MouseEvent.MOUSE_UP)) || ((((_local3.type == MouseEvent.MOUSE_MOVE)) && (!(_local3.buttonDown)))))))){
                this.setHeldWindow(null);
            };
            this.m_curEvent = _arg1;
            if (_local3){
                if (_local3.type == MouseEvent.MOUSE_DOWN){
                    this.m_cursorPos.x = 0;
                };
                this.m_cursorPos.x = _local3.localX;
                this.m_cursorPos.y = _local3.localY;
                _local3.localX = this.m_cursorPos.x;
                _local3.localY = this.m_cursorPos.y;
                if (((this.m_cursorAttachWnd) && (this.m_cursorAttachWnd.inUITree))){
                    this.m_cursorAttachWnd.setGlobal((this.m_cursorPos.x - this.m_attachPos.x), (this.m_cursorPos.y - this.m_attachPos.y));
                };
                _local6 = (this.m_holdWnd) ? this.m_holdWnd : this.detectTopWnd(this.m_cursorPos, (_local3.type == MouseEvent.MOUSE_WHEEL));
                if (((((!(this.m_holdWnd)) && (_local7))) && (!((_local6 == _local7))))){
                    return;
                };
            };
            _local6 = (_local6) ? _local6 : this.m_rootWnd.focusWnd;
            if (_local3){
                if (this.m_lastMouseOverWnd != _local6){
                    if (((this.m_lastMouseOverWnd) && (this.m_lastMouseOverWnd.parent))){
                        _local9 = new Point(_local3.localX, _local3.localY);
                        new Point(_local3.localX, _local3.localY).x = (_local9.x - this.m_lastMouseOverWnd.globalX);
                        _local9.y = (_local9.y - this.m_lastMouseOverWnd.globalY);
                        this.m_lastMouseOverWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_LEAVE, _local9, _local3.delta, _local3.ctrlKey, _local3.shiftKey, _local3.altKey, _local3.buttonDown));
                    };
                    if (_local6){
                        _local9 = new Point(_local3.localX, _local3.localY);
                        new Point(_local3.localX, _local3.localY).x = (_local9.x - _local6.globalX);
                        _local9.y = (_local9.y - _local6.globalY);
                        _local6.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_ENTER, _local9, _local3.delta, _local3.ctrlKey, _local3.shiftKey, _local3.altKey, _local3.buttonDown));
                    };
                    this.m_preMouseOverTime = getTimer();
                    this.m_lastMouseOverWnd = _local6;
                };
            };
            if ((((_local6 == null)) || (!(_local6.enable)))){
                return;
            };
            if (((_local3) && (_local3.buttonDown))){
                _local6.setFocus();
                this.m_lastMouseOverWnd = null;
                this.m_curTooltipWnd = null;
            };
            if (((((_local3) && ((_local3.type == MouseEvent.MOUSE_DOWN)))) && (!((this.m_holdWnd == _local6))))){
                this.setHeldWindow(_local6);
            };
            this.dispatchEvent(_local6, _arg1);
        }
        public function dispatchEvent(target:DeltaXWindow, e:Event):void{
            var _local4:KeyboardEvent;
            var _local5:MouseEvent;
            var _local6:Point;
            var _local7:int;
            var _local8:int;
            if ((e is KeyboardEvent)){
                _local4 = (e as KeyboardEvent);
                if (_local4.type == KeyboardEvent.KEY_UP){
                    target.dispatchEvent(new DXWndKeyEvent(DXWndKeyEvent.KEY_UP, _local4.keyCode, _local4.ctrlKey, _local4.shiftKey, _local4.altKey));
                };
                if (_local4.type == KeyboardEvent.KEY_DOWN){
                    target.dispatchEvent(new DXWndKeyEvent(DXWndKeyEvent.KEY_DOWN, _local4.keyCode, _local4.ctrlKey, _local4.shiftKey, _local4.altKey));
                };
                return;
            };
            var _local3:int = getTimer();
            if ((((e is TextEvent)) && (((_local3 - this.m_preHoldTime) > 200)))){
                target.dispatchEvent(new DXWndEvent(DXWndEvent.TEXT_INPUT, TextEvent(e).text));
                return;
            };
            if ((e is MouseEvent)){
                _local5 = (e as MouseEvent);
                _local6 = new Point(_local5.localX, _local5.localY);
                if (((((target.isHeld) && ((_local5.type == MouseEvent.MOUSE_MOVE)))) && (_local5.buttonDown))){
                    if (target.parent){
                        if ((WindowStyle.CHILD & target.style) == 0){
                            _local7 = (this.m_curHeldPos.x + target.globalX);
                            _local8 = (this.m_curHeldPos.y + target.globalY);
                            if (target.isInTitleArea(_local7, _local8)){
                                _local6.x = (_local6.x - _local7);
                                _local6.y = (_local6.y - _local8);
                                if (!this.m_holdWndMoving){
                                    this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAGSTART, _local6, 0, false, false, false, true));
                                    this.m_holdWndMoving = true;
                                };
                                if (target.onWndPreMoved(_local6)){
									//判断组件是否拖动居中
                                    target.setGlobal((target.globalX + _local6.x + (target.dragCenter?m_curHeldPos.x - target.width/2:0)), 
										(target.globalY + _local6.y + (target.dragCenter?m_curHeldPos.y - target.height/2:0)));
                                };
                            };
                        } else {
                            _local6.x = (_local6.x - target.globalX);
                            _local6.y = (_local6.y - target.globalY);
                            if (!this.m_holdWndMoving){
                                this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAGSTART, _local6, 0, false, false, false, true));
                                this.m_holdWndMoving = true;
                            };
                            target.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAG, _local6, _local5.delta, _local5.ctrlKey, _local5.shiftKey, _local5.altKey, _local5.buttonDown));
                        };
                    };
                } else {
                    _local6.x = (_local6.x - target.globalX);
                    _local6.y = (_local6.y - target.globalY);
                    if (_local5.type == MouseEvent.MOUSE_UP){
                        if (((this.m_lastMouseUpTime) && (((_local3 - this.m_lastMouseUpTime) < 200)))){
                            this.m_lastMouseUpTime = _local3;
                            target.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DOUBLE_CLICK, _local6, _local5.delta, _local5.ctrlKey, _local5.shiftKey, _local5.altKey, _local5.buttonDown));
                            return;
                        };
                        this.m_lastMouseUpTime = _local3;
                    };
                    target.dispatchEvent(new DXWndMouseEvent(_local5.type, _local6, _local5.delta, _local5.ctrlKey, _local5.shiftKey, _local5.altKey, _local5.buttonDown));
                };
                return;
            };
            if (e.type == Event.RESIZE){
				//this.rootWnd.setSize(Stage(e.target).stageWidth, Stage(e.target).stageHeight);
				this.rootWnd.setSize(BaseApplication.instance.rootUIComponent.width, BaseApplication.instance.rootUIComponent.height);
            };
        }
        public function unregistWnd(_arg1:DeltaXWindow):void{
            if (this.m_holdWnd == _arg1){
                this.setHeldWindow(null);
            };
            this.unRegisterAccelKeyCommandByWnd(_arg1);
        }
		
		/**
		 * 隐藏tips
		 */		
        public function hideToolTips():void{
            var _local1:Array = this.m_componentToTooltipUIMap[this.m_curTooltipWnd];
            if (!_local1){
                this.m_commonTooltipsWnd.hide();
                return;
            };
            var _local2:DeltaXWindow = _local1[0];
            if (((_local2) && ((_local2 == this.m_curShowingCustomTooltip)))){
                this.m_curShowingCustomTooltip.visible = false;
                this.m_curShowingCustomTooltip = null;
            };
        }
		
		/**
		 * 显示tips,重绘tips
		 */		
        public function showToolTips():void{
            var _local3:String;
            var paramObj:Object;
            var tipArr:Array = this.m_componentToTooltipUIMap[this.m_curTooltipWnd];
            if (!tipArr){
                _local3 = this.m_curTooltipWnd.tooltipsText;
                if (!_local3){
                    return;
                };
                this.m_commonTooltipsWnd.setText(_local3);
                this.m_commonTooltipsWnd.show();
                this.calcTooltipPosition(this.m_commonTooltipsWnd, this.m_curTooltipWnd);
                return;
            };
            var tipGui:DeltaXWindow = tipArr[0];
            if (tipGui){
                if (((this.m_curShowingCustomTooltip) && (!((this.m_curShowingCustomTooltip == tipGui))))){
                    this.m_curShowingCustomTooltip.visible = false;
                };
                this.m_curShowingCustomTooltip = tipGui;
                if ((tipGui is ICustomTooltip)){
					//TIPS实现了ICustomTooltip接口则调用接口方法
                    paramObj = tipArr[1];
                    tipGui.visible = ICustomTooltip(tipGui).prepareContent(this.m_curTooltipWnd, paramObj);
                } else {
					//否则调用普通tips组件的设置文本
                    tipGui.setText(this.m_curTooltipWnd.tooltipsText);
                    tipGui.visible = true;
                };
                this.calcTooltipPosition(tipGui, this.m_curTooltipWnd);
				
				
                if ((tipGui is ICustomTooltip)){
					//TIPS实现了ICustomTooltip接口则调用接口方法
					//存在意义不大
                    ICustomTooltip(tipGui).postCalcPosition(this.m_curTooltipWnd, paramObj);
                };
            };
        }
		
		/**
		 * 设置默认tips样式 
		 * @param resURL		url
		 */		
        public function setDefaultTooltipRes(resURL:String):void{
            this.m_commonTooltipsWnd.createFromRes(resURL, this.m_rootWnd);
        }
		
		/**
		 * 注册自定义tips 
		 * @param registerGui	需要注册的gui
		 * @param tipsGui		tips界面gui
		 * @param param			参数
		 * 
		 */		
        public function registerCustomTooltip(registerGui:DeltaXWindow, tipsGui:DeltaXWindow, param:Object=null):void{
            this.m_componentToTooltipUIMap[registerGui] = [tipsGui, param];
        }
        public function unregisterCustomTooltip(_arg1:DeltaXWindow):void{
            delete this.m_componentToTooltipUIMap[_arg1];
        }
		
		/**
		 * 计算tips坐标，根据侦听的组件 
		 * @param tipGui			tips组件
		 * @param globalBounds		侦听组件的全局矩形xy宽高
		 * @param isFollow			是否跟随鼠标
		 * 
		 */		
        public function calcTooltipPositionByTargetBound(tipGui:DeltaXWindow, globalBounds:Rectangle, isFollow:Boolean=false):void{
            var t_mouseX:Number;
            var t_mouseY:Number;
            var gameState:DeltaXWindow;
            var _local13:Number;
            var _local14:Number;
            var _local15:Boolean;
            if (((!(tipGui)) || (!(globalBounds)))){
                return;
            };
            var _local4:Number = globalBounds.x;
            var _local5:Number = globalBounds.y;
            var _local6:Number = globalBounds.width;
            var _local7:Number = globalBounds.height;
            var _local8:Rectangle = MathUtl.TEMP_RECTANGLE2;
            var _local9:DeltaXWindow = this.m_rootWnd;
            _local8.x = (_local8.y = 0);
            _local8.width = _local9.width;
            _local8.height = _local9.height;
            if (isFollow){
				
				/**
				 * 鼠标跟随，加入偏移坐标。避免鼠标与tips组件重叠产生一闪一闪问题<br>
				 * 坐标限制，加入x判断
				 * @modify	Exin 2015.03.26
				 */	
				var t_offsetX:int = 10;
				var t_offsetY:int = 20;
                tipGui.x = tipGui.mouseX + t_offsetX;
                tipGui.y = tipGui.mouseY + t_offsetY;
                
				
            } else {
				
				tipGui.x = globalBounds.right;
				tipGui.y = globalBounds.bottom;
				/*
                _local13 = _local4;
                _local14 = (_local5 - tipGui.height);
                _local15 = false;
                if (_local14 < _local8.x){
                    _local14 = (_local5 + _local7);
                    if ((_local14 + tipGui.height) > _local8.bottom){
                        _local14 = (_local8.bottom - tipGui.height);
                        if (_local14 < _local8.top){
                            _local14 = _local8.top;
                        };
                        _local15 = true;
                    };
                };
                if (_local13 > (_local8.left + (_local8.width / 2))){
                    _local13 = ((_local4 + _local6) - tipGui.width);
                    if (_local15){
                        _local13 = (_local4 - tipGui.width);
                    };
                } else {
                    if (_local15){
                        _local13 = (_local4 + _local6);
                    };
                };
                if ((_local13 + tipGui.width) > _local8.right){
                    _local13 = (Math.min((_local4 + tipGui.width), _local8.right) - tipGui.width);
                };
                if (_local13 < _local8.left){
                    _local13 = Math.max(((_local4 + _local6) - tipGui.width), _local8.left);
                };
                tipGui.globalX = _local13;
                tipGui.globalY = _local14;
				
				*/
            }
			
			gameState = _local9.getChildByName("GameMainState");
			if (((gameState) && (((tipGui.y + tipGui.height) > (gameState.y + gameState.height))))){
				//y坐标根据GameMainState限制
				tipGui.y = (gameState.y + gameState.height - tipGui.height);
			};
			
			if (((gameState) && (((tipGui.x + tipGui.width) > (gameState.x + gameState.width))))){
				//x坐标限制
				tipGui.x = (gameState.x + gameState.width - tipGui.width);
			};
        }
		
		/**
		 *  计算tips坐标
		 * @param tipGui		tips组件
		 * @param tipTarget		侦听tips的组件
		 */		
        private function calcTooltipPosition(tipGui:DeltaXWindow, tipTarget:DeltaXWindow):void{
            if (((!(tipGui)) || (!(tipTarget)))){
                return;
            };
            var isFollow:Boolean;
            if ((tipTarget is DeltaXWindow)){
                //isFollow = Boolean((DeltaXWindow(tipTarget).properties.style & WindowStyle.TOOLTIP_FOLLOW_CURSOR));
				isFollow = Boolean((DeltaXWindow(tipTarget).style & WindowStyle.TOOLTIP_FOLLOW_CURSOR));
            };
            var bounds:Rectangle = tipTarget.globalBounds.clone();
            this.calcTooltipPositionByTargetBound(tipGui, bounds, isFollow);
        }
		
		/**
		 * 渲染
		 * @param	context3D	3d容器
		 * @param	isDebugUI	ui是否是debug。是对焦点组件边框画线
		 */
        public function render(context3D:Context3D, isDebugUI:Boolean):void{
            var _local6:DeltaXWindow;
            var _local7:int;
            var _local8:DeltaXWindow;
            var _local9:DeltaXWindow;
            if (!context3D){
                return;
            };
            if (this.m_curMouseEvent != null){
                this.processEvent(this.m_curMouseEvent);
                this.m_curMouseEvent = null;
            };
            var _local3:uint = getTimer();
            var _local4:uint = (this.m_preRenderTime) ? (_local3 - this.m_preRenderTime) : 0;
            var _local5:DeltaXWindow = this.lastMouseOverWnd;
            this.m_preRenderTime = _local3;
            if (((((_local5) && (_local5.visible))) && (((_local3 - this.m_preMouseOverTime) >= _local5.mouseOverDescDelay)))){
                if (this.m_curTooltipWnd != _local5){
                    this.m_curTooltipWnd = _local5;
                    this.showToolTips();
                }else
				{
					//坐标更新
					this.calcTooltipPosition(this.m_commonTooltipsWnd.visible?m_commonTooltipsWnd:m_curShowingCustomTooltip, this.m_curTooltipWnd);
				}
            } else {
                if (((this.m_curTooltipWnd) && (!((this.m_curTooltipWnd == _local5))))){
                    this.hideToolTips();
                    this.m_curTooltipWnd = null;
                };
            };
            if (((((this.m_holdingSameWnd) && (this.m_holdWnd))) && (this.m_holdWnd.enableMouseContinousDownEvent))){
                this.m_continuosMouseDownPassTime = (this.m_continuosMouseDownPassTime + _local4);
                _local7 = MathUtl.max(1, this.m_holdWnd.mouseContinousDownInterval);
                while (int(this.m_continuosMouseDownPassTime) >= _local7) {
                    this.m_continuosMouseDownPassTime = (this.m_continuosMouseDownPassTime - _local7);
                    this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN, this.cursorPos, 0, false, false, false, true));
                };
            };
            this.draw(context3D, this.m_rootWnd, _local3, _local4);
            for each (_local6 in this.m_listModuleWnd) {
                if (((!(_local6.parent)) || (((!(_local6.visible)) && (!(_local6.fading)))))){
                } else {
                    this.draw(context3D, _local6, _local3, _local4);
                };
            };
            if (isDebugUI){
                _local8 = this.rootWnd.focusWnd;
                _local9 = (_local5) ? _local5 : _local8;
                if (_local8 == _local9){
                    this.drawRectWireFrame(context3D, _local8.globalBounds, 0xffff00ff);
                } else {
                    this.drawRectWireFrame(context3D, _local8.globalBounds, 0xffff0000);
                    this.drawRectWireFrame(context3D, _local9.globalBounds, 0xff0000ff);
                };
            };
            DeltaXRectRenderer.Instance.flushAll(context3D);
            DeltaXFontRenderer.Instance.endFontRender(context3D);
        }
		
		/**
		 * 画线
		 * @param	context3D		3d容器
		 * @param	rect			画线矩形
		 * @param	color			颜色
		 */
        private function drawRectWireFrame(context3D:Context3D, rect:Rectangle, color:uint):void{
            var _local4:DeltaXRectRenderer = DeltaXRectRenderer.Instance;
            _local4.renderRect(context3D, 0, 0, new Rectangle(rect.left, rect.top, rect.width, 1), color);
            _local4.renderRect(context3D, 0, 0, new Rectangle((rect.right - 1), rect.top, 1, rect.height), color);
            _local4.renderRect(context3D, 0, 0, new Rectangle(rect.left, (rect.bottom - 1), rect.width, 1), color);
            _local4.renderRect(context3D, 0, 0, new Rectangle(rect.left, rect.top, 1, rect.height), color);
        }
		
		/**
		 * 渲染组件
		 * @param	context3D		3d容器
		 * @param	value			gui组件
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        public function draw(context3D:Context3D, value:DeltaXWindow, valueGetTimer:uint, fpsTime:int):void{
            var gui:DeltaXWindow;
            if (value != this.m_rootWnd){
				value.render(context3D, valueGetTimer, fpsTime);
            };
            if (value.fadingChildCount > 0){
				gui = value.childBottomMost;
                while (gui) {
                    if ((gui.style & WindowStyle.MODAL)){
                    } else {
                        if (((!(gui.visible)) && (!(gui.fading)))){
                        } else {
                            this.draw(context3D, gui, valueGetTimer, fpsTime);
                        };
                    };
					gui = gui.brotherAbove;
                };
            } else {
				gui = value.visibleChildBottomMost;
                while (gui) {
                    if ((gui.style & WindowStyle.MODAL)){
                    } else {
                        this.draw(context3D, gui, valueGetTimer, fpsTime);
                    };
					gui = gui.visibleBrotherAbove;
                };
            };
			gui = null;
        }
		
		/**
		 * 隐藏鼠标
		 */
        public function hideMouse():void{
            Mouse.hide();
        }
		
		/**
		 * 显示鼠标
		 */
        public function showMouse():void{
            Mouse.show();
        }
        public function get globalCursorName():String{
            return this.m_globalCursorName;
        }
        public function set globalCursorName(value:String):void{
            this.m_globalCursorName = value;
        }
		
		/**
		 * 设置鼠标样式名
		 * @param	value	鼠标样式名
		 */
        public function setCursor(value:String):void{
            if (this.m_guiHandler && value){
                this.m_guiHandler.doSetCursor(value);
            };
        }
        public function get curTooltipWnd():DeltaXWindow{
            return this.m_curTooltipWnd;
        }
        public function get curShowingCustomTooltip():DeltaXWindow{
            return this.m_curShowingCustomTooltip;
        }

    }
}//package deltax.gui.manager 

import deltax.gui.component.*;

class AcceKey {

    public var m_targetWnd:DeltaXWindow;
    public var m_context:Object;
    public var m_allowRepeat:Boolean;

    public function AcceKey(){
    }
}
class DeltaXRootWnd extends DeltaXFrame {

    public function DeltaXRootWnd(){
        super(null, null);
        m_visible = true;
    }
}
