using System.Collections;
using System.Collections.Generic;
using Cookgame.Panel;
using UnityEngine;

namespace Cookgame.Stage
{
    public partial class LobbyStage : BaseStage
    {
        public LobbyStage(StageType stageType, string sceneName, StageLoadingType loadingType) : base(stageType,
            sceneName, loadingType)
        {
        }

        protected override void OnInitStage()
        {
        }

        public override void PrepareResource()
        {
            base.PrepareResource();
        }
        protected override IEnumerator OnEnterStage()
        {
            yield return 0;
        }

        protected override IEnumerator OnInitLayout()
        {
            GameUtility.GetPanel<LobbyPanel>(GamePanelEnum.LobbyPanel).Show();
            GameUtility.BroadcastData(BroadcastId.CarModuleShowCar,null);
            yield return 0;
        }

        protected override IEnumerator OnStageReady()
        {
            yield return 0;
        }

        protected override IEnumerator OnLeaveStage()
        {
            yield return 0;
        }

        protected override void OnDispose()
        {
        }
    }
}