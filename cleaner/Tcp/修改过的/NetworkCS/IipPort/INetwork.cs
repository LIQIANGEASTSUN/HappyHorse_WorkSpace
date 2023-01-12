using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Network
{
    public interface INetwork
    {
        void SetData(NetworkData networkData);

        void Start();

        void Send(string msg);
    }

	public enum NetWorkState
	{
		// init
		Closed,

		// client
		Connected,
		Connecting,
		ConnectFailed,

		// both
		Timeout,
		Disconnected,
		// server
		Listening,
	}
}
