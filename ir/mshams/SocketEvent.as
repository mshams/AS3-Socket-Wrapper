package ir.mshams{
	 
	// 
	// [Developer        Date         Comment]
	// mshams.ir         2/29/2012    Class creation.
	// mshams.ir         3/22/2012    SOCKET_READ_ERROR added.
	//

	import flash.events.Event;
	import flash.utils.ByteArray;

	public class SocketEvent extends Event {
		public var dataString:String = "";
		public var message:String = "";
		public var dataFile:ByteArray;

		public static const SOCKET_READ_STRING:String = "socketReadString";
		//public static const SOCKET_READ_FILE:String = "socketReadFile";
		public static const SOCKET_READ_ERROR:String = "socketReadError";

		public function SocketEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		public override function clone():Event {
			return new SocketEvent(type, bubbles, cancelable);
		}
	}
}