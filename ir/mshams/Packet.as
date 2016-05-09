package ir.mshams{
	
	// 
	// [Developer        Date         Comment]
	// mshams.ir         3/2/2012    Class creation.
	// mshams.ir         3/3/2012    Sign Function added.
	//

	import flash.utils.ByteArray;

	public class Packet {
		public var dataSize:uint;
		public var packetSize:uint;
		public var ack:Boolean;
		public var sign:String;
		public var sended:Boolean;
		public var packetType:int;

		public static const TYPE_STRING:int = 11;
		public static const TYPE_BYTES:int = 22;

		private var _dataString:String;
		private var _dataBytes:ByteArray;

		public function Packet(data:String) {
			_dataString = data;
			dataSize = _dataString.length;
			sign = String.fromCharCode("A".charCodeAt(0) + dataSize % 26) + (100 + Math.random() * 899).toFixed(0);
			packetSize = dataSize + 14;
			ack = false;
			sended = false;
		}

		public static function sizeBlock(size:uint):String {
			return size.toPrecision(9).toString();
		}

		public static function signPacket(sign:String):String {
			return sizeBlock(3) + sign + "ACK";
		}

		public function toString():String {
			return sizeBlock(dataSize) + sign + _dataString;
		}

	}
}