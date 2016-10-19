package deltax.graphic.shader
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
    import __AS3__.vec.Vector;

    public class DeltaXAssembler 
	{
        public static const INPUT:int = 0;                   //va 
        public static const PARAM:int = 1;                // vc or fc
        public static const TEMP:int = 2;                  //vt or ft
        public static const VARING:int = 3;              //v
        public static const SAMPLE:int = 4;             //fs
        public static const OUTPUT:int = 5;
		
        public static const MAX_INPUT_COUNT:int = 8;           //va最大数量
        public static const MAX_VERTEX_PARAM_COUNT:int = 128;                     //vc最大数量
        public static const MAX_FRAGMENT_PARAM_COUNT:int = 28;               //fc最大数量
        public static const MAX_TEMP_COUNT:int = 8;            //vt or ft 最大数量
        public static const MAX_VARING_COUNT:int = 8;         //v
        public static const MAX_SAMPLE_COUNT:int = 8;        //fs
        public static const MAX_OUTPUT_COUNT:int = 1;
		
        public static const OUTSIDE_BLOCK:int = -1;
        public static const WAIT_BLOCK_START:int = 0;
        public static const WAIT_BLOCK_END:int = 1;
		
        public static const REGISTER_TYPE:Vector.<String> = Vector.<String>(["input", "param", "temporary", "varing", "sample", "output"]);
		public static const VERTEX_REGISTER_NAME:Vector.<String> = Vector.<String>(["va", "vc", "vt", "v", "vs", "op"]);
		public static const FRAGMENT_REGISTER_NAME:Vector.<String> = Vector.<String>(["fa", "fc", "ft", "v", "fs", "oc"]);

        private var m_asmVertexByteCode:ByteArray;
        private var m_asmFragmentByteCode:ByteArray;
        private var m_asmVertexSourceCode:String = "";
        private var m_asmFragmentSourceCode:String = "";
        private var m_vecVertexRegisterGroup:Vector.<Vector.<DeltaXShaderRegister>>;
        private var m_vecFragmentRegisterGroup:Vector.<Vector.<DeltaXShaderRegister>>;

        public function DeltaXAssembler()
		{
            this.m_vecVertexRegisterGroup = new Vector.<Vector.<DeltaXShaderRegister>>();
            this.m_vecFragmentRegisterGroup = new Vector.<Vector.<DeltaXShaderRegister>>();
            super();
        }
        public function get asmVertexByteCode():ByteArray
		{
            return (this.m_asmVertexByteCode);
        }
        public function get asmFragmentByteCode():ByteArray
		{
            return (this.m_asmFragmentByteCode);
        }
        public function get asmVertexSourceCode():String
		{
            return (this.m_asmVertexSourceCode);
        }
        public function get asmFragmentSourceCode():String
		{
            return (this.m_asmFragmentSourceCode);
        }
        public function getVertexRegister(index:uint):Vector.<DeltaXShaderRegister>
		{
            return (((index > OUTPUT)) ? null : this.m_vecVertexRegisterGroup[index]);
        }
        public function getFragmentRegister(index:uint):Vector.<DeltaXShaderRegister>
		{
            return (((index > OUTPUT)) ? null : this.m_vecFragmentRegisterGroup[index]);
        }
		
		/**
		 * 
		 * @param byte
		 */		
		public function load(byte:ByteArray):void
		{
			var index:int;
			var subIndex:int;
			var len:int;
			index = 0;
			while (index <= OUTPUT) 
			{
				this.m_vecVertexRegisterGroup[index] = new Vector.<DeltaXShaderRegister>();
				len = byte.readInt();
				subIndex = 0;
				while (subIndex < len)
				{
					this.m_vecVertexRegisterGroup[index][subIndex] = new DeltaXAssembleShaderRegister(0, "", "", "", null);
					DeltaXAssembleShaderRegister(this.m_vecVertexRegisterGroup[index][subIndex]).load(byte);
					subIndex++;
				};
				index++;
			};
			this.m_asmVertexByteCode = new ByteArray();
			this.m_asmVertexByteCode.endian = Endian.LITTLE_ENDIAN;
			this.m_asmVertexByteCode.length = byte.readInt();
			byte.readBytes(this.m_asmVertexByteCode, 0, this.m_asmVertexByteCode.length);
			//
			index = 0;
			while (index <= OUTPUT)
			{
				this.m_vecFragmentRegisterGroup[index] = new Vector.<DeltaXShaderRegister>();
				len = byte.readInt();
				subIndex = 0;
				while (subIndex < len) 
				{
					this.m_vecFragmentRegisterGroup[index][subIndex] = new DeltaXAssembleShaderRegister(0, "", "", "", null);
					DeltaXAssembleShaderRegister(this.m_vecFragmentRegisterGroup[index][subIndex]).load(byte);
					subIndex++;
				};
				index++;
			};
			this.m_asmFragmentByteCode = new ByteArray();
			this.m_asmFragmentByteCode.endian = Endian.LITTLE_ENDIAN;
			this.m_asmFragmentByteCode.length = byte.readInt();
			byte.readBytes(this.m_asmFragmentByteCode, 0, this.m_asmFragmentByteCode.length);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
        private function getType(_arg1:String):int
		{
            var _local2:Array = _arg1.match(/^[a-z]+[0-9]*$/);
            if ((((_local2 == null)) || (!((_local2.length == 1))))){
                return (-1);
            };
            _arg1 = _arg1.replace(/[0-9]/g, "");
            var _local3:int;
            while (_local3 < REGISTER_TYPE.length)
			{
                if (REGISTER_TYPE[_local3] == _arg1)
				{
                    return (_local3);
                };
                _local3++;
            };
            return (-1);
        }
        private function getTypeIndex(_arg1:String):int{
            var _local2:Array = _arg1.match(/[0-9]+/);
            if (_local2 == null){
                return (-1);
            };
            return (int(_local2[0]));
        }
        private function isValidName(_arg1:String):Boolean{
            var _local2:Array = _arg1.match(/^[a-zA-z_][a-zA-Z_0-9]*$/);
            return (((!((_local2 == null))) && ((_local2.length == 1))));
        }
		
		
		
        
		
		
		

    }
} 

