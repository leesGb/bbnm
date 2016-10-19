package deltax.gui.component {
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import __AS3__.vec.Vector;
    
    import deltax.appframe.BaseApplication;
    import deltax.common.DictionaryUtil;
    import deltax.common.debug.ObjectCounter;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.manager.IResource;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ResourceType;
    import deltax.graphic.render2D.font.DeltaXFont;
    import deltax.graphic.render2D.font.DeltaXFontRenderer;
    import deltax.graphic.util.IAlphaChangeable;
    import deltax.gui.base.ComponentDisplayItem;
    import deltax.gui.base.ComponentDisplayStateInfo;
    import deltax.gui.base.DisplayImageInfo;
    import deltax.gui.base.WindowCreateParam;
    import deltax.gui.base.WindowResource;
    import deltax.gui.base.WndSoundFxType;
    import deltax.gui.base.style.AreaHitTestColor;
    import deltax.gui.base.style.LockFlag;
    import deltax.gui.base.style.WindowStyle;
    import deltax.gui.component.event.DXWndEvent;
    import deltax.gui.component.event.DXWndKeyEvent;
    import deltax.gui.component.event.DXWndMouseEvent;
    import deltax.gui.component.subctrl.CommonWndSubCtrlType;
    import deltax.gui.component.subctrl.SubCtrlStateType;
    import deltax.gui.manager.GUIManager;
    import deltax.gui.manager.WindowClassManager;
    import deltax.gui.util.ImageList;
    import deltax.gui.util.Size;

	/**
	 * UI基类
	 * @author admin
	 *
	 */
    public class DeltaXWindow implements IAlphaChangeable {

        private static const DEFAULT_Z:Number = 0.999999;

        private static var m_focusWnd:DeltaXWindow;
        private static var m_tempResizeRect:Rectangle = new Rectangle();
        private static var ms_clip:Rectangle = new Rectangle();
        private static var ms_effectMatrix:Matrix3D = new Matrix3D();

        protected var m_guiManager:GUIManager;
        protected var m_properties:WindowCreateParam;
        protected var m_userObject:Object;
        protected var m_text:String = "";
        protected var m_style:uint = 0;
        protected var m_toolTips:String;
        private var m_enableMouseContinousDownEvent:Boolean;
        private var m_mouseContinousDownInterval:uint = 100;
        protected var m_parent:DeltaXWindow;
        protected var m_childTopMost:DeltaXWindow;
        protected var m_childBottomMost:DeltaXWindow;
        protected var m_brotherAbove:DeltaXWindow;
        protected var m_brotherBelow:DeltaXWindow;
        protected var m_visibleChildTopMost:DeltaXWindow;
        protected var m_visibleChildBottomMost:DeltaXWindow;
        protected var m_visibleBrotherAbove:DeltaXWindow;
        protected var m_visibleBrotherBelow:DeltaXWindow;
        protected var m_visible:Boolean = true;
        private var m_mouseChildren:Boolean = true;
        private var m_bounds:Rectangle;
        private var m_tabIndex:int = -1;
        private var m_tabEnable:Boolean;
        private var m_eventListenerMap:Dictionary;
        private var m_invalidate:Boolean = true;
        private var m_enable:Boolean = true;
        private var m_created:Boolean;
        private var m_onLoadedHandler:Function;
        protected var m_font:DeltaXFont;
        protected var m_fontSize:uint;
        protected var m_mouseOverDescDelay:uint = 400;
        private var m_cursorName:String;
        private var m_name:String = "anonymous";
        private var m_fadeSpeed:Number = 0;
        private var m_destAlpha:Number = 1;
        private var m_fadeDuration:Number = 0;
        private var m_alpha:Number = 1;
        private var m_fadingChildCount:int;
        private var m_dragEnable:Boolean;
        protected var m_designatedParent:DeltaXWindow;
        private var m_attachEffects:Dictionary;
        protected var m_gray:Boolean;
		
		/**
		 * 拖动的时候是否居中拖动 
		 */		
		public var dragCenter:Boolean = false;
		
        public function DeltaXWindow(){
            this.m_guiManager = GUIManager.instance;
            this.m_bounds = new Rectangle();
            this.m_eventListenerMap = new Dictionary();
            super();
            ObjectCounter.add(this, 320);
            m_focusWnd = ((m_focusWnd) || (this));
            this.m_font = DeltaXFontRenderer.Instance.createFont();
            this.m_fontSize = 12;
        }
		
		/**
		 * 静态方法。声音播放
		 * @param	event	事件，点击播放还是界面关闭播放等
		 */
        private static function onComponentSoundEvent(event:DXWndEvent):void{
            var url:String;
            var gui:DeltaXWindow = (event.target as DeltaXWindow);
            if (((((!(gui)) || (!(gui.m_properties)))) || (!(gui.m_properties.soundFxs)))){
                return;
            };
            if (event.type == DXWndEvent.HIDDEN){
                url = gui.m_properties.soundFxs[WndSoundFxType.CLOSE];
            } else {
                if (event.type == DXWndEvent.SHOWN){
                    url = gui.m_properties.soundFxs[WndSoundFxType.OPEN];
                } else {
                    if (event.type == DXWndMouseEvent.MOUSE_DOWN){//if (event.type == MouseEvent.CLICK){
                        url = gui.m_properties.soundFxs[WndSoundFxType.CLICK];
                    };
                };
            };
//            if (url)
//			{
//                BaseApplication.instance.playSound((BaseApplication.instance.rootResourcePath + url));
//            }
        }
		
		/**
		 * 设置子对象能否派发事件
		 */
        public function set childNotifyEnable(value:Boolean):void{
            if (value){
                this.m_style = (this.m_style | WindowStyle.REQUIRE_CHILD_NOTIFY);
            } else {
                this.m_style = (this.m_style & ~(WindowStyle.REQUIRE_CHILD_NOTIFY));
            };
        }
        public function get childNotifyEnable():Boolean{
            return (!(((this.m_style & WindowStyle.REQUIRE_CHILD_NOTIFY) == 0)));
        }
		
		/**
		 * 设置鼠标能否接受事件
		 */
        public function set mouseEnabled(value:Boolean):void{
            var _local2:Boolean = this.mouseEnabled;
            if (value){
                this.m_style = (this.m_style & ~(WindowStyle.MSG_TRANSPARENT));
            } else {
                this.m_style = (this.m_style | WindowStyle.MSG_TRANSPARENT);
            };
            if (_local2 != this.mouseEnabled){
                this.m_guiManager.invalidWndPositionMap();
            };
        }
        public function get mouseEnabled():Boolean{
            var style:Boolean = ((this.m_style & WindowStyle.MSG_TRANSPARENT) == 0);
            if (!style){
                return false;
            };
            if (this.m_parent){
                if (!this.m_parent.mouseChildren){
                    return false;
                };
            };
            return true;
        }
        public function set mouseChildren(value:Boolean):void{
            this.m_mouseChildren = value;
        }
        public function get mouseChildren():Boolean{
            if (!this.m_mouseChildren){
                return false;
            };
            return (!this.m_parent || this.m_parent.mouseChildren);
        }
        public function get enable():Boolean{
            return (this.m_enable);
        }
        public function set enable(value:Boolean):void{
            if (this.m_enable != value){
                this.m_guiManager.invalidWndPositionMap();
            };
            this.m_enable = value;
        }
        public function get cursorName():String{
            return (this.m_cursorName);
        }
        public function set cursorName(value:String):void{
            this.m_cursorName = value;
        }
		
		/**
		 * 侦听事件
		 * @param	type		事件类型
		 * @param	callback	回调函数
		 */
        public function addEventListener(type:String, callback:Function):void{
            var eventsArr:Vector.<Function> = (this.m_eventListenerMap[type] = ((this.m_eventListenerMap[type]) || (new Vector.<Function>())));
			eventsArr.push(callback);
            if (type == DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN){
                this.enableMouseContinousDownEvent = true;
            };
        }
		
		/**
		 * 设置是否可见
		 * @param	value		是否可见
		 */
        private function setVisible(value:Boolean):void{
            var gui:DeltaXWindow;
            if (!this.parent){
                return;
            };
            if (value){
                if ((((((this.parent.m_visibleChildTopMost == this)) || (!((this.m_visibleBrotherAbove == null))))) || (!((this.m_visibleBrotherBelow == null))))){
                    throw (new Error("the windows is top visible child"));
                };
                gui = this.m_brotherAbove;
                while (((gui) && (!(gui.m_visible)))) {
                    gui = gui.m_brotherAbove;
                };
                if (gui){
                    this.m_visibleBrotherAbove = gui;
                    this.m_visibleBrotherBelow = gui.m_visibleBrotherBelow;
                    gui.m_visibleBrotherBelow = this;
                    if (this.m_visibleBrotherBelow){
                        this.m_visibleBrotherBelow.m_visibleBrotherAbove = this;
                    };
                } else {
                    this.m_visibleBrotherAbove = null;
                    this.m_visibleBrotherBelow = this.parent.m_visibleChildTopMost;
                    this.parent.m_visibleChildTopMost = this;
                    if (this.m_visibleBrotherBelow){
                        this.m_visibleBrotherBelow.m_visibleBrotherAbove = this;
                    };
                };
                if (this.parent.m_visibleChildBottomMost == gui){
                    this.parent.m_visibleChildBottomMost = this;
                };
            } else {
                if (this.parent.m_visibleChildTopMost == this){
                    this.parent.m_visibleChildTopMost = this.m_visibleBrotherBelow;
                };
                if (this.parent.m_visibleChildBottomMost == this){
                    this.parent.m_visibleChildBottomMost = this.m_visibleBrotherAbove;
                };
                if (this.m_visibleBrotherBelow){
                    this.m_visibleBrotherBelow.m_visibleBrotherAbove = this.m_visibleBrotherAbove;
                };
                if (this.m_visibleBrotherAbove){
                    this.m_visibleBrotherAbove.m_visibleBrotherBelow = this.m_visibleBrotherBelow;
                };
                this.m_visibleBrotherBelow = null;
                this.m_visibleBrotherAbove = null;
            };
        }
        public function onDispose():void{
        }
		
		/**
		 * 清理
		 */
        public function dispose():void{
            var eventsArr:Vector.<Function>;
            if (this.creatingFromRes){
                this.m_designatedParent = null;
            };
            this.dispatchEvent(new DXWndEvent(DXWndEvent.DISPOSE));
            for each (eventsArr in this.m_eventListenerMap) {
				eventsArr.length = 0;
            };
            DictionaryUtil.clearDictionary(this.m_eventListenerMap);
            while (((this.m_childTopMost) && (this.parent))) {
                this.m_childTopMost.dispose();
            };
            this.m_guiManager.unregistWnd(this);
            this.m_guiManager.setModuleWnd(this, false);
            var t_focus:Boolean = this.focus;
            var t_parent:DeltaXWindow = this.parent;
            if (t_parent){
                this.remove();
                if (t_focus){
					t_parent.setFocus();
                };
            };
            if (this.m_properties){
                this.m_properties.release();
            };
            if (this.m_font){
                this.m_font.release();
            };
            this.m_properties = null;
            this.m_font = null;
            this.m_userObject = null;
            this.m_created = false;
        }
		
		/**
		 * 移除事件
		 * @param	type		事件类型
		 * @param	callback	回调函数
		 */
        public function removeEventListener(type:String, callback:Function):void{
            var eventsArr:Vector.<Function> = this.m_eventListenerMap[type];
            if (!eventsArr){
                return;
            };
            var i:uint;
            while (i < eventsArr.length) {
                if (eventsArr[i] == callback){
					eventsArr.splice(i, 1);
                    if (eventsArr.length == 0){
                        delete this.m_eventListenerMap[type];
                        if (type == DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN){
                            this.enableMouseContinousDownEvent = false;
                        };
                    };
                    break;
                };
                i++;
            };
        }
		
		/**
		 * 派发事件<br>
		 * 事件会给父容器一层一层网上冒泡派发事件。知道有设置停止。<br>
		 * 1.判断如果是DXWndEvent.CREATED事件，则调用自身_onWndCreatedInternal<br>
		 * 2.执行processMessage方法<br>
		 * 3.调用当前组件addEventListener当前事件的回调方法.如果回调函数有设置参数的event.stopPropagationImmediately()则立即停止冒泡<br>
		 * 4.有任何回调函数设置了形参event的stopPropagation()方法也停止冒泡<br>
		 * 5.父类有设置childNotifyEnable方法为false的也停止给父类冒泡<br>
		 * event的stopPropagationImmediately与stopPropagation方法区别:<br>
		 * 如果同一事件有多个地方侦听，例如：this.addEventListener(DXWndEvent.CREATED,a)<br>
		 *                        this.addEventListener(DXWndEvent.CREATED,b)<br>
		 *                        this.addEventListener(DXWndEvent.CREATED,c)<br>
		 * 若在b回调函数里面执行event.stopPropagationImmediately()方法，则立即停止冒泡，并不执行c方法<br>
		 * 若只执行event.stopPropagation()方法，则会继续完成执行当前侦听的所有的回调函数，c回调会继续执行。只是停止往父容器冒泡
		 * @param	event		事件
		 * @return	true派发成功。false组件不在渲染中
		 */
        public function dispatchEvent(event:DXWndEvent):Boolean{
            var callback:Function;
            if (!this.inUITree){
                return (false);
            };
            if (event.target == null){
                event.target = this;
            };
            if ((((event.type == DXWndEvent.CREATED)) && ((event.target == this)))){
                this._onWndCreatedInternal();
            };
            this.processMessage(event);
            var callbackArr:Vector.<Function> = this.m_eventListenerMap[event.type];
            if (callbackArr){
                if (event.currentTarget == null){
                    event.currentTarget = this;
                };
                for each (callback in callbackArr) {
                    if (this.enable){
                        callback(event);
                    };
                    if (event.stopImmediately){
                        return (true);
                    };
                };
            };
            if (event.stop){
                return (true);
            };
            if (!this.parent){
                return (true);
            };
            if ((this.parent.style & WindowStyle.REQUIRE_CHILD_NOTIFY) == 0){
                return (true);
            };
            event = event.clone();
            event.currentTarget = this.parent;
            if ((event is DXWndMouseEvent)){
                DXWndMouseEvent(event).point.offset(this.x, this.y);
            };
            this.parent.dispatchEvent(event);
            return true;
        }
		
		/**
		 * 是否有侦听事件
		 * @param	type		事件类型
		 * @param	true：有
		 */
        public function hasEventListener(type:String):Boolean{
            return !(this.m_eventListenerMap[type] == null);
        }
		
        public function willTrigger(type:String):Boolean{
            return !(this.m_eventListenerMap[type] == null);
        }
		
		/**
		 * 组件自身事件处理
		 * @param	event		事件
		 */
        public function processMessage(event:DXWndEvent):void{
            if (event.target != this){
                return;
            };
            switch (event.type){
                case DXWndMouseEvent.MOUSE_MOVE:
                    this.onMouseMove(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_ENTER:
                    this.m_guiManager.setCursor((this.m_cursorName) ? this.m_cursorName : this.m_guiManager.globalCursorName);
                    this.onMouseEnter(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_LEAVE:
                    this.onMouseLeave(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.DRAGSTART:
                    this.onDragStart(event.point);
                    break;
                case DXWndMouseEvent.DRAG:
                    this.onDrag(event.point);
                    break;
                case DXWndMouseEvent.DRAGEND:
                    this.onDragEnd(event.point);
                    break;
                case DXWndMouseEvent.DOUBLE_CLICK:
                    this.onMouseDbClick(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_DOWN:
                    this.onMouseDown(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    if (this.enableMouseContinousDownEvent){
                        this.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN, event.point, event.delta, event.ctrlKey, event.shiftKey, event.altKey, true));
                    };
                    break;
                case DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN:
                    this.onMouseContinousDown(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_UP:
                    this.onMouseUp(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.MIDDLE_MOUSE_DOWN:
                    this.onMouseMiddleDown(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.MIDDLE_MOUSE_UP:
                    this.onMouseMiddleUp(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.RIGHT_MOUSE_DOWN:
                    this.onMouseRightDown(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.RIGHT_MOUSE_UP:
                    this.onMouseRightUp(event.point, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndMouseEvent.MOUSE_WHEEL:
                    this.onMouseWheel(event.point, event.delta, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndKeyEvent.KEY_UP:
                    this.onKeyUp(event.keyCode, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndKeyEvent.KEY_DOWN:
                    this.onKeyDown(event.keyCode, event.ctrlKey, event.shiftKey, event.altKey);
                    break;
                case DXWndEvent.MOVED:
                    this.onMove(event.point);
                    break;
                case DXWndEvent.CREATED:
                    this.onWndCreated();
                    break;
                case DXWndEvent.DISPOSE:
                    this.onDispose();
                    break;
                case DXWndEvent.SELECTED:
                    break;
                case DXWndEvent.SHOWN:
                    this.onWndShown(true);
                    break;
                case DXWndEvent.HIDDEN:
                    this.onWndShown(false);
                    break;
                case DXWndEvent.ADDED_TO_PARENT:
                    this.onAddToParent((event.param as DeltaXWindow));
                    break;
                case DXWndEvent.REMOVED_FROM_PARENT:
                    this.onRemoveFromParent((event.param as DeltaXWindow));
                    break;
                case DXWndEvent.RESIZED:
                    this.onResize(event.size);
                    break;
                case DXWndEvent.TITLE_CHANGED:
                    this.onTextureChanged((event.param as String));
                    break;
                case DXWndEvent.STATE_CHANGED:
                    this.onStateChanged(event.param);
                    break;
                case DXWndEvent.ACCELKEY:
                    this.onAccelKey(event.param);
                    break;
                case DXWndEvent.TEXT_INPUT:
                    this.onText((event.param as String));
                    break;
                case DXWndEvent.FOCUS:
                    this.onFocus((event.param as Boolean));
                    break;
                case DXWndEvent.ACTIVE:
                    this.onActive((event.param as Boolean));
                    break;
            };
        }
		
		
		/**
		 * 添加子显示对象
		 * @param	child			组件
		 * @param	childTopMost	当前组件子对象中最上层的对象
		 */
        public function addChild(child:DeltaXWindow, childTopMost:DeltaXWindow=null):void{
            if (child == this){
                throw (new Error(("add self to child windos! " + this.name)));
            };
            if (childTopMost == child){
                return;
            };
            if (((childTopMost) && ((childTopMost == child.m_brotherBelow)))){
                return;
            };
            if (((childTopMost) && (!((childTopMost.parent == this))))){
                return;
            };
            var t_parent:DeltaXWindow = child.m_parent;
            if (t_parent){
                child.setVisible(false);
                if (child == t_parent.m_childBottomMost){
                    t_parent.m_childBottomMost = child.m_brotherAbove;
                } else {
                    if (child.m_brotherBelow){
                        child.m_brotherBelow.m_brotherAbove = child.m_brotherAbove;
                    };
                };
                if (child == t_parent.m_childTopMost){
                    t_parent.m_childTopMost = child.m_brotherBelow;
                } else {
                    if (child.m_brotherAbove){
                        child.m_brotherAbove.m_brotherBelow = child.m_brotherBelow;
                    };
                };
                if (t_parent != this){
                    child.addPosition(-(t_parent.globalX), -(t_parent.globalY));
                };
            };
            if (t_parent != this){
                child.m_parent = this;
                child.addPosition(this.globalX, this.globalY);
                if (((!(child.m_visible)) && ((child.m_fadeSpeed < 0)))){
                    child._incParentFadingChildCount();
                };
            };
            if (!(child.style & WindowStyle.TOP_MOST)){
                if (!childTopMost){
                    childTopMost = this.m_childTopMost;
                };
                while (((((childTopMost) && (!((childTopMost == child))))) && ((childTopMost.style & WindowStyle.TOP_MOST)))) {
                    childTopMost = childTopMost.m_brotherBelow;
                };
                child.m_brotherAbove = (childTopMost) ? childTopMost.m_brotherAbove : this.m_childBottomMost;
                child.m_brotherBelow = (childTopMost) ? childTopMost : null;
            } else {
                if (!childTopMost){
                    childTopMost = this.m_childBottomMost;
                };
                while (((((childTopMost) && (childTopMost.m_brotherAbove))) && (!((childTopMost.m_brotherAbove.style & WindowStyle.TOP_MOST))))) {
                    childTopMost = childTopMost.m_brotherAbove;
                };
                child.m_brotherAbove = (childTopMost) ? childTopMost.m_brotherAbove : null;
                child.m_brotherBelow = (childTopMost) ? childTopMost : this.m_childTopMost;
            };
            if (child.m_brotherAbove){
                child.m_brotherAbove.m_brotherBelow = child;
            } else {
                this.m_childTopMost = child;
            };
            if (child.m_brotherBelow){
                child.m_brotherBelow.m_brotherAbove = child;
            } else {
                this.m_childBottomMost = child;
            };
            if (child.m_visible){
                child.setVisible(true);
                if ((child.style & WindowStyle.MODAL)){
                    this.m_guiManager.setModuleWnd(child, true);
                };
            };
            child.dispatchEvent(new DXWndEvent(DXWndEvent.ADDED_TO_PARENT, t_parent));
            if (child.mouseEnabled){
                this.m_guiManager.invalidWndPositionMap();
            };
			
        }
		
		/**
		 * 自身移除显示对象
		 */
        public function remove():void{
            var t_parent:DeltaXWindow = this.m_parent;
            if (t_parent == null){
                return;
            };
            if (t_parent.m_childTopMost == this){
                t_parent.m_childTopMost = this.m_brotherBelow;
            };
            if (t_parent.m_childBottomMost == this){
                t_parent.m_childBottomMost = this.m_brotherAbove;
            };
            if (this.m_brotherBelow){
                this.m_brotherBelow.m_brotherAbove = this.m_brotherAbove;
            };
            if (this.m_brotherAbove){
                this.m_brotherAbove.m_brotherBelow = this.m_brotherBelow;
            };
            this.setVisible(false);
            this.m_brotherBelow = null;
            this.m_brotherAbove = null;
            if (((!(this.m_visible)) && ((this.m_fadeSpeed < 0)))){
                this._decParentFadingChildCount();
            };
            this.m_parent = null;
            this.addPosition(-(t_parent.globalX), -(t_parent.globalY));
            this.dispatchEvent(new DXWndEvent(DXWndEvent.REMOVED_FROM_PARENT, t_parent));
            if (this.mouseEnabled){
                this.m_guiManager.invalidWndPositionMap();
            };
        }
		
		/**
		 * 移除子对象
		 * @param	child	子显示对象
		 */
        public function removeChild(child:DeltaXWindow):void{
            if (child.parent != this){
                return;
            };
			child.remove();
        }
		
		/**
		 * 根据名字获取子显示对象
		 * @param	value	子显示对象名字
		 */
        public function getChildByName(value:String):DeltaXWindow{
            var gui:DeltaXWindow = this.m_childTopMost;
            while (gui) {
                if (gui.name == value){
                    return gui;
                };
				gui = gui.m_brotherBelow;
            };
            return null;
        }
		
		/**
		 * 将childName子对象移除，并把相关属性赋值给child
		 * @param	childName	子显示对象名字
		 * @param	child		显示对象
		 */
        public function reassignChild(childName:String, child:DeltaXWindow):void{
            var gui:DeltaXWindow = this.getChildByName(childName);
            if (!gui){
                throw (new Error(((this.name + " don't have a child name with ") + childName)));
            };
            if (gui.m_properties.refCount > 1){
                this.initComponentFromRes(gui.m_properties, child);
            } else {
                this.initComponentFromRes(gui.m_properties.clone(), child);
            };
            child.m_font.release();
            child.m_font = DeltaXFontRenderer.Instance.createFont(gui.font);
            child.m_fontSize = gui.fontSize;
            child.m_style = gui.m_style;
            child.m_text = gui.m_text;
            child.m_toolTips = gui.m_toolTips;
            gui.dispose();
            child.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, child));
        }
		
		/**
		 * 获取root显示对象
		 */
        public function get rootWnd():DeltaXWindow{
            return (GUIManager.CUR_ROOT_WND);
        }
		
		/**
		 * 获取父对象
		 */
        public function get parent():DeltaXWindow{
            return (this.m_parent);
        }
		
		/**
		 * 设置父对象
		 */
        public function set parent(value:DeltaXWindow):void{
            if (this.m_parent){
                this.m_parent.removeChild(this);
            };
            if (value){
                this.m_parent = value;
                this.m_parent.addChild(this);
            };
        }
        public function get childTopMost():DeltaXWindow{
            return (this.m_childTopMost);
        }
        public function get childBottomMost():DeltaXWindow{
            return (this.m_childBottomMost);
        }
        public function get brotherAbove():DeltaXWindow{
            return (this.m_brotherAbove);
        }
        public function get brotherBelow():DeltaXWindow{
            return (this.m_brotherBelow);
        }
        public function get visibleChildTopMost():DeltaXWindow{
            return (this.m_visibleChildTopMost);
        }
        public function get visibleChildBottomMost():DeltaXWindow{
            return (this.m_visibleChildBottomMost);
        }
        public function get visibleBrotherAbove():DeltaXWindow{
            return (this.m_visibleBrotherAbove);
        }
        public function get visibleBrotherBelow():DeltaXWindow{
            return (this.m_visibleBrotherBelow);
        }
        public function setClipMasked(value:Boolean):void{
            if (value){
                this.m_style = (this.m_style | WindowStyle.CLIP_BY_PARENT);
            } else {
                this.m_style = (this.m_style & ~(WindowStyle.CLIP_BY_PARENT));
            };
            this.invalidate();
        }
        public function isClipMasked():Boolean{
            return (!(((this.m_style & WindowStyle.CLIP_BY_PARENT) == 0)));
        }
        public function get xBorder():int{
            return (this.m_properties.xBorder);
        }
        public function get yBorder():int{
            return (this.m_properties.yBorder);
        }
        public function get lockFlag():uint{
            return (this.m_properties.lockFlag);
        }
        public function set lockFlag(value:uint):void{
            this.prepareChangeProperties();
            this.m_properties.lockFlag = value;
        }
        public function get x():int{
            return ((this.parent) ? (this.globalX - this.parent.globalX) : 0);
        }
        public function set x(value:int):void{
            this.setLocation(value, this.y);
        }
        public function get y():int{
            return ((this.parent) ? (this.globalY - this.parent.globalY) : 0);
        }
        public function set y(value:int):void{
            this.setLocation(this.x, value);
        }
		
		/**
		 * 设置xy
		 * @param	valueX		x坐标
		 * @param	valueY		y坐标
		 */
        public function setLocation(valueX:int, valueY:int):void{
            if (this.parent){
                this.setGlobal((this.parent.globalX + valueX), (this.parent.globalY + valueY));
            } else {
                this.setGlobal(valueX, valueY);
            };
        }
		
		/**
		 * 获取全局x坐标
		 */
        public function get globalX():int{
            return (this.m_bounds.x);
        }
		
		/**
		 * 设置全局x坐标
		 */
        public function set globalX(value:int):void{
            this.setGlobal(value, this.globalY);
        }
		
		/**
		 * @get
		 * 获取全局y坐标
		 */
        public function get globalY():int{
            return (this.m_bounds.y);
        }
		
		/**
		 * @set
		 * 设置全局y坐标
		 */
        public function set globalY(value:int):void{
            this.setGlobal(this.globalX, value);
        }
		
		/**
		 * 偏移
		 * @param	valueX		x
		 * @param	valueY		y
		 */
        private function addPosition(valueX:int, valueY:int):void{
            this.m_bounds.offset(valueX, valueY);
            var gui:DeltaXWindow = this.m_childTopMost;
            while (gui) {
				gui.addPosition(valueX, valueY);
				gui = gui.m_brotherBelow;
            };
        }
		
		/**
		 * 设置全局坐标
		 * @param	valueX		x
		 * @param	valueY		y
		 */
        public function setGlobal(valueX:int, valueY:int):void{
            var p:Point;
            if (((!((this.m_bounds.x == valueX))) || (!((this.m_bounds.y == valueY))))){
                p = new Point(this.x, this.y);
                this.addPosition((valueX - this.m_bounds.x), (valueY - this.m_bounds.y));
                this.dispatchEvent(new DXWndEvent(DXWndEvent.MOVED, p));
                if (this.mouseEnabled){
                    this.m_guiManager.invalidWndPositionMap();
                };
            };
        }
		
		/**
		 * @set
		 * 设置宽
		 */
        public function set width(value:int):void{
            this.setSize(value, this.height);
        }
		/**
		 * @set
		 * 设置高
		 */
        public function set height(value:int):void{
            this.setSize(this.width, value);
        }
        public function get width():int{
            return (this.m_bounds.width);
        }
        public function get height():int{
            return (this.m_bounds.height);
        }
		
		/**
		 *	x,y,宽,高渲染改变
		 * @param	offsetX			x偏移
		 * @param	offsetY			y偏移
		 * @param	scaleWidth		拉伸宽
		 * @param	scaleHeight		拉伸高
		 * @param	isDispatch		是否派发事件
		 */
        private function calcResizedRect(offsetX:int, offsetY:int, scaleWidth:int, scaleHeight:int, isDispatch:Boolean):void{
            if (this.m_properties == null){
                return;
            };
            var t_x:int = (this.m_bounds.x + offsetX);
            var t_y:int = (this.m_bounds.y + offsetY);
            var t_w:int = this.m_bounds.width;
            var t_h:int = this.m_bounds.height;
            var t_flag:uint = this.m_properties.lockFlag;
            if ((t_flag & (LockFlag.RIGHT | LockFlag.LEFT)) == 0){
                t_x = (t_x + (scaleWidth / 2));
            };
            if ((t_flag & (LockFlag.TOP | LockFlag.BOTTOM)) == 0){
                t_y = (t_y + (scaleHeight / 2));
            };
            if ((t_flag & LockFlag.RIGHT)){
                t_w = (t_w + scaleWidth);
                if ((t_flag & LockFlag.LEFT) == 0){
                    t_x = (t_x + scaleWidth);
                    t_w = (t_w - scaleWidth);
                };
            };
            if ((t_flag & LockFlag.BOTTOM)){
                t_h = (t_h + scaleHeight);
                if ((t_flag & LockFlag.TOP) == 0){
                    t_y = (t_y + scaleHeight);
                    t_h = (t_h - scaleHeight);
                };
            };
            offsetX = (t_x - this.m_bounds.x);
            offsetY = (t_y - this.m_bounds.y);
            scaleWidth = (t_w - this.m_bounds.width);
            scaleHeight = (t_h - this.m_bounds.height);
            this.m_bounds.x = t_x;
            this.m_bounds.y = t_y;
            this.m_bounds.width = t_w;
            this.m_bounds.height = t_h;
            if (isDispatch){
                if (((scaleWidth) || (scaleHeight))){
                    this.dispatchEvent(new DXWndEvent(DXWndEvent.RESIZED, new Size((this.m_bounds.width - scaleWidth), (this.m_bounds.height - scaleHeight))));
                };
                if (((offsetX) || (offsetY))){
                    this.dispatchEvent(new DXWndEvent(DXWndEvent.MOVED, new Point(offsetX, offsetY)));
                };
            };
            var _local11:DeltaXWindow = this.m_childTopMost;
            while (_local11) {
                _local11.calcResizedRect(offsetX, offsetY, scaleWidth, scaleHeight, isDispatch);
                _local11 = _local11.m_brotherBelow;
            };
        }
		
		/**
		 * 设置宽高
		 * @param	valueWidth		宽
		 * @param	valueHeight		高
		 */
        public function setSize(valueWidth:int, valueHeight:int,changeChild:Boolean=true):void{
            var size:Size;
            var scaleWidth:Number;
            var scaleHeight:Number;
            var gui:DeltaXWindow;
            if (((!((valueWidth == this.width))) || (!((valueHeight == this.height))))){
				size = new Size(this.width, this.height);
				scaleWidth = (valueWidth - size.width);
				scaleHeight = (valueHeight - size.height);
                this.m_bounds.width = valueWidth;
                this.m_bounds.height = valueHeight;
				gui = this.m_childTopMost;
				if(changeChild)
				{
					while (gui) {
						gui.calcResizedRect(0, 0, scaleWidth, scaleHeight, true);
						gui = gui.m_brotherBelow;
					};
				}
				
                
                this.dispatchEvent(new DXWndEvent(DXWndEvent.RESIZED, size));
                if (((this.m_childTopMost) || (this.mouseEnabled))){
                    this.m_guiManager.invalidWndPositionMap();
                };
            };
        }
        public function getSize():Size{
            return (new Size(this.width, this.height));
        }
		
		/**
		 * 设置x,y宽,高
		 * @param	rect		x,y,宽,高
		 */
        public function set bounds(rect:Rectangle):void{
            var t_x:Number = rect.x;
            var t_y:Number = rect.y;
            var t_w:Number = rect.width;
            var t_h:Number = rect.height;
            this.setLocation(t_x, t_y);
            this.setSize(t_w, t_h);
        }
		
		/**
		 * 获取当前x,y,宽,高
		 */
        public function get bounds():Rectangle{
            return (new Rectangle(this.x, this.y, this.width, this.height));
        }
		
		/**
		 * 设置全局x,y。宽,高
		 * @param	rect		x,y,宽,高
		 */
        public function set globalBounds(rect:Rectangle):void{
			var t_x:Number = rect.x;
			var t_y:Number = rect.y;
			var t_w:Number = rect.width;
			var t_h:Number = rect.height;
            this.setGlobal(t_x, t_y);
            this.setSize(t_w, t_h);
        }
		/**
		 * 获取全局x,y。宽,高
		 */
        public function get globalBounds():Rectangle{
            return (this.m_bounds.clone());
        }
		
		/**
		 * 获取z
		 */
        public function get z():Number{
            return DEFAULT_Z;
        }
        public function get mouseOverDescDelay():uint{
            return (this.m_mouseOverDescDelay);
        }
        public function set mouseOverDescDelay(value:uint):void{
            this.m_mouseOverDescDelay = value;
        }
        public function get visible():Boolean{
            return (this.m_visible);
        }
		
		/**
		 * 设置visible
		 */
        public function set visible(value:Boolean):void{
            var gui:DeltaXWindow;
            if (this.m_visible != value){
                this.m_visible = value;
                this.setVisible(this.m_visible);
                if (((!(value)) && (this.focus))){
                    gui = this.parent;
                    while (((gui) && (!(gui.visible)))) {
                        gui = gui.parent;
                    };
                    if (gui){
                        gui.setFocus();
                    };
                };
                if ((this.style & WindowStyle.MODAL)){
                    this.m_guiManager.setModuleWnd(this, this.m_visible);
                };
                this.dispatchEvent(new DXWndEvent((value) ? DXWndEvent.SHOWN : DXWndEvent.HIDDEN));
                if (this.mouseEnabled){
                    this.m_guiManager.invalidWndPositionMap();
                };
                this._startFadeOnShown(value);
            };
        }
        private function _startFadeOnShown(value:Boolean):void{
            if (this.fadeDuration > 0){
                if (value){
                    this.alpha = 0;
                    this.destAlpha = 1;
                } else {
                    this.destAlpha = 0;
                };
            };
        }
        public function get isShowing():Boolean{
            if (this.visible){
                return (((!(this.parent)) || (this.parent.isShowing)));
            };
            return (false);
        }
        protected function onWndShown(value:Boolean):void{
        }
		
		/**
		 * 本地坐标转全局坐标
		 * @param	value	本地坐标
		 * @return	全局坐标
		 */
        public function localToGlobal(value:Point):Point{
            return (new Point((value.x + this.globalX), (value.y + this.globalY)));
        }
		
		/**
		 * 全局坐标转本地坐标
		 * @param	value	全局坐标
		 * @return	本地坐标
		 */
        public function globalToLocal(value:Point):Point{
            return (new Point((value.x - this.globalX), (value.y - this.globalY)));
        }
		
		/**
		 * 隐藏\显示切换
		 */
        public function toggle():void{
            if (this.visible){
                this.hide();
            } else {
                this.show();
            };
        }
		
		/**
		 * 隐藏
		 */
        public function hide():void{
            this.visible = false;
        }
		/**
		 * 显示
		 */
        public function show():void{
            this.visible = true;
        }
		
		/**
		 * 组件名字
		 */
        public function get name():String{
            return (this.m_name);
        }
        public function set name(value:String):void{
            this.m_name = value;
        }
		
		/**
		 * 设置label文本
		 */
        public function setText(value:String):void{
            var str:String;
            if (this.m_text != value){
				str = this.m_text;
                this.m_text = value;
                this.dispatchEvent(new DXWndEvent(DXWndEvent.TITLE_CHANGED, str));
            };
        }
        public function getText():String{
            return (this.m_text);
        }
        public function getUserObject():Object{
            return (this.m_userObject);
        }
        public function setUserObject(value:Object):void{
            this.m_userObject = value;
        }
		
		/**
		 * 设置文本颜色
		 * @param	index	哪种状态的索引.CommonWndSubCtrlType
		 * @param	color	颜色
		 */
        public function setTextForegroundColor(index:uint, color:uint):void{
            var info:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, index);
            if (info){
                this.prepareChangeProperties();
				info = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, index);
				info.fontColor = color;
            };
        }
		
		/**
		 * 设置文本边框颜色
		 * @param	index	哪种状态的索引.CommonWndSubCtrlType
		 * @param	color	颜色
		 */
        public function setTextForegroundEdgeColor(index:uint, color:uint):void{
            var info:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, index);
            if (info){
                this.prepareChangeProperties();
				info = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, index);
				info.fontEdgeColor = color;
            };
        }
		
		/**
		 * 设置背景贴图与颜色
		 * @param	index	哪种状态的索引.CommonWndSubCtrlType
		 * @param	color	颜色
		 */
        public function setBackgroundColor(index:uint, color:uint):void{
            var i:uint;
            var info:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, index);
            if (info){
                this.prepareChangeProperties();
                info = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, index);
                i = 0;
                while (i < info.imageList.imageCount) {
                    info.imageList.getImage(i).color = color;
                    i++;
                };
            };
        }
		
		/**
		 * 更新透明度
		 * @param	value	当前帧与上一帧的间隔时间（毫秒）
		 */
        private function updateAlpha(value:int):void{
            var gui:DeltaXWindow;
            if (((value) && ((Math.abs((this.m_alpha - this.m_destAlpha)) > 0.001)))){
                this.m_alpha = (this.m_alpha + (this.m_fadeSpeed * value));
                if ((((((this.m_fadeSpeed >= 0)) && ((this.m_alpha >= this.m_destAlpha)))) || ((((this.m_fadeSpeed < 0)) && ((this.m_alpha <= this.m_destAlpha)))))){
                    this.m_alpha = this.m_destAlpha;
                    if (((!(this.m_visible)) && ((this.m_fadeSpeed < 0)))){
                        this._decParentFadingChildCount();
                    };
                    this.m_fadeSpeed = 0;
                };
                gui = this.m_childBottomMost;
                while (gui) {
                    gui.alpha = this.m_alpha;
                    gui = gui.m_brotherAbove;
                };
            };
        }
        public function get fadingChildCount():int{
            return (this.m_fadingChildCount);
        }
        private function _incParentFadingChildCount():void{
            if (this.m_parent){
                this.m_parent.m_fadingChildCount++;
            };
        }
        private function _decParentFadingChildCount():void{
            if (this.m_parent){
                this.m_parent.m_fadingChildCount--;
            };
        }
        public function get fading():Boolean{
            return (!((this.m_alpha == this.m_destAlpha)));
        }
		
		/**
		 * 设置透明度
		 * @param	value	透明度
		 */
        public function set alpha(value:Number):void{
            this.m_destAlpha = (this.m_alpha = value);
            var gui:DeltaXWindow = this.m_childBottomMost;
            while (gui) {
                gui.alpha = this.alpha;
                gui = gui.m_brotherAbove;
            };
        }
        public function get alpha():Number{
            return (this.m_alpha);
        }
		
		/**
		 * 透明度渐变到value
		 * @param	value	透明度
		 */
        public function set destAlpha(value:Number):void{
            this.m_destAlpha = value;
            var t_change:Boolean = ((!(this.m_visible)) && ((this.m_fadeSpeed < 0)));
            this.calcFadeSpeed();
            if (t_change != ((!(this.m_visible)) && ((this.m_fadeSpeed < 0)))){
                this._incParentFadingChildCount();
            };
        }
        public function set fadeDuration(value:Number):void{
            this.m_fadeDuration = value;
        }
        public function get fadeDuration():Number{
            return (this.m_fadeDuration);
        }
        private function calcFadeSpeed():void{
            if (((!((this.m_destAlpha == this.m_alpha))) && ((this.m_fadeDuration > 0)))){
                this.m_fadeSpeed = ((this.m_destAlpha - this.m_alpha) / this.m_fadeDuration);
            } else {
                this.m_fadeSpeed = 0;
            };
        }
		
			
		/**
		 * 貌似没用 
		 * @return
		 */		
        public function get dragEnable():Boolean{
            return (this.m_dragEnable);
        }
		/**
		 * 貌似没用
		 * @param value
		 */		
        public function set dragEnable(value:Boolean):void{
            this.m_dragEnable = value;
        }
		
		
		
		/**
		 * 字体
		 * @param	value	字体
		 */
        public function set font(value:String):void{
            if (this.m_font){
                this.m_font.release();
            };
            this.m_font = DeltaXFontRenderer.Instance.createFont(value);
        }
        public function get font():String{
            return ((this.m_font) ? this.m_font.name : "");
        }
		
		/**
		 * 字体大小
		 * @param	value	字体大小
		 */
        public function set fontSize(value:uint):void{
            this.m_fontSize = value;
        }
        public function get fontSize():uint{
            return (this.m_fontSize);
        }
		
		/**
		 * tips文本
		 * @param	value	tips文本
		 */
        public function setToolTipText(value:String):void{
            if (this.m_toolTips != value){
                this.m_toolTips = value;
                if (this.m_guiManager.curTooltipWnd == this){
                    this.m_guiManager.showToolTips();
                };
            };
        }
        public function setTooltipShowDelay(value:uint=0):void{
        }
		
		/**
		 * 拖动的时候判断能否移动 
		 * @param value
		 * @return 
		 * 
		 */		
        public function onWndPreMoved(value:Point):Boolean{
            return (true);
        }
		
        public function startDrag():void{
            this.m_guiManager.cursorAttachWnd = this;
        }
        public function stopDrag():void{
            this.m_guiManager.cursorAttachWnd = null;
        }
		
		/**
		 * 获取拖动对象<br>
		 * this.m_guiManager.cursorPos位置下面，排除当前window的第一个window
		 */
        public function getDropTarget():DeltaXWindow{
            if (this.m_guiManager.cursorAttachWnd != this){
                return (null);
            };
            var guiArr:Array = this.m_guiManager.getWindowUnderPoint(this.m_guiManager.cursorPos);
            var index:int = guiArr.indexOf(this);
            if (index >= 0){
				guiArr.splice(index, 1);
            };
            return guiArr[0];
        }
		
		/**
		 * 设置组件各种属性数据
		 * @param	title			标题文本
		 * @param	imgList			部件列表，贴图数据
		 * @param	style			style
		 * @param	parentValue		父容器
		 * @param	fontName		字体
		 * @param	fontSize		字体大小
		 * @param	groupID			groupId
		 */
        public function createFromDispItemInfo(title:String, 
											   imgList:Vector.<ComponentDisplayItem>, 
											   style:uint, 
											   parentValue:DeltaXWindow,
											   fontName:String="", 
											   fontSize:uint=12, 
											   groupID:int=-1):Boolean{
            if (this.m_properties){
                this.m_properties.release();
            };
            if (this.m_font){
                this.m_font.release();
            };
            this.m_properties = new WindowCreateParam();
            var i:uint;
            while (i < imgList.length) {
                this.m_properties.setSubCtrlInfo((CommonWndSubCtrlType.BACKGROUND + i), imgList[i]);
                i++;
            };
            var _local9:ComponentDisplayItem = this.m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            this.m_properties.className = WindowClassManager.getComponentClassName(this);
            this.m_properties.title = (this.m_text = title);
            this.m_properties.style = (this.m_style = (style | WindowStyle.REQUIRE_CHILD_NOTIFY));
            this.m_properties.x = _local9.rect.x;
            this.m_properties.y = _local9.rect.y;
            this.m_properties.width = _local9.rect.width;
            this.m_properties.height = _local9.rect.height;
            this.m_properties.xBorder = 0;
            this.m_properties.yBorder = 0;
            this.m_properties.groupID = groupID;
            this.m_properties.fontName = fontName;
            this.m_properties.fontSize = fontSize;
            this.m_properties.textHorzDistance = 0;
            this.m_properties.textVertDistance = 0;
            this.m_properties.tooltip = "";
            this.m_properties.userClassName = "";
            this.m_properties.userInfo = "";
            this.m_properties.fadeDuration = 0;
            this.m_bounds = _local9.rect.clone();
            this.m_font = DeltaXFontRenderer.Instance.createFont(this.m_properties.fontName);
            this.m_fontSize = this.m_properties.fontSize;
            if (this != this.m_guiManager.rootWnd){
				parentValue = (parentValue) ? parentValue : this.m_guiManager.rootWnd;
				parentValue.addChild(this);
            };
            this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
            return (true);
        }
		
		/**
		 * 创建DeltaXWindow,设置基础属性
		 * @param	title			标题文本
		 * @param	style			style
		 * @param	x				x
		 * @param	y				y
		 * @param	width			宽
		 * @param	height			高
		 * @param	parentwindow	父容器
		 * @param	fontName		字体
		 * @param	fontSize		字体大小
		 * @param	groupID			groupID
		 * @param	valueObj		没用到
		 * @param	valueU			没用到
		 * @param	valueV			没用到
		 * @param	enableColor		enable样式颜色
		 * @param	disableColor	disable样式颜色
		 * @param	lockFlag		lockFlag
		 * @return
		 */
        public function create(title:String, 
							   style:uint, 
							   x:int, 
							   y:int,
							   width:int, 
							   height:int, 
							   parentwindow:DeltaXWindow,
							   fontName:String="", 
							   fontSize:uint=12,
							   groupID:int=-1, 
							   valueObj:Object=null, 
							   valueU:uint=0,
							   valueV:uint=1, 
							   enableColor:uint=0xff000000,
							   disableColor:uint=0xff000000, 
							   lockFlag:uint=0):Boolean{
            if (this.m_properties){
                this.m_properties.release();
            };
            if (this.m_font){
                this.m_font.release();
            };
            this.m_properties = new WindowCreateParam();
            this.m_properties.className = WindowClassManager.getComponentClassName(this);
            this.m_properties.title = (this.m_text = title);
            this.m_properties.style = (this.m_style = (style | WindowStyle.REQUIRE_CHILD_NOTIFY));
            this.m_properties.x = x;
            this.m_properties.y = y;
            this.m_properties.width = width;
            this.m_properties.height = height;
            this.m_properties.xBorder = 0;
            this.m_properties.yBorder = 0;
            this.m_properties.groupID = groupID;
            this.m_properties.fontName = fontName;
            this.m_properties.fontSize = fontSize;
            this.m_properties.textHorzDistance = 0;
            this.m_properties.textVertDistance = 0;
            this.m_properties.tooltip = "";
            this.m_properties.userClassName = "";
            this.m_properties.userInfo = "";
            this.m_properties.fadeDuration = 0;
            this.m_properties.lockFlag = lockFlag;
			
            this.m_properties.makeDefaultSubCtrlInfos(CommonWndSubCtrlType);
            var _local17:ComponentDisplayItem = this.m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var _local18:ComponentDisplayStateInfo = _local17.displayStateInfos[SubCtrlStateType.ENABLE];
			_local18.imageList.addImage(0, null, new Rectangle(), new Rectangle(0, 0, width, height), enableColor,LockFlag.ALL);
            var _local19:ComponentDisplayStateInfo = _local17.displayStateInfos[SubCtrlStateType.DISABLE];
            _local19.imageList.addImage(0, null, new Rectangle(), new Rectangle(0, 0, width, height), disableColor,LockFlag.ALL);
			
            this.m_bounds.x = x;
            this.m_bounds.y = y;
            this.m_bounds.width = width;
            this.m_bounds.height = height;
            this.m_font = DeltaXFontRenderer.Instance.createFont(this.m_properties.fontName);
            this.m_fontSize = this.m_properties.fontSize;
            if (this != this.m_guiManager.rootWnd){
				parentwindow = (parentwindow) ? parentwindow : this.m_guiManager.rootWnd;
				parentwindow.addChild(this);
            };
            this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
            return (true);
        }
		
		/**
		 * 加载显示ui布局配置文件
		 * @param	resURL			组件二进制url
		 * @param	parentwindow	父容器
		 * @param	loadedHandler	加载完成回调
		 * @return
		 */
        public function createFromRes(resURL:String, parentwindow:DeltaXWindow=null, loadedHandler:Function=null):Boolean{
            if (!resURL){
                return (false);
            };
            this.m_onLoadedHandler = loadedHandler;
            this.m_designatedParent = (parentwindow) ? parentwindow : this.m_guiManager.rootWnd;
            this.m_designatedParent.dispatchEvent(new DXWndEvent(DXWndEvent.PRE_CREATED, this));
            var res:IResource = ResourceManager.instance.getResource((Enviroment.ResourceRootPath + resURL), ResourceType.GUI, this.onResRetrieved);
            return (res && res.loaded);
        }
		
		/**
		 * 根据参数对象 设置ui组件各种属性
		 * @param	windowParam		参数对象
		 * @param	parentWindow	组件
		 * @return
		 */
		public function createFromWindowParam(windowParam:WindowCreateParam,parentWindow:DeltaXWindow = null):Boolean{
			if (this.m_properties){
				this.m_properties.release();
			};
			if (this.m_font){
				this.m_font.release();
			};
			this.m_properties = windowParam;
			this.m_bounds.x = this.m_properties.x;
			this.m_bounds.y = this.m_properties.y;
			this.m_bounds.width = this.m_properties.width;
			this.m_bounds.height = this.m_properties.height;
			if (this != this.m_guiManager.rootWnd){
				parentWindow = (parentWindow) ? parentWindow : this.m_guiManager.rootWnd;
				parentWindow.initComponentFromRes(windowParam, this);
			};
			this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
			return (true);
		}
		
		/**
		 * ui资源加载完成
		 * @param	resource		资源
		 * @param	value	
		 * @return
		 */
		protected function onResRetrieved(resource:IResource, value:Boolean):void{
			var _local3:WindowResource;
			var _local4:WindowCreateParam;
			var _local5:Class;
			var _local6:DeltaXWindow;
			if (((value) && (this.m_designatedParent))){
				if (this.m_properties){
					this.m_properties.release();
				};
				if (this.m_font){
				};
				this.m_font.release();
				if (((this.m_parent) && (!((this.m_parent == this.m_designatedParent))))){
					this.m_designatedParent = this.m_parent;
				};
				_local3 = (resource as WindowResource);
				this.m_designatedParent.initComponentFromRes(_local3.createParam, this);
				this.m_designatedParent = null;
				if (_local3.childCreateParams){
					for each (_local4 in _local3.childCreateParams) {
						_local5 = WindowClassManager.getComponentClassByName(_local4.className);
						_local6 = new _local5();
						this.initComponentFromRes(_local4, _local6);
						_local6.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, _local6));
					};
				};
				this.m_created = true;
				this.dispatchEvent(new DXWndEvent(DXWndEvent.CREATED, this));
				if (this.m_onLoadedHandler != null){
					this.m_onLoadedHandler(this);
				};
			} else {
				this.m_created = false;
				this.m_designatedParent = null;
			};
		}
		
		/**
		 * 根据参数设置ui组件各种属性
		 * @param	value		参数对象
		 * @param	gui			组件	
		 * @return
		 */
        public function initComponentFromRes(value:WindowCreateParam, gui:DeltaXWindow):void{
            var i:uint;
            if (value.soundFxs){
                i = 0;
                while (i < value.soundFxs.length) {
                    if (!value.soundFxs[i]){
                    } else {
                        if (i == WndSoundFxType.CLICK){
                            gui.addEventListener(DXWndMouseEvent.MOUSE_DOWN, onComponentSoundEvent);
                        } else {
                            if (i == WndSoundFxType.CLOSE){
                                gui.addEventListener(DXWndEvent.HIDDEN, onComponentSoundEvent);
                            } else {
                                gui.addEventListener(DXWndEvent.SHOWN, onComponentSoundEvent);
                            };
                        };
                    };
                    i++;
                };
            };
            if (gui.m_properties){
                gui.m_properties.release();
            };
            value.reference();
            if (gui.m_font){
                gui.m_font.release();
            };
            gui.m_properties = value;
            gui.m_name = value.id;
            gui.m_font = DeltaXFontRenderer.Instance.createFont(value.fontName);
            gui.m_fontSize = value.fontSize;
            gui.m_text = value.title;
            gui.m_style = (value.style | WindowStyle.REQUIRE_CHILD_NOTIFY);
            if (!gui.m_toolTips){
                gui.m_toolTips = value.tooltip;
            };
            gui.m_fadeDuration = value.fadeDuration;
            gui.addPosition((value.x - gui.x), (value.y - gui.y));
            gui.m_bounds.width = value.width;
            gui.m_bounds.height = value.height;
            if (gui.m_parent != this){
                this.addChild(gui);
            };
            if (((this.m_properties) && (((!((this.m_properties.width == this.width))) || (!((this.m_properties.height == this.height))))))){
				gui.calcResizedRect(0, 0, (this.width - this.m_properties.width), (this.height - this.m_properties.height), false);
            };
        }
		
		/**
		 * 子显示对象添加事件侦听
		 * @param	guiName		组件名
		 * @param	eventType	事件类型
		 * @param	callback	回调函数
		 */
        protected function fastAddEventListenerForChild(guiName:String, eventType:String, callback:Function):void{
            var gui:DeltaXWindow = (this.getChildByName(guiName) as DeltaXWindow);
            if (gui){
				gui.addEventListener(eventType, callback);
            };
        }
		
		/**
		 * 子显示对象添加DXWndEvent.ACTION事件侦听
		 * @param	guiName		组件名
		 * @param	callback	回调函数
		 * @return	子显示对象
		 */
        protected function fastAddActionListenerForChild(guiName:String, callback:Function):DeltaXWindow{
            var gui:DeltaXWindow = (this.getChildByName(guiName) as DeltaXWindow);
            if (gui){
				gui.addActionListener(callback);
            };
            return (gui);
        }
		
		/**
		 * 添加DXWndEvent.ACTION事件侦听
		 * @param	callback	回调函数
		 */
        public function addActionListener(callback:Function):void{
            this.addEventListener(DXWndEvent.ACTION, callback);
        }
		
		/**
		 * 移除DXWndEvent.ACTION事件侦听
		 * @param	callback	回调函数
		 */
        public function removeActionListener(callback:Function):void{
            this.removeEventListener(DXWndEvent.ACTION, callback);
        }
		
		/**
		 * 添加DXWndEvent.STATE_CHANGED事件侦听
		 * @param	callback	回调函数
		 */
        public function addStateListener(callback:Function):void{
            this.addEventListener(DXWndEvent.STATE_CHANGED, callback);
        }
		
		/**
		 * 移除DXWndEvent.STATE_CHANGED事件侦听
		 * @param	callback	回调函数
		 */
        public function removeStateListener(callback:Function):void{
            this.removeEventListener(DXWndEvent.STATE_CHANGED, callback);
        }
        protected function onWndCreated():void{
        }
        protected function _onWndCreatedInternal():void{
            if (((this.m_visible) && ((this.fadeDuration > 0)))){
                this._startFadeOnShown(true);
            };
        }
        protected function onAddToParent(_arg1:DeltaXWindow):void{
        }
        protected function onRemoveFromParent(_arg1:DeltaXWindow):void{
        }
        protected function onMove(_arg1:Point):void{
        }
        protected function onResize(_arg1:Size):void{
        }
        protected function onTextureChanged(_arg1:String):void{
        }
        protected function onStateChanged(_arg1:Object):void{
        }
        protected function onAccelKey(_arg1:Object):Boolean{
            return (true);
        }
        protected function onMouseEnter(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseLeave(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseDbClick(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseContinousDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseUp(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseMiddleDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseMiddleUp(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseRightDown(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseRightUp(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseMove(_arg1:Point, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onMouseWheel(_arg1:Point, _arg2:Number, _arg3:Boolean, _arg4:Boolean, _arg5:Boolean):void{
        }
        protected function onDrag(_arg1:Point):void{
        }
        protected function onDragStart(_arg1:Point):void{
        }
        protected function onDragEnd(_arg1:Point):void{
        }
        protected function onKeyDown(_arg1:uint, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onKeyUp(_arg1:uint, _arg2:Boolean, _arg3:Boolean, _arg4:Boolean):void{
        }
        protected function onText(_arg1:String):void{
        }
        protected function onActive(_arg1:Boolean):void{
        }
        protected function onFocus(_arg1:Boolean):void{
        }
        public function invalidate():void{
            this.m_invalidate = true;
        }
        public function validate():void{
        }
        public function prepareChangeProperties():void{
            if (((this.m_properties) && ((this.m_properties.refCount > 1)))){
                this.m_properties = new WindowCreateParam(this.m_properties);
            };
        }
        public function get creatingFromRes():Boolean{
            return (!((this.m_designatedParent == null)));
        }
        public function get resLoaded():Boolean{
            return (this.m_created);
        }
        public function get properties():WindowCreateParam{
            return (this.m_properties);
        }
        public function get tabIndex():int{
            return (this.m_tabIndex);
        }
        public function set tabIndex(_arg1:int):void{
            this.m_tabIndex = _arg1;
        }
        public function get tabEnable():Boolean{
            return (this.m_tabEnable);
        }
        public function set tabEnable(_arg1:Boolean):void{
            this.m_tabEnable = _arg1;
        }
        public function get style():uint{
            return (this.m_style);
        }
        public function set style(value:uint):void{
            if (((!(this.inUITree)) || ((this.m_style == value)))){
                return;
            };
            var t_style:uint = this.m_style;
            this.m_style = value;
            if ((((t_style & WindowStyle.MODAL)) && (((value & WindowStyle.MODAL) == 0)))){
                this.m_guiManager.setModuleWnd(this, false);
            } else {
                if ((((((value & WindowStyle.MODAL)) && (((t_style & WindowStyle.MODAL) == 0)))) && (this.visible))){
                    this.m_guiManager.setModuleWnd(this, true);
                };
            };
            if ((value & WindowStyle.TOP_MOST) != (t_style & WindowStyle.TOP_MOST)){
                if ((value & WindowStyle.TOP_MOST)){
                    this.parent.addChild(this, (this.active) ? this.parent.childTopMost : null);
                } else {
                    if ((this.brotherBelow.style & WindowStyle.TOP_MOST)){
                        this.parent.addChild(this, (this.active) ? this.parent.brotherBelow : null);
                    } else {
                        if (!this.active){
                            this.parent.addChild(this);
                        };
                    };
                };
            };
        }
		/**
		 * 文本文字的水平间隔
		 */	
        public function get textHorzDistance():uint{
            return (this.m_properties.textHorzDistance);
        }
		/**
		 * 文本文字的垂直间隔 
		 */		
        public function get textVertDistance():uint{
            return (this.m_properties.textVertDistance);
        }
        public function get mouseX():Number{
            return (this.m_guiManager.xCursor);
        }
        public function get mouseY():Number{
            return (this.m_guiManager.yCursor);
        }
        public function get focusWnd():DeltaXWindow{
            return (m_focusWnd);
        }
        public function get focus():Boolean{
            return ((m_focusWnd == this));
        }
        public function get active():Boolean{
            var _local1:DeltaXWindow = m_focusWnd;
            while (_local1) {
                if (_local1 == this){
                    return (true);
                };
                _local1 = _local1.parent;
            };
            return (false);
        }
        public function get inUITree():Boolean{
            return this.parent != null || GUIManager.CUR_ROOT_WND == this;
        }
		
		/**
		 * @get
		 * 鼠标是否按下
		 */
        public function get isHeld():Boolean{
            return ((this.m_guiManager.holdWnd == this));
        }
		
		/**
		 * @get
		 * 鼠标按下的坐标
		 */
        public function get holdPos():Point{
            return ((this.isHeld) ? this.m_guiManager.holdPos : null);
        }
        public function set holdPos(_arg1:Point):void{
            if (this.isHeld){
                this.m_guiManager.holdPos = _arg1;
            };
        }
        public function get tooltipsText():String{
            return (this.m_toolTips);
        }
        public function get tooltipsWnd():DeltaXWindow{
            return (this.m_guiManager.commonTooltipsWnd);
        }
        public function getTopChild(value:Class, callback:Function=null):DeltaXWindow{
            var gui:DeltaXWindow;
            var childTop:DeltaXWindow = this.childTopMost;
            while (childTop) {
				gui = childTop.getTopChild(value, callback);
                if (gui){
                    return (gui);
                };
				childTop = childTop.brotherBelow;
            };
            if (callback != null){
                if (callback(value, this)){
                    return (this);
                };
            } else {
                if ((this is value)){
                    return (this);
                };
            };
            return (null);
        }
		
		/**
		 * 获取当前在最顶层父容器里面，是第几层
		 */
        public function depthInUITree():uint{
            var i:uint;
            var t_parent:DeltaXWindow = this.parent;
            while (t_parent) {
				t_parent = t_parent.parent;
                i++;
            };
            return i;
        }
		
		/**
		 * 设置焦点
		 */
        public function setFocus():void{
            if (!this.inUITree){
                return;
            };
            if (m_focusWnd == this){
                return;
            };
            this.m_guiManager.invalidWndPositionMap();
            var gui:DeltaXWindow = this;
            var t_parent:DeltaXWindow = this.parent;
            var index:uint = m_focusWnd.depthInUITree();
            var i:uint;
            while (t_parent) {
				/*
                if (((gui.m_brotherAbove) && (((!(((gui.style & WindowStyle.TOP_MOST) == 0))) || (((gui.m_brotherAbove.style & WindowStyle.TOP_MOST) == 0)))))){
                    t_parent.addChild(gui, t_parent.childTopMost);
                };*/
				if ((gui.style  & WindowStyle.FOCUS_TOP) != 0) {
					t_parent.addChild(gui);
				}
                gui = t_parent;
                t_parent = gui.parent;
                i++;
            };
            var t_focusGui:DeltaXWindow = m_focusWnd;
            var t_oldActivate:DeltaXWindow = this;
            while (index > i) {
                t_focusGui = t_focusGui.parent;
                index--;
            };
            while (index < i) {
                t_oldActivate = t_oldActivate.parent;
                i--;
            };
            while (t_focusGui != t_oldActivate) {
                t_oldActivate = t_oldActivate.parent;
                t_focusGui = t_focusGui.parent;
            };
            var t_focusWnd:DeltaXWindow = m_focusWnd;
            m_focusWnd = this;
            t_focusWnd.dispatchEvent(new DXWndEvent(DXWndEvent.FOCUS, false));
            var t_deactivate:DeltaXWindow = t_focusWnd;
            while (t_deactivate != t_focusGui) {
                t_deactivate.dispatchEvent(new DXWndEvent(DXWndEvent.ACTIVE, false));
                t_deactivate = t_deactivate.parent;
            };
            var t_activate:DeltaXWindow = this;
            while (t_activate != t_oldActivate) {
                t_activate.dispatchEvent(new DXWndEvent(DXWndEvent.ACTIVE, true));
                t_activate = t_activate.parent;
            };
            m_focusWnd.dispatchEvent(new DXWndEvent(DXWndEvent.FOCUS, true));
        }
		
		/**
		 * 判断坐标是否在当前渲染区域,类似碰撞检测
		 * @param	valueX				貌似是全局坐标
		 * @param	valueY				貌似是全局坐标
		 * 
		 * ----------------------------------------
		 * @param	checkMouseEnabaled	新加参数，是否判断鼠标enabled。<br>
		 * (默认true：只有样式MSG_TRANSPARENT木有设置时候才纳入检测，否则直接返回false。false：忽略MSG_TRANSPARENT的设置，继续检测)<br>
		 * 目的：编辑器需要通过点获取所有点下面的组件，如果有的组件设置了MSG_TRANSPARENT样式，则选不了组件。<br>
		 * 参数先不加，还需要在GUIManager里面buildWndPositionMap里修改。里面默认mouseEnabled与enable为true才加入。
		 * 修改影响教大，暂不修改
		 * @modify Exin 2015.03.13
		 * ----------------------------------------
		 */
        public function isInWndArea(valueX:int, valueY:int):Boolean{
            var t_x:int;
            var t_y:int;
            var info:ComponentDisplayStateInfo;
            var i:uint;
            var imgInfo:DisplayImageInfo;
            if (!this.inUITree){
                return (false);
            };
            var t_style:uint = this.style;
            if ((t_style & WindowStyle.CLIP_BY_PARENT)){
                if (((this.parent) && (!(this.parent.isInWndArea(valueX, valueY))))){
                    return (false);
                };
            };
            if ((WindowStyle.MSG_TRANSPARENT & t_style) == 0){
                t_x = (valueX - this.globalX);
                t_y = (valueY - this.globalY);
                if ((WindowStyle.USER_CLIP_RECT & t_style)){
                    info = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.HITTEST_AREA);
                    i = 0;
                    while (i < info.imageList.imageCount) {
                        imgInfo = info.imageList.getImage(i);
                        if ((((imgInfo.color == AreaHitTestColor.MASKCOLOR_AREA)) && (imgInfo.wndRect.contains(t_x, t_y)))){
                            return (true);
                        };
                        i++;
                    };
                } else 
				{
					if((WindowStyle.MOUSE_CHECK_ON_PIXEL & t_style)==0)//加入像素检测  by lrw
					{
						if ((((((((t_x >= 0)) && ((t_y >= 0)))) && ((t_x < this.width)))) && ((t_y < this.height))))
						{
							return (true);
						};
					}else
					{
						if(t_x>=0 && t_y>=0)
						{
							return pixelCheck(t_x,t_y);
						}
					}
                };
            };
            return (false);
        }
		
		public function pixelCheck(px:int,py:int):Boolean
		{
			if(!properties.pixelArea || properties.pixelArea.length==0)
			{
				return false;
			}
			//
			var pos:uint = py*this.width+px;
//			trace("===================pos",pos,properties.pixelArea.length,py,px);
			if(pos>=properties.pixelArea.length)
			{
				return false;
			}
			properties.pixelArea.position = pos;
			var record:uint = properties.pixelArea.readUnsignedByte();
			if(record>0)
			{
//				trace("=========================true");
				return true;
			}
			return false;
		}
		
		/**
		 * 判断坐标是否在当前渲染区域.全局坐标
		 * @param	valueX		貌似是全局坐标
		 * @param	valueY		貌似是全局坐标
		 */
        public function isInTitleArea(valueX:int, valueY:int):Boolean{
            var t_x:int;
            var t_y:int;
            var stateInfo:ComponentDisplayStateInfo;
            var i:uint;
            var imgInfo:DisplayImageInfo;
            if (!this.inUITree){
                return (false);
            };
            var _local3:uint = this.style;
            if ((_local3 & WindowStyle.CLIP_BY_PARENT)){
                if (((this.parent) && (!(this.parent.isInWndArea(this.x, this.y))))){
                    return (false);
                };
            };
            if ((((((((valueX < this.globalX)) || ((valueY < this.globalY)))) || ((valueX >= (this.globalX + this.width))))) || ((valueY >= (this.globalY + this.height))))){
                return (false);
            };
            if ((WindowStyle.MSG_TRANSPARENT & _local3) == 0){
                t_x = (valueX - this.globalX);
                t_y = (valueY - this.globalY);
                if ((WindowStyle.USER_CLIP_RECT & _local3)){
                    stateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.HITTEST_AREA);
                    i = 0;
                    while (i < stateInfo.imageList.imageCount) {
                        imgInfo = stateInfo.imageList.getImage(i);
                        if ((((imgInfo.color == AreaHitTestColor.MASKCOLOR_TITLE)) && (imgInfo.wndRect.contains(t_x, t_y)))){
                            return (true);
                        };
                        i++;
                    };
                };
            };
            return (true);
        }
        public function get globalClipBounds():Rectangle{
            var rect:Rectangle;
            var xborder:int = this.m_properties.xBorder;
            var yborder:int = this.m_properties.yBorder;
            if (((!(this.m_parent)) || (((this.m_style & WindowStyle.CLIP_BY_PARENT) == 0)))){
                rect = ms_clip;
                rect.left = (this.m_bounds.left + xborder);
                rect.right = (this.m_bounds.right - xborder);
                rect.top = (this.m_bounds.top + yborder);
                rect.bottom = (this.m_bounds.bottom - yborder);
            } else {
                rect = this.m_parent.globalClipBounds;
                rect.left = Math.max(rect.left, (this.m_bounds.left + xborder));
                rect.right = Math.min(rect.right, (this.m_bounds.right - xborder));
                rect.top = Math.max(rect.top, (this.m_bounds.top + yborder));
                rect.bottom = Math.min(rect.bottom, (this.m_bounds.bottom - xborder));
            };
            return rect;
        }
		
		/**
		 * 背景渲染
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        protected function renderBackground(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
			var info:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, (this.enable) ? SubCtrlStateType.ENABLE : SubCtrlStateType.DISABLE);
            this.renderImageList(context3D, info.imageList, null, -1, 1, this.m_gray);
			
        }
		
		/**
		 * 渲染位图
		 * @param	context3D		3D容器
		 * @param	imgList			位图列表
		 * @param	renderRect		矩形：渲染区域范围,类似于flash.display.DisplayObject：：scrollRect属性
		 * @param	renderIndex		渲染位图索引。-1或者大于当前位图数量。则渲染所有
		 * @param	alpha			透明度
		 * @param	gray			是否灰度,true:灰度
		 */
        public function renderImageList(context3D:Context3D, imgList:ImageList, renderRect:Rectangle=null, renderIndex:int=-1, alpha:Number=1, gray:Boolean=false):void{
            var scaleWidth:Number = (this.m_bounds.width - this.m_properties.width);
            var scaleHeight:Number = (this.m_bounds.height - this.m_properties.height);
            var t_x:Number = this.m_bounds.x;
            var t_y:Number = this.m_bounds.y;
			if(this.name == "shopBtn")
			{
				trace("S");
			}
            if (renderRect){
				imgList.drawTo(context3D, t_x, t_y, DEFAULT_Z, scaleWidth, scaleHeight, renderRect, true, renderIndex, (this.m_alpha * alpha), gray);
            } else {
                if (((!(this.m_parent)) || (((this.m_style & WindowStyle.CLIP_BY_PARENT) == 0)))){
					imgList.drawTo(context3D, t_x, t_y, DEFAULT_Z, scaleWidth, scaleHeight, this.m_bounds, false, renderIndex, (this.m_alpha * alpha), gray);
                } else {
					renderRect = this.m_parent.globalClipBounds;
					renderRect.left = Math.max(renderRect.left, this.m_bounds.left);
					renderRect.right = Math.min(renderRect.right, this.m_bounds.right);
					renderRect.top = Math.max(renderRect.top, this.m_bounds.top);
					renderRect.bottom = Math.min(renderRect.bottom, this.m_bounds.bottom);
					renderRect.left = Math.min(renderRect.left, renderRect.right);
					renderRect.top = Math.min(renderRect.top, renderRect.bottom);
					imgList.drawTo(context3D, t_x, t_y, DEFAULT_Z, scaleWidth, scaleHeight, renderRect, false, renderIndex, (this.m_alpha * alpha), gray);
                };
            };
        }
		
		/**
		 * 文本渲染
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        protected function renderText(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
            var info:ComponentDisplayStateInfo = this.m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, (this.enable) ? SubCtrlStateType.ENABLE : SubCtrlStateType.DISABLE);
            this.drawTextWithStyle(context3D, this.m_text, info.fontColor, info.fontEdgeColor);
        }
		
		/**
		 * 渲染
		 * @param	context3D		3D容器
		 * @param	valueGetTimer	当前渲染的getTimer()值
		 * @param	fpsTime			上次渲染到这次渲染的间隔时间(毫秒)
		 */
        public function render(context3D:Context3D, valueGetTimer:uint, fpsTime:int):void{
            if (!this.m_properties){
                return;
            };
            if (this.m_invalidate){
                this.m_invalidate = false;
                this.validate();
            };
            if (this.m_fadeSpeed != 0){
                this.updateAlpha(fpsTime);
            };
            if (this.alpha < 0.01){
                return;
            };
            this.renderBackground(context3D, valueGetTimer, fpsTime);
            if ((((this is DeltaXEdit)) || (this.m_text))){
                this.renderText(context3D, valueGetTimer, fpsTime);
            };
        }
		
		/**
		 * 文本渲染
		 * @param	context3D		3D容器
		 * @param	value			文本
		 * @param	fontColor		文本颜色
		 * @param	fontEdgeColor	边框颜色
		 */
        public function drawTextWithStyle(context3D:Context3D, value:String, fontColor:uint, fontEdgeColor:uint):void{
            var t_size:Size;
            if (((!(this.m_font)) || (!(value)))){
                return;
            };
            var xborder:int;
            var yborder:int;
            var t_style:uint = this.style;
            if (((((this.style & WindowStyle.FONT_SHADOW) == 0)) && ((fontEdgeColor & 0xff000000)))){
                yborder = this.m_font.getEdgeSize(this.m_fontSize);
                xborder = yborder;
            };
			//由样式判断文本对齐方式
            if ((t_style & WindowStyle.TEXT_ALIGN_STYLE_MASK)){
                t_size = this.m_font.calTextBounds(value, this.m_fontSize, 0, -1, false, this.textHorzDistance, this.textVertDistance);
                if (t_size == null){
                    return;
                };
                t_size.width = (t_size.width + (xborder * 2));
                t_size.height = (t_size.height + (yborder * 2));
                if ((t_style & WindowStyle.TEXT_HORIZON_ALIGN_CENTER)){
                    xborder = (xborder + ((this.width / 2) - (t_size.width / 2)));
                } else {
                    if ((t_style & WindowStyle.TEXT_HORIZON_ALIGN_RIGHT)){
                        xborder = (xborder + (this.width - t_size.width));
                    };
                };
                if ((t_style & WindowStyle.TEXT_VERTICAL_ALIGN_CENTER)){
                    yborder = (yborder + ((this.height / 2) - (t_size.height / 2)));
                } else {
                    if ((t_style & WindowStyle.TEXT_VERTICAL_ALIGN_BOTTOM)){
                        yborder = (yborder + (this.height - t_size.height));
                    };
                };
            };
            xborder = (xborder + this.xBorder);
            yborder = (yborder + this.yBorder);
            this.drawText(context3D, value, xborder, yborder, fontColor, fontEdgeColor, 0, -1, false, null, this.textHorzDistance, this.textVertDistance);
        }
		
		/**
		 * 文本渲染
		 * @param	context3D		3D容器
		 * @param	value			文本
		 * @param	xborder			x偏移
		 * @param	yborder			y偏移
		 * @param	fontColor		字体颜色
		 * @param	fontEdgeColor	边框颜色
		 * @param	startIndex		渲染开始索引，0从第一个字符串开始渲染
		 * @param	endIndex		渲染结束索引，-1渲染到最后一个字符串
		 * @param	multiline		表示字段是否为多行文本字段。
		 * @param	offsetRect		偏移渲染位置
		 * @param	paramA			没用到
		 * @param	paramB			没用到
		 * @param	dxfont			文本渲染器
		 * @param	fontSize		字体大小
		 * @param	shadow			貌似阴影,-1根据style判断是否有阴影。非0其他值貌似有
		 * 
		 */
        public function drawText(context3D:Context3D, 
								 value:String, 
								 xborder:Number, 
								 yborder:Number, 
								 fontColor:uint, 
								 fontEdgeColor:uint, 
								 startIndex:int, 
								 endIndex:int, 
								 multiline:Boolean, 
								 offsetRect:Rectangle, 
								 paramA:Number, 
								 paramB:Number, 
								 dxfont:DeltaXFont=null, 
								 fontSize:uint=0, 
								 shadow:int=-1):void{					
            var t_alpha2:uint;
            if (((!(this.m_font)) || (!(value)))){
                return;
            };
            var rect:Rectangle = this.globalClipBounds;
            if (offsetRect != null){
                rect.left = Math.max((offsetRect.left + this.m_bounds.x), rect.left);
                rect.right = Math.min((offsetRect.right + this.m_bounds.x), rect.right);
                rect.top = Math.max((offsetRect.top + this.m_bounds.y), rect.top);
                rect.bottom = Math.min((offsetRect.bottom + this.m_bounds.y), rect.bottom);
            };
            if ((((rect.left >= rect.right)) || ((rect.top >= rect.bottom)))){
                return;
            };
            var t_alpha:Number = this.alpha;
            if (t_alpha < 0.99){
                t_alpha2 = ((fontColor >>> 24) * this.alpha);
                fontColor = ((fontColor & 0xFFFFFF) | (t_alpha2 << 24));
                t_alpha2 = ((fontEdgeColor >>> 24) * this.alpha);
                fontEdgeColor = ((fontEdgeColor & 0xFFFFFF) | (t_alpha2 << 24));
            };
            if (dxfont == null){
                dxfont = this.m_font;
            };
            if (fontSize == 0){
                fontSize = this.m_fontSize;
            };
            if (shadow < 0){
				shadow = (this.style & WindowStyle.FONT_SHADOW);
            };
            xborder = (xborder + (this.m_bounds.x - rect.x));
            yborder = (yborder + (this.m_bounds.y - rect.y));
			dxfont.drawText(context3D, value, fontSize, fontColor, fontEdgeColor, xborder, yborder, rect, startIndex, endIndex, multiline, this.z, this.textHorzDistance, this.textVertDistance, !((shadow == 0)));
        }
        public function renderAfterChildren():void{
        }
        public function get isHover():Boolean{
            return ((this.m_guiManager.lastMouseOverWnd == this));
        }
        public function get enableMouseContinousDownEvent():Boolean{
            return (this.m_enableMouseContinousDownEvent);
        }
        public function set enableMouseContinousDownEvent(_arg1:Boolean):void{
            this.m_enableMouseContinousDownEvent = _arg1;
        }
        public function get mouseContinousDownInterval():uint{
            return (this.m_mouseContinousDownInterval);
        }
        public function set mouseContinousDownInterval(_arg1:uint):void{
            this.m_mouseContinousDownInterval = _arg1;
        }
        public function set gray(_arg1:Boolean):void{
            this.m_gray = _arg1;
        }
        public function get gray():Boolean{
            return (this.m_gray);
        }
		
		
		public function changeToCreateParam():WindowCreateParam{
			var curWindow:DeltaXWindow = this;
			var param:WindowCreateParam = new WindowCreateParam(curWindow.properties);
			param.id = curWindow.name;
			param.fontName = curWindow.font;
			param.fontSize = curWindow.fontSize;
			param.title = curWindow.getText();
			param.style = curWindow.style;
			trace("style=======================33333",param.style,param.id);
			param.tooltip = curWindow.tooltipsText;
			param.fadeDuration = curWindow.fadeDuration;
			param.x = curWindow.x;
			param.y = curWindow.y;
			param.width = curWindow.bounds.width;
			param.height = curWindow.bounds.height;
			return param;
		}
    }
}

import mx.effects.Effect;

class AttachEffectInfo {

    public var effect:Effect;
    public var endTime:uint;

    public function AttachEffectInfo(){
    }
}
