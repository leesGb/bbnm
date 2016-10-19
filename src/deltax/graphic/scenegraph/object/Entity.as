package deltax.graphic.scenegraph.object 
{
    import flash.geom.Matrix3D;
    
    import deltax.delta;
    import deltax.common.error.AbstractMethodError;
	use namespace delta;
    public class Entity extends ObjectContainer3D 
	{
        protected var m_movable:Boolean;
        protected var _modelViewProjection:Matrix3D;
        protected var _zIndex:Number;
        protected var _boundsInvalid:Boolean = true;
        private var _mouseEnabled:Boolean;

        public function Entity(){
            this._modelViewProjection = new Matrix3D();
            super();
        }
        public function get mouseEnabled():Boolean{
            return (this._mouseEnabled);
        }
        public function set mouseEnabled(_arg1:Boolean):void{
            this._mouseEnabled = _arg1;
        }
        public function get movable():Boolean{
            return (this.m_movable);
        }
        public function set movable(_arg1:Boolean):void{
            this.m_movable = _arg1;
        }
        protected function updateBounds():void{
            throw (new AbstractMethodError());
        }

    }
}