import flash.utils.ByteArray;

import deltax.graphic.shader.DeltaXShaderRegister;

class LinePos 
{
    public var start:int;
    public var end:int;

    public function LinePos()
	{
    }
}

class DeltaXAssembleShaderRegister extends DeltaXShaderRegister
{
    public function DeltaXAssembleShaderRegister(_index:int, _name:String, _semantics:String, _format:String, _values:Vector.<Number>)
	{
        super(_index, _name, _semantics, _format, _values);
    }
    public function setNumberVector(_valueVec:Vector.<Number>):void
	{
        var len:uint = Math.min(_valueVec.length, values.length);
        var index:uint;
        while (index < len)
		{
            values[index] = _valueVec[index];
			index++;
        }
    }
    public function clone():DeltaXAssembleShaderRegister
	{
        return (new DeltaXAssembleShaderRegister(index, ((name == null)) ? null : name.concat(), ((semantics == null)) ? null : semantics.concat(), ((format == null)) ? null : format.concat(), (values) ? values : null));
    }
    public function save(byte:ByteArray):void
	{
		byte.writeInt(index);
		byte.writeUTF(name);
		byte.writeUTF((semantics) ? semantics : "");
		byte.writeUTF(format);
        var len:int = (values) ? values.length : -1;
		byte.writeInt(len);
        var index:uint;
        while (index < len) 
		{
            byte.writeDouble(values[index]);
			index++;
        };
    }
    public function load(byte:ByteArray):void
	{
        index = byte.readInt();
        name = byte.readUTF();
        semantics = byte.readUTF();
        format = byte.readUTF();
        count = (byte.readInt() / 4);
        if (count >= 0)values = new Vector.<Number>();
        var indexS:uint;
        while (indexS < (count * 4))
		{
            values[indexS] = byte.readDouble();
			indexS++;
        }
    }
}
