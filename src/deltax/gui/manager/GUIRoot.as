//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.manager {
    import deltax.appframe.BaseApplication;
    import deltax.common.error.*;
    import deltax.gui.component.event.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.ui.*;
	
	/**
	 * root类 
	 * @author Administrator
	 * 
	 */	
    public class GUIRoot extends Sprite implements IGUIHandler {

        private var m_textInput:TextField;
        private var m_forceFocusSelf:Boolean = true;

        public function GUIRoot(){
            this.m_textInput = new TextField();
            super();
            this.m_textInput.alpha = 0;
            this.m_textInput.type = TextFieldType.INPUT;
            this.m_textInput.doubleClickEnabled = true;
            alpha = 0;
            doubleClickEnabled = true;
        }
		
		/**
		 * 初始化 
		 * @param value	场景
		 */		
        public function init(value:Stage):void{
            value.align = StageAlign.TOP_LEFT;
            value.scaleMode = StageScaleMode.NO_SCALE;
            value.stageFocusRect = false;
           // value.addChild(this);
            value.addEventListener(Event.RESIZE, this.processEvent);
            this.m_textInput.autoSize = TextFieldAutoSize.NONE;
            this.m_textInput.width = value.stageWidth;
            this.m_textInput.height = value.stageHeight;
            value.addEventListener(TextEvent.TEXT_INPUT, this.processEvent);
            value.addEventListener(DXWndMouseEvent.DOUBLE_CLICK, this.processEvent);
            value.addEventListener(DXWndMouseEvent.MOUSE_DOWN, this.processEvent);
            value.addEventListener(DXWndMouseEvent.MOUSE_UP, this.processEvent);
            value.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_DOWN, this.processEvent);
            value.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_UP, this.processEvent);
            value.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.processEvent);
            value.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.processEvent);
            value.addEventListener(DXWndMouseEvent.MOUSE_MOVE, this.processEvent);
            value.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.processEvent);
            value.addEventListener(KeyboardEvent.KEY_DOWN, this.processEvent);
            value.addEventListener(KeyboardEvent.KEY_UP, this.processEvent);
            value.addEventListener(Event.SELECT_ALL, this.processEvent);
            value.addEventListener(Event.COPY, this.processEvent);
            value.addEventListener(Event.PASTE, this.processEvent);
            value.addEventListener(Event.CUT, this.processEvent);
            value.focus = this;
            addEventListener(FocusEvent.FOCUS_OUT, this.focusOutHandler);
            new GUIManager(this);
            //GUIManager.instance.init(value.stageWidth, value.stageHeight);
			GUIManager.instance.init(BaseApplication.instance.rootUIComponent.width,BaseApplication.instance.rootUIComponent.height);
        }
		
		/**
		 * 移除侦听.类似析构函数
		 */		
        public function deInit():void{
            stage.removeEventListener(Event.RESIZE, this.processEvent);
            stage.removeChild(this);
            stage.removeEventListener(TextEvent.TEXT_INPUT, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.DOUBLE_CLICK, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.MOUSE_DOWN, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.MOUSE_UP, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.MIDDLE_MOUSE_DOWN, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.MIDDLE_MOUSE_UP, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.MOUSE_MOVE, this.processEvent);
            stage.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.processEvent);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.processEvent);
            stage.removeEventListener(KeyboardEvent.KEY_UP, this.processEvent);
            stage.removeEventListener(Event.SELECT_ALL, this.processEvent);
            stage.removeEventListener(Event.COPY, this.processEvent);
            stage.removeEventListener(Event.PASTE, this.processEvent);
            stage.removeEventListener(Event.CUT, this.processEvent);
            removeChild(this.m_textInput);
        }
		
		/**
		 * 事件 
		 * @param event
		 */		
        private function processEvent(event:Event):void{
            var orgCode:* = 0;
            var keyEvent:* = null;
            var event:* = event;
            var keyCode:* = 0;
            var charCode:* = 0;
            if (event.type == Event.RESIZE){
                this.m_textInput.width = stage.stageWidth;
                this.m_textInput.height = stage.stageHeight;
            } else {
                if (event.type == TextEvent.TEXT_INPUT){
                    orgCode = TextEvent(event).text.charCodeAt(0);
                    if (orgCode < 32){
                        if (orgCode <= 26){
                            keyCode = ((Keyboard.A + orgCode) - 1);
                            charCode = (("A".charCodeAt(0) + orgCode) - 1);
                        } else {
                            keyCode = ((Keyboard.LEFTBRACKET + orgCode) - 27);
                            charCode = ((91 + orgCode) - 27);
                        };
                    };
                } else {
                    if ((((((((event.type == Event.SELECT_ALL)) || ((event.type == Event.COPY)))) || ((event.type == Event.PASTE)))) || ((event.type == Event.CUT)))){
                        keyCode = Keyboard.A;
                        if (event.type == Event.COPY){
                            keyCode = Keyboard.C;
                        } else {
                            if (event.type == Event.PASTE){
                                keyCode = Keyboard.V;
                            } else {
                                if (event.type == Event.CUT){
                                    keyCode = Keyboard.X;
                                };
                            };
                        };
                        charCode = ("A".charCodeAt(0) + (keyCode - Keyboard.A));
                    } else {
                        if ((event is KeyboardEvent)){
                            keyEvent = (event as KeyboardEvent);
                            if (keyEvent.ctrlKey){
                                if ((((((((keyEvent.keyCode == Keyboard.A)) || ((keyEvent.keyCode == Keyboard.C)))) || ((keyEvent.keyCode == Keyboard.V)))) || ((keyEvent.keyCode == Keyboard.X)))){
                                    return;
                                };
                            };
                        };
                    };
                };
            };
            var guiManager:* = GUIManager.instance;
            if (((keyCode) && (charCode))){
                guiManager.processEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, charCode, keyCode, 0, true, false, false));
                event = new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, charCode, keyCode, 0, true, false, false);
            };
            if (Exception.throwError){
                guiManager.processEvent(event);
            } else {
                try {
                    guiManager.processEvent(event);
                } catch(e:Error) {
                    Exception.sendCrashLog(e);
                };
            };
            this.m_textInput.text = "";
            this.m_textInput.selectable = guiManager.curWndSelectable;
            if (((guiManager.curWndEditable) && (!((this.m_textInput.parent == this))))){
                addChild(this.m_textInput);
            } else {
                if (((!(guiManager.curWndEditable)) && ((this.m_textInput.parent == this)))){
                    removeChild(this.m_textInput);
                };
            };
        }
        private function focusOutHandler(event:FocusEvent):void{
            if (this.m_forceFocusSelf){
               // stage.focus = this;
            };
        }
        public function doSetCursor(value:String):Boolean{
            Mouse.cursor = value;
            return (true);
        }
        public function enableForceSelfFocus(value:Boolean):void{
            this.m_forceFocusSelf = value;
            if (value){
                stage.focus = this;
            };
        }

    }
}//package deltax.gui.manager 
