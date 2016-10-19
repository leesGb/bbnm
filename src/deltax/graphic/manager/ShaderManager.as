package deltax.graphic.manager 
{
    import deltax.graphic.camera.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.shader.*;
    
    import flash.display3D.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;

    public class ShaderManager 
	{
		[Embed(source='../../../shader/DefaultProgram', mimeType='application/octet-stream')] 
        private static const DefaultProgram:Class;
		[Embed(source='../../../shader/DefaultLightProgram', mimeType='application/octet-stream')] 
        private static const DefaultLightProgram:Class;
		[Embed(source='../../../shader/DefaultProgramClamp', mimeType='application/octet-stream')] 
        private static const DefaultProgramClamp:Class;
		[Embed(source='../../../shader/DefaultLightProgramClamp', mimeType='application/octet-stream')] 
        private static const DefaultLightProgramClamp:Class;
		[Embed(source='../../../shader/SkinnedMeshProgram', mimeType='application/octet-stream')] 
        private static const SkinnedMeshProgram:Class;
		[Embed(source='../../../shader/SkinnedMeshProgram2', mimeType='application/octet-stream')] 
        private static const SkinnedMeshProgram2:Class;
		[Embed(source='../../../shader/SkinnedMeshEmissiveProgram', mimeType='application/octet-stream')] 
        private static const SkinnedMeshEmissiveProgram:Class;
		[Embed(source='../../../shader/SkinnedMeshEmissiveProgram2', mimeType='application/octet-stream')] 
        private static const SkinnedMeshEmissiveProgram2:Class;
		[Embed(source='../../../shader/SkinnedMeshSpecularProgram', mimeType='application/octet-stream')] 
        private static const SkinnedMeshSpecularProgram:Class;
		[Embed(source='../../../shader/SkinnedMeshSpecularProgram2', mimeType='application/octet-stream')] 
        private static const SkinnedMeshSpecularProgram2:Class;
		[Embed(source='../../../shader/SkinnedMeshShadowProgram', mimeType='application/octet-stream')] 
        private static const SkinnedMeshShadowProgram:Class;
		[Embed(source='../../../shader/SkinnedMeshShadowProgram2', mimeType='application/octet-stream')] 
        private static const SkinnedMeshShadowProgram2:Class;
		[Embed(source='../../../shader/ScreenFilterVertexProgram', mimeType='application/octet-stream')] 
        private static const ScreenFilterVertexProgram:Class;
		[Embed(source='../../../shader/ScreenFilterTexturedFragmentProgram', mimeType='application/octet-stream')] 
        private static const ScreenFilterTexturedFragmentProgram:Class;
		[Embed(source='../../../shader/ScreenFilterTexturedMaterialProgram', mimeType='application/octet-stream')] 
        private static const ScreenFilterTexturedMaterialProgram:Class;
		[Embed(source='../../../shader/ScreenFilterGrayFragmentProgram', mimeType='application/octet-stream')] 
        private static const ScreenFilterGrayFragmentProgram:Class;
		[Embed(source='../../../shader/ScreenFilterGrayMaterialProgram', mimeType='application/octet-stream')] 
        private static const ScreenFilterGrayMaterialProgram:Class;
		[Embed(source='../../../shader/DisturbProgram', mimeType='application/octet-stream')] 
        private static const DisturbProgram:Class;
		[Embed(source='../../../shader/BlurHorizonProgram', mimeType='application/octet-stream')] 
        private static const BlurHorizonProgram:Class;
		[Embed(source='../../../shader/BlurHorizonProgram2', mimeType='application/octet-stream')] 
        private static const BlurHorizonProgram2:Class;
		[Embed(source='../../../shader/BlurVerticalProgram', mimeType='application/octet-stream')] 
        private static const BlurVerticalProgram:Class;
		[Embed(source='../../../shader/BlurVerticalProgram2', mimeType='application/octet-stream')] 
        private static const BlurVerticalProgram2:Class;
		[Embed(source='../../../shader/BlurDownSampleProgram', mimeType='application/octet-stream')] 
        private static const BlurDownSampleProgram:Class;
		[Embed(source='../../../shader/ParticleCamera', mimeType='application/octet-stream')] 
        private static const ParticleCamera:Class;
		[Embed(source='../../../shader/ParticleVelocity', mimeType='application/octet-stream')] 
        private static const ParticleVelocity:Class;
		[Embed(source='../../../shader/ParticleFace2Velocity', mimeType='application/octet-stream')] 
        private static const ParticleFace2Velocity:Class;
		[Embed(source='../../../shader/ParticleAlwaysUp', mimeType='application/octet-stream')] 
        private static const ParticleAlwaysUp:Class;
		[Embed(source='../../../shader/ParticleUpupup', mimeType='application/octet-stream')] 
        private static const ParticleUpupup:Class;
		[Embed(source='../../../shader/ParticleEmissPlan', mimeType='application/octet-stream')] 
        private static const ParticleEmissPlan:Class;
		[Embed(source='../../../shader/ParticleVecNoCamr', mimeType='application/octet-stream')] 
        private static const ParticleVecNoCamr:Class;
		[Embed(source='../../../shader/BillboardAttachTerrain', mimeType='application/octet-stream')] 
        private static const BillboardAttachTerrain:Class;
		[Embed(source='../../../shader/BillboardNormal', mimeType='application/octet-stream')] 
        private static const BillboardNormal:Class;
		[Embed(source='../../../shader/PolygonTrailNormal', mimeType='application/octet-stream')] 
        private static const PolygonTrailNormal:Class;
		[Embed(source='../../../shader/PolygonTrailNormal2', mimeType='application/octet-stream')] 
        private static const PolygonTrailNormal2:Class;
		[Embed(source='../../../shader/PolygonTrailBlock', mimeType='application/octet-stream')] 
        private static const PolygonTrailBlock:Class;
		[Embed(source='../../../shader/PolygonTrailBlock2', mimeType='application/octet-stream')] 
        private static const PolygonTrailBlock2:Class;
		[Embed(source='../../../shader/PolygonChainNormal', mimeType='application/octet-stream')] 
        private static const PolygonChainNormal:Class;
		[Embed(source='../../../shader/TerrianProgram', mimeType='application/octet-stream')] 
        private static const TerrianProgram:Class;
		[Embed(source='../../../shader/TerrianProgram2', mimeType='application/octet-stream')] 
        private static const TerrianProgram2:Class;
		[Embed(source='../../../shader/WaterProgram', mimeType='application/octet-stream')] 
        private static const WaterProgram:Class;
		[Embed(source='../../../shader/WaterProgram2', mimeType='application/octet-stream')] 
        private static const WaterProgram2:Class;
		[Embed(source='../../../shader/SeperateAlphaProgram', mimeType='application/octet-stream')] 
        private static const SeperateAlphaProgram:Class;
		[Embed(source='../../../shader/AddTextureMaskProgram', mimeType='application/octet-stream')] 
        private static const AddTextureMaskProgram:Class;
		[Embed(source='../../../shader/AddTextureMask2Program', mimeType='application/octet-stream')] 
        private static const AddTextureMask2Program:Class;
		[Embed(source='../../../shader/DebugProgram', mimeType='application/octet-stream')] 
        private static const DebugProgram:Class;
		[Embed(source='../../../shader/FontProgram', mimeType='application/octet-stream')] 
        private static const FontProgram:Class;
		[Embed(source='../../../shader/RectProgram', mimeType='application/octet-stream')] 
        private static const RectProgram:Class;
		/*[Embed(source='../../../shader/SHADER_SKINNED.txt', mimeType='application/octet-stream')] 
		private static const TestProgram:Class;*/
		
        public static const SHADER_DEFAULT:uint = SHADER_ID++;
        public static const SHADER_LIGHT:uint = SHADER_ID++;
        public static const SHADER_SKINNED:uint = SHADER_ID++;
        public static const SHADER_SKINNED_EMISSIVE:uint = SHADER_ID++;
        public static const SHADER_SKINNED_SPECULAR:uint = SHADER_ID++;
        public static const SHADER_SKINNED_SHADOW:uint = SHADER_ID++;
        public static const SHADER_SCREEN_TEXTURE:uint = SHADER_ID++;
        public static const SHADER_SCREEN_GRAY:uint = SHADER_ID++;
        public static const SHADER_SCREEN_BLUR_DOWN:uint = SHADER_ID++;
        public static const SHADER_SCREEN_BLUR_H:uint = SHADER_ID++;
        public static const SHADER_SCREEN_BLUR_V:uint = SHADER_ID++;
        public static const SHADER_DISTURB:uint = SHADER_ID++;
        public static const SHADER_PARTICLE_CAMERA:uint = SHADER_ID++;
        public static const SHADER_PARTICLE_VELOCITY:uint = SHADER_ID++;
        public static const SHADER_PARTICLE_FACE2VEL:uint = SHADER_ID++;
        public static const SHADER_PARTICLE_ALWAYSUP:uint = SHADER_ID++;
        public static const SHADER_PARTICLE_UPUPUP:uint = SHADER_ID++;
        public static const SHADER_PARTICLE_EMISPLAN:uint = SHADER_ID++;
        public static const SHADER_PARTICLE_VECNOCAMR:uint = SHADER_ID++;
        public static const SHADER_BILLBOARD_ATCHTERR:uint = SHADER_ID++;
        public static const SHADER_BILLBOARD_NORMAL:uint = SHADER_ID++;
        public static const SHADER_POLYTRAIL_NORMAL:uint = SHADER_ID++;
        public static const SHADER_POLYTRAIL_BLOCK:uint = SHADER_ID++;
        public static const SHADER_POLYCHAIN_NORMAL:uint = SHADER_ID++;
        public static const SHADER_TERRAIN:uint = SHADER_ID++;
        public static const SHADER_WATER:uint = SHADER_ID++;
        public static const SHADER_SEPERATE_ALPHA:uint = SHADER_ID++;
        public static const SHADER_ADDMASK:uint = SHADER_ID++;
        public static const SHADER_ADDMASK2:uint = SHADER_ID++;
        public static const SHADER_DEFAULT_CLAMP:uint = SHADER_ID++;
        public static const SHADER_LIGHT_CLAMP:uint = SHADER_ID++;
        public static const SHADER_DEBUG:uint = SHADER_ID++;
        public static const SHADER_FONT:uint = SHADER_ID++;
        public static const SHADER_RECT:uint = SHADER_ID++;
        public static const SHADER_COUNT:uint = SHADER_ID++;

        private static var SHADER_ID:uint = 0;
        private static var m_instance:ShaderManager;
        private static var m_constrainedModel:int = -1;

        public var m_shaderASMClasses:Vector.<Array>;
        private var m_program3Ds:Vector.<DeltaXProgram3D>;
        private var m_maxLightCount:uint = 0;

        public function ShaderManager(_arg1:SingletonEnforcer){
            var _local3:Array;
            var _local4:uint;
            var _local5:uint;
            var _local6:Class;
            this.m_program3Ds = new Vector.<DeltaXProgram3D>(SHADER_COUNT);
            super();
            if (m_constrainedModel < 0){
                throw (new Error("canot create shader without init constrained model!!!"));
            };
            this.m_shaderASMClasses = new Vector.<Array>(SHADER_COUNT, true);
            this.m_shaderASMClasses[SHADER_DEFAULT] = [DefaultProgram];
            this.m_shaderASMClasses[SHADER_LIGHT] = [DefaultLightProgram];
            this.m_shaderASMClasses[SHADER_DEFAULT_CLAMP] = [DefaultProgramClamp];
            this.m_shaderASMClasses[SHADER_LIGHT_CLAMP] = [DefaultLightProgramClamp];
            this.m_shaderASMClasses[SHADER_SKINNED] = [[SkinnedMeshProgram], [SkinnedMeshProgram2]];//[TestProgram];//
            this.m_shaderASMClasses[SHADER_SKINNED_EMISSIVE] = [[SkinnedMeshEmissiveProgram], [SkinnedMeshEmissiveProgram2]];
            this.m_shaderASMClasses[SHADER_SKINNED_SPECULAR] = [[SkinnedMeshSpecularProgram], [SkinnedMeshSpecularProgram2]];
            this.m_shaderASMClasses[SHADER_SKINNED_SHADOW] = [[SkinnedMeshShadowProgram], [SkinnedMeshShadowProgram2]];
            this.m_shaderASMClasses[SHADER_SCREEN_TEXTURE] = [ScreenFilterVertexProgram, ScreenFilterTexturedMaterialProgram, ScreenFilterTexturedFragmentProgram];
            this.m_shaderASMClasses[SHADER_SCREEN_GRAY] = [ScreenFilterVertexProgram, ScreenFilterGrayMaterialProgram, ScreenFilterGrayFragmentProgram];
            this.m_shaderASMClasses[SHADER_SCREEN_BLUR_DOWN] = [BlurDownSampleProgram];
            this.m_shaderASMClasses[SHADER_SCREEN_BLUR_H] = [[BlurHorizonProgram], [BlurHorizonProgram2]];
            this.m_shaderASMClasses[SHADER_SCREEN_BLUR_V] = [[BlurVerticalProgram], [BlurVerticalProgram2]];
            this.m_shaderASMClasses[SHADER_DISTURB] = [DisturbProgram];
            this.m_shaderASMClasses[SHADER_PARTICLE_CAMERA] = [ParticleCamera];
            this.m_shaderASMClasses[SHADER_PARTICLE_VELOCITY] = [ParticleVelocity];
            this.m_shaderASMClasses[SHADER_PARTICLE_FACE2VEL] = [ParticleFace2Velocity];
            this.m_shaderASMClasses[SHADER_PARTICLE_ALWAYSUP] = [ParticleAlwaysUp];
            this.m_shaderASMClasses[SHADER_PARTICLE_UPUPUP] = [ParticleUpupup];
            this.m_shaderASMClasses[SHADER_PARTICLE_EMISPLAN] = [ParticleEmissPlan];
            this.m_shaderASMClasses[SHADER_PARTICLE_VECNOCAMR] = [ParticleVecNoCamr];
            this.m_shaderASMClasses[SHADER_BILLBOARD_ATCHTERR] = [BillboardAttachTerrain];
            this.m_shaderASMClasses[SHADER_BILLBOARD_NORMAL] = [BillboardNormal];
            this.m_shaderASMClasses[SHADER_POLYTRAIL_NORMAL] = [[PolygonTrailNormal], [PolygonTrailNormal2]];
            this.m_shaderASMClasses[SHADER_POLYTRAIL_BLOCK] = [[PolygonTrailBlock], [PolygonTrailBlock2]];
            this.m_shaderASMClasses[SHADER_POLYCHAIN_NORMAL] = [PolygonChainNormal];
            this.m_shaderASMClasses[SHADER_TERRAIN] = [[TerrianProgram], [TerrianProgram2]];
            this.m_shaderASMClasses[SHADER_WATER] = [[WaterProgram], [WaterProgram2]];
            this.m_shaderASMClasses[SHADER_SEPERATE_ALPHA] = [SeperateAlphaProgram];
            this.m_shaderASMClasses[SHADER_ADDMASK] = [AddTextureMaskProgram];
            this.m_shaderASMClasses[SHADER_ADDMASK2] = [AddTextureMask2Program];
            this.m_shaderASMClasses[SHADER_DEBUG] = [DebugProgram];
            this.m_shaderASMClasses[SHADER_FONT] = [FontProgram];
            this.m_shaderASMClasses[SHADER_RECT] = [RectProgram];
            var _local2:uint;
            while (_local2 < this.m_shaderASMClasses.length) {
                _local3 = this.m_shaderASMClasses[_local2];
                if (!(_local3[0] is Array)){
                    _local3 = [_local3];
                };
                _local4 = 0;
                while (_local4 < _local3.length) {
                    _local5 = 0;
                    while (_local5 < _local3[_local4].length) {
                        _local6 = Class(_local3[_local4][_local5]);
                        _local3[_local4][_local5] = new _local6();
                        _local5++;
                    };
                    _local4++;
                };
                this.getProgram3D(_local2);
                _local2++;
            };
        }
        public static function get instance():ShaderManager{
            return ((m_instance = ((m_instance) || (new ShaderManager(new SingletonEnforcer())))));
        }
        public static function onLostDevice():void{
            if (m_constrainedModel < 0){
                return;
            };
            var _local1:uint;
            while (_local1 < instance.m_program3Ds.length) {
                instance.m_program3Ds[_local1].onLostDevice();
                _local1++;
            };
        }
        public static function set constrained(_arg1:Boolean):void{
            var _local3:uint;
            var _local4:Array;
            var _local5:uint;
            var _local2:int = (_arg1) ? 1 : 0;
            if ((((m_constrainedModel >= 0)) && (!((_local2 == m_constrainedModel))))){
                _local3 = 0;
                while (_local3 < instance.m_shaderASMClasses.length) {
                    _local4 = instance.m_shaderASMClasses[_local3];
                    if (!(_local4[0] is Array)){
                    } else {
                        _local4 = _local4[_local2];
                        _local5 = 0;
                        while (_local5 < _local4.length) {
                            _local4[_local5].position = 0;
                            _local5++;
                        };
                        instance.rebuildProgram3D(_local3, _local4);
                    };
                    _local3++;
                };
            };
            m_constrainedModel = _local2;
        }

        public function getProgram3D(_arg1:uint):DeltaXProgram3D{
            var _local3:Array;
            var _local2:DeltaXProgram3D = this.m_program3Ds[_arg1];
            if (!_local2){
                _local2 = new DeltaXProgram3D();
                _local3 = this.m_shaderASMClasses[_arg1];
                if ((_local3[0] is Array)){
                    _local3 = _local3[m_constrainedModel];
                };
                if (_local3.length == 3){
                    _local2.buildPBProgram3D(_local3[0], _local3[1], _local3[2]);
                } else {
                    _local2.buildDeltaXProgram3D(_local3[0]);
                };
                this.m_program3Ds[_arg1] = _local2;
                this.m_maxLightCount = Math.max(this.m_maxLightCount, _local2.getVertexParamRegisterCount(DeltaXProgram3D.LIGHTPOS));
            };
            return (_local2);
        }
		public function getShaderTypeByProgram3D(program3D:DeltaXProgram3D):int{
			if(program3D){
				return this.m_program3Ds.indexOf(program3D);
			}
			return -1;
		}
        public function createDeltaXProgram3D(_arg1:ByteArray):uint{
            var _local2:uint = this.m_program3Ds.length;
            this.m_program3Ds[_local2] = new DeltaXProgram3D();
            this.rebuildProgram3D(_local2, [_arg1]);
            return (_local2);
        }
        public function rebuildProgram3D(_arg1:uint, _arg2:Array):void{
            if ((((_arg1 >= this.m_program3Ds.length)) || (!(this.m_program3Ds[_arg1])))){
                return;
            };
            if (_arg2.length < 3){
                this.m_program3Ds[_arg1].buildDeltaXProgram3D(_arg2[0]);
            } else {
                this.m_program3Ds[_arg1].buildPBProgram3D(_arg2[0], _arg2[1], _arg2[2]);
            };
        }
        public function reloadShader(_arg1:uint, _arg2:String, _arg3:String, _arg4:String):void{
            var loadType:* = 0;
            var loaderArray:* = null;
            var shaderLoaded:* = null;
            var loader:* = null;
            var type:* = _arg1;
            var vertexShader:* = _arg2;
            var fragmentShader:* = _arg3;
            var materialShader:* = _arg4;
            shaderLoaded = function (_arg1:Event):void{
                var _local2:Boolean;
                var _local3:URLLoader = URLLoader(_arg1.target);
                var _local4:uint;
                while (_local4 < loaderArray.length) {
                    if (loaderArray[_local4] == _local3){
                        loaderArray[_local4] = _local3.data;
                    };
                    if ((loaderArray[_local4] is URLLoader)){
                        _local2 = false;
                    };
                    _local4++;
                };
                if (!_local2){
                    return;
                };
                ShaderManager.instance.rebuildProgram3D(loadType, loaderArray);
            };
            if ((((type >= this.m_program3Ds.length)) || (!(this.m_program3Ds[type])))){
                return;
            };
            loadType = type;
            loaderArray = new Array(vertexShader);
            if (((!((fragmentShader == null))) && (!((fragmentShader == ""))))){
                loaderArray[1] = fragmentShader;
            };
            if (((!((materialShader == null))) && (!((materialShader == ""))))){
                loaderArray[2] = materialShader;
            };
            var i:* = 0;
            while (i < loaderArray.length) {
                loader = new URLLoader();
                loader.dataFormat = URLLoaderDataFormat.BINARY;
                loader.load(new URLRequest(loaderArray[i]));
                loader.addEventListener(Event.COMPLETE, shaderLoaded);
                loaderArray[i] = loader;
                i = (i + 1);
            };
        }
//        public function resetOnFrameStart(_arg1:Context3D, _arg2:RenderScene, _arg3:DeltaXEntityCollector, _arg4:Camera3D):void{
//            var _local5:uint;
//            while (_local5 < SHADER_COUNT) {
//                this.getProgram3D(_local5).resetOnFrameStart(_arg1, _arg2, _arg3, _arg4);
//                _local5++;
//            };
//        }
        public function resetCameraState(_arg1:Camera3D):void{
            var _local2:uint;
            while (_local2 < SHADER_COUNT) {
                this.getProgram3D(_local2).resetCameraState(_arg1);
                _local2++;
            };
        }
        public function get maxLightCount():uint{
            return (this.m_maxLightCount);
        }

    }
}//package deltax.graphic.manager 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
