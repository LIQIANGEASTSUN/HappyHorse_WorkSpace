
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Network
{
    public enum NetworkType
    {
        Tcp,
        Udp,
    }

    public enum NetworkCS
    {
        Client,
        Server,
    }

    public class NetworkData
    {
        public NetworkType networkType;
        public NetworkCS networkCS;
        public string localIp;
        public int localPort;
        public string remoteIp;
        public int remotePort;
        public int uid;
        public int cmdID;
    }
}
