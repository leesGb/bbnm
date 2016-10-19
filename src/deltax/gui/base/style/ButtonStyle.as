//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base.style {
	/**
	 * 按钮样式 
	 * @author Administrator
	 * 
	 */	
    public final class ButtonStyle {
		
		/**
		 * 鼠标按下，文本偏移 x
		 */		
        public static const TEXT_OFFSET_X:uint = 0xF000;
		
		/**
		 * 鼠标按下，文本偏移 y
		 */		
        public static const TEXT_OFFSET_Y:uint = 0x0F00;
		
		/**
		 * 鼠标按下时，获取文本x偏移值 
		 * @param style		样式值
		 * @return 偏移大小
		 * 
		 */		
        public static function offsetXFromStyle(style:uint):uint{
            return (((style & TEXT_OFFSET_X) >>> 12));
        }
		
		/**
		 * 鼠标按下时，获取文本y偏移值 
		 * @param style		样式值
		 * @return 偏移大小
		 * 
		 */	
        public static function offsetYFromStyle(style:uint):uint{
            return (((style & TEXT_OFFSET_Y) >>> 8));
        }

    }
}//package deltax.gui.base.style 
