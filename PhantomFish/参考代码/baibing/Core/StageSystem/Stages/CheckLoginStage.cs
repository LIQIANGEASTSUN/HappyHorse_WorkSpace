using System.Collections;
using System.Collections.Generic;
using Cookgame;
using Cookgame.Panel;
using UnityEngine;

namespace Cookgame.Stage
{
    public partial class CheckLoginStage : BaseStage
    {
        public CheckLoginStage(StageType stageType, string sceneName, StageLoadingType loadingType) : base(stageType,
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
            RegisterUIPrefabs();
            
            yield return null;
        }

        protected override IEnumerator OnInitLayout()
        {
            //加载登录界面
            //  GameUtility.OpenPanel();
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