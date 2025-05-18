using Cookgame.Panel;

namespace Cookgame
{
    public enum BroadcastId
    {
        RangeSize = 1000,
        //各个模块分段 一般区间100
        //广播监听用这个       GameUtility.RegisterBroadcast
        //取消广播监听用这个   GameUtility.UnRegisterBroadcast
        //新的广播用这个       GameUtility.BroadcastData

        #region UpdatingPanel
        UpdatingPanelBroadcastIdStart,
        UpdatingShowTxt,
        UpdatingUpdateProgress,
        #endregion
        #region LoginPanel
        LoginPanelBroadcastIdStart,
        LoginShowServerList,
        LoginStateLogin,
        #endregion
        #region TopViewPanel
        TopViewPanelBroadcastIdStart,
        TopViewPanelRef,
        #endregion
        #region CarModule
        CarModuleBroadcastIdStart,
        CarModuleASortCars,
        CarModuleShowCar,
        #endregion

        #region GaragePanel
        GaragePanelIdStart,
        GaragePanelChangeUseCar,


        #endregion

        #region KnapsackPanel
        KnapsackItemShow,
        #endregion



        #region Battle

        #region GameEffectBase
        GameEffectBaseBroadcastIdStart,
        MotionBlurEffect,
        RearviewMirrorEffect,
        LowNoneEffect,
        WeatherEffect,
        SecondNitrogenEffect,
        ColorGradingEffect,
        DepthOfFieldDeprecatedEffect,
        SoftParticlesEffect,
        SkidMarkEffect,
        RealShadow,
        GaragePostFxEffect,

        #endregion

        #region RaceBase
        RaceBroadcastIdStart,
        CurrentRaceStatusNeedChange,
        SetCountDownData,

        #endregion

        #region GameRacePanel
        GameRacePanelBroadcastIdStart,
        GameUICanInput,//开始游戏 可以输入
        TriggerCameraTypeChanged,

        SteerPanelLeftSteerState,//CarDriveController.inputState
        SteerPanelRightSteerState,
        NitrogenPanelNitrogenBtnState,
        NitrogenProgressPanelData,
        NitrogenPanelBrakeState,
        NitrogenPanelTurboState,
        NitrogenPanelQteState,
        CarSpeedPanelUpdateSpeed,
        CarSpeedPanelSpeedUnitChanged,//速度单位 NB
        CarSpeedPanelCurLapCountChanged,
        CarSpeedPanelTotalLapCountChanged,
        LapInfoPanelBestLapTimeChanged,
        LapInfoPanelCurLapTimeChanged,
        LapInfoPanelCurRankChanged,
        LapInfoPanelTotalCarsChanged,
        MiniMapPanelShowStateChanged,//NB
        StartCountdownChanged,
        StartOverCountdown,
        CurrentRaceStatusChanged,

        ShowPvpResultPanel,
        PvpResultPanelUpdate,

        PlayerRankPanelInit,
        PlayerRankPanelUpdate,

        #endregion


        #endregion



        #region LoadingPanel
        LoadingPanelUpdateTipsText,
        LoadingPanelUpdateProgress,
        RaceLoadingStateProgressChanged,

        #endregion

    }
}