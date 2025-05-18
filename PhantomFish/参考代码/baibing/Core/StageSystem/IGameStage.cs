namespace Cookgame.Stage
{
    public enum StageLoadingType
    {
        StageLoaded = 0, //Scene已加载
        StageSyncLoad, //同步加载
        StageAsyncLoad, //异步加载
    }

    public enum StageState
    {
        StatePrepare = 0,
        StateResourceLoading,
        StateResourceLoaded,
        StateScenePrepare,
        StateSceneLoading,
        StateSceneLoaded,
        StateDone
    }

    public enum StageType
    {
        StageUpdate = 0,
        StageLogin,
        StageLobby,
        StageGame
    }

    public interface IGameStage
    {
        StageType StageType { get; set; }
        string StageName { get; set; }
        StageState State { get; set; }
        float LoadingProgress { get; set; }

        void ClearAllUI();
        void PrepareResource();
        void DoEnterStage();
        void DoLeaveStage();
        void DoDispose();
        void DoUpdate();
        void DoFixedUpdate();
        void DoLateUpdate();
        void OnLevelWasLoaded(bool isLoading);
    }
}