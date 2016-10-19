package deltax.graphic.camera 
{
    import deltax.delta;
    import deltax.graphic.camera.lenses.LensBase;
    import deltax.graphic.scenegraph.object.Entity;

    public class Camera3D extends Entity 
	{
        private var _lens:LensBase;

        public function Camera3D(_arg1:LensBase=null)
		{
        }
        public function get lens():LensBase{
            return (this._lens);
        }
        public function set lens(_arg1:LensBase):void{
            if (this._lens == _arg1){
                return;
            };
            if (!_arg1){
                throw (new Error("Lens cannot be null!"));
            };
            this._lens = _arg1;
        }
        override protected function updateBounds():void{
            _boundsInvalid = false;
        }
        public function onFrameBegin():void{
        }
        public function onFrameEnd():void{
        }

    }
}
