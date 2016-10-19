//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.util {
    import flash.display3D.*;
    import deltax.common.*;
    import deltax.gui.component.*;
    import flash.geom.*;
    import deltax.gui.base.*;
    import deltax.gui.manager.*;
    import deltax.graphic.util.*;

    public class Icon {

        private var m_images:ImageList;

        public function Icon(){
            this.m_images = new ImageList();
            super();
            this.m_images.addImage(0, "", null, IconManager.DEFAULT_ICON_RECT, Color.WHITE);
        }
        public function get imageList():ImageList{
            return (this.m_images);
        }
        public function release():void{
            this.m_images.clear();
            this.m_images.addImage(0, "", null, IconManager.DEFAULT_ICON_RECT, Color.WHITE);
        }
        public function insertSelfImageToOther(_arg1:uint, _arg2:ImageList):void{
            _arg1 = _arg2.addImage(_arg1, "", null, IconManager.DEFAULT_ICON_RECT, Color.WHITE);
            this.replaceSelfImageToOther(_arg1, _arg2);
        }
        public function replaceSelfImageToOther(_arg1:uint, _arg2:ImageList):void{
            var _local3:DisplayImageInfo = _arg2.getImage(0);
            safeRelease(_local3.texture);
            _local3.copyFrom(this.m_images.getImage(0));
            if (_local3.texture){
                _local3.texture.reference();
            };
        }
        public function drawTo(context3D:Context3D, _arg2:DeltaXWindow, renderRect:Rectangle=null, renderIndex:int=-1, gray:Boolean=false):void{
            _arg2.renderImageList(context3D , this.m_images, renderRect , renderIndex , 1, gray);
        }

    }
}//package deltax.gui.util 
