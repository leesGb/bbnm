package deltax.graphic.camera.lenses 
{
    import flash.geom.Matrix3D;
    
    import deltax.delta;
    import deltax.common.error.AbstractMethodError;

    public class LensBase 
	{
        protected var _matrix:Matrix3D;
        protected var _near:Number = 20;
        protected var _far:Number = 3000;
        protected var _aspectRatio:Number = 1;
        private var _matrixInvalid:Boolean = true;
        delta var onMatrixUpdate:Function;
        protected var m_adjustMatrix:Matrix3D;

        public function LensBase()
		{
            this._matrix = new Matrix3D();
        }
        public function set adjustMatrix(_arg1:Matrix3D):void
		{
            this.m_adjustMatrix = _arg1;
            this.invalidateMatrix();
        }
        public function get adjustMatrix():Matrix3D
		{
            return (this.m_adjustMatrix);
        }
        public function get matrix():Matrix3D
		{
            if (this._matrixInvalid){
                this.updateMatrix();
                if (this.delta::onMatrixUpdate != null){
                    this.delta::onMatrixUpdate();
                }
                if (this.m_adjustMatrix){
                    this._matrix.append(this.m_adjustMatrix);
                };
                this._matrixInvalid = false;
            };
            return (this._matrix);
        }
        public function get near():Number{
            return (this._near);
        }
        public function set near(_arg1:Number):void{
            if (_arg1 == this._near){
                return;
            };
            this._near = _arg1;
            this.invalidateMatrix();
        }
        public function get far():Number{
            return (this._far);
        }
        public function set far(_arg1:Number):void{
            if (_arg1 == this._far){
                return;
            };
            this._far = _arg1;
            this.invalidateMatrix();
        }
        public function get aspectRatio():Number{
            return (this._aspectRatio);
        }
        public function set aspectRatio(_arg1:Number):void{
            if (this._aspectRatio == _arg1){
                return;
            };
            this._aspectRatio = _arg1;
            this.invalidateMatrix();
        }
        protected function invalidateMatrix():void{
            this._matrixInvalid = true;
        }
        protected function updateMatrix():void{
            throw (new AbstractMethodError());
        }

    }
}
