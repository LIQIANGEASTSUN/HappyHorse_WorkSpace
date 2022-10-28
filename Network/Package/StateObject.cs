using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Net.Sockets;

namespace Network
{
    public class StateObject
    {
        public Socket workSocket;
        public const int bufferSize = 100; // 1024 * 10;
        public byte[] buffer = new byte[bufferSize];
    }

    public class StateUdpObject : StateObject
    {
        public EndPoint remote = new IPEndPoint(IPAddress.Any, 0);
    }
}
