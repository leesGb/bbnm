//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base.style {
	
	/**
	 * 列表样式
	 * @author Administrator
	 * 
	 */	
    public final class ListStyle {

        public static const SMOOTH_SCROLL:uint = 2;
        public static const AUTO_SHOW_SCROLL:uint = 4;
        public static const MULTI_SELECTION:uint = 8;
        public static const CLICK_TO_SELECT:uint = 16;
        public static const FULL_ROW_SELECT:uint = 32;
        public static const SHOW_GRID:uint = 64;
		
		/**
		 * 是否有水平滚动条样式。勾选：有
		 */		
        public static const HORIZON_SCROLLBAR:uint = 0x4000;
		
		/**
		 * 是否有垂直滚动条样式。勾选：有
		 */		
        public static const VERTICAL_SCROLLBAR:uint = 0x8000;

    }
}//package deltax.gui.base.style 
