package deltax.graphic.camera {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import deltax.graphic.camera.lenses.LensBase;

    public class DeltaXCamera3D extends Camera3D {

        private static var m_tempPosForCalc:Vector3D = new Vector3D();

        private var m_upAxis:Vector3D;
        private var m_lookAtPos:Vector3D;
        private var m_lookAtPosInvalid:Boolean = true;
        private var m_needReLookAt:Boolean = true;
        private var m_viewInvalid:Boolean = true;
        private var m_direction:Vector3D;
        private var m_rightVector:Vector3D;
        private var m_rightValid:Boolean = true;
        private var m_billboardInvalid:Boolean = true;
        private var m_billboardMatrix:Matrix3D;
        public var m_preExtraCameraOffset:Vector3D;
        private var m_extraCameraOffset:Vector3D;
        private var m_onCameraUpdatedHandler:Function;
        private var m_distanceFromTarget:Number = 1;
        private var m_enableCameraShake:Boolean = true;

        public function DeltaXCamera3D(_arg1:LensBase=null)
		{
        }

    }
}
