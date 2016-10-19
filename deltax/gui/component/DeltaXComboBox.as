//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;
	
	/**
	 * 下拉列表<br>
	 * 列表选中事件：TableSelectionEvent.SELECTION_CHANGED
	 * @author admin
	 */
    public class DeltaXComboBox extends DeltaXEdit {

        private var m_dropList:DeltaXTable;
        private var m_dropDownButton:DeltaXButton;
		
		/**
		 * @get
		 * 获取下拉按钮
		 */
		public function get dropDownButton():DeltaXButton
		{
			return m_dropDownButton;
		}		
		
		/**
		 * 获取弹出列表DeltaXTable
		 */
        public function getPopupList():DeltaXTable{
            return (this.m_dropList);
        }
		
		/**
		 * 获取编辑文本
		 */
        public function getEditor():DeltaXEdit{
            return (this);
        }
        override protected function onActive(value:Boolean):void{
            if (!value){
                this.m_dropList.visible = false;
            };
            super.onActive(value);
        }
        override protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
        override protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            return (null);
        }
		
		/**
		 * 初始化组件
		 */
        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
			
			//下拉按钮创建
            var items:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            items[0] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.DROP_BUTTON);
            this.m_dropDownButton = new DeltaXButton();
            this.m_dropDownButton.createFromDispItemInfo("", items, WindowStyle.CHILD, this);
			
			//弹出列表样式
            items[0] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_BACKGROUND);
            items[1] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR);
            items[2] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_DOWN_BTN);
            items[3] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_UP_BTN);
            items[4] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_THUMB);
            items[5] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR);
            items[6] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_DOWN_BTN);
            items[7] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_UP_BTN);
            items[8] = m_properties.getSubCtrlInfo(ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_THUMB);
            var t_x:Number = items[0].rect.x;
            var t_y:Number = items[0].rect.y;
            var i:uint;
            while (i <= 8) {
                items[i].rect.offset(-(t_x), -(t_y));
                i++;
            };
            this.m_dropList = new DeltaXTable();
            var t_style:uint = WindowStyle.CHILD;
            if ((style & ComboBoxStyle.VERTICAL_SCROLLBAR)){
                t_style = (t_style | ListStyle.VERTICAL_SCROLLBAR);
            };
            this.m_dropList.createFromDispItemInfo("", items, t_style, this);
            this.m_dropList.properties.xBorder = this.xBorder;
            this.m_dropList.properties.yBorder = this.yBorder;
            this.m_dropList.setLocation(t_x, t_y);
            this.m_dropList.visible = false;
            this.m_dropDownButton.addEventListener(DXWndMouseEvent.MOUSE_DOWN, this._dropButtonPress);
            this.m_dropList.addEventListener(TableSelectionEvent.SELECTION_CHANGED, this._selectChanged);			
        }
        protected function _dropButtonPress(_arg1:DXWndMouseEvent):void{
            this.m_dropList.visible = !(this.m_dropList.visible);
        }
		
		/**
		 * 下拉列表选中<br>
		 * 派发TableSelectionEvent.SELECTION_CHANGED事件 
		 * @param event
		 */		
        protected function _selectChanged(event:TableSelectionEvent):void{
            event.stopPropagation();
            this.m_dropList.visible = false;
            setText(this.m_dropList.getSubItem(event.getRowIndex(), event.getColIndex()).getText());
            dispatchEvent(new TableSelectionEvent(TableSelectionEvent.SELECTION_CHANGED, event.getRowIndex(), 0));
        }
        public function insertStringFromRes(_arg1:Object, _arg2:int, _arg3:String, _arg4:Class, _arg5:Function=null, _arg6:*=null):int{
            var onInsertItem:* = null;
            var object:* = _arg1;
            var index:* = _arg2;
            var guiResName:* = _arg3;
            var itemGUIClass:* = _arg4;
            var onItemCreated:Function = _arg5;
            var createContext:* = _arg6;
            onInsertItem = function (_arg1:DeltaXTable, _arg2:int, _arg3:int):void{
                var _local4:DeltaXWindow = _arg1.getSubItem(_arg2, _arg3);
                if ((object is String)){
                    _local4.setText(String(object));
                } else {
                    _local4.setUserObject(object);
                    _local4.setText(object.toString());
                };
                if (onItemCreated != null){
                    onItemCreated(this, _arg2);
                };
            };
            index = this.m_dropList.insertRowItemsFromRes(index, guiResName, itemGUIClass, onInsertItem, createContext);
            return (index);
        }
		
		/**
		 * 插入数据到下拉list中
		 * @param value			数据，文本
		 * @param index			索引，小于0则插入到最后
		 * @param cellHeigth	cell高
		 * @return 返回插入的索引
		 * 
		 */		
        public function insertString(value:Object, index:int=-1, cellHeigth:int=20):int{
            var _local4:int = this.m_dropList.getSelectedRow();
            index = this.m_dropList.insertRowItems(index, cellHeigth);
            var _local5:DeltaXWindow = this.m_dropList.getSubItem(index, 0);
            if ((value is String)){
                _local5.setText(String(value));
            } else {
                _local5.setUserObject(value);
                _local5.setText(value.toString());
            };
            return (index);
        }
		
		/**
		 * 获取选中的索引
		 */	
        public function getSelectedIndex():int{
            return (this.m_dropList.getSelectedRow());
        }
		
		/**
		 * 设置下拉list选中索引
		 */	
        public function setSelectedIndex(index:int):void{
            this.m_dropList.selectItem(index, 0);
        }
		
		/**
		 * 获取选中下拉列表里的cell
		 */	
        public function getSelectedItem():DeltaXWindow{
            return (this.m_dropList.getSubItem(this.getSelectedIndex(), 0));
        }
		
		/**
		 * 获取选中下拉列表里的cell.getUserObject()里的数据
		 */	
        public function getSelectedItemData():Object{
            var cell:DeltaXWindow = this.getSelectedItem();
            return cell ? cell.getUserObject() : null;
        }
		
		/**
		 * 移除list所有，设置文本空
		 */	
        public function removeAllItems():void{
            this.m_dropList.removeAllRows();
            setText("");
        }
		
		/**
		 * 设置宽高
		 */	
		public function adjustWH(w:int, h:int=-1):void
		{						
			m_dropDownButton.x = w - m_dropDownButton.width - 2;
			if(h==-1){
				h = m_dropList.height+60; 
			}else{
				h = h+60;
			}
			m_dropList.setSize(w, h);
			m_dropList.setColumnWidth(0, w);
			this.width = w;
		}

    }
}//package deltax.gui.component 
