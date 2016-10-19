//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.render2D.font {
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import __AS3__.vec.Vector;
    
    import deltax.graphic.manager.NelboSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;
    import deltax.graphic.shader.DeltaXProgram3D;
	
	/**
	 * 文本渲染器<br>
	 * @author admin
	 */
    public class DeltaXFontRenderer {

        public static var FLUSH_COUNT:uint;
        private static var m_instance:DeltaXFontRenderer;

        private var m_fontMap:Dictionary;
        private var m_fontShader:DeltaXProgram3D;
        private var m_viewPort:Rectangle;
        private var m_fontInfo:DeltaXFontInfo;
        private var m_fontZ:Number;
        private var m_fontCount:uint;
        private var m_fontMaxCount:uint;
        private var m_fontStartIndex:uint;
        private var m_fontInfoArray:Vector.<Number>;
        private var m_vertexRectCount:uint;

        public function DeltaXFontRenderer(value:SingletonEnforcer){
            this.m_fontMap = new Dictionary();
            this.m_viewPort = new Rectangle();
        }
        public static function get Instance():DeltaXFontRenderer{
            m_instance = ((m_instance) || (new DeltaXFontRenderer(new SingletonEnforcer())));
            return (m_instance);
        }

        public function unregisterDeltaXSubGeometry(value:DeltaXFont):void{
            this.m_fontMap[value.name] = null;
            delete this.m_fontMap[value.name];
        }
        public function onLostDevice():void{
            var _local1:DeltaXFont;
            for each (_local1 in this.m_fontMap) {
                _local1.onLostDevice();
            };
            this.m_fontShader = null;
        }
        private function recreateShader():void{
            this.m_fontShader = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_FONT);
            this.m_fontMaxCount = (this.m_fontShader.getVertexParamRegisterCount(DeltaXProgram3D.WORLD) / 2);
            this.m_fontStartIndex = (this.m_fontShader.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4);
            this.m_fontInfoArray = this.m_fontShader.getVertexParamCache();
        }
		
		/**
		 * 创建字体DeltaXFont
		 * @param	font	字体
		 * @return	DeltaXFont
		 */
        public function createFont(font:String=""):DeltaXFont{
            if (this.m_fontMap[font] == null){
                this.m_fontMap[font] = new DeltaXFont(font);
            } else {
                DeltaXFont(this.m_fontMap[font]).reference();
            };
            return DeltaXFont(this.m_fontMap[font]);
        }
        public function setViewPort(valueWidth:Number, valueHeight:Number):void{
            this.m_viewPort.width = valueWidth;
            this.m_viewPort.height = valueHeight;
        }
        public function get viewPort():Rectangle{
            return this.m_viewPort;
        }
		
		/**
		 * 开始渲染文本
		 * @param	context3D		3d
		 * @param	fontInfo		文本数据
		 * @param	valueZ			z坐标
		 */
        public function beginFontRender(context3D:Context3D, fontInfo:DeltaXFontInfo, valueZ:Number):void{
            var _local4:uint;
            var _local5:uint;
            DeltaXRectRenderer.Instance.flushAll(context3D);
            if (((!((this.m_fontInfo == fontInfo))) || (!((this.m_fontZ == valueZ))))){
                if (this.m_fontCount){
                    this.flushAll(context3D);
                };
                this.m_fontInfo = fontInfo;
                this.m_fontZ = valueZ;
                this.m_fontCount = 0;
                _local4 = this.m_fontInfo.fontEdgeSize;
                _local5 = ((this.m_fontInfo.fontOrgSize + (_local4 * 2)) + 1);
                if (!this.m_fontShader){
                    this.recreateShader();
                };
                this.m_fontShader.setParamValue(DeltaXProgram3D.FACTOR, DeltaXFontInfo.FONT_TEXTURE_WIDTH_RCP, DeltaXFontInfo.FONT_TEXTURE_HEIGHT_RCP, _local5, _local4);
                this.m_fontShader.setParamValue(DeltaXProgram3D.PROJECTION, (2 / this.m_viewPort.width), (-2 / this.m_viewPort.height), valueZ, 0);
                context3D.setProgram(this.m_fontShader.getProgram3D(context3D));
                context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                context3D.setCulling(Context3DTriangleFace.BACK);
                context3D.setDepthTest(true, Context3DCompareMode.ALWAYS);
            };
        }
		
		/**
		 * 渲染文本<br>
		 * 把相关数据保存到m_fontShader里面的m_vertexConstCache
		 * @param	context3D		3d
		 * @param	valueX			x
		 * @param	valueY			y
		 * @param	BA				RGBA的BA
		 * @param	RG				RGBA的RG
		 * @param	rectLeft		
		 * @param	rectTop		
		 * @param	rectRight
		 * @param	rectBottom
		 */
        public function renderFont(context3D:Context3D, valueX:Number, valueY:Number, BA:uint, RG:uint, rectLeft:Number, rectTop:Number, rectRight:Number, rectBottom:Number):void{
            if (this.m_fontCount >= this.m_fontMaxCount){
                this.flushAll(context3D);
            };
            var _local10:uint = ((this.m_fontCount << 3) + this.m_fontStartIndex);
            this.m_fontInfoArray[_local10] = valueX;
            _local10++;
            this.m_fontInfoArray[_local10] = valueY;
            _local10++;
            this.m_fontInfoArray[_local10] = BA;
            _local10++;
            this.m_fontInfoArray[_local10] = RG;
            _local10++;
            this.m_fontInfoArray[_local10] = rectLeft;
            _local10++;
            this.m_fontInfoArray[_local10] = rectTop;
            _local10++;
            this.m_fontInfoArray[_local10] = rectRight;
            _local10++;
            this.m_fontInfoArray[_local10] = rectBottom;
            this.m_fontCount++;
        }
		
		/**
		 * 结束渲染
		 * @param	context3D		3d
		 */
        public function endFontRender(context3D:Context3D):void{
            if (this.m_fontCount == 0){
                this.m_fontInfo = null;
                return;
            };
            this.flushAll(context3D);
            this.m_fontInfo = null;
        }
		
		/**
		 * 渲染，提交到显卡
		 * @param	context3D		3d
		 */
        private function flushAll(context3D:Context3D):void{
            if (!this.m_fontShader){
                this.recreateShader();
                context3D.setProgram(this.m_fontShader.getProgram3D(context3D));
            };
            FLUSH_COUNT++;
            this.m_fontShader.setSampleTexture(0, this.m_fontInfo.getTexture(context3D));
            this.m_fontShader.update(context3D);
            NelboSubGeometryManager.Instance.drawPackRect(context3D, this.m_fontCount);
            this.m_fontShader.deactivate(context3D);
            this.m_fontCount = 0;
        }

    }
}

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
