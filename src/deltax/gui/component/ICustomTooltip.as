//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {

    public interface ICustomTooltip {
		
		/**
		 * 设置数据 ,返回ture则显示tips
		 * @param targetGui		侦听的目标gui
		 * @param param			注册的参数
		 * @return 
		 * 
		 */		
        function prepareContent(targetGui:DeltaXWindow, param:Object=null):Boolean;
		
		/**
		 * tips坐标设置。意义不大 
		 * @param targetGui
		 * @param param
		 * 
		 */		
        function postCalcPosition(targetGui:DeltaXWindow, param:Object=null):void;

    }
}//package deltax.gui.component 
