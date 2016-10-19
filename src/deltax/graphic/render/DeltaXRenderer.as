package deltax.graphic.render 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.TextureBase;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Rectangle;
    
    import deltax.delta;
    import deltax.common.error.SingletonMultiCreateError;
    import deltax.graphic.event.Context3DEvent;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.manager.Stage3DProxy;
    import deltax.graphic.manager.View3D;
    import deltax.graphic.render2D.font.DeltaXFontRenderer;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;

    public class DeltaXRenderer extends EventDispatcher {

        private static var m_instance:DeltaXRenderer;

        protected var _stage3DProxy:Stage3DProxy;
        private var _backBufferWidth:int;
        private var _backBufferHeight:int;
        protected var _backBufferInvalid:Boolean;
        private var _antiAlias:uint;
        private var _renderMode:String = "auto";
        private var m_contextProfile:String = "baseline";
        protected var _backgroundR:Number = 0;
        protected var _backgroundG:Number = 0;
        protected var _backgroundB:Number = 0;
        protected var _backgroundAlpha:Number = 1;
        protected var _viewPortWidth:Number = 1;
        protected var _viewPortHeight:Number = 1;
        protected var _viewPortX:Number = 0;
        protected var _viewPortY:Number = 0;
        private var _viewPortInvalid:Boolean;
        private var _enableDepthAndStencil:Boolean;
        private var _swapBackBuffer:Boolean = true;
        private var _depthPrePass:Boolean;
        private var m_curRenderTarget:TextureBase;
        private var m_view3D:View3D;
        private var m_ignoreSceneCheckOnRender:Boolean;
        delta var showRenderableBoundingBox:Boolean;
        delta var showPartitionNode:Boolean;

        public function DeltaXRenderer(_arg1:uint=0, _arg2:Boolean=true, _arg3:String="auto", _arg4:String="baseline"){
            if (m_instance){
                throw (new SingletonMultiCreateError(DeltaXRenderer));
            };
            m_instance = this;
            this._antiAlias = _arg1;
            this._renderMode = _arg3;
            this.m_contextProfile = _arg4;
            this._enableDepthAndStencil = _arg2;
        }
        public static function get instance():DeltaXRenderer{
            return (m_instance);
        }

        public function get ignoreSceneCheckOnRender():Boolean{
            return (this.m_ignoreSceneCheckOnRender);
        }
        public function set ignoreSceneCheckOnRender(_arg1:Boolean):void{
            this.m_ignoreSceneCheckOnRender = _arg1;
        }
        public function get curRenderTarget():TextureBase{
            return (this.m_curRenderTarget);
        }
        public function get context():Context3D{
            return (this._stage3DProxy.context3D);
        }
        public function reloadShader(_arg1:uint, _arg2:String, _arg3:String, _arg4:String):void{
            ShaderManager.instance.reloadShader(_arg1, _arg2, _arg3, _arg4);
        }
        public function get swapBackBuffer():Boolean{
            return (this._swapBackBuffer);
        }
        public function set swapBackBuffer(_arg1:Boolean):void{
            this._swapBackBuffer = _arg1;
        }
        public function get antiAlias():uint{
            return (this._antiAlias);
        }
        public function set antiAlias(_arg1:uint):void{
            this._backBufferInvalid = true;
            this._antiAlias = _arg1;
        }
        delta function get backgroundR():Number{
            return (this._backgroundR);
        }
        delta function set backgroundR(_arg1:Number):void{
            this._backgroundR = _arg1;
        }
        delta function get backgroundG():Number{
            return (this._backgroundG);
        }
        delta function set backgroundG(_arg1:Number):void{
            this._backgroundG = _arg1;
        }
        delta function get backgroundB():Number{
            return (this._backgroundB);
        }
        delta function set backgroundB(_arg1:Number):void{
            this._backgroundB = _arg1;
        }
        delta function get backgroundAlpha():Number{
            return (this._backgroundAlpha);
        }
        delta function set backgroundAlpha(_arg1:Number):void{
            this._backgroundAlpha = _arg1;
        }
        public function get constrainedMode():Boolean{
            return ((this.m_contextProfile == "baselineConstrained"));
        }
        delta function get stage3DProxy():Stage3DProxy{
            return (this._stage3DProxy);
        }
        delta function set stage3DProxy(_arg1:Stage3DProxy):void{
            if (this._stage3DProxy){
                this._stage3DProxy.removeEventListener(Event.CONTEXT3D_CREATE, this.onContextUpdate);
                this._stage3DProxy.removeEventListener(Context3DEvent.CONTEXT_LOST, this.onContextLost);
            };
            if (!_arg1){
                this._stage3DProxy = null;
                return;
            };
            if (this._stage3DProxy){
                throw (new Error("A Stage3D instance was already assigned!"));
            };
            this._stage3DProxy = _arg1;
            this._stage3DProxy.addEventListener(Event.CONTEXT3D_CREATE, this.onContextUpdate);
            this._stage3DProxy.addEventListener(Context3DEvent.CONTEXT_LOST, this.onContextLost);
            this.updateViewPort();
        }
        delta function get backBufferWidth():int{
            return (this._backBufferWidth);
        }
        delta function set backBufferWidth(_arg1:int):void{
            this._backBufferWidth = _arg1;
            this._backBufferInvalid = true;
        }
        delta function get backBufferHeight():int{
            return (this._backBufferHeight);
        }
        delta function set backBufferHeight(_arg1:int):void{
            this._backBufferHeight = _arg1;
            this._backBufferInvalid = true;
        }
        delta function get viewPortX():Number{
            return (this._viewPortX);
        }
        delta function set viewPortX(_arg1:Number):void{
            this._viewPortX = _arg1;
            this._viewPortInvalid = true;
        }
        delta function get viewPortY():Number{
            return (this._viewPortY);
        }
        delta function set viewPortY(_arg1:Number):void{
            this._viewPortY = _arg1;
            this._viewPortInvalid = true;
        }
        delta function get viewPortWidth():Number{
            return (this._viewPortWidth);
        }
        delta function set viewPortWidth(_arg1:Number):void{
            this._viewPortWidth = _arg1;
            this._viewPortInvalid = true;
        }
        delta function get viewPortHeight():Number{
            return (this._viewPortHeight);
        }
        delta function set viewPortHeight(_arg1:Number):void{
            this._viewPortHeight = _arg1;
            this._viewPortInvalid = true;
        }
        delta function dispose():void{
            this.delta::stage3DProxy = null;
        }
        delta function render():void{
            if (!this._stage3DProxy){
                return;
            };
            if (this._viewPortInvalid){
                this.updateViewPort();
            };
            DeltaXFontRenderer.FLUSH_COUNT = 0;
            DeltaXRectRenderer.FLUSH_COUNT = 0;
        }
        public function present():void{
            if (((!(this._stage3DProxy)) || (!(this._stage3DProxy.context3D)))){
                return;
            };
            this._stage3DProxy.context3D.present();
        }
        public function clear(_arg1:TextureBase=null, _arg2:int=0, _arg3:int=7):Boolean{
            var target = _arg1;
            var surfaceSelector:int = _arg2;
            var additionalClearMask:int = _arg3;
            try {
                if (this._backBufferInvalid){
                    this.updateBackBuffer();
                };
                this.m_curRenderTarget = target;
                if (target){
                    this.context.setRenderToTexture(target, this._enableDepthAndStencil, this._antiAlias, surfaceSelector);
                } else {
                    this.context.setRenderToBackBuffer();
                };
                this.context.clear(this._backgroundR, this._backgroundG, this._backgroundB, this._backgroundAlpha, 1, 0, additionalClearMask);
            } catch(error:Error) {
                trace(error.message);
                trace(error.getStackTrace());
                resetContextManually(_renderMode, m_contextProfile, false);
                return (false);
            };
            return (true);
        }
        protected function updateViewPort():void{
            this._stage3DProxy.viewPort = new Rectangle(this._viewPortX, this._viewPortY, this._viewPortWidth, this._viewPortHeight);
            this._viewPortInvalid = false;
        }
        private function updateBackBuffer():void{
            this._stage3DProxy.configureBackBuffer(this._backBufferWidth, this._backBufferHeight, this._antiAlias, this._enableDepthAndStencil);
            this._backBufferInvalid = false;
        }
        private function onContextUpdate(_arg1:Event):void{
            var _local2:String = this._stage3DProxy.context3D.driverInfo.toLowerCase();
            trace("context updated: ", _local2);
            if (_local2.indexOf("software") >= 0){
                if ((((_local2.indexOf("unavaiable") >= 0)) && (!((this.m_contextProfile == "baselineConstrained"))))){
                    if (this._stage3DProxy.supportContrainedMode){
                        trace("try to use baselineConstrained profile for context3D");
                        this.resetContextManually("auto", "baselineConstrained", false);
                    };
                } else {
                    if (hasEventListener(Context3DEvent.CREATED_SOFTWARE)){
                        dispatchEvent(new Context3DEvent(Context3DEvent.CREATED_SOFTWARE, _local2));
                    };
                };
            } else {
                if (hasEventListener(Context3DEvent.CREATED_HARDWARE)){
                    dispatchEvent(new Context3DEvent(Context3DEvent.CREATED_HARDWARE, _local2));
                };
            };
            ShaderManager.constrained = this.constrainedMode;
        }
        private function onContextLost(_arg1:Context3DEvent):void{
            this.resetContextManually(this._renderMode, this.m_contextProfile);
            trace("on context lost");
            if (hasEventListener(Context3DEvent.CONTEXT_LOST)){
                dispatchEvent(_arg1);
            };
        }
        public function resetContextManually(_arg1:String="auto", _arg2:String="baseline", _arg3:Boolean=true):void{
            trace("resetContextManually", _arg1, _arg2);
            this.onLostDevice();
            if (((!(_arg3)) && (hasEventListener(Context3DEvent.CONTEXT_LOST)))){
                dispatchEvent(new Context3DEvent(Context3DEvent.CONTEXT_LOST));
            };
            this._renderMode = _arg1;
            this.m_contextProfile = _arg2;
            this._stage3DProxy.resetContext(this._renderMode, this.m_contextProfile);
        }
        protected function onLostDevice():void
		{
            ShaderManager.onLostDevice();
            DeltaXTextureManager.instance.onLostDevice();
            DeltaXFontRenderer.Instance.onLostDevice();
            DeltaXRectRenderer.Instance.onLostDevice();
        }
        public function get view3D():View3D{
            return (this.m_view3D);
        }
        public function set view3D(_arg1:View3D):void{
            this.m_view3D = _arg1;
        }

    }
}//package deltax.graphic.render 
