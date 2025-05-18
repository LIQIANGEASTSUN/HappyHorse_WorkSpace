using System;
using System.Collections;
using System.Collections.Generic;
using Cookgame.Stage;
using UnityEngine;

public class GameStageFactory : IStageFactory
{
    public IGameStage CreateStage(StageType stageType, string sceneName, StageLoadingType loadingType)
    {
        IGameStage result = null;
        switch (stageType)
        {
            case StageType.StageUpdate:
                result = new UpdatingStage(stageType, sceneName, loadingType);
                break;
            case StageType.StageLogin:
                result = new CheckLoginStage(stageType, sceneName, loadingType);
                break;
            case StageType.StageLobby:
                result = new LobbyStage(stageType, sceneName, loadingType);
                break;
            case StageType.StageGame:
                result = new GameRaceStage(stageType, sceneName, loadingType);
                break;
        }
        return result;
    }
}
