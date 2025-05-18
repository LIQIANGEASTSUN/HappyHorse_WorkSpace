using System;
using System.Collections;
using Cookgame.ABResource;
using Cookgame.Network;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Cookgame.Stage
{
    public abstract class BaseStage : IGameStage
    {
        private StageType _stageState;
        public StageType StageType
        {
            get => _stageState;
            set => _stageState = value;
        }

        protected string mStageName;
        public string StageName
        {
            get { return mStageName; }
            set { mStageName = value; }
        }
        public StageState State { get; set; }
        public float LoadingProgress { get; set; }


        private readonly StageLoadingType _loadingType;
        private AsyncOperation _asyncOperation;
        private float _lastAsyncOperationProgress;
        private bool _isFirstResourceLoaded = true;
        private UIGameManager _uiManager;

        public UIGameManager UIManager => _uiManager;

        public const float PrepareProgress = 0.3f;
        public const float ResourceProgress = 0.2f;
        public const float LoadProgress = 0.5f;

        public BaseStage(StageType stageType, string sceneName, StageLoadingType loadingType)
        {
            StageType = stageType;
            StageName = sceneName;
            _loadingType = loadingType;
            _uiManager = new UIGameManager();
            _lastAsyncOperationProgress = 0f;
        }

        public void ClearAllUI()
        {
        }
        /// <summary>
        /// 场景加载完毕准备加载资源
        /// </summary>
        public virtual void PrepareResource()
        {
            PrepareUIPrefabResource();
        }

        public void DoEnterStage()
        {
            OnInitStage();
            _isFirstResourceLoaded = true;
            //AsgardGame.DataDispatcher.BroadcastData(GameLogicConst.DATA_TANK_ENTER_STAGE, _stageType, null);
            //((BaseStage)Stage).InitRelinkSys();
            switch (_loadingType)
            {
                case StageLoadingType.StageAsyncLoad:
                    //异步加载场景
                    DoAsyncSwitchGC();
                    break;
                case StageLoadingType.StageSyncLoad:
                    //同步加载场景
                    PrepareResource();
                    DoSyncSwitchScene();
                    break;
                case StageLoadingType.StageLoaded:
                    //场景已加载，只需要绑定代码
                    PrepareResource();
                    OnLevelWasLoaded();
                    break;
            }
        }
        protected void DoAsyncSwitchGC()
        {
            //异步加载
            State = StageState.StatePrepare;
            LoadingProgress = 0.0f;
            SceneManager.LoadScene(StageSystem.LoadingSceneLevel);
            GameUtility.WaitForFrameCount(2, () =>
            {
                _asyncOperation = Resources.UnloadUnusedAssets();
                _asyncOperation.allowSceneActivation = true;
                _lastAsyncOperationProgress = _asyncOperation?.progress ?? 0f;
            });
        }

        protected void DoSyncSwitchScene()
        {
            //真正切换场景
            State = StageState.StateSceneLoading;
            UnityEngine.SceneManagement.SceneManager.LoadScene(StageName);
        }

        public void OnLevelWasLoaded(bool isLoading = false)
        {
            if (isLoading)
            {
                //AsgardGame.AbResExplorer.DisposeUnusedAssets();
            }
            else
            {
                GameUtility.StartCoroutine(DoSceneEnterStage());
            }
        }

        IEnumerator DoSceneEnterStage()
        {
            UIManager.CheckAndCreateUINeed();
            State = StageState.StateSceneLoaded;
            yield return OnEnterStage();
            yield return OnInitLayout();
            yield return OnStageReady();

            yield return null;
            LoadingSceneManager.DestroyLoading();
            State = StageState.StateDone;
        }

        public void DoLeaveStage()
        {
            GameUtility.StartCoroutine(OnLeaveStage());
            _uiManager.ClearAllUI();
        }

        public void DoDispose()
        {
            OnDispose();
        }

        public void DoUpdate()
        {
            // GameWorld.Network.ConnectionOf()
            switch (State)
            {
                case StageState.StateDone:
                    DoFrameUpdate();
                    break;
                case StageState.StatePrepare:
                    if (_asyncOperation == null)
                        break;
                    if (!_asyncOperation.isDone)
                    {
                        if (!Mathf.Approximately(_lastAsyncOperationProgress, _asyncOperation.progress))
                        {
                            _lastAsyncOperationProgress = _asyncOperation.progress;
                            LoadingProgress = _lastAsyncOperationProgress * BaseStage.PrepareProgress;
                        }
                    }
                    else
                    {
                        _asyncOperation = null;
                        _lastAsyncOperationProgress = 0f;
                        //开始加载资源
                        LoadingProgress = BaseStage.PrepareProgress;
                        State = StageState.StateResourceLoading;
                        PrepareResource();
                    }
                    break;
                case StageState.StateResourceLoading:
                    break;
                case StageState.StateResourceLoaded:
                    if (_isFirstResourceLoaded)
                    {
                        _isFirstResourceLoaded = false;
                        LoadingProgress = BaseStage.PrepareProgress + BaseStage.ResourceProgress;
                        //资源加载完加载场景
#if UNITY_EDITOR && !USEAB
                        State = StageState.StateScenePrepare;

#else
                        if (_loadingType == StageLoadingType.StageAsyncLoad)
                        {
                            GameWorld.AbRes.LoadResourceAsync(GameUtility.GetFilePathByName(ScenePath + StageName, Cookgame.GameAbConfig.ScenePathRoot),
                                sceneRes =>
                                {
                                    //AsgardGame.AbResExplorer.UnloadResourcesByName(sceneRes.abResMapItem.AssetBundleName);
                                    State = StageState.StateScenePrepare;
                                });
                        }
                        else
                        {
                            State = StageState.StateScenePrepare;
                        }
#endif
                    }
                    break;
                case StageState.StateScenePrepare:
                    State = StageState.StateSceneLoading;
                    ClearAllUI();
                    _asyncOperation = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(StageName);
                    _asyncOperation.allowSceneActivation = true;
                    _lastAsyncOperationProgress = (_asyncOperation != null) ? _asyncOperation.progress : 0f;
                    break;
                case StageState.StateSceneLoading:
                    if (_asyncOperation == null)
                        break;

                    if (!_asyncOperation.isDone)
                    {
                        if (!Mathf.Approximately(_lastAsyncOperationProgress, _asyncOperation.progress))
                        {
                            _lastAsyncOperationProgress = _asyncOperation.progress;
                            LoadingProgress = BaseStage.PrepareProgress + BaseStage.ResourceProgress + _lastAsyncOperationProgress * BaseStage.LoadProgress;
                        }
                        else
                        {
                            _asyncOperation.allowSceneActivation = true;
#if !(UNITY_EDITOR && !USEAB)
                                if (_loadingType == StageLoadingType.StageAsyncLoad)
                                {
                                    //AsgardGame.AbResExplorer.UnloadResourcesByName(GameUtility.GetFilePathByName(ScenePath + _sceneName, Cookgame.GameAbConfig.ScenePath));
                                }
#endif
                        }
                    }
                    else
                    {
                        _asyncOperation = null;
                        _lastAsyncOperationProgress = 0f;

                        LoadingProgress = 1.0f;
                    }
                    break;
                case StageState.StateSceneLoaded:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private string ScenePath
        {
            get { return StageType == StageType.StageLobby ? "LobbyMap/" : "RaceMap/"; }
        }

        public virtual void DoFrameUpdate()
        {
            _uiManager.DoFrameUpdate();
        }

        public virtual void DoLateUpdate()
        {
        }
        protected void PrepareUIPrefabResource(Action complete=null)
        {
            RegisterUIPrefabs();
            if (complete == null)
                complete = UIPrefabLoadingComplete;
            StageUIPrefabsLoader.Instance.PrepareUIPrefabs(_uiManager, UIPrefabLoadingProgress, complete);
        }

        protected void UIPrefabLoadingProgress()
        {
            LoadingProgress = PrepareProgress + StageUIPrefabsLoader.Instance.LoadingProgress * ResourceProgress;
        }

        protected void UIPrefabLoadingComplete()
        {
            State = StageState.StateResourceLoaded;
        }

        public virtual void DoFixedUpdate()
        {
        }
        /// <summary>
        /// 准备进入新场景 还没有加载场景
        /// </summary>
        protected abstract void OnInitStage();
        /// <summary>
        /// 注册该场景所需要的UI界面  后面会同意加载UI
        /// </summary>
        protected abstract void RegisterUIPrefabs();
        /// <summary>
        /// 场景Scene 加载完毕 进入新场景
        /// </summary>
        protected abstract IEnumerator OnEnterStage();
        /// <summary>
        /// 初始化界面相关
        /// </summary>
        protected abstract IEnumerator OnInitLayout();
        /// <summary>
        /// 该场景所有东西准备就绪
        /// </summary>
        protected abstract IEnumerator OnStageReady();
        /// <summary>
        /// 即将推出该场景  做一些销毁工作
        /// </summary>
        protected abstract IEnumerator OnLeaveStage();
        /// <summary>
        /// 场景销毁
        /// </summary>
        protected abstract void OnDispose();
    }
}