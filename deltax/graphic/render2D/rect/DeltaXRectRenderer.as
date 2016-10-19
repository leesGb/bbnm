//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.render2D.rect {
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import deltax.common.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.render2D.font.*;
    import flash.utils.*;
    import deltax.graphic.texture.*;
    import deltax.common.math.*;
    import flash.display3D.textures.*;
    import deltax.graphic.shader.*;
	
	/**
	 * 矩形渲染，2D位图渲染
	 * @author admin
	 *
	 */
    public class DeltaXRectRenderer 
	{
		
		[Embed(source='../../../../shader/DeltaXRectRenderer_SingleRectProgram', mimeType='application/octet-stream')] 
        private static const SingleRectProgram:Class;
		[Embed(source='../../../../shader/DeltaXRectRenderer_GrayRectProgram', mimeType='application/octet-stream')] 
        private static const GrayRectProgram:Class;

        public static var FLUSH_COUNT:uint;
        private static var m_instance:DeltaXRectRenderer;

        private var m_viewPort:Rectangle;
        private var m_defaultTexture:DeltaXTexture;
        private var m_texture:DeltaXTexture;
        private var m_color:uint;
        private var m_addColor:Boolean;
        private var m_defaultRectShader:DeltaXProgram3D;
        private var m_rectShader:DeltaXProgram3D;
        private var m_rectInfoArray:Vector.<Number>;
        private var m_rectStartIndex:uint;
        private var m_rectMaxCount:uint;
        private var m_rectCurCount:uint;
        private var m_vertexBuffer:VertexBuffer3D;
        private var m_indexBuffer:IndexBuffer3D;
        private var m_grayEnable:Boolean;
        private var m_grayShader:DeltaXProgram3D;
        private var m_singleRectVertexBuffer:VertexBuffer3D;
        private var m_singleRectIndexBuffer:IndexBuffer3D;
        private var m_singleRectProgram:DeltaXProgram3D;

        public function DeltaXRectRenderer(_arg1:SingletonEnforcer){
            this.m_viewPort = new Rectangle();
            this.m_defaultTexture = DeltaXTextureManager.defaultTexture;
        }
        public static function get Instance():DeltaXRectRenderer{
            m_instance = ((m_instance) || (new DeltaXRectRenderer(new SingletonEnforcer())));
            return (m_instance);
        }

        private function getDefaultRectShader():DeltaXProgram3D{
            if (this.m_defaultRectShader){
                return (this.m_defaultRectShader);
            };
            this.m_defaultRectShader = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_RECT);
            return (this.m_defaultRectShader);
        }
        public function onLostDevice():void{
            if (this.m_vertexBuffer){
                this.m_vertexBuffer.dispose();
            };
            if (this.m_indexBuffer){
                this.m_indexBuffer.dispose();
            };
            if (this.m_singleRectVertexBuffer){
                this.m_singleRectVertexBuffer.dispose();
            };
            if (this.m_singleRectIndexBuffer){
                this.m_singleRectIndexBuffer.dispose();
            };
            this.m_vertexBuffer = null;
            this.m_indexBuffer = null;
            this.m_singleRectVertexBuffer = null;
            this.m_singleRectIndexBuffer = null;
            this.m_rectShader = null;
            this.m_grayShader = null;
            this.m_singleRectProgram = null;
            this.m_defaultRectShader = null;
        }
        public function setViewPort(_arg1:Number, _arg2:Number):void{
            this.m_viewPort.width = _arg1;
            this.m_viewPort.height = _arg2;
        }
        public function get viewPort():Rectangle{
            return (this.m_viewPort);
        }
		
		/**
		 * 矩形渲染，2D位图渲染.批量渲染
		 * @param	context3D		3d容器
		 * @param	x				x坐标
		 * @param	y				y坐标	
		 * @param	wndRect			矩形：渲染对象的x,y,宽，高
		 * @param	color			颜色包括透明度
		 * @param	texture			DeltaXTexture贴图
		 * @param	textureRect		矩形：需要渲染的贴图里面哪块内容
		 * @param	addColor		颜色添加,true:颜色贴图用0xffffffff,环境色用color。false:颜色贴图用color,环境色是0。
		 * @param	renderRect		矩形：渲染区域范围,类似于flash.display.DisplayObject：：scrollRect属性
		 * @param	isTranslate		渲染范围是否平移。false:renderRect有值则用renderRect。<br>
		 * 							true:则渲染区域renderRect.x加上x,renderRect.y加上y,renderRect.right加上x,renderRect.bottom加上y<br>
		 * 							渲染区域偏移
		 * @param	z				z坐标，默认
		 * @param	gray			是否灰度,true:灰度
		 */
        public function renderRect(context3D:Context3D,
								   x:Number, 
								   y:Number, 
								   wndRect:Rectangle, 
								   color:uint=0xffffffff, 
								   texture:DeltaXTexture=null,
								   textureRect:Rectangle=null,
								   addColor:Boolean=false,
								   renderRect:Rectangle=null,
								   isTranslate:Boolean=true,
								   z:Number=0.999999,
								   gray:Boolean=false):void{
            var _local14:TextureBase;
            var _local16:Number;
            var _local17:Number;
            var _local13:TextureBase = this.m_defaultTexture.getTextureForContext(context3D);
            if ((((texture == null)) || ((texture == this.m_defaultTexture)))){
				texture = this.m_defaultTexture;
				addColor = true;
                _local14 = _local13;
            } else {
                _local14 = texture.getTextureForContext(context3D);
                if (_local14 == _local13){
                    return;
                };
            };
            DeltaXFontRenderer.Instance.endFontRender(context3D);
            if ( texture != this.m_texture || color != this.m_color  || addColor != this.m_addColor || this.m_grayEnable != gray){
                this.flushAll(context3D);
                this.m_texture = texture;
                this.m_color = color;
                this.m_addColor = addColor;
                if (((!((this.m_grayEnable == gray))) || (!(this.m_rectShader)))){
                    this.m_grayEnable = gray;
                    if (!gray){
                        this.m_rectShader = this.getDefaultRectShader();
                    } else {
                        this.m_rectShader = this.getGrayRectProgram();
                    };
                    this.m_rectMaxCount = (this.m_rectShader.getVertexParamRegisterCount(DeltaXProgram3D.WORLD) / 3);
                    this.m_rectStartIndex = (this.m_rectShader.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4);
                    this.m_rectInfoArray = this.m_rectShader.getVertexParamCache();
                };
                _local16 = (1 / this.m_texture.width);
                _local17 = (1 / this.m_texture.height);
                this.m_rectShader.setParamColor(DeltaXProgram3D.DIFFUSEMATERIAL, (this.m_addColor) ? 0xffffffff : color);
                this.m_rectShader.setParamColor(DeltaXProgram3D.AMBIENTCOLOR, (this.m_addColor) ? color : 0);
                this.m_rectShader.setParamValue(DeltaXProgram3D.FACTOR, _local16, _local17, 765, 0.25);
                this.m_rectShader.setParamValue(DeltaXProgram3D.PROJECTION, (2 / this.m_viewPort.width), (-2 / this.m_viewPort.height), z, 1);
                this.m_rectShader.setSampleTexture(0, _local14);
				context3D.setProgram(this.m_rectShader.getProgram3D(context3D));
				context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				context3D.setCulling(Context3DTriangleFace.BACK);
				context3D.setDepthTest(true, Context3DCompareMode.ALWAYS);
            };
            if (this.m_rectCurCount >= this.m_rectMaxCount){
                this.flushAll(context3D);
                this.m_texture = texture;
            };
            var _local15:uint = ((this.m_rectCurCount * 12) + this.m_rectStartIndex);
            var _temp1:uint = _local15;
            _local15 = (_local15 + 1);
            var _local18:uint = _temp1;
            this.m_rectInfoArray[_local18] = (wndRect.x + x);
            var _temp2:uint = _local15;
            _local15 = (_local15 + 1);
            var _local19:uint = _temp2;
            this.m_rectInfoArray[_local19] = (wndRect.y + y);
            var _temp3:uint = _local15;
            _local15 = (_local15 + 1);
            var _local20:uint = _temp3;
            this.m_rectInfoArray[_local20] = wndRect.width;
            var _temp4 :uint= _local15;
            _local15 = (_local15 + 1);
            var _local21:uint = _temp4;
            this.m_rectInfoArray[_local21] = wndRect.height;
            if (renderRect == null){
                var _temp5:uint = _local15;
                _local15 = (_local15 + 1);
                var _local22:uint = _temp5;
                this.m_rectInfoArray[_local22] = this.m_viewPort.left;
                var _temp6:uint = _local15;
                _local15 = (_local15 + 1);
                var _local23:uint = _temp6;
                this.m_rectInfoArray[_local23] = this.m_viewPort.top;
                var _temp7:uint = _local15;
                _local15 = (_local15 + 1);
                var _local24:uint = _temp7;
                this.m_rectInfoArray[_local24] = this.m_viewPort.right;
                var _temp8:uint = _local15;
                _local15 = (_local15 + 1);
                var _local25:uint = _temp8;
                this.m_rectInfoArray[_local25] = this.m_viewPort.bottom;
            } else {
                if (isTranslate){
                    var _temp9:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local22 = _temp9;
                    this.m_rectInfoArray[_local22] = (renderRect.left + x);
                    var _temp10:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local23 = _temp10;
                    this.m_rectInfoArray[_local23] = (renderRect.top + y);
                    var _temp11:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local24 = _temp11;
                    this.m_rectInfoArray[_local24] = (renderRect.right + x);
                    var _temp12:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local25 = _temp12;
                    this.m_rectInfoArray[_local25] = (renderRect.bottom + y);
                } else {
                    var _temp13:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local22 = _temp13;
                    this.m_rectInfoArray[_local22] = renderRect.left;
                    var _temp14:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local23 = _temp14;
                    this.m_rectInfoArray[_local23] = renderRect.top;
                    var _temp15:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local24 = _temp15;
                    this.m_rectInfoArray[_local24] = renderRect.right;
                    var _temp16:uint = _local15;
                    _local15 = (_local15 + 1);
                    _local25 = _temp16;
                    this.m_rectInfoArray[_local25] = renderRect.bottom;
                };
            };
            if (textureRect){
                var _temp17:uint = _local15;
                _local15 = (_local15 + 1);
                _local22 = _temp17;
                this.m_rectInfoArray[_local22] = textureRect.x;
                var _temp18:uint = _local15;
                _local15 = (_local15 + 1);
                _local23 = _temp18;
                this.m_rectInfoArray[_local23] = textureRect.y;
                var _temp19:uint = _local15;
                _local15 = (_local15 + 1);
                _local24 = _temp19;
                this.m_rectInfoArray[_local24] = textureRect.width;
                this.m_rectInfoArray[_local15] = textureRect.height;
            } else {
                var _temp20:uint = _local15;
                _local15 = (_local15 + 1);
                _local22 = _temp20;
                this.m_rectInfoArray[_local22] = 0;
                var _temp21:uint = _local15;
                _local15 = (_local15 + 1);
                _local23 = _temp21;
                this.m_rectInfoArray[_local23] = 0;
                var _temp22:uint = _local15;
                _local15 = (_local15 + 1);
                _local24 = _temp22;
                this.m_rectInfoArray[_local24] = this.m_texture.width;
                this.m_rectInfoArray[_local15] = this.m_texture.height;
            };
            this.m_rectCurCount++;
        }
		
		/**
		 * 批量渲染-提交到GPU
		 * @param	context3D		3d容器
		 */
        public function flushAll(context3D:Context3D):void{
            if (this.m_rectCurCount == 0){
                this.m_texture = null;
                return;
            };
            FLUSH_COUNT++;
            if (!this.m_rectShader){
                this.m_defaultRectShader = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_RECT);
                this.m_rectShader = this.m_defaultRectShader;
                this.m_rectMaxCount = (this.m_rectShader.getVertexParamRegisterCount(DeltaXProgram3D.WORLD) / 3);
                this.m_rectStartIndex = (this.m_rectShader.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4);
                this.m_rectInfoArray = this.m_rectShader.getVertexParamCache();
                this.m_defaultTexture = DeltaXTextureManager.defaultTexture;
                this.m_rectShader.setSampleTexture(0, this.m_defaultTexture.getTextureForContext(context3D));
				context3D.setProgram(this.m_rectShader.getProgram3D(context3D));
            };
            this.m_rectShader.update(context3D);
            this.uploadRect(context3D);
            this.m_rectShader.deactivate(context3D);
            this.m_rectCurCount = 0;
            this.m_texture = null;
        }
		
		/**
		 * 批量渲染-定点，索引提交
		 * @param	context3D		3d容器
		 */
        private function uploadRect(context3D:Context3D):void{
            var _local2:uint;
            var _local3:uint;
            var _local4:ByteArray;
            if (this.m_vertexBuffer == null){
                this.m_vertexBuffer = context3D.createVertexBuffer((this.m_rectMaxCount * 4), 1);
                _local4 = new LittleEndianByteArray();
                _local2 = 0;
                _local3 = 0;
                while (_local2 < this.m_rectMaxCount) {
                    _local4.writeUnsignedInt((0xFF00 | _local3));
                    _local4.writeUnsignedInt((0 | _local3));
                    _local4.writeUnsignedInt((0xFFFF | _local3));
                    _local4.writeUnsignedInt((0xFF | _local3));
                    _local2++;
                    _local3 = (_local3 + 0x1000000);
                };
                this.m_vertexBuffer.uploadFromByteArray(_local4, 0, 0, (this.m_rectMaxCount * 4));
            };
            if (this.m_indexBuffer == null){
                this.m_indexBuffer = context3D.createIndexBuffer((this.m_rectMaxCount * 6));
                _local4 = new LittleEndianByteArray();
                _local2 = 0;
                while (_local2 < this.m_rectMaxCount) {
                    _local4.writeShort(((_local2 * 4) + 0));
                    _local4.writeShort(((_local2 * 4) + 1));
                    _local4.writeShort(((_local2 * 4) + 2));
                    _local4.writeShort(((_local2 * 4) + 2));
                    _local4.writeShort(((_local2 * 4) + 1));
                    _local4.writeShort(((_local2 * 4) + 3));
                    _local2++;
                };
                this.m_indexBuffer.uploadFromByteArray(_local4, 0, 0, (this.m_rectMaxCount * 6));
            };
            this.m_rectShader.setVertexBuffer(context3D, this.m_vertexBuffer);
			context3D.drawTriangles(this.m_indexBuffer, 0, (this.m_rectCurCount * 2));
        }
		
		/**
		 * 单个位图，矩形渲染
		 * @param	context3D		3d容器
		 * @param	rect
		 * @param	color			颜色
		 * @param	addColor		颜色添加。与renderRect方法的addColor一致
		 * @param	texture1		贴图1
		 * @param	texture2		贴图2
		 * @param	rect1
		 * @param	rect2
		 * @param	matrix3D
		 * @param	program3D
		 */
        public function renderSingleRect(context3D:Context3D, 
										 rect:Rectangle, 
										 color:uint=0xffffffff, 
										 addColor:Boolean=false, 
										 texture1:DeltaXTexture=null, 
										 texture2:DeltaXTexture=null, 
										 rect1:Rectangle=null, 
										 rect2:Rectangle=null, 
										 matrix3D:Matrix3D=null, 
										 program3D:DeltaXProgram3D=null):void{
            var ambientColor:uint;
            var materialColor:uint;
            var byArr:ByteArray;
            DeltaXFontRenderer.Instance.endFontRender(context3D);
            this.flushAll(context3D);
            if (!this.m_singleRectIndexBuffer){
                this.m_singleRectIndexBuffer = context3D.createIndexBuffer(6);
				byArr = new LittleEndianByteArray();
				byArr.writeShort(0);
				byArr.writeShort(3);
				byArr.writeShort(1);
				byArr.writeShort(3);
				byArr.writeShort(2);
				byArr.writeShort(1);
				//索引数据，两个三角形,矩形
                this.m_singleRectIndexBuffer.uploadFromByteArray(byArr, 0, 0, 6);
            };
            if (!this.m_singleRectVertexBuffer){
                this.m_singleRectVertexBuffer = context3D.createVertexBuffer(4, 2);
				byArr = new LittleEndianByteArray();
				byArr.writeFloat(0);
				byArr.writeFloat(0);
				byArr.writeFloat(1);
				byArr.writeFloat(0);
				byArr.writeFloat(2);
				byArr.writeFloat(0);
				byArr.writeFloat(3);
				byArr.writeFloat(0);
				//顶点数据，两组数据，没组4个。x,y,u,v
                this.m_singleRectVertexBuffer.uploadFromByteArray(byArr, 0, 0, 4);
            };
            if (!texture1){
				texture1 = DeltaXTextureManager.defaultTexture;
            };
            if (!texture2){
				texture2 = texture1;
            };
            if (!rect1){
				rect1 = new Rectangle(0, 0, texture1.width, texture1.height);
            };
            if (!rect2){
				rect2 = new Rectangle(0, 0, texture2.width, texture2.height);
            };
            if (!program3D){
				program3D = this.getSingleRectProgram();
            };
            if (addColor){
				ambientColor = color;
				materialColor = 0xffffffff;
            } else {
                ambientColor = 0;
				materialColor = color;
            };
            var _local13:Matrix3D = MathUtl.TEMP_MATRIX3D;
            var _local14:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
            var _local15:uint;
            while (_local15 < 15) {
                _local14[_local15] = 0;
                _local15++;
            };
            _local14[0] = (2 / this.m_viewPort.width);
            _local14[4] = 0;
            _local14[8] = -1;
            _local14[12] = 0;
            _local14[1] = 0;
            _local14[5] = (-2 / this.m_viewPort.height);
            _local14[9] = 1;
            _local14[13] = 0;
            _local14[10] = 0;
            _local14[15] = 1;
            _local13.copyRawDataFrom(_local14);
            if (matrix3D){
                _local13.prepend(matrix3D);
            };
            var _local16:Vector.<Number> = program3D.getVertexParamCache();
            this.setRectToParamCache(_local16, 0, rect);
            this.setRectToParamCache(_local16, 16, rect1);
            this.setRectToParamCache(_local16, 32, rect2);
			program3D.setParamColor(DeltaXProgram3D.DIFFUSEMATERIAL, materialColor);
			program3D.setParamColor(DeltaXProgram3D.AMBIENTCOLOR, ambientColor);
			program3D.setParamValue(DeltaXProgram3D.FACTOR, (1 / texture1.width), (1 / texture1.height), (1 / texture2.width), (1 / texture2.height));
			program3D.setParamMatrix(DeltaXProgram3D.WORLDVIEWPROJECTION, _local13, true);
			context3D.setProgram(program3D.getProgram3D(context3D));
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context3D.setCulling(Context3DTriangleFace.BACK);
			context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
			program3D.setSampleTexture(0, texture1.getTextureForContext(context3D));
			program3D.setSampleTexture(1, texture2.getTextureForContext(context3D));
			program3D.setVertexBuffer(context3D, this.m_singleRectVertexBuffer);
			program3D.update(context3D);
			context3D.drawTriangles(this.m_singleRectIndexBuffer, 0, 2);
			program3D.deactivate(context3D);
        }
        private function setRectToParamCache(nums:Vector.<Number>, value:uint, rect:Rectangle):void{
			
			//优化后
			nums[value] = rect.left;
			nums[value+1] = rect.top;
			nums[value+4] = rect.left;
			nums[value+5] = rect.bottom;
			nums[value+8] = rect.right;
			nums[value+9] = rect.bottom;
			nums[value+12] = rect.right;
			nums[value+13] = rect.top;
			/*
			var _temp1:uint = _arg2;
			_arg2 = (_arg2 + 1);//+1
			var _local4:uint = _temp1;//0
			_arg1[_arg2] = _arg3.left;
			var _temp2:uint = _arg2;//+1
			_arg2 = (_arg2 + 1);//+2
			var _local5:uint = _temp2;//+1
			_arg1[_arg2+1] = _arg3.top;
			_arg2 = (_arg2 + 2);//+4
			var _temp3:uint = _arg2;//+4
			_arg2 = (_arg2 + 1);//+5
			var _local6:uint = _temp3;//+4
			_arg1[_arg2+4] = _arg3.left;
			var _temp4:uint = _arg2;//+5
			_arg2 = (_arg2 + 1);//+6
			var _local7:uint = _temp4;
			_arg1[_arg2+5] = _arg3.bottom;
			_arg2 = (_arg2 + 2);//+8
			var _temp5:uint = _arg2;//+8
			_arg2 = (_arg2 + 1);//+9
			var _local8:uint = _temp5;//+8
			_arg1[_arg2+8] = _arg3.right;
			var _temp6:uint = _arg2;//+9
			_arg2 = (_arg2 + 1);//+10
			var _local9:uint = _temp6;//+9
			_arg1[_arg2+9] = _arg3.bottom;
			_arg2 = (_arg2 + 2);//+12
			var _temp7:uint = _arg2;//+12
			_arg2 = (_arg2 + 1);//+13
			var _local10:uint = _temp7;
			_arg1[_arg2+12] = _arg3.right;
			var _temp8:uint = _arg2;//+13
			_arg2 = (_arg2 + 1);//+14
			var _local11:uint = _temp8;
			_arg1[_arg2+13] = _arg3.top;
			_arg2 = (_arg2 + 2);
			*/
			/*
			//默认的。
            var _temp1:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local4:uint = _temp1;
            _arg1[_local4] = _arg3.left;
            var _temp2:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local5:uint = _temp2;
            _arg1[_local5] = _arg3.top;
            _arg2 = (_arg2 + 2);
            var _temp3:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local6:uint = _temp3;
            _arg1[_local6] = _arg3.left;
            var _temp4:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local7:uint = _temp4;
            _arg1[_local7] = _arg3.bottom;
            _arg2 = (_arg2 + 2);
            var _temp5:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local8:uint = _temp5;
            _arg1[_local8] = _arg3.right;
            var _temp6:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local9:uint = _temp6;
            _arg1[_local9] = _arg3.bottom;
            _arg2 = (_arg2 + 2);
            var _temp7:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local10:uint = _temp7;
            _arg1[_local10] = _arg3.right;
            var _temp8:uint = _arg2;
            _arg2 = (_arg2 + 1);
            var _local11:uint = _temp8;
            _arg1[_local11] = _arg3.top;
            _arg2 = (_arg2 + 2);
			*/
        }
        public function getSingleRectProgram():DeltaXProgram3D{
            if (!this.m_singleRectProgram){
                this.m_singleRectProgram = this.getEmbedRectProgram(SingleRectProgram);
            };
            return (this.m_singleRectProgram);
        }
        public function getGrayRectProgram():DeltaXProgram3D{
            if (!this.m_grayShader){
                this.m_grayShader = this.getEmbedRectProgram(GrayRectProgram);
            };
            return (this.m_grayShader);
        }
        private function getEmbedRectProgram(_arg1:Class):DeltaXProgram3D{
            var _local2:uint = ShaderManager.instance.createDeltaXProgram3D((new _arg1() as ByteArray));
            return (ShaderManager.instance.getProgram3D(_local2));
        }

    }
}//package deltax.graphic.render2D.rect 

class SingletonEnforcer {

    public function SingletonEnforcer(){
    }
}
