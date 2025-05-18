using System;
using System.Collections.Generic;
using Cookgame.Broadcast;

namespace Cookgame
{
    public class BroadcastSystem : ISystem
    {
        private bool _needTidy;
        private Dictionary<int, BroadcastDataCollection> _dataBroadcastMap;
        private List<BroadcastDataCollection> _dataBroadcastList;

        public void InitSystem()
        {
            _dataBroadcastMap = new Dictionary<int, BroadcastDataCollection>();
            _dataBroadcastList = new List<BroadcastDataCollection>();
            _needTidy = false;
        }

        public void InitData()
        {
        }

        public void DoUpdate()
        {
            if (_needTidy)
            {
                for (int i = 0; i < _dataBroadcastList.Count; i++)
                {
                    _dataBroadcastList[i].Tidy();
                }
                _needTidy = false;
            }
        }

        public void DoFixedUpdate()
        {
        }

        public void DoLateUpdate()
        {
        }

        public void OnDispose()
        {
        }

        public void RegisterDataListener(BroadcastId broadcastId, BroadcastDataListener dataReceive)
        {
            RegisterDataListener((int)broadcastId, dataReceive);
        }

        private void RegisterDataListener(int dataId, BroadcastDataListener dataReceive)
        {
            if (dataId > 0 && dataReceive != null)
            {
                BroadcastDataCollection listeners = null;
                if (_dataBroadcastMap.ContainsKey(dataId))
                    listeners = _dataBroadcastMap[dataId];
                else
                {
                    listeners = new BroadcastDataCollection();
                    _dataBroadcastMap[dataId] = listeners;
                    _dataBroadcastList.Add(listeners);
                }

                listeners.AddListener(dataReceive);
                if (listeners.NeedTidy)
                {
                    _needTidy = true;
                }
            }
        }
        public void UnRegisterDataListener(BroadcastId broadcastId, BroadcastDataListener dataReceive)
        {
            UnRegisterDataListener((int) broadcastId, dataReceive);
        }

        private void UnRegisterDataListener(int dataId, BroadcastDataListener dataReceive)
        {
            if (dataId > 0 && dataReceive != null && _dataBroadcastMap.ContainsKey(dataId))
            {
                BroadcastDataCollection listeners = _dataBroadcastMap[dataId];
                if (listeners != null)
                {
                    listeners.RemoveListener(dataReceive);
                    if (listeners.NeedTidy)
                    {
                        _needTidy = true;
                    }
                }
            }
        }

        public void BroadcastData(BroadcastId broadcastId, IBroadcastData data, int flag = 0)
        {
            BroadcastData((int) broadcastId, flag, data);
        }
        
        private void BroadcastData(int dataId, int flag, IBroadcastData data)
        {
            if (dataId > 0 && _dataBroadcastMap.ContainsKey(dataId))
            {
                BroadcastDataCollection listeners = _dataBroadcastMap[dataId];
                try
                {
                    listeners.BroadcastData(flag, data);
                }
                catch (Exception e)
                {
                    GameLog.Log("BroadcastData", e);
                }
            }
        }

        public class BroadcastDataCollection
        {
            private List<BroadcastDataListener> _listenerList;
            private bool _needTidy;
            private bool _idle;
            private List<BroadcastDataListener> _addList;
            private List<BroadcastDataListener> _removeList;

            public BroadcastDataCollection()
            {
                _idle = true;
                _needTidy = false;
                _listenerList = new List<BroadcastDataListener>();
                _addList = new List<BroadcastDataListener>();
                _removeList = new List<BroadcastDataListener>();
            }

            public bool NeedTidy
            {
                get { return _needTidy; }
            }

            public void AddListener(BroadcastDataListener listener)
            {
                Tidy();
                if (listener != null)
                {
                    if (_removeList.Contains(listener))
                    {
                        _removeList.Remove(listener);
                    }
                    else if (!_listenerList.Contains(listener) && !_addList.Contains(listener))
                    {
                        if (_idle)
                            _listenerList.Add(listener);
                        else
                        {
                            _addList.Add(listener);
                            _needTidy = true;
                        }
                    }
                }
            }

            public void RemoveListener(BroadcastDataListener listener)
            {
                Tidy();
                if (listener != null)
                {
                    if (_addList.Contains(listener))
                    {
                        _addList.Remove(listener);
                    }
                    else if (_listenerList.Contains(listener) && !_removeList.Contains(listener))
                    {
                        if (_idle)
                            _listenerList.Remove(listener);
                        else
                        {
                            _removeList.Add(listener);
                            _needTidy = true;
                        }
                    }
                }
            }

            public void Tidy()
            {
                if (_needTidy && _idle)
                {
                    int index = 0;
                    for (; index < _removeList.Count; index++)
                    {
                        _listenerList.Remove(_removeList[index]);
                    }

                    _removeList.Clear();
                    for (index = 0; index < _addList.Count; index++)
                    {
                        _listenerList.Add(_addList[index]);
                    }

                    _addList.Clear();
                    _needTidy = false;
                }
            }

            public void BroadcastData(int flag, IBroadcastData data)
            {
                Tidy();
                _idle = false;
                int count = _listenerList.Count;
                for (int i = 0; i < count; i++)
                {
                    _listenerList[i](data, flag);
                }
                _idle = true;
            }
        }
    }
}