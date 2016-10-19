//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.manager {
    import deltax.gui.component.*;
    import deltax.gui.base.*;
    import flash.utils.*;
	/**
	 * gui组件类管理 
	 * @author Administrator
	 * 
	 */	
    public final class WindowClassManager {

        private static var COMPONENT_CLASSES:Dictionary;
		
		/**
		 * 通过 WindowClassName获取class
		 * @param className		类名
		 * @return 	Class
		 * 
		 */		
        public static function getComponentClassByName(className:String):Class{
            if (!COMPONENT_CLASSES){
                COMPONENT_CLASSES = new Dictionary();
                COMPONENT_CLASSES[WindowClassName.NORMAL_WND] = DeltaXWindow;
                COMPONENT_CLASSES[WindowClassName.BUTTON] = DeltaXButton;
                COMPONENT_CLASSES[WindowClassName.CHECK_BUTTON] = DeltaXCheckBox;
                COMPONENT_CLASSES[WindowClassName.COMBOBOX] = DeltaXComboBox;
                COMPONENT_CLASSES[WindowClassName.EDIT] = DeltaXEdit;
                COMPONENT_CLASSES[WindowClassName.TABLE] = DeltaXTable;
                COMPONENT_CLASSES[WindowClassName.MESSAGE_BOX] = DeltaXMessageBox;
                COMPONENT_CLASSES[WindowClassName.PROGRESS_BAR] = DeltaXProgressBar;
                COMPONENT_CLASSES[WindowClassName.RICH_TEXTAREA] = DeltaXRichWnd;
                COMPONENT_CLASSES[WindowClassName.SCROLL_BAR] = DeltaXScrollBar;
                COMPONENT_CLASSES[WindowClassName.TREE] = DeltaXTree;
				COMPONENT_CLASSES[WindowClassName.ITEM_TABLE] = DeltaXTable;
            }
            return (COMPONENT_CLASSES[className]);
        }
		
		/**
		 * 通过实例对象获取对应的GUI组件名 
		 * @param instanceObj		实例对象
		 * @return Class类名
		 * 
		 */		
        public static function getComponentClassName(instanceObj:Object):String{
            var _local2:*;
            for (_local2 in COMPONENT_CLASSES) {
                if ((instanceObj is COMPONENT_CLASSES[_local2])){
                    return (_local2);
                };
            };
            return ("");
        }
		
		/**
		 * 通过Class获取对应的GUI组件类名 
		 * @param value		CLASS
		 * @return 类名
		 * 
		 */		
        public static function getClassName(value:Class):String{
            var _local2:*;
            for (_local2 in COMPONENT_CLASSES) {
                if (value == COMPONENT_CLASSES[_local2]){
                    return (_local2);
                };
            };
            return ("");
        }

    }
}//package deltax.gui.manager 
