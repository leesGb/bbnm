package deltax.gui.base.style 
{
	/**
	 * DeltaXWindow基础样式 
	 * @author Administrator
	 * 
	 */	
    public final class WindowStyle 
	{
		/**能否拖动*/	
        public static const MODAL:uint =   																	0x80000000;
		/**能否接受鼠标事件*/
		public static const CHILD:uint =     																	0x40000000;
		/**鼠标经过检测等，是否把所有子对象加进去计算 */
		public static const MSG_TRANSPARENT:uint = 												0x20000000;
		/**使用矩形遮罩*/
		public static const USER_CLIP_RECT:uint = 														0x10000000;
		/**文本底对齐*/	
		public static const TEXT_VERTICAL_ALIGN_BOTTOM:uint = 							0x8000000;
		/**文本垂直居中对齐*/
		public static const TEXT_VERTICAL_ALIGN_CENTER:uint = 								0x4000000;
		/**文本右对齐*/
		public static const TEXT_HORIZON_ALIGN_RIGHT:uint = 								0x2000000;
		/**文本水平居中*/
		public static const TEXT_HORIZON_ALIGN_CENTER:uint = 								0x1000000;
		/**垂直，水平居中*/
		public static const TEXT_ALIGN_STYLE_MASK:uint = (TEXT_VERTICAL_ALIGN_BOTTOM | TEXT_VERTICAL_ALIGN_CENTER | TEXT_HORIZON_ALIGN_RIGHT | TEXT_HORIZON_ALIGN_CENTER);
		/**组件显示深度，在最上*/
		public static const TOP_MOST:uint = 																0x800000;
		/**鼠标滚轮事件*/
		public static const NO_MOUSEWHEEL:uint = 													0x400000;
		/**是否用父容器遮罩*/
		public static const CLIP_BY_PARENT:uint = 														0x200000;
		/**子对象能否派发事件*/
		public static const REQUIRE_CHILD_NOTIFY:uint = 											0x100000;
		/**文本阴影 */
		public static const FONT_SHADOW:uint = 														0x80000;
		/**tips是否跟随鼠标*/
		public static const TOOLTIP_FOLLOW_CURSOR:uint = 									0x40000;
		/**鼠标开启像素检测*/
		public static const MOUSE_CHECK_ON_PIXEL:uint = 										0x20000;
		/**焦点最上层*/
		public static const FOCUS_TOP:uint =																0x10000;
		
			
    }
}
