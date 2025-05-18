namespace Cookgame.Stage
{
    public interface IStageFactory
    {
        IGameStage CreateStage(StageType stageType,string sceneName,StageLoadingType loadingType);
    }
}