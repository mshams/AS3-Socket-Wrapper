package ir.mshams{
	
	// 
	// [Developer        Date         Comment]
	// mshams.ir         2/29/2012    Class creation.
	// mshams.ir         3/22/2012    Array _Clients & Function listen added.
	// mshams.ir         3/23/2012    Child class changed to wrapper.	
	//

	import flash.events.*;
	import flash.net.ServerSocket;
	import flash.errors.IOError;
	import ir.mshams.SocketEvent;
	import ir.mshams.ClientSocketWrap;
	import flash.utils.ByteArray;

	public class ServerSocketWrap extends EventDispatcher {
		private var _outstr:String;
		private var _clients:Array;
		private var _server:ServerSocket;

		public function ServerSocketWrap(host:String = null, port:uint = 0) {
			_clients = new Array();

			_server = new ServerSocket();
			_server.addEventListener(Event.CLOSE, evtClose);
			_server.addEventListener(ServerSocketConnectEvent.CONNECT, evtConnect);

			if (host && port) {
				listen(host, port);
			}
		}

		public function listen(host:String = null, port:uint = 0) {
			try {
				_server.bind(port, host);
				_server.listen();
			} catch (e:Error) {
				trace(e.errorID, e.message);
			}
		}

		public function get server():ServerSocket {
			return _server;
		}

		public function set server(s:ServerSocket) {
			_server = s;
		}

		public function get lastDataString():String {
			return _outstr;
		}

		private function evtClientData(e:SocketEvent) {
			var str:String = e.dataString;
			_outstr = str;
			trace("evtClientData", str);
			
			var evt:SocketEvent = new SocketEvent(SocketEvent.SOCKET_READ_STRING);
			evt.dataString = str;
			dispatchEvent(evt);
		}

		private function evtClose(e:Event) {
			trace("evtServerClose: " + e);
		}

		private function evtClientClose(e:Event) {
			trace("evtServerClose: " + e);
			_clients.splice(_clients.indexOf(e.target), 1);
		}

		private function evtClientDataError(e:SocketEvent) {
			trace("evtClientDataError: " + e.message);
		}

		private function evtConnect(e:ServerSocketConnectEvent) {
			trace("evtConnect: " + e);
			var client:ClientSocketWrap = new ClientSocketWrap(e.socket);
			client.addEventListener(SocketEvent.SOCKET_READ_STRING, evtClientData);
			client.addEventListener(SocketEvent.SOCKET_READ_ERROR, evtClientDataError);
			client.addEventListener(Event.CLOSE, evtClientClose);

			_clients.push(client);
		}
	}
}