# AS3-Socket-Wrapper
An ActionScript 3 TCP socket wrapper with buffering and acknowledgment mechanism to prevent data loss problems in READ methods of SOCKET class.

Packet.as: 
	A class to define a packet (ASCII messages, but you can add ByteArray or other objects if you need), size of them, signatures and …

SocketEvent.as: 
	Customized socket event.

ClientSocketWrap.as: 
	Wrapper class of clients, with buffering mechanism for any sending messages and timer and acknowledgement routines. Any sending message will store in a buffer (queue) and will send after receiving ACK of previous messages.

ServerSocketWrap.as: 
	Wrapper class of server that uses a list for handling multi clients.


Related blog post: http://www.mshams.ir/blogs/1391/02/as3-tcp-chat-with-buffering-and-acknowledgment
