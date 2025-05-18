using System;
using UnityEngine;


namespace Cookgame
{
    public sealed class GameWorld : MonoBehaviour
    {
        public const string GameDontDestroyRoot = "GameWorld";
        private static bool _isQuitApp;
        private bool _canDoUpdate;
        private ISystem[] _gameSystem;

        private static GameWorld _instance;
        public static GameWorld Instance
        {
            get
            {
                if (_instance == null)
                {
                    if (_isQuitApp)
                    {
                        GameLog.LogError("IsQuitApp but use GameWorld.Instance");
                        return null;
                    }
                    _instance = GetGameDontDestroyRoot().AddComponent<GameWorld>();
                    _instance.Initialize();
                }
                return _instance;
            }
        }

        private GameWorld() { }

        private void Initialize()
        {
            _gameSystem = new ISystem[(int) GameSystemEnum.SystemCount];
            //各个系统之间的初始化应该是有顺序的
            _gameSystem[(int) GameSystemEnum.AbRes] = AbRes = AbResSystem.Instance;
            _gameSystem[(int) GameSystemEnum.Broadcast] = Broadcast = new BroadcastSystem();
            _gameSystem[(int) GameSystemEnum.ConfigData] = ConfigData = new ConfigDataSystem();
            _gameSystem[(int) GameSystemEnum.DataModule] = DataModule = new DataModuleSystem();
            _gameSystem[(int) GameSystemEnum.Network] = Network = new NetworkSystem();
            _gameSystem[(int)GameSystemEnum.Stage] = Stage = new StageSystem();
            //_gameSystem[(int)GameSystemEnum.Lua] = Lua = new LuaSystem();
            _gameSystem[(int)GameSystemEnum.MessageDispatcher] = MessageDispatcher = new MessageDispatcherSystem();


            foreach (var system in _gameSystem)
            {
                system.InitSystem();
            }
            _canDoUpdate = true;
        }

        public static  AbResSystem AbRes { get; private set; }
        public static BroadcastSystem Broadcast { get; private set; }
        public static ConfigDataSystem ConfigData { get; private set; }
        public static DataModuleSystem DataModule { get; private set; }
        public static NetworkSystem Network { get; private set; }
        public static StageSystem Stage { get; private set; }
        public static Old_LuaSystem Lua { get; private set; }
        public static MessageDispatcherSystem MessageDispatcher { get; private set; }


        public T GetSystem<T>(GameSystemEnum system) where T : class, ISystem
        {
            int index = (int) system;
            if (index < 0 || index >= _gameSystem.Length)
            {
                return default;
            }
            return _gameSystem[index] as T;
        }


        public void InitData()
        {
            foreach (var system in _gameSystem)
            {
                system.InitData();
            }
        }

        void Update()
        {
            if (!_canDoUpdate) return;
            foreach (var system in _gameSystem)
            {
                system.DoUpdate();
            }
        }

        void LateUpdate()
        {
            if (!_canDoUpdate) return;
            foreach (var system in _gameSystem)
            {
                system.DoLateUpdate();
            }
        }

        void FixedUpdate()
        {
            if (!_canDoUpdate) return;
            foreach (var system in _gameSystem)
            {
                system.DoFixedUpdate();
            }
        }

        void OnApplicationPause(bool pauseStatus)
        {

        }

        void OnApplicationQuit()
        {
            Dispose();
            _instance = null;
            _isQuitApp = true;
        }

        void Dispose()
        {
            try
            {
                foreach (var system in _gameSystem)
                {
                    system.OnDispose();
                }
            }
            catch (Exception e)
            {
                GameLog.Log("GameWorld Dispose",e);
            }

            AbRes = null;
            Broadcast = null;
            ConfigData = null;
            DataModule = null;
            Network = null;
            Stage = null;
            Lua = null;
            MessageDispatcher = null;
        }

        private static GameObject _dontDestroyGo;
        public static GameObject GetGameDontDestroyRoot()
        {
            if (!_dontDestroyGo)
            {
                _dontDestroyGo = new GameObject(GameDontDestroyRoot);
                if(Application.isPlaying)
                    DontDestroyOnLoad(_dontDestroyGo);
            }
            return _dontDestroyGo;
        }
    }

    public enum GameSystemEnum : int
    {
        //各个System 在Initialize初始化  在Dispose里销毁
        AbRes,
        Broadcast,
        ConfigData,
        DataModule,
        Network,
        Stage,
        //Lua,
        MessageDispatcher,

        SystemCount
    }
}