//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import deltax.gui.component.event.*;
    import deltax.gui.util.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.gui.base.*;
    import deltax.gui.base.style.*;
    import deltax.gui.component.subctrl.*;
	
	/**
	 * 列表,表格。可多行多列<br>
	 * @author admin
	 */
    public class DeltaXTable extends DeltaXScrollPane {

        public static const DEFAULT_ROW_HEIGHT:uint = 20;
        public static const DEFAULT_COLUMN_WIDTH:uint = 20;

        private var m_columnGap:int;
        private var m_rowGap:int;
        private var m_defaultItemDispInfo:ComponentDisplayItem;
		
		/** 列，行各项创建完成回调函数 */
        private var m_itemsCreatedFunc:Function;
		
		/** 各项总数 */
        private var m_itemsCreatedCount:uint;
        private var m_columnsWidths:Vector.<int>;
		
		/** 所有项 */
        private var m_allRowItems:Vector.<Vector.<SubItemStruct>>;
        private var m_selectedRow:int = -1;
        private var m_selectedCol:int = -1;
        private var m_needRelayout:Boolean = true;
        protected var m_viewWidth:uint;
        protected var m_viewHeight:uint;
        protected var m_viewSizeInvalidate:Boolean = true;

        public function DeltaXTable(){
            this.m_columnsWidths = new Vector.<int>();
            this.m_allRowItems = new Vector.<Vector.<SubItemStruct>>();
            super();
        }
        private static function setClip(_arg1:DeltaXWindow):void{
            _arg1.style = (_arg1.style | WindowStyle.CLIP_BY_PARENT);
            var _local2:DeltaXWindow = _arg1.childTopMost;
            while (_local2) {
                setClip(_local2);
                _local2 = _local2.brotherBelow;
            };
        }

        override protected function _onWndCreatedInternal():void{
            super._onWndCreatedInternal();
            this.insertColumn(0, m_properties.width);
            addEventListener(DXWndMouseEvent.MOUSE_DOWN, this._onTablePress);
        }
        override protected function getVerticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & ListStyle.VERTICAL_SCROLLBAR) == 0){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = ListSubCtrlType.VERTICAL_SCROLLBAR;
            while (_local2 <= ListSubCtrlType.VERTICAL_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function getHorticalScrollBarDisplayItems():Vector.<ComponentDisplayItem>{
            if ((style & ListStyle.HORIZON_SCROLLBAR) == 0){
                return (null);
            };
            var _local1:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            var _local2:uint = ListSubCtrlType.HORIZON_SCROLLBAR;
            while (_local2 <= ListSubCtrlType.HORIZON_SCROLLBAR_THUMB) {
                _local1.push(m_properties.getSubCtrlInfo(_local2));
                _local2++;
            };
            return (_local1);
        }
        override protected function onVScroll(value:Number):void{
            this.relayoutItems();
        }
        override protected function onHScroll(value:Number):void{
            this.relayoutItems();
        }
        public function get rowGap():int{
            return (this.m_rowGap);
        }
		/**
		 * @set
		 * 设置行 间隔
		 * @param value	行
		 * 
		 */
        public function set rowGap(value:int):void{
            this.m_rowGap = value;
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
        public function get columnGap():int{
            return (this.m_columnGap);
        }
		
		/**
		 * @set
		 * 设置列间隔
		 * @param value	列
		 * 
		 */
        public function set columnGap(value:int):void{
            this.m_columnGap = value;
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
		
		/**
		 * 选中 
		 * @param row	行
		 * @param col	列
		 * 
		 */		
        public function selectItem(row:int, col:int=0):void{
            if ((((row >= this.getRowCount())) || ((col >= this.getColumnCount())))){
                return;
            };
            this.m_selectedRow = row;
            dispatchEvent(new TableSelectionEvent(TableSelectionEvent.SELECTION_CHANGED, row, col));
        }
		
		/**
		 * 初始化默认组件属性信息
		 */
        private function makeDefaultItemProperties():void{
            if (this.m_defaultItemDispInfo){
                return;
            };
            this.m_defaultItemDispInfo = new ComponentDisplayItem();
            var bgItem:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
            var t_defaultInfo:ComponentDisplayItem = this.m_defaultItemDispInfo;
            t_defaultInfo.displayStateInfos[SubCtrlStateType.MOUSEOVER] = new ComponentDisplayStateInfo();
            t_defaultInfo.displayStateInfos[SubCtrlStateType.CLICKDOWN] = new ComponentDisplayStateInfo();
            t_defaultInfo.displayStateInfos[SubCtrlStateType.ENABLE].copyFrom(bgItem.displayStateInfos[SubCtrlStateType.LISTITEM_NORMAL]);
            t_defaultInfo.displayStateInfos[SubCtrlStateType.DISABLE].copyFrom(bgItem.displayStateInfos[SubCtrlStateType.DISABLE]);
            t_defaultInfo.displayStateInfos[SubCtrlStateType.MOUSEOVER].copyFrom(bgItem.displayStateInfos[SubCtrlStateType.MOUSEOVER]);
            t_defaultInfo.displayStateInfos[SubCtrlStateType.CLICKDOWN].copyFrom(bgItem.displayStateInfos[SubCtrlStateType.LISTITEM_SELECTED]);
            t_defaultInfo.rect = t_defaultInfo.displayStateInfos[SubCtrlStateType.ENABLE].imageList.bounds;
            t_defaultInfo.rect = t_defaultInfo.rect.union(t_defaultInfo.displayStateInfos[SubCtrlStateType.DISABLE].imageList.bounds);
            t_defaultInfo.rect = t_defaultInfo.rect.union(t_defaultInfo.displayStateInfos[SubCtrlStateType.MOUSEOVER].imageList.bounds);
            t_defaultInfo.rect = t_defaultInfo.rect.union(t_defaultInfo.displayStateInfos[SubCtrlStateType.CLICKDOWN].imageList.bounds);
        }
		
		/**
		 * 插入行<br>
		 * 如果是多列，创建N个cell列为一行
		 * @param	row			行
		 * @param	cellHeight	行高
		 * @return	返回行索引
		 */
        public function insertRowItems(row:int, cellHeight:uint=20):int{
            var cell:SubItemStruct;
            if (row < 0){
                row = this.getRowCount();
            };
            var colCount:int = this.getColumnCount();
            this.m_viewSizeInvalidate = true;
            this.makeDefaultItemProperties();
            var _local5:Vector.<ComponentDisplayItem> = new Vector.<ComponentDisplayItem>();
            _local5[0] = this.m_defaultItemDispInfo;
            var i:int;
			//创建列
            while (i < colCount) {
                cell = new SubItemStruct();
                cell.itemWindow = new CommondItemWnd();
                this.m_allRowItems[i].splice(row, 0, cell);
                cell.itemWindow.createFromDispItemInfo("", _local5, (WindowStyle.CHILD | WindowStyle.NO_MOUSEWHEEL), this);
                cell.itemWindow.height = cellHeight;
                cell.height = cellHeight;
                i++;
            };
            this.relayoutItems();
            return row;
        }
		
		/**
		 * 设置行列创建完成回调函数
		 * @param	callback		
		 */
        public function setItemsCreatedFunc(callback:Function):void{
            this.m_itemsCreatedFunc = callback;
        }
		
		/**
		 * 插入自定义cell到行<br>
		 * 如果是多列，创建N个cell列为一行
		 * @param rowIndex				行索引
		 * @param guiResName			资源url
		 * @param cellRenderClass		cell类
		 * @param createdCallback		创建完成回调函数
		 * @param cellRenderClassParam	cell类构造参数
		 * @return 返回行索引
		 * 
		 */		
        public function insertRowItemsFromRes(rowIndex:int, guiResName:String, cellRenderClass:Class, createdCallback:Function=null, cellRenderClassParam:*=null):int{
            var cell:SubItemStruct;
            if (rowIndex < 0){
                rowIndex = this.getRowCount();
            };
            var cols:int = this.getColumnCount();
            this.m_viewSizeInvalidate = true;
            var i:int;
			//创建列
            while (i < cols) {
                cell = new SubItemStruct();
                cell.itemWindow = ((cellRenderClassParam)!=null) ? new cellRenderClass(cellRenderClassParam) : new cellRenderClass();
                this.m_allRowItems[i].splice(rowIndex, 0, cell);
                this.createItem(i, rowIndex, cell, guiResName, createdCallback);
                i++;
            };
            return rowIndex;
        }
		
		/**
		 * 创建列
		 * @param colIndexValue		列索引
		 * @param rowIndexValue		行索引
		 * @param item				列cell
		 * @param guiResName		资源url
		 * @param createdCallback	创建回调行数
		 * 
		 */		
        private function createItem(colIndexValue:int, rowIndexValue:int, item:SubItemStruct, guiResName:String, createdCallback:Function):void{
            var onSubItemCreated:Function = null;
            var colIndex:int = colIndexValue;
            var rowIndex:int = rowIndexValue;
            var userSubItemCreatedHandler:Function = createdCallback;
            onSubItemCreated = function (_arg1:DeltaXWindow):void{
                setClip(_arg1);
                if (userSubItemCreatedHandler != null){
                    userSubItemCreatedHandler(_arg1.parent, rowIndex, colIndex);
                };
                var _local2:Vector.<SubItemStruct> = m_allRowItems[colIndex];
                if (((_local2) && ((rowIndex < _local2.length)))){
                    _local2[rowIndex].height = _arg1.height;
                    relayoutItems();
                    m_viewSizeInvalidate = true;
                } else {
                    _arg1.dispose();
                };
                if (++m_itemsCreatedCount == getRowCount()){
                    if (m_itemsCreatedFunc != null){
                        m_itemsCreatedFunc();
                    };
                    m_itemsCreatedCount = 0;
                };
            };
            item.itemWindow.createFromRes(guiResName, this, onSubItemCreated);
        }
		
		/**
		 * 移除行 
		 * @param rowIndex		行索引,-1最后一行
		 */		
        public function removeRow(rowIndex:int=-1):void{
            var gui:DeltaXWindow;
            var rowCount:int = this.getRowCount();
            if (rowCount <= 0){
                return;
            };
            if (rowIndex < 0){
                rowIndex = (rowCount - 1);
            };
            if (rowIndex >= rowCount){
                return;
            };
            var colCount:int = this.getColumnCount();
            var i:int;
            while (i < colCount) {
				gui = this.m_allRowItems[i][rowIndex].itemWindow;
                gui.dispose();
                this.m_allRowItems[i].splice(rowIndex, 1);
                i++;
            };
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
		
		/**
		 * 获取行列gui 
		 * @param rowIndex	行
		 * @param colIndex	列
		 * @return gui
		 * 
		 */		
        public function getSubItem(rowIndex:uint, colIndex:uint):DeltaXWindow{
            if ((((rowIndex >= this.getRowCount())) || ((colIndex >= this.getColumnCount())))){
                return (null);
            };
            return (this.m_allRowItems[colIndex][rowIndex].itemWindow);
        }
		
		/**
		 * 通过索引获取gui 
		 * @param index		索引
		 * @return gui
		 * 
		 */		
        public function getSubItemByIndex(index:int):DeltaXWindow{
            var _local2:int = (index / this.getColumnCount());
            var _local3:int = (index % this.getColumnCount());
            return (this.getSubItem(_local2, _local3));
        }
		
		/**
		 * 获取item总数
		 */	
        public function get totalSubItemCount():uint{
            return ((this.getColumnCount() * this.getRowCount()));
        }
		
		/**
		 * 设置索引guivisible 
		 * @param index		索引
		 * @param value		visible值
		 */		
        public function setSubItemVisibleByIndex(index:int, value:Boolean):void{
            var row:int = (index / this.getColumnCount());
            var col:int = (index % this.getColumnCount());
            this.setSubItemVisible(row, col, value);
        }
		
		/**
		 * 获取行索引。通过y坐标（此方法内部判断应该有错误）
		 * @param localY	y坐标
		 * @param rowIndex	行索引
		 * @return 返回行索引
		 * 
		 */		
        public function getRowAtPoint(localY:int, rowIndex:int=-1):int{
            var _local4:int;
            var _local5:SubItemStruct;
            var _local3:Size = this.getViewSize();
            localY = (localY + scrollVerticalPos);
            if ((((localY < 0)) || ((localY > _local3.height)))){
                return (-1);
            };
            if ((((rowIndex < 0)) || ((rowIndex >= this.m_columnsWidths.length)))){
                rowIndex = 0;
            };
            for each (_local5 in this.m_allRowItems[rowIndex]) {
				// _local5.height固定的。。应该有问题
                if (localY <= _local5.height){
                    return (_local4);
                };
                localY = (localY - (_local5.height + this.m_rowGap));
                _local4++;
            };
            return (_local4);
        }
		
		/**
		 * 根据localX获取列索引 
		 * @param localX		x坐标
		 * @return	返回列索引
		 */	
        public function getColumnAtPoint(localX:int):int{
            var _local3:int;
            var _local2:Size = this.getViewSize();
            localX = (localX + scrollHorizonPos);
            if ((((localX < 0)) || ((localX > _local2.width)))){
                return (-1);
            };
            var _local4:int = this.getColumnCount();
            while (_local3 < _local4) {
                if (localX <= this.m_columnsWidths[_local3]){
                    break;
                };
                localX = (localX - (this.m_columnsWidths[_local3] + this.m_columnGap));
                _local3++;
            };
            return (_local3);
        }
		
		/**
		 * 根据localX,localY获取gui 
		 * @param localX		x坐标
		 * @param localY		y坐标
		 * @return	返回gui
		 */	
        public function getSubItemByPoint(localX:uint, localY:uint):DeltaXWindow{
            var _local4:int;
            var _local6:SubItemStruct;
            var _local3:Size = this.getViewSize();
            if ((((localX > _local3.width)) || ((localY > _local3.height)))){
                return (null);
            };
            var _local5:int = this.getColumnCount();
            while (_local4 < _local5) {
                if (localX <= this.m_columnsWidths[_local4]){
                    break;
                };
                localX = (localX - (this.m_columnsWidths[_local4] + this.m_columnGap));
                _local4++;
            };
            for each (_local6 in this.m_allRowItems[_local4]) {
                if (localY <= _local6.height){
                    return (_local6.itemWindow);
                };
                localY = (localY - (_local6.height + this.m_rowGap));
            };
            return (null);
        }
		
		/**
		 * 设置行高 
		 * @param localX		x坐标
		 * @param localY		y坐标
		 */	
        public function setRowHeight(rowIndex:int, rowHeight:int):void{
            if (rowIndex >= this.getRowCount()){
                return;
            };
            var colCount:int = this.getColumnCount();
            var col:int;
            while (col < colCount) {
                this.m_allRowItems[col][rowIndex].height = rowHeight;
                col++;
            };
            this.m_viewSizeInvalidate = true;
            this.relayoutItems();
        }
		
		/**
		 * 获取选中行
		 */	
        public function getSelectedRow():int{
            return (this.m_selectedRow);
        }
		
		/**
		 * 获取选中列
		 */
        public function getSelectedCol():int{
            return (this.m_selectedCol);
        }
		
		/**
		 * 获取行数量
		 */	
        public function getRowCount():int{
            return ((this.m_allRowItems.length) ? this.m_allRowItems[0].length : 0);
        }
		
		/**
		 * 获取列数量
		 */	
        public function getColumnCount():int{
            return (this.m_columnsWidths.length);
        }
		
		/**
		 * 设置item的visible 
		 * @param rowIndex			行
		 * @param colIndex			列
		 * @param visibleValue		visible值
		 * 
		 */		
        public function setSubItemVisible(rowIndex:uint, colIndex:int, visibleValue:Boolean):void{
            var _local4:int = this.getColumnCount();
            if ((((rowIndex >= this.getRowCount())) || ((colIndex >= _local4)))){
                return;
            };
            if (colIndex < 0){
                colIndex = 0;
                while (colIndex < _local4) {
                    this.m_allRowItems[colIndex][rowIndex].forceHide = !(visibleValue);
                    this.m_allRowItems[colIndex][rowIndex].itemWindow.visible = visibleValue;
                    colIndex++;
                };
            } else {
                this.m_allRowItems[colIndex][rowIndex].forceHide = !(visibleValue);
                this.m_allRowItems[colIndex][rowIndex].itemWindow.visible = visibleValue;
            };
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
		
		/**
		 * 插入列 
		 * @param colIndex		列索引
		 * @param widthValue	宽
		 * @return 列索引
		 * 
		 */		
        public function insertColumn(colIndex:int, widthValue:int):int{
            var cell:SubItemStruct;
            var rowCount:int = this.getRowCount();
            this.m_allRowItems.splice(colIndex, 0, new Vector.<SubItemStruct>(rowCount));
            this.m_viewSizeInvalidate = true;
            var row:int;
            while (row < rowCount) {
                cell = (this.m_allRowItems[colIndex][row] = new SubItemStruct());
				row++;
            };
            this.m_columnsWidths.splice(colIndex, 0, widthValue);
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
            return (colIndex);
        }
		
		/**
		 * 删除列 
		 * @param colIndex	列索引
		 * 
		 */		
        public function deleteColumn(colIndex:int):void{
            var _local3:DeltaXWindow;
            if (colIndex >= this.m_columnsWidths.length){
                return;
            };
            this.m_viewSizeInvalidate = true;
            var _local2:int = this.getRowCount();
            var _local4:int;
            while (_local4 < _local2) {
                _local3 = this.m_allRowItems[colIndex][_local4].itemWindow;
                if (_local3){
                    _local3.dispose();
                };
                _local4++;
            };
            this.m_allRowItems.splice(colIndex, 1);
            this.m_columnsWidths.splice(colIndex, 1);
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
		
		/**
		 * 设置列宽 
		 * @param colIndex		列索引
		 * @param colWidth		宽
		 * 
		 */		
        public function setColumnWidth(colIndex:int, colWidth:int):void{
            if (colIndex >= this.m_columnsWidths.length){
                return;
            };
            this.m_viewSizeInvalidate = true;
            this.m_columnsWidths[colIndex] = colWidth;
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
		
		/**
		 * 获取列宽 
		 * @param colIndex	列索引
		 * @return 宽
		 * 
		 */		
        public function getColumnWidth(colIndex:int):int{
            if (colIndex >= this.m_columnsWidths.length){
                return (0);
            };
            return (this.m_columnsWidths[colIndex]);
        }
		
		/**
		 * 移除所有行
		 */		
        public function removeAllRows():void{
            var _local3:DeltaXWindow;
            var _local5:int;
            var _local1:int = this.getRowCount();
            var _local2:int = this.getColumnCount();
            var _local4:int;
            while (_local4 < _local2) {
                _local5 = 0;
                while (_local5 < _local1) {
                    _local3 = this.m_allRowItems[_local4][_local5].itemWindow;
                    if (_local3){
                        _local3.dispose();
                    };
                    _local5++;
                };
                this.m_allRowItems[_local4].length = 0;
                _local4++;
            };
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
		
		/**
		 * 移除所有列
		 */		
        public function removeAllColumns():void{
            this.removeAllRows();
            this.m_columnsWidths.length = 0;
        }
		
		/**
		 * 移除某行某列 
		 * @param rowIndex		行索引
		 * @param colIndex		列索引
		 */		
        public function removeOneSubItem(rowIndex:uint, colIndex:int):void{
            if ((((rowIndex > this.getRowCount())) || ((colIndex > this.getColumnCount())))){
                return;
            };
            this.m_allRowItems[colIndex][rowIndex].itemWindow.dispose();
            this.m_allRowItems[colIndex].splice(rowIndex, 1);
            this.relayoutItems();
            this.m_viewSizeInvalidate = true;
        }
		/**
		 * 根据item的gui获取索引 
		 * @param item		gui
		 * @return 返回索引
		 * 
		 */		
        public function getItemIndex(item:DeltaXWindow):int{
            var _local3:int;
            var _local2:int;
            while (_local2 < this.getColumnCount()) {
                _local3 = 0;
                while (_local3 < this.m_allRowItems[_local2].length) {
                    if (this.m_allRowItems[_local2][_local3].itemWindow == item){
                        return (((this.getColumnCount() * _local3) + _local2));
                    };
                    _local3++;
                };
                _local2++;
            };
            return (-1);
        }
		
		/**
		 * 根据item的gui获取行索引 
		 * @param item
		 * @return 返回行索引
		 * 
		 */		
        public function getRowIndex(item:DeltaXWindow):int{
            var _local3:int;
            var _local2:int;
            while (_local2 < this.getColumnCount()) {
                _local3 = 0;
                while (_local3 < this.m_allRowItems[_local2].length) {
                    if (this.m_allRowItems[_local2][_local3].itemWindow == item){
                        return (_local3);
                    };
                    _local3++;
                };
                _local2++;
            };
            return (-1);
        }
		
		/**
		 *  判断是否需要重画组件
		 */		
        override public function validate():void{
            if (this.m_needRelayout){
                this.doRelayoutItems();
                this.m_needRelayout = false;
            };
            if (this.m_viewSizeInvalidate){
                this.checkViewSize();
                this.m_viewSizeInvalidate = false;
            };
            super.validate();
        }
		
		/**
		 * 重排组件
		 */
        protected function doRelayoutItems():void{
            var _local7:SubItemStruct;
            var _local8:int;
            var _local11:int;
            var _local1:int = this.getColumnCount();
            var _local2:int = this.getRowCount();
            var _local3:int = (-(scrollHorizonPos) + xBorder);
            var _local4:int = (-(scrollVerticalPos) + yBorder);
            var _local5:int = _local3;
            var _local6:int = _local4;
            var _local9:Boolean;
            var _local10:int;
            while (_local10 < _local1) {
                _local8 = this.m_columnsWidths[_local10];
                _local6 = _local4;
                _local11 = 0;
                while (_local11 < _local2) {
                    _local7 = this.m_allRowItems[_local10][_local11];
                    if (!_local7.itemWindow.inUITree){
                    } else {
                        _local7.itemWindow.x = _local5;
                        _local7.itemWindow.y = _local6;
                        _local7.itemWindow.width = _local8;
                        if (_local7.height != _local7.itemWindow.height){
                            _local7.height = _local7.itemWindow.height;
                        };
                        if (((((((_local5 + _local8) < 0)) || ((_local5 > this.width)))) || (((((_local6 + _local7.height) < 0)) || ((_local6 > this.height)))))){
                            _local7.itemWindow.visible = false;
                            _local9 = true;
                        } else {
                            _local7.itemWindow.visible = !(_local7.forceHide);
                        };
                        if (!_local7.forceHide){
                            _local6 = (_local6 + (_local7.height + this.m_rowGap));
                        };
                    };
                    _local11++;
                };
                _local5 = (_local5 + (_local8 + this.m_columnGap));
                _local10++;
            };
        }
        public function relayoutItems():void{
            invalidate();
            this.m_needRelayout = true;
        }
        protected function fireStateChanged():void{
            dispatchEvent(new DXWndEvent(DXWndEvent.STATE_CHANGED));
        }
        public function getExtentSize():Size{
            return (getSize());
        }
        protected function checkViewSize():void{
            var _local1:uint;
            this.m_viewWidth = 0;
            this.m_viewHeight = 0;
            _local1 = 0;
            while (_local1 < this.m_columnsWidths.length) {
                this.m_viewWidth = (this.m_viewWidth + (this.m_columnsWidths[_local1] + this.m_columnGap));
                _local1++;
            };
            var _local2:int = this.getRowCount();
            _local1 = 0;
            while (_local1 < _local2) {
                this.m_viewHeight = (this.m_viewHeight + (this.m_allRowItems[0][_local1].height + this.m_rowGap));
                _local1++;
            };
            if (verticalScrollBar){
                verticalScrollBar.range = this.m_viewHeight;
            };
            if (horizontalScrollBar){
                horizontalScrollBar.range = this.m_viewWidth;
            };
        }
        public function getViewSize():Size{
            if (this.m_viewSizeInvalidate){
                this.checkViewSize();
                this.m_viewSizeInvalidate = false;
            };
            return (new Size(this.m_viewWidth, this.m_viewHeight));
        }
        public function getViewPosition():Point{
            return (new Point(scrollHorizonPos, scrollVerticalPos));
        }
        public function setViewPosition(_arg1:Point):void{
            if (((!((scrollHorizonPos == _arg1.x))) || (!((scrollVerticalPos == _arg1.y))))){
                this.restrictionViewPos(_arg1);
                if ((((scrollHorizonPos == _arg1.x)) && ((scrollVerticalPos == _arg1.y)))){
                    return;
                };
                if (horizontalScrollBar){
                    horizontalScrollBar.value = _arg1.x;
                };
                if (verticalScrollBar){
                    verticalScrollBar.value = _arg1.y;
                };
                this.fireStateChanged();
                this.relayoutItems();
            };
        }
        public function scrollRectToVisible(_arg1:Rectangle):void{
            this.setViewPosition(new Point(_arg1.x, _arg1.y));
        }
        private function restrictionViewPos(_arg1:Point):Point{
            var _local2:Point = this.getViewMaxPos();
            _arg1.x = Math.max(0, Math.min(_local2.x, _arg1.x));
            _arg1.y = Math.max(0, Math.min(_local2.y, _arg1.y));
            return (_arg1);
        }
        private function getViewMaxPos():Point{
            var _local1:Size = this.getExtentSize();
            var _local2:Size = this.getViewSize();
            var _local3:Point = new Point((_local2.width - _local1.width), (_local2.height - _local1.height));
            if (_local3.x < 0){
                _local3.x = 0;
            };
            if (_local3.y < 0){
                _local3.y = 0;
            };
            return (_local3);
        }
        public function addSelectionListener(_arg1:Function):void{
            addEventListener(TableSelectionEvent.SELECTION_CHANGED, _arg1);
        }
        public function removeSelectionListener(_arg1:Function):void{
            removeEventListener(TableSelectionEvent.SELECTION_CHANGED, _arg1);
        }
        public function getViewportPane():DeltaXWindow{
            return (this);
        }
        protected function _onTablePress(_arg1:DXWndMouseEvent):void{
            var _local2:int = this.getColumnAtPoint(_arg1.localX);
            if (_local2 < 0){
                return;
            };
            var _local3:int = this.getRowAtPoint(_arg1.localY, _local2);
            if (_local3 < 0){
                return;
            };
            this.selectItem(_local3, _local2);
        }

    }
}//package deltax.gui.component 

import flash.display3D.*;
import deltax.gui.base.*;
import deltax.gui.component.subctrl.*;
import deltax.gui.component.*;

/**
 * 默认渲染项 
 * @author Administrator
 * 
 */
class SubItemStruct {

    public var height:uint = 20;
    public var forceHide:Boolean;
    public var itemWindow:DeltaXWindow;

    public function SubItemStruct(){
    }
}
/**
 * 默认渲染gui 
 * @author Administrator
 * 
 */
class CommondItemWnd extends DeltaXButton {

    public function CommondItemWnd(){
    }
    private function get isSelect():Boolean{
        var _local1:DeltaXTable = DeltaXTable(parent);
        return ((_local1.getSubItem(_local1.getSelectedRow(), _local1.getSelectedCol()) == this));
    }
    override protected function renderBackground(_arg1:Context3D, _arg2:uint, _arg3:int):void{
        if (((!(enable)) || (!(this.isSelect)))){
            return (super.renderBackground(_arg1, _arg2, _arg3));
        };
        var _local4:ComponentDisplayItem = m_properties.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);
        renderImageList(_arg1, _local4.displayStateInfos[SubCtrlStateType.CLICKDOWN].imageList, null, -1, 1, m_gray);
    }
    override protected function renderText(_arg1:Context3D, _arg2:uint, _arg3:int):void{
        if (((!(enable)) || (!(this.isSelect)))){
            return (super.renderText(_arg1, _arg2, _arg3));
        };
        var _local4:ComponentDisplayStateInfo = m_properties.getStateImageList(CommonWndSubCtrlType.BACKGROUND, SubCtrlStateType.CLICKDOWN);
        drawTextWithStyle(_arg1, getText(), _local4.fontColor, _local4.fontEdgeColor);
    }

}
