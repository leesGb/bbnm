package deltax.graphic.manager 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Vector3D;
    
    import deltax.delta;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.camera.lenses.Orthographic2DLens;
    import deltax.graphic.render.DeltaXRenderer;

    public class View3D extends Sprite {

        public static var TraverseSceneTime:uint;
        public static var RenderSceneTime:uint;

        private var _width:Number = 0;
        private var _height:Number = 0;
        private var _scaleX:Number = 1;
        private var _scaleY:Number = 1;
        private var _x:Number = 0;
        private var _y:Number = 0;
        private var _camera:Camera3D;
        private var m_camera2D:DeltaXCamera3D;
        private var _aspectRatio:Number;
        private var _time:Number = 0;
        private var _backgroundColor:uint = 0;
        private var _stage3DManager:Stage3DManager;
        private var _renderer:DeltaXRenderer;

        public function View3D(_arg2:Camera3D=null,$render:DeltaXRenderer = null){
            this._camera = ((_arg2) || (new DeltaXCamera3D()));
			_renderer = $render;
            addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
            addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage, false, 0, true);
        }
        public function get renderer():DeltaXRenderer{
            return (this._renderer);
        }
        public function set renderer(_arg1:DeltaXRenderer):void{
            var _local2:Stage3DProxy = this._renderer.delta::stage3DProxy;
            this._renderer.delta::dispose();
            this._renderer = _arg1;
            this._renderer.delta::stage3DProxy = _local2;
            this._renderer.delta::viewPortX = this._x;
            this._renderer.delta::viewPortY = this._y;
            this._renderer.delta::backBufferWidth = this._width;
            this._renderer.delta::backBufferHeight = this._height;
            this._renderer.delta::viewPortHeight = (this._width * this._scaleX);
            this._renderer.delta::viewPortHeight = (this._height * this._scaleY);
            this._renderer.delta::backgroundR = (((this._backgroundColor >> 16) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundG = (((this._backgroundColor >> 8) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundB = ((this._backgroundColor & 0xFF) / 0xFF);
            this._renderer.delta::backgroundAlpha = (((this._backgroundColor >>> 24) & 0xFF) / 0xFF);
        }
        public function get backgroundColor():uint{
            return (this._backgroundColor);
        }
        public function set backgroundColor(_arg1:uint):void{
            this._backgroundColor = _arg1;
            this._renderer.delta::backgroundR = (((_arg1 >>> 16) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundG = (((_arg1 >>> 8) & 0xFF) / 0xFF);
            this._renderer.delta::backgroundB = ((_arg1 & 0xFF) / 0xFF);
            this._renderer.delta::backgroundAlpha = (((_arg1 >>> 24) & 0xFF) / 0xFF);
        }
        public function get camera2D():DeltaXCamera3D{
            if (!this.m_camera2D){
                this.m_camera2D = new DeltaXCamera3D();
                this.m_camera2D.position = new Vector3D(0, 0, -1);
                this.m_camera2D.lookAt(new Vector3D());
                this.m_camera2D.lens = new Orthographic2DLens();
                this.m_camera2D.lens.near = 1;
                this.m_camera2D.lens.far = 1000;
            };
            return (this.m_camera2D);
        }
        override public function get width():Number{
            return (this._width);
        }
        override public function set width(_arg1:Number):void{
            this._renderer.delta::viewPortWidth = (_arg1 * this._scaleX);
            this._renderer.delta::backBufferWidth = _arg1;
            this._width = _arg1;
//            this._aspectRatio = (this._width / this._height);
//            this._camera.lens.aspectRatio = this._aspectRatio;
        }
        override public function get height():Number{
            return (this._height);
        }
        override public function set height(_arg1:Number):void{
            this._renderer.delta::viewPortHeight = (_arg1 * this._scaleY);
            this._renderer.delta::backBufferHeight = _arg1;
            this._height = _arg1;
//            this._aspectRatio = (this._width / this._height);
//            this._camera.lens.aspectRatio = this._aspectRatio;
        }
        override public function get scaleX():Number{
            return (this._scaleX);
        }
        override public function set scaleX(_arg1:Number):void{
            this._scaleX = _arg1;
            this._renderer.delta::viewPortWidth = (this._width * this._scaleX);
        }
        override public function get scaleY():Number{
            return (this._scaleY);
        }
        override public function set scaleY(_arg1:Number):void{
            this._scaleY = _arg1;
            this._renderer.delta::viewPortHeight = (this._height * this._scaleY);
        }
        override public function get x():Number{
            return (this._x);
        }
        override public function set x(_arg1:Number):void{
            this._renderer.delta::viewPortX = _arg1;
            this._x = _arg1;
        }
        override public function get y():Number{
            return (this._y);
        }
        override public function set y(_arg1:Number):void{
            this._renderer.delta::viewPortY = _arg1;
            this._y = _arg1;
        }
        public function get antiAlias():uint{
            return (this._renderer.antiAlias);
        }
        public function set antiAlias(_arg1:uint):void{
            this._renderer.antiAlias = _arg1;
        }
        public function render():void{
        }
        public function dispose():void{
            this._renderer.delta::dispose();
        }
        private function onAddedToStage(_arg1:Event):void{
            this._stage3DManager = Stage3DManager.getInstance(stage);
            if (this._width == 0){
                this.width = stage.stageWidth;
            };
            if (this._height == 0){
                this.height = stage.stageHeight;
            };
            this._renderer.delta::stage3DProxy = this._stage3DManager.getFreeStage3DProxy();
            removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        }
        private function onRemovedFromStage(_arg1:Event):void{
            this._renderer.delta::stage3DProxy.dispose();
            removeEventListener(Event.ADDED_TO_STAGE, this.onRemovedFromStage);
        }

    }
}
