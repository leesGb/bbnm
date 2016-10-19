package deltax.graphic.manager
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import deltax.common.LittleEndianByteArray;
	
	/**
	 *几何体数据管理器
	 *author lees
	 *date 2016-2-17
	 */
	public class NelboSubGeometryManager
	{
		private static var _instance:NelboSubGeometryManager;
		
		/**几何体数据列表*/
		private var m_subGeometryMap:Dictionary;
		/***/
		private var m_vertexBuffer:VertexBuffer3D;
		/***/
		private var m_indexBuffer:IndexBuffer3D;
		/***/
		private var m_index2Pos:Vector.<uint>;
		/***/
		private var m_vertexBuffer2:VertexBuffer3D;
		/***/
		private var m_indexBuffer2:IndexBuffer3D;
		
		public function NelboSubGeometryManager()
		{
			this.m_subGeometryMap = new Dictionary();
			this.m_index2Pos = new Vector.<uint>((21 * 21), true);
			
			var pIndex:uint;
			var index:uint = 0;
			var subIndex:uint;
			while (index <= 20) 
			{
				subIndex = 0;
				while (subIndex < index) 
				{
					this.m_index2Pos[pIndex++] = (index << 8) | subIndex;
					this.m_index2Pos[pIndex++] = (subIndex << 8) | index;
					subIndex++;
				}
				this.m_index2Pos[pIndex++] = (index << 8) | index;
				index++;
			}
		}
		
		public static function get Instance():NelboSubGeometryManager
		{
			if(_instance == null)
			{
				_instance = new NelboSubGeometryManager();
			}
			return _instance;
		}
		
		/**
		 * 索引位置列表
		 * @return 
		 */		
		public function get index2Pos():Vector.<uint>
		{
			return this.m_index2Pos;
		}
		
		/**
		 * 获取顶点缓冲区里矩形的数量
		 * @return 
		 */		
		public function get rectCountInVertexBuffer():uint
		{
			return 0x1000;//4096
		}
		
		/**
		 * 写入索引数据
		 * @param outData
		 * @param inputs
		 * @param v1
		 * @param v2
		 * @param v3
		 */		
		private static function writeIndex(outData:ByteArray, inputs:Vector.<uint>, v1:uint, v2:uint, v3:uint):void
		{
			var i1:uint = inputs[(((v3 + 1) * 21) + v2)];
			var i2:uint = inputs[(((v3 * 21) + v2) + 1)];
			var i3:uint = inputs[((((v3 + 1) * 21) + v2) + 1)];
			outData.writeShort(v1);
			outData.writeShort(i1);
			outData.writeShort(i2);
			outData.writeShort(i2);
			outData.writeShort(i1);
			outData.writeShort(i3);
		}
		
		/**
		 * 矩形打包渲染1
		 * @param context3d
		 * @param num
		 */		
		public function drawPackRect(context3d:Context3D, num:uint):void
		{
			var index:uint;
			var data:ByteArray;
			var rectCount:uint;
			if (this.m_vertexBuffer == null)
			{
				rectCount = this.rectCountInVertexBuffer;
				this.m_vertexBuffer = context3d.createVertexBuffer(rectCount * 4, 1);
				data = new LittleEndianByteArray();
				
				var v1:uint = 0;
				var v2:uint = 0;
				var v3:uint = 0;
				index = 0;
				while (index < rectCount) 
				{
					v3 = v1 | v2;
					data.writeUnsignedInt((0xFF00 | v3));//65280
					data.writeUnsignedInt((0 | v3));
					data.writeUnsignedInt((0xFFFF | v3));//65535
					data.writeUnsignedInt((0xFF | v3));//255
					v1 += 16777216;//0xFFFFFF
					v2 += (v1) ? 0 : 65536;
					index++;
				}
				this.m_vertexBuffer.uploadFromByteArray(data, 0, 0, rectCount * 4);
			}
			//
			if (this.m_indexBuffer == null)
			{
				rectCount = this.rectCountInVertexBuffer;
				this.m_indexBuffer = context3d.createIndexBuffer(rectCount * 6);
				data = new LittleEndianByteArray();
				index = 0;
				while (index < rectCount) 
				{
					data.writeShort(index * 4 + 0);
					data.writeShort(index * 4 + 1);
					data.writeShort(index * 4 + 2);
					data.writeShort(index * 4 + 2);
					data.writeShort(index * 4 + 1);
					data.writeShort(index * 4 + 3);
					index++;
				}
				this.m_indexBuffer.uploadFromByteArray(data, 0, 0, rectCount * 6);
			}
			context3d.setVertexBufferAt(0, this.m_vertexBuffer, 0, Context3DVertexBufferFormat.BYTES_4);
			context3d.drawTriangles(this.m_indexBuffer, 0, num * 2);
		}
		
		/**
		 * 矩形打包渲染2
		 * @param context3d
		 * @param num
		 */		
		public function drawPackRect2(context3d:Context3D, num:uint):void
		{
			var index:uint;
			var v:uint;
			var data:ByteArray;
			if (this.m_vertexBuffer2 == null)
			{
				data = new LittleEndianByteArray();
				index = 0;
				v = 0;
				while (index < this.m_index2Pos.length) 
				{
					data.writeUnsignedInt((this.m_index2Pos[index] | v));
					index++;
					v += 65536;
				}
				this.m_vertexBuffer2 = context3d.createVertexBuffer(this.m_index2Pos.length, 1);
				this.m_vertexBuffer2.uploadFromByteArray(data, 0, 0, this.m_index2Pos.length);
			}
			//
			if (this.m_indexBuffer2 == null)
			{
				var inputs:Vector.<uint> = new Vector.<uint>((21 * 21), true);
				index = 0;
				while (index < this.m_index2Pos.length) 
				{
					inputs[(((this.m_index2Pos[index] >> 8) * 21) + (this.m_index2Pos[index] & 0xFF))] = index;
					index++;
				}
				
				var v1:uint;
				data = new LittleEndianByteArray();
				index = 0;
				v = 0;
				while (index < 20) 
				{
					v1 = 0;
					while (v1 < index) 
					{
						writeIndex(data, inputs, v++, v1, index);
						writeIndex(data, inputs, v++, index, v1);
						v1++;
					}
					writeIndex(data, inputs, v++, index, index);
					index++;
				}
				this.m_indexBuffer2 = context3d.createIndexBuffer((data.position >> 1));
				this.m_indexBuffer2.uploadFromByteArray(data, 0, 0, (data.position >> 1));
			}
			context3d.setVertexBufferAt(0, this.m_vertexBuffer2, 0, Context3DVertexBufferFormat.BYTES_4);
			context3d.drawTriangles(this.m_indexBuffer2, 0, (num << 1));
		}
		
		/**
		 * 设备丢失
		 */		
		public function onLostDevice():void
		{
			if (this.m_vertexBuffer)
			{
				this.m_vertexBuffer.dispose();
			}
			
			if (this.m_indexBuffer)
			{
				this.m_indexBuffer.dispose();
			}
			this.m_vertexBuffer = null;
			this.m_indexBuffer = null;
			
			if (this.m_vertexBuffer2)
			{
				this.m_vertexBuffer2.dispose();
			}
			
			if (this.m_indexBuffer2)
			{
				this.m_indexBuffer2.dispose();
			}
			this.m_vertexBuffer2 = null;
			this.m_indexBuffer2 = null;
		}
		
		
		
	}
}