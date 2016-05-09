package ir.mshams{
	 
	// 
	// [Developer        Date         Comment]
	// mshams.ir         2/29/2012    Class creation.
	// mshams.ir         2/29/2012    Function configureListeners added.
	// mshams.ir         3/23/2012    Child class changed to wrapper.
	//

	import flash.events.*;
	import flash.net.Socket;
	import flash.errors.IOError;
	import ir.mshams.SocketEvent;
	import ir.mshams.Packet;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class ClientSocketWrap extends EventDispatcher {
	public var uid:uint;	
	public const _sign:String = "978b28198e10533b62e9cacec77d793e";
	//reserved;
	
	private var _outstr:String;
	private var _sock:Socket;
	private var _buffer:Vector.<Packet > ;
	private var _tim:Timer;

	public function ClientSocketWrap(socket:Socket = null, host:String = null, port:int = 0) {

		_sock = socket || new Socket(host,port);
		_buffer = new Vector.<Packet>();

		_tim = new Timer(1,10);
		_tim.addEventListener(TimerEvent.TIMER, evtTimer);
		_tim.start();

		initEvents();
		if (host && port) {
			_sock.connect(host, port);
		}
	}

	private function initEvents() {
		with (_sock) {
			addEventListener(Event.CLOSE, evtClose);
			addEventListener(Event.CONNECT, evtConnect);
			addEventListener(IOErrorEvent.IO_ERROR, evtIoError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, evtSecError);
			addEventListener(ProgressEvent.SOCKET_DATA, evtData);
		}
	}

	public function get socket():Socket {
		return _sock;
	}

	public function set socket(s:Socket) {
		_sock = s;
		initEvents();
		trace(s);
	}

	private function evtTimer(e:TimerEvent) {
		_tim.reset();
		_tim.start();

		if (! _buffer.length) {
			return;
		}

		if (_buffer[0].ack) {
			_buffer.shift();
		}
		else if (! _buffer[0].sended) {
			try {
				_sock.writeUTFBytes(_buffer[0].toString());
				_sock.flush();
				_buffer[0].sended = true;
			} catch (e:IOError) {
				trace(e.errorID, e.message);
			}
		}
	}

	public function writeSizedString(s:String):uint {
		try {
			var p:Packet = new Packet(s);
			_buffer.push(p);

		} catch (e:IOError) {
			trace(e.errorID, e.message);
		}
		return _buffer.length;
	}

	public function readSizedString():void {
		try {
			var dataSize:uint = parseInt(_sock.readUTFBytes(10));
			var sign:String = _sock.readUTFBytes(4);
			var str:String = _sock.readUTFBytes(dataSize);
			
		} catch (err:Error) {
			var edr:SocketEvent = new SocketEvent(SocketEvent.SOCKET_READ_ERROR);
			edr.message = err.message + "[dataSize=" + dataSize.toString() + "] [sign=" + sign + "] [str=" + str + "]";

			dispatchEvent(edr);
			return;
		}

		trace("readSizedString", dataSize, sign, str);
		_outstr = str;

		//Packet acknowledgment received
		if (dataSize == 3 && str == "ACK") {
			setAck(sign);
			return;
		}

		sendAck(sign);
		var ers:SocketEvent = new SocketEvent(SocketEvent.SOCKET_READ_STRING);
		ers.dataString = str;
		dispatchEvent(ers);
	}

	private function setAck(sign:String):int {
		for (var i:uint = 0; i<_buffer.length; i++) {
			if (_buffer[i].sign == sign) {
				_buffer[i].ack = true;
				return i;
			}
		}
		return -1;
	}

	private function sendAck(sign:String) {
		try {
			_sock.writeUTFBytes(Packet.signPacket(sign));
			_sock.flush();
		} catch (e:IOError) {
			trace(e.errorID, e.message);
		}
	}

	public function get lastDataString():String {
		return _outstr;
	}

	private function evtData(e:ProgressEvent):void {
		trace("evtData: " + e);
		readSizedString();
	}

	private function evtClose(e:Event):void {
		trace("evtClientClose: " + e);
		dispatchEvent(new Event(Event.CLOSE));
	}

	private function evtConnect(e:Event):void {
		trace("evtConnect: " + e);
	}

	private function evtIoError(e:IOErrorEvent):void {
		trace("evtIoError: " + e);
	}

	private function evtSecError(e:SecurityErrorEvent):void {
		trace("evtSecError: " + e);
		_sock.close();
	}
}
}