//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base.style {
	/**
	 * DeltaXEdit样式
	 * @author Administrator
	 * 
	 */	
    public final class EditBoxStyle {
		
		/**
		 * 能否换行 
		 */		
        public static const MULTI_LINE:uint = 1;
		
		/**
		 * 是否作为密码
		 */		
        public static const PASSWORD:uint = 2;
		
		/**
		 * 能否复制，粘帖，剪切 
		 */		
        public static const ENABLE_CLIPBOARD:uint = 4;
		
		/**
		 * 能否输入 
		 */		
        public static const DISABLE_IME:uint = 8;
		
		/**
		 * 是否只能数字输入,包括小数
		 */		
        public static const DIGIT_ONLY:uint = 0x1000;
		
		/**
		 * 是否只读
		 */		
        public static const READ_ONLY:uint = 0x2000;
		
        public static const HORIZON_SCROLLBAR:uint = 0x4000;
        public static const VERTICAL_SCROLLBAR:uint = 0x8000;

    }
}//package deltax.gui.base.style 
