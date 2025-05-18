using System;
using System.Collections.Generic;
using Cookgame.ABResource;
using Cookgame.Panel;

namespace Cookgame.Stage
{
    public partial class StageUIPrefabsLoader
    {
        public void RegisterCommonUIPrefabs(UIGameManager uiManager)
        {
            uiManager.RegisterPanel<MessageTipsPanel>(GamePanelEnum.MessageTipsPanel);
            uiManager.RegisterPanel<MessageBoxPanel>(GamePanelEnum.MessageBoxPanel);
            uiManager.RegisterPanel<LoadingCommonPanel>(GamePanelEnum.LoadingCommonPanel);
        }
    }

    public partial class LobbyStage
    {
        protected override void RegisterUIPrefabs()
        {
            UIManager.RegisterPanel<TopViewPanel>(GamePanelEnum.TopViewPanel,"TopViewPanel");
            UIManager.RegisterPanel<LobbyPanel>(GamePanelEnum.LobbyPanel,"LobbyPanel");
            UIManager.RegisterPanel<GaragePanel>(GamePanelEnum.GaragePanel, "GaragePanel");
            UIManager.RegisterPanel<KnapsackPanel>(GamePanelEnum.KnapsackPanel, "KnapsackPanel");
            UIManager.RegisterPanel<AddItemsOnEditor>(GamePanelEnum.AddItemsOnEditor, "AddItemsOnEditor");
            UIManager.RegisterPanel<CompoundCarPanel>(GamePanelEnum.CompoundCarPanel, "CompoundCarPanel");
        }
    }

    public partial class CheckLoginStage
    {
        protected override void RegisterUIPrefabs()
        {
            UIManager.RegisterPanel<LoginPanel>(GamePanelEnum.LoginPanel, "LoginPanel");
            UIManager.RegisterPanel<CreatePlayerPanel>(GamePanelEnum.CreatePlayerPanel, "CreatePlayerPanel");
        }
    }

    public partial class UpdatingStage
    {
        protected override void RegisterUIPrefabs()
        {
            UIManager.RegisterPanel<UpdatingPanel>(GamePanelEnum.UpdatingPanel, "UpdatingPanel");
            StageUIPrefabsLoader.Instance.RegisterCommonUIPrefabs(UIManager);
        }
    }



    public partial class StageUIPrefabsLoader
    {
        private const float ScenefileProgress = 0.1f;
        private const float DependenciesProgress = 0.8f;
        private Action _mLoaderCompleteDel;
        private Action _mLoaderProgressDel;

        private int mBatchCount;
        private int mLoadedCount;
        private float mLoadingProgress;
        private static StageUIPrefabsLoader instance;

        public static StageUIPrefabsLoader Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new StageUIPrefabsLoader();
                }
                return instance;
            }
        }

        private StageUIPrefabsLoader()
        {
            this.InitUIPrefabsHelper();
        }

        private void InitUIPrefabsHelper()
        {
            mBatchCount = 0;
            mLoadingProgress = 0f;
            mLoadedCount = 0;
            _mLoaderCompleteDel = null;
            _mLoaderProgressDel = null;
        }

        public float LoadingProgress
        {
            get { return mLoadingProgress; }
        }

        public void PrepareUIPrefabs(UIGameManager uiManager, Action progressNotify, Action completeNotify)
        {
            this.InitUIPrefabsHelper();
            RegisterCommonUIPrefabs(uiManager);
            this._mLoaderProgressDel = progressNotify;
            this._mLoaderCompleteDel = completeNotify;
            List<string> list = new List<string>();


            Dictionary<int, UIPanelPrefabConfig> prefabsTable = uiManager.UIPanelPrefabsTable;
            foreach (UIPanelPrefabConfig config in prefabsTable.Values)
            {
                list.Add(GameUtility.GetFilePathByName(config.RootName, GameAbConfig.UIPrefabPathRoot));
                if (config.Depend != null)
                {
                    for (int i = 0; i < config.Depend.Count; i++)
                    {
                        list.Add(GameUtility.GetFilePathByName(config.Depend[i], GameAbConfig.UIPrefabPathRoot));
                    }
                }
            }

            GameUtility.LoadUIPrefab(list, AllResoruceLoaded, ResourceItemLoaded);
            mBatchCount = list.Count;
            mLoadedCount = 0;
        }

        private void ResourceItemLoaded(BaseResource resource)
        {
            mLoadedCount++;
            if (mBatchCount > 0)
            {
                mLoadingProgress = ScenefileProgress + mLoadedCount * DependenciesProgress / mBatchCount;
            }
            if (_mLoaderProgressDel != null)
                _mLoaderProgressDel();
        }

        private void AllResoruceLoaded(List<BaseResource> baseResource)
        {
            if (_mLoaderCompleteDel != null)
                _mLoaderCompleteDel();
            _mLoaderCompleteDel = null;
            _mLoaderProgressDel = null;
        }
    }
}