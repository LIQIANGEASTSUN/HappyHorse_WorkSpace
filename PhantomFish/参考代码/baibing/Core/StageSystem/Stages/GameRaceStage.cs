using System.Collections;
using Cookgame.Module;
using Cookgame.Panel;
using UnityEngine;

namespace Cookgame.Stage
{
    public class GameRaceStage : BaseStage
    {
        private GameRaceModule _gameRaceModule;
        private RacePanelBridgeBase _racePanelBridge;

        public RaceBase CurRace { get;private set; }

        public GameRaceStage(StageType stageType, string sceneName, StageLoadingType loadingType) : 
            base(stageType, sceneName, loadingType)
        {

        }

        protected override void OnInitStage()
        {
            _gameRaceModule = GameUtility.GetModule<GameRaceModule>(DataModuleEnum.GameRace);
            _racePanelBridge = RacePanelBridgeBase.CreatePanelFactory(_gameRaceModule.CurRaceType);
            _racePanelBridge.InitData();
        }

        public override void PrepareResource()
        {//未加载场景之前做的事  预加载场景所需的资源包括UI
            base.PrepareResource();
        }

        protected override void RegisterUIPrefabs()
        {
            _racePanelBridge.RegisterUI();
        }

        protected override IEnumerator OnEnterStage()
        {//场景加载完成了 可以初始化场景信息了
            CurRace = RaceBase.CreateRaceController(_gameRaceModule.CurRaceType);
            _racePanelBridge.OnEnterGameRace();
            yield return GameUtility.StartCoroutine(CurRace.InitRace());
            _racePanelBridge.OnRaceInitEnd();
        }

        protected override IEnumerator OnInitLayout()
        {
            yield return null;
        }

        protected override IEnumerator OnStageReady()
        {
            yield return null;
        }

        protected override IEnumerator OnLeaveStage()
        {
            _racePanelBridge.OnLeaveGameRace();
            _racePanelBridge = null;
            OnLeaveStageClear();



            yield return null;
        }

        protected override void OnDispose()
        {
        }

        public override void DoFrameUpdate()
        {
            base.DoFrameUpdate();
            CurRace?.DoUpdate();
            _racePanelBridge?.DoUpdate();
        }

        public override void DoLateUpdate()
        {
            base.DoLateUpdate();
            _racePanelBridge?.DoLateUpdate();
        }

        public override void DoFixedUpdate()
        {
            base.DoFixedUpdate();
            _racePanelBridge?.DoFixedUpdate();
        }


        private void OnLeaveStageClear()
        {
            CurRace.LeaveRace();
            DriveAidSystem.Instance.ClearInfo();
            if (MultiPlayerController.Instance != null)
            {
                MultiPlayerController.Instance.UnboundCameraTextures();
            }
        }
    }
}