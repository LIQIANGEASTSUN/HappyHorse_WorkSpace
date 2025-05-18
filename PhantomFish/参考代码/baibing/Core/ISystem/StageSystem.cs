using System.Collections.Generic;
using Cookgame.Stage;
using UnityEngine.SceneManagement;

namespace Cookgame
{
    public class StageSystem : ISystem
    {
        public const int LoadingSceneLevel = 1;
        private IStageFactory _stageFactory = null;
        private IGameStage _curStage;
        private List<IGameStage> _stageList;

        public void InitSystem()
        {
            _stageList = new List<IGameStage>();
            SceneManager.sceneLoaded += SceneWasLoaded;
        }
        public void InitData()
        {
        }


        public void OnDispose()
        {
            ClearStages();
        }

        public IGameStage CurStage => _curStage;

        public void SetStageFactory(IStageFactory stageFactory)
        {
            _stageFactory = stageFactory;
        }

        public IGameStage FindStage(StageType stageType)
        {
            int idx = IndexOfStage(stageType);
            return (idx >= 0) ? _stageList[idx] : null;
        }


        private int IndexOfStage(StageType stageType)
        {
            int result = -1;
            int stageCount = _stageList.Count;
            for (int i = 0; result < 0 && i < stageCount; i++)
            {
                if (stageType == _stageList[i].StageType)
                {
                    result = i;
                }
            }
            return result;
        }


        public void RegisterStage(StageType stageType, string stageName, StageLoadingType stageLoadType)
        {
            IGameStage stageRef = _stageFactory.CreateStage(stageType, stageName, stageLoadType);
            _stageList.Add(stageRef);
        }

        public void EnterStage(StageType stageType, string sceneName="")
        {
            IGameStage stage = FindStage(stageType);
            if (stage != null)
            {
                if (!string.IsNullOrEmpty(sceneName))
                {
                    stage.StageName = sceneName;
                }
                _curStage?.DoLeaveStage();
                _curStage = stage;
                _curStage.DoEnterStage();
            }
        }
        private void SceneWasLoaded(Scene scene, LoadSceneMode mode)
        {
             _curStage?.OnLevelWasLoaded(scene.buildIndex== LoadingSceneLevel);
        }

        private void ClearStages()
        {
            for (int i = 0; i < _stageList.Count; i++)
            {
                _stageList[i].DoDispose();
            }
            _stageList.Clear();
        }

        public void DoUpdate()
        {
            _curStage?.DoUpdate();
        }

        public void DoFixedUpdate()
        {
            if(CurStage.State == StageState.StateDone)
                _curStage?.DoFixedUpdate();
        }

        public void DoLateUpdate()
        {
            if (CurStage.State == StageState.StateDone)
                _curStage?.DoLateUpdate();
        }
    }
}
