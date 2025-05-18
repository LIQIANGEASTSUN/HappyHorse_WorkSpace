using UnityEngine;
using System.Collections;
using System;
using Cookgame.Entity;
using Cookgame.Module;
using Cookgame.Network;
using Cookgame.Stage;

namespace Cookgame
{
    public class GameMain : MonoBehaviour
    {
        void Start()
        {
            TimeManager.DefaultFixedDeltaTime = Time.fixedDeltaTime;
            GameWorld instance = GameWorld.Instance;

            //注册module
            InitModuleManager();
            InitNetwork();

            InitStage();
            GameWorld.Stage.EnterStage(StageType.StageUpdate);
        }
        private void InitModuleManager()
        {
            DataModuleSystem dataModule = GameWorld.DataModule;
            dataModule.RegisterModule(DataModuleEnum.GameRace, new GameRaceModule());
            dataModule.RegisterModule(DataModuleEnum.Player, new PlayerModule());
            dataModule.RegisterModule(DataModuleEnum.Entity,new EntityClientModule());
            dataModule.RegisterModule(DataModuleEnum.GridClient,new GridClientModule());
            dataModule.RegisterModule(DataModuleEnum.Login,new LoginModule());
            dataModule.RegisterModule(DataModuleEnum.Match,new MatchModule());
            dataModule.RegisterModule(DataModuleEnum.Car, new CarModule());
            dataModule.RegisterModule(DataModuleEnum.Garage, new GarageModule());
            dataModule.RegisterModule(DataModuleEnum.AutodromeMap, new AutodromeMapModule());
            dataModule.RegisterModule(DataModuleEnum.GameServer, new GameServerModule());
            dataModule.RegisterModule(DataModuleEnum.Knapsack,new KnapsackMoudle());
        }
        private void InitNetwork()
        {
            NetworkSystem networkSystem = GameWorld.Network;
            GameWorld.MessageDispatcher.NetworkManager = networkSystem;
            networkSystem.OnReceiveMessage = GameWorld.MessageDispatcher.ReceiveMessage;
            networkSystem.PrepareConnection(SessionType.Login, new MessageProtocal());
            networkSystem.PrepareConnection(SessionType.Lobby, new MessageProtocal());
            networkSystem.PrepareConnection(SessionType.Race, new MessageProtocal());
            networkSystem.CreateUdpConnect(new UdpMessageProtocal());
        }

        private void InitStage()
        {
            StageSystem stageSystem = GameWorld.Stage;
            stageSystem.SetStageFactory(new GameStageFactory());
            stageSystem.RegisterStage(StageType.StageUpdate, "UpdatingScene", StageLoadingType.StageLoaded);
            stageSystem.RegisterStage(StageType.StageLogin, "CheckLoginScene", StageLoadingType.StageSyncLoad);
            stageSystem.RegisterStage(StageType.StageLobby, "", StageLoadingType.StageAsyncLoad);
            stageSystem.RegisterStage(StageType.StageGame, "", StageLoadingType.StageAsyncLoad);
        }
    }
}
