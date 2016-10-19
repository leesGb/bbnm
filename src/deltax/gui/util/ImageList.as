//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.util {
    import flash.display3D.Context3D;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    
    import __AS3__.vec.Vector;
    
    import deltax.common.Util;
    import deltax.common.safeRelease;
    import deltax.common.math.MathUtl;
    import deltax.common.math.Vector2D;
    import deltax.common.resource.Enviroment;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;
    import deltax.gui.base.DisplayImageInfo;
    import deltax.gui.base.ImageDrawFlag;
    import deltax.gui.base.style.LockFlag;
	
	/**
	 * 位图列表<br>
	 * 位图渲染，3、9宫格渲染<br>
	 * @author admin
	 *
	 */
    public class ImageList {

        private static var TEMP_RECTANGLE:Rectangle = new Rectangle();
		
		/** 静态共用变量。当位图宽高拉伸，需要用到此变量 */
        private static var m_staticImageInfoForDraw:DisplayImageInfo = new DisplayImageInfo();
        private static var m_finalDrawRect:Rectangle;
        private static var m_drawMatrix:Matrix = new Matrix();
		
		/** 当前位图有几个小图块组成（3、9宫格需要用到） */
        private var m_imageInfos:Vector.<DisplayImageInfo>;

        public function ImageList(_arg1:ImageList=null){
            this.m_imageInfos = new Vector.<DisplayImageInfo>();
            super();
            if (_arg1){
                this.copyFrom(_arg1);
            };
        }
		
		/**
		 * 清理位图，并移除引用
		 */
        public function clear():void{
            var i:uint;
            while (i < this.m_imageInfos.length) {
                safeRelease(this.m_imageInfos[i].texture);
                i++;
            };
            this.m_imageInfos.length = 0;
        }
		
		/**
		 * 加载解析二进制位图数据
		 * @param	value	二进制数据
		 */
        public function load(value:ByteArray):void{
            var imgCount:uint = value.readUnsignedInt();
            this.m_imageInfos = new Vector.<DisplayImageInfo>(imgCount);
            var i:uint;
            while (i < imgCount) {
                this.m_imageInfos[i] = new DisplayImageInfo();
                this.m_imageInfos[i].load(value);
                i++;
            };
        }
		
		/**
		 * 将位图数据写入到ByteArray
		 * @param	data	需要写到的二进制
		 */
		public function write(data:ByteArray):void{
			data.writeUnsignedInt(this.m_imageInfos.length);
			var i:uint = 0;
			while (i < this.m_imageInfos.length) {
				this.m_imageInfos[i].write(data);
				i++;
			}
		}
		
		/**
		 * 添加位图到列表
		 * @param	index			位图索引
		 * @param	imgName			位图名
		 * @param	textureRect		位图所在贴图的位置,如果为null：则是整个贴图大小范围
		 * @param	wndRect			位图宽高坐标
		 * @param	color			颜色
		 * @param	lockFlag		状态，3，9宫格拉伸需要用到
		 * @param	drawFlag		状态，3，9宫格拉伸需要用到
		 * @return	返回位图所在列表的索引
		 */
        public function addImage(index:uint, imgName:String, textureRect:Rectangle, wndRect:Rectangle, color:uint, lockFlag:uint=0, drawFlag:uint=0):uint{
            var imgInfo:DisplayImageInfo = new DisplayImageInfo();
            if (((imgName) && ((imgName.length > 0)))){
				imgName = (Enviroment.ResourceRootPath + Util.convertOldTextureFileName(imgName, false));
            };
			imgInfo.texture = DeltaXTextureManager.instance.createTexture(imgName);
            if (textureRect){
				imgInfo.textureRect.copyFrom(textureRect);
            } else {
                if (imgInfo.texture && imgInfo.texture.isLoaded){
					imgInfo.textureRect.x = 0;
					imgInfo.textureRect.y = 0;
					imgInfo.textureRect.width = imgInfo.texture.width;
					imgInfo.textureRect.height = imgInfo.texture.height;
                };
            };
			imgInfo.wndRect.copyFrom(wndRect);
			imgInfo.color = color;
			imgInfo.lockFlag = lockFlag;
			imgInfo.drawFlag = drawFlag;
			imgInfo.texDivideWnd = new Vector2D();
            if (Math.abs(imgInfo.wndRect.width) > 0.0001){
				imgInfo.texDivideWnd.x = (imgInfo.textureRect.width / imgInfo.wndRect.width);
            };
            if (Math.abs(imgInfo.wndRect.height) > 0.0001){
				imgInfo.texDivideWnd.y = (imgInfo.textureRect.height / imgInfo.wndRect.height);
            };
			index = Math.min(uint(index), this.m_imageInfos.length);
            this.m_imageInfos.splice(index, 0, imgInfo);
            return index;
        }
		
		/**
		 * 添加位图列表到当前列表
		 * @param	imgList			位图列表
		 * @param	startIndex		开始索引。imgList的开始索引
		 * @param	endIndex		结束索引。imgList的结束索引
		 * @return	返回当前位图列表的长度
		 */
        public function addImageFromImageList(imgList:ImageList, startIndex:int, endIndex:int):int{
            if (this == imgList){
                return -1;
            };
			endIndex = Math.min(uint(endIndex), imgList.m_imageInfos.length);
			startIndex = MathUtl.max(startIndex, 0);
            var i:uint = startIndex;
            while (i < endIndex) {
                this.m_imageInfos.push(imgList.m_imageInfos[i]);
                if (imgList.m_imageInfos[i].texture){
					imgList.m_imageInfos[i].texture.reference();
                };
                i++;
            };
            return this.m_imageInfos.length;
        }
		
		/**
		 * 获取位图长度
		 */
        public function get imageCount():uint{
            return this.m_imageInfos.length;
        }
		
		/**
		 * 删除一张位图
		 * @param	index	删除的索引
		 */
        public function deleteImage(index:uint):void{
            if (index >= this.m_imageInfos.length){
                return;
            };
            safeRelease(this.m_imageInfos[index].texture);
            this.m_imageInfos.splice(index, 1);
        }
		
		/**
		 * 获取位图数据
		 * @param	index	位图索引
		 * @return	DisplayImageInfo
		 */
        public function getImage(index:uint):DisplayImageInfo{
            if (index >= this.m_imageInfos.length){
                throw (new Error(("invalid image index in imageList! " + index)));
            };
            return this.m_imageInfos[index];
        }
		
		/**
		 * 设置所有位图颜色
		 * @param	color	颜色值
		 */
        public function setAllImageColor(color:uint):void{
            var i:uint =0;
			var len:int = this.m_imageInfos.length;
            while (i < len) {
                this.m_imageInfos[i].color = color;
                i++;
            };
        }
		
		/**
		 * 删除一张包含点的位图
		 * @param	value	点
		 * @return	返回索引。-1没有删除
		 */
        public function detectCursorInImage(value:Point):int{
            var i:uint;
            while (i < this.m_imageInfos.length) {
                if (this.m_imageInfos[i].wndRect.containsPoint(value)){
                    return (i);
                };
                i++;
            };
            return -1;
        }
		
		/**
		 * 位图拉伸
		 * @param	imgInfo		位图数据
		 * @param	width		拉伸的宽差值（当前宽-贴图宽）
		 * @param	height		拉伸的高差值（当前高-贴图高）
		 */
        private function scaleImage(imgInfo:DisplayImageInfo, width:int, height:int):void{
            var _local6:Number;
            imgInfo.texDivideWnd = ((imgInfo.texDivideWnd) || (new Vector2D()));
            var _local4:Vector2D = imgInfo.texDivideWnd;
            var _local5:Rectangle = TEMP_RECTANGLE;
            _local5.copyFrom(imgInfo.wndRect);
            if (Math.abs(_local5.width) > 0.0001){
                _local4.x = (imgInfo.textureRect.width / _local5.width);
            };
            if (Math.abs(_local5.height) > 0.0001){
                _local4.y = (imgInfo.textureRect.height / _local5.height);
            };
            if (width != 0){
                if ((imgInfo.lockFlag & LockFlag.RIGHT)){
                    imgInfo.wndRect.right = (imgInfo.wndRect.right + width);
                    if ((imgInfo.lockFlag & LockFlag.LEFT) == 0){
                        imgInfo.wndRect.left = (imgInfo.wndRect.left + width);
                    };
                } else {
                    if ((imgInfo.lockFlag & LockFlag.LEFT) == 0){
                        imgInfo.wndRect.left = (imgInfo.wndRect.left + (width / 2));
                        imgInfo.wndRect.right = (imgInfo.wndRect.right + (width / 2));
                    };
                };
            };
            if (height != 0){
                if ((imgInfo.lockFlag & LockFlag.BOTTOM)){
                    imgInfo.wndRect.bottom = (imgInfo.wndRect.bottom + height);
                    if ((imgInfo.lockFlag & LockFlag.TOP) == 0){
                        imgInfo.wndRect.top = (imgInfo.wndRect.top + height);
                    };
                } else {
                    if ((imgInfo.lockFlag & LockFlag.TOP) == 0){
                        imgInfo.wndRect.top = (imgInfo.wndRect.top + (height / 2));
                        imgInfo.wndRect.bottom = (imgInfo.wndRect.bottom + (height / 2));
                    };
                };
            };
            if (!Util.hasFlag(imgInfo.drawFlag, ImageDrawFlag.ZOOM_WHILE_SCALE)){
                if (_local5.width != imgInfo.wndRect.width){
                    _local6 = ((imgInfo.wndRect.width - _local5.width) * _local4.x);
                    if (Util.hasFlag(imgInfo.drawFlag, ImageDrawFlag.TILE_HORIZON)){
                        imgInfo.textureRect.left = (imgInfo.textureRect.left - _local6);
                    } else {
                        imgInfo.textureRect.right = (imgInfo.textureRect.right + _local6);
                    };
                };
                if (_local5.height != imgInfo.wndRect.height){
                    _local6 = ((imgInfo.wndRect.height - _local5.height) * _local4.y);
                    if (Util.hasFlag(imgInfo.drawFlag, ImageDrawFlag.TILE_VERTICAL)){
                        imgInfo.textureRect.top = (imgInfo.textureRect.top - _local6);
                    } else {
                        imgInfo.textureRect.bottom = (imgInfo.textureRect.bottom + _local6);
                    };
                };
            };
        }
		
		/**
		 * 位图列表拉伸
		 * @param	width		拉伸的宽差值（当前宽-贴图宽）
		 * @param	height		拉伸的高差值（当前高-贴图高）
		 */
        public function scaleAll(width:int, _arg2:int):void{
            var len:uint = this.m_imageInfos.length;
            var i:uint;
            while (i < len) {
                this.scaleImage(this.m_imageInfos[i], width, _arg2);
                i++;
            };
        }
		
		/**
		 * 渲染位图
		 * @param	context3D		3d容器
		 * @param	x				x坐标
		 * @param	y				y坐标	
		 * @param	z				z坐标，默认
		 * @param	scaleWidth		拉伸的宽
		 * @param	scaleHeight		拉伸的高
		 * @param	renderRect		矩形：渲染区域范围,类似于flash.display.DisplayObject：：scrollRect属性
		 * @param	isTranslate		渲染范围是否平移。false:renderRect有值则用renderRect。<br>
		 * @param	renderIndex		渲染位图索引。-1或者大于当前位图数量。则渲染所有
		 * @param	alpha			透明度
		 * @param	gray			是否灰度,true:灰度
		 */
        public function drawTo(context3D:Context3D, 
							   x:Number, 
							   y:Number, 
							   z:Number, 
							   scaleWidth:Number, 
							   scaleHeight:Number, 
							   renderRect:Rectangle=null, 
							   isTranslate:Boolean=true, 
							   renderIndex:int=-1, 
							   alpha:Number=1, 
							   gray:Boolean=false):void{
            var i:uint;
            var len:uint = this.m_imageInfos.length;
            if (renderIndex == -1 || renderIndex >= len){
                i = 0;
                while (i < len) {
                    this.drawSingleImage(context3D, i, x, y, z, scaleWidth, scaleHeight, renderRect, isTranslate, alpha, gray);
                    i++;
                };
            } else {
                this.drawSingleImage(context3D, renderIndex, x, y, z, scaleWidth, scaleHeight, renderRect, isTranslate, alpha, gray);
            };
        }
		
        private function drawSingleImage(context3D:Context3D, 
										 renderIndex:uint, 
										 x:Number, 
										 y:Number, 
										 z:Number, 
										 scaleWidth:int, 
										 scaleHeight:int, 
										 renderRect:Rectangle=null, 
										 isTranslate:Boolean=true, 
										 alpha:Number=1, 
										 gray:Boolean=false):void{
            var t_alpha:uint;
            if (renderIndex >= this.m_imageInfos.length){
                return;
            };
            var imgInfo:DisplayImageInfo = this.m_imageInfos[renderIndex];
            var addColor:Boolean = !(((imgInfo.drawFlag & ImageDrawFlag.ADD_TEXTURE_COLOR) == 0));
            if ((((addColor == false)) && (((imgInfo.color & 0xff000000) == 0)))){
                return;
            };
            if (scaleWidth != 0 || scaleHeight != 0){
                m_staticImageInfoForDraw.copyFrom(this.m_imageInfos[renderIndex]);
                this.scaleImage(m_staticImageInfoForDraw, scaleWidth, scaleHeight);
                imgInfo = m_staticImageInfoForDraw;
            } else {
                imgInfo = this.m_imageInfos[renderIndex];
            };
            var color:uint = imgInfo.color;
            if (alpha < 0.99){
				t_alpha = ((color >>> 24) * alpha);
				color = ((color & 0xFFFFFF) | (t_alpha << 24));
            };
            DeltaXRectRenderer.Instance.renderRect(context3D, x, y, imgInfo.wndRect, color, imgInfo.texture, imgInfo.textureRect, addColor, renderRect, isTranslate, z, gray);
        }
		
		/**
		 * 获取位图列表
		 */
        public function get imageInfos():Vector.<DisplayImageInfo>{
            return (this.m_imageInfos);
        }
		
		/**
		 * 从value里面复制位图数据到当前列表
		 * @param	value	位图列表
		 */
        public function copyFrom(value:ImageList):void{
            if (this == value){
                return;
            };
            this.clear();
            this.m_imageInfos.length = value.imageCount;
            var i:uint;
            while (i < this.m_imageInfos.length) {
                if (!this.m_imageInfos[i]){
                    this.m_imageInfos[i] = new DisplayImageInfo();
                };
                this.m_imageInfos[i].copyFrom(value.m_imageInfos[i]);
                if (this.m_imageInfos[i].texture){
                    this.m_imageInfos[i].texture.reference();
                };
                i++;
            };
        }
		
		/**
		 * 获取位图列表整体范围
		 * @return Rectangle
		 */
        public function get bounds():Rectangle{
            var i:uint = 0;
            var len:uint = this.imageCount;
            if (len == 0){
                return null;
            };
            if (len == 1){
                return this.getImage(i).wndRect.clone();
            };
            var rect:Rectangle = this.getImage(0).wndRect;
            i = 1;
            while (i < this.imageCount) {
				rect = rect.union(this.getImage(i).wndRect);
                i++;
            };
            return rect;
        }
		
		/**
		 * 整体位图偏移
		 * @param	offsetX		偏移x
		 * @param	offsetY		偏移y
		 */
        public function offset(offsetX:Number, offsetY:Number):void{
            var i:uint;
            while (i < this.imageCount) {
                this.getImage(i).wndRect.offset(offsetX, offsetY);
                i++;
            };
        }

    }
}//package deltax.gui.util 
