using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using Cookgame.ABResource;
using Cookgame.Broadcast;
using Cookgame.Panel;
using Cookgame.Stage;
using FmodSounds;
using UnityEngine;
using UnityEngine.Networking;

namespace Cookgame.Stage
{
    public partial class UpdatingStage : BaseStage
    {
        HotUpdate hotUpdate = new HotUpdate();
        bool isRemoteServerCfgLoaded = false;
        public UpdatingStage(StageType stageType, string sceneName, StageLoadingType loadingType) : base(stageType, sceneName, loadingType)
        {
        }

        public override void DoFixedUpdate()
        {
        }

        protected override void OnInitStage()
        {
            
        }

        protected override void OnDispose()
        {
        }

        public override void PrepareResource()
        {
            RegisterUIPrefabs();
            UIPrefabsLoadedNotify();
        }

        protected override IEnumerator OnEnterStage()
        {
            yield return null;
        }

        private void UIPrefabsLoadedNotify()
        {
            GameUtility.GetPanel<UpdatingPanel>(GamePanelEnum.UpdatingPanel).Show();
            //检测热更
            //GameWorld.AbRes.AbResChecker.GetLatestVersion(DoEnterLoginStage);
            GameUtility.StartCoroutine(InitializeFrameWork());
        }

        private IEnumerator DoHotUpdateEnd()
        {
            yield return ExcelData.Instance.LoadData();
            yield return FmodCommon.Init();
            FmodCommon.LoadBankAssetBundle(EnumFmodBank.Bank_BGM_UI);
            FmodCommon.LoadBankAssetBundle(EnumFmodBank.Bank_UI_Panel);
            yield return null;
        }

        private IEnumerator InitializeFrameWork()
        {
            bool checkEnd = !GameConfig.IsEnableHotUpdate();
            if (GameConfig.IsEnableHotUpdate())
            {
                GameUtility.BroadcastData(BroadcastId.UpdatingShowTxt, new BroadcastData<string>("正在获取版本信息......"));
                GameWorld.AbRes.AbResChecker.GetLatestVersion(() => checkEnd = true);
                //先初始化本地资源列表
                yield return hotUpdate.InitLocalResourcesList();
            }
            yield return new WaitUntil(() => checkEnd);
            yield return DoHotUpdateEnd();

            if (GameConfig.IsEnableHotUpdate())
            {
                //进入热更新流程
                GameUtility.BroadcastData(BroadcastId.UpdatingShowTxt, new BroadcastData<string>("正在获取版本信息......"));
                //GameUtility.BroadcastData(BroadcastId.ResourceUpdateProgress, new ProgressInfo { type = ProgressInfo.ProgressType.CHACK_RES });
                //DispatcherProinfo(ProgressInfo.ProgressType.CHACK_RES);
                yield return hotUpdate.InitHotUpdate();
            }
            // 检查设备是否达到游戏的要求
            yield return CheckDeviceReachTheRequirement();

            //初始化服务器配置文件
            if (GameConfig.Instance.UseNetWork)
            {
                //初始化服务器配置
                if (GameConfig.Instance.useLocalServerConfig)
                {
                    //本地加载配置 获取dir文件
                    TextAsset assetDir = Resources.Load<TextAsset>("LoginDir");
                    string serverlistLink = string.Empty;
                    string textDir = Encoding.UTF8.GetString(assetDir.bytes);
                    InitServerDirFile(textDir, out serverlistLink);
                    GameLog.Log("【SetTCPClient】【解析目录服文件】 ip:" + GameConfig.Instance.host + ",port:" + GameConfig.Instance.port);
                    
                    //请求服务器配置文件
                    TextAsset assetServerlist = Resources.Load<TextAsset>("serverlist");
                    string textServerlist = Encoding.UTF8.GetString(assetServerlist.bytes);
                    InitServerListFromConfigXml(textServerlist);

                    isRemoteServerCfgLoaded = true;
                }
                else
                {
                    //http加载配置
                    yield return RefreshServerConfig();
                }
                yield return new WaitUntil(() => isRemoteServerCfgLoaded);
                InitRecentServerList();
            }

            //GameUtility.BroadcastData(BroadcastId.ResourceUpdateProgress, new ProgressInfo { type = ProgressInfo.ProgressType.LOAD_META_DATA_FINISH, Progress = 1 });
            DoEnterLoginStage();
        }


        //初始化最近登录服务器列表
        private void InitRecentServerList()
        {
            //获取最近登录服务器列表
            string tempStr = PlayerPrefs.GetString(ServerDM.RECENT_SERVERLIST, string.Empty);
            int tempInt = 0;
            string[] wordIds = tempStr.Split(',');
            for (int i = 0; i < wordIds.Length; ++i)
            {
                tempInt = 0;
                int.TryParse(wordIds[i], out tempInt);
                if (tempInt > 0)
                    ServerDM.recentServerList.Add(tempInt);
            }
        }

        //从http下载 IP过滤表、服务器配置表 、并初始化服务器列表
        private IEnumerator RefreshServerConfig()
        {
            if (isRemoteServerCfgLoaded == false)
            {
                // 循环等待服务器配置文件下载，每10秒一轮，超过5秒提示耐心等待
                //ServerTimeoutHandler.instance.WaitingServer(WAIT_TIME, true, 5);

                int MAX_TRY_COUNT = 3;
                string serverlistLink = string.Empty;
                string msg;
                int loopCount = 1;
                bool needtry = true;
                bool fetchDirRes = false;
                bool fetchServerLstRes = false;

                while (needtry && fetchDirRes == false)
                {
                    //外网配置路径
                    string loginDir = "https://s-1000113702.gamebean.net/" + GameConfig.Instance.VersionName + "_LoginDir.xml";
                    //内网配置路径
                    if (GameConfig.Instance.useInternalNetwork)
                        loginDir = "https://s-1000113702.gamebean.net/top_loginDir.xml";

                    UnityWebRequest request = UnityWebRequest.Get(loginDir);
                    GameLog.Log("开始第" + loopCount + "次下载目录文件," + loginDir);
                    yield return request.SendWebRequest();

                    if (!string.IsNullOrEmpty(request.error))
                    {
                        GameLog.Log(request.error);
                    }
                    else
                    {
                        string text = Encoding.UTF8.GetString(request.downloadHandler.data);
                        fetchDirRes = InitServerDirFile(text, out serverlistLink);
                    }

                    if (false == fetchDirRes)
                    {
                        loopCount++;
                        if (loopCount > MAX_TRY_COUNT)
                            needtry = false;

                        // 还可以继续尝试
                        if (needtry)
                        {
                            msg = "拉取目录文件失败，正在尝试第 " + loopCount + " 次拉取...";
                            GameUtility.ShowMessageTips(msg);
                        }
                        // 超过指定失败次数，提示退出游戏重试
                        else
                        {
                            msg = "拉取目录文件失败！";
                            //-----这里提示退出游戏
                            //ShowLoadConfigFailedMsg();
                        }
                        GameLog.LogWarning(msg);
                        yield return new WaitForSeconds(2f);
                    }
                }

                if (fetchDirRes)
                {
                    loopCount = 1;
                    needtry = true;

                    while (needtry && fetchServerLstRes == false)
                    {
                        //请求服务器配置文件
                        UnityWebRequest wwwServerlist = UnityWebRequest.Get(serverlistLink);
                        GameLog.Log("开始第" + loopCount + "次下载服务器列表文件," + serverlistLink);
                        yield return wwwServerlist.SendWebRequest();

                        if (!string.IsNullOrEmpty(wwwServerlist.error))
                        {
                            GameLog.Log(wwwServerlist.error);
                        }
                        else
                        {
                            string text = Encoding.UTF8.GetString(wwwServerlist.downloadHandler.data);
                            fetchServerLstRes = InitServerListFromConfigXml(text);
                        }

                        if (false == fetchServerLstRes)
                        {
                            loopCount++;
                            if (loopCount > MAX_TRY_COUNT)
                                needtry = false;

                            // 还可以继续尝试
                            if (needtry)
                            {
                                msg = "拉取服务器列表文件失败，正在尝试第 " + loopCount + " 次拉取...";
                                GameUtility.ShowMessageTips(msg);
                            }
                            // 超过指定失败次数，提示退出游戏重试
                            else
                            {
                                msg = "拉取服务器列表文件失败！";
                                //ShowLoadConfigFailedMsg();
                            }
                            GameLog.LogWarning(msg);
                            yield return new WaitForSeconds(2f);
                        }
                    }

                    isRemoteServerCfgLoaded = fetchServerLstRes;
                }
                else
                {
                    isRemoteServerCfgLoaded = false;
                }
                //ServerTimeoutHandler.instance.HandleResponse();
                //trnPanelQuit.gameObject.SetActive(!isRemoteServerCfgLoaded);
                yield return null;
            }
        }

        //解析Logindir文件
        private bool InitServerDirFile(string text, out string serverlistLink)
        {
            serverlistLink = string.Empty;
            try
            {
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(text);
                XmlNode root = doc.SelectSingleNode("scheme");

                //如果是内部包，使用配置中id
                //外部包使用包体本身打包进的id
                //暂时适配
                XmlNode entry = null;
                ServerDM.configAreaId = 0;
                entry = root.ChildNodes[0];
                if (!GameConfig.Instance.useInternalNetwork && root.ChildNodes.Count > 1)
                {
                    entry = root.ChildNodes[1];  //选择外网

                    //foreach (var rootChildNode in root.ChildNodes)
                    //{
                    //    XmlElement xmlElement = (XmlElement)rootChildNode;
                    //    string curAreaId = xmlElement.GetAttribute("id");

                    //    if (curAreaId == "100")
                    //    {
                    //        entry = (XmlNode)rootChildNode;
                    //        break;
                    //    }
                    //}
                }


                XmlElement entryE = (XmlElement)entry;
                string defaultEnteryAreaId = entryE.GetAttribute("id");

                ServerDM.DirEndpointDic.Clear();

                for (int i = 0; i < entry.ChildNodes.Count; ++i)
                {
                    XmlNode area = entry.ChildNodes[i];
                    XmlElement areaE = (XmlElement)area;
                    string curAreaId = areaE.GetAttribute("id");

                    long tick = System.DateTime.Now.Ticks;
                    int endPointCount = 0;
                    int serverListLinkCount = 0;
                    for (int j = 0; j < area.ChildNodes.Count; ++j)
                    {
                        if (area.ChildNodes[j].Name.Equals("endPoint"))
                        {
                            ++endPointCount;
                        }
                        else
                        {
                            ++serverListLinkCount;
                        }
                    }
                    ////包括min 不包括max
                    System.Random rd = new System.Random((int)((tick + i) & 0xffffffffL) | (int)(tick >> 32)); //包括min 不包括max
                    int randomEpIdx = rd.Next(0, endPointCount);


                    XmlNode n = area.ChildNodes[randomEpIdx];
                    XmlElement endpoint = (XmlElement)n;

                    DirEndpointInfo info = new DirEndpointInfo();
                    info.ip = endpoint.GetAttribute("ip");
                    info.port = int.Parse(endpoint.GetAttribute("port"));

                    ServerDM.DirEndpointDic.Add(int.Parse(curAreaId), info);

                    int randomLinkIdx = rd.Next(endPointCount, endPointCount + serverListLinkCount);

                    if (curAreaId == defaultEnteryAreaId)
                    {
                        serverlistLink = ((XmlElement)area.ChildNodes[randomLinkIdx]).GetAttribute("http");
                    }
                }

                //获取配置表中选择的区域id
                ServerDM.configAreaId = int.Parse(((XmlElement)entry).GetAttribute("id"));
                ServerDM.serverAreaId = ServerDM.configAreaId;
            }
            catch (System.Exception e)
            {
                GameLog.LogError("解析服务器目录配置文件出错:" + e.StackTrace);
                return false;
            }
            return true;
        }

        //解析serverList文件
        private bool InitServerListFromConfigXml(string text)
        {
            try
            {
                //GameLog.Log(text);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(text);
                XmlNode root = doc.SelectSingleNode("scheme");

                //如果是内部包，使用配置中id
                //外部包使用包体本身打包进的id
                //暂时适配
                XmlNode entry = root.ChildNodes[0];
                if (!GameConfig.Instance.useInternalNetwork && root.ChildNodes.Count > 1)
                    entry = root.ChildNodes[1];

                XmlElement entryE = (XmlElement)entry;
                var attribute = entryE.GetAttribute("id");

                bool bLimit = string.IsNullOrEmpty(attribute) == false;   //如果有指定id，则不显示全部area
                int areaLimitId = -1;
                if (bLimit)
                {
                    areaLimitId = int.Parse(attribute);
                }

                ServerDM.ServerDic.Clear();
                ServerDM.recommandServerList.Clear();

                for (int i = 0; i < entry.ChildNodes.Count; ++i)
                {
                    XmlNode area = entry.ChildNodes[i];
                    XmlElement areaE = (XmlElement)area;
                    int areaId = int.Parse(areaE.GetAttribute("id"));
                    XmlElement info;

                    for (int j = 0; j < area.ChildNodes.Count; ++j)
                    {
                        info = (XmlElement)area.ChildNodes[j];
                        ServerInfo serverInfo =
                            new ServerInfo
                            {
                                serverLogicId = int.Parse(info.GetAttribute("serverLogicId")),
                                name = info.GetAttribute("name"),
                                listName = info.GetAttribute("listName"),
                                areaId = areaId,
                                recommand = info.GetAttribute("recommand"),
                            };

                        if (bLimit)
                        {
                            if (serverInfo.areaId == areaLimitId)
                                ServerDM.ServerDic.Add(serverInfo.serverLogicId, serverInfo);
                        }
                        else
                        {
                            ServerDM.ServerDic.Add(serverInfo.serverLogicId, serverInfo);
                        }

                        //recommand
                        int recommand = int.Parse(info.GetAttribute("recommand"));
                        if (recommand > 0)
                            ServerDM.recommandServerList.Add(serverInfo.serverLogicId);
                    }
                }
            }
            catch (System.Exception e)
            {
                GameLog.LogError("解析服务器列表配置文件出错:" + e.StackTrace);
                return false;
            }
            return true;
        }
        private void DoEnterLoginStage()
        {
            GameUtility.StartCoroutine(OnEnterLogin());
        }

        IEnumerator OnEnterLogin()
        {
            yield return ExcelData.Instance.LoadData();
            GameWorld.Instance.InitData();
            GameWorld.Stage.EnterStage(StageType.StageLogin);
        }

        protected override IEnumerator OnLeaveStage()
        {
            FmodCommon.UnLoadBankAssetBundle(EnumFmodBank.Bank_BGM_UI);
            FmodCommon.UnLoadBankAssetBundle(EnumFmodBank.Bank_UI_Panel);
            yield return null;
        }

        protected override IEnumerator OnInitLayout()
        {
            yield return null;
        }

        protected override IEnumerator OnStageReady()
        {
            yield return null;
        }

        public override void DoLateUpdate()
        {
        }


        // 检测手机是否达到要求
        IEnumerator CheckDeviceReachTheRequirement()
        {
#if UNITY_EDITOR
            yield return null;

#elif UNITY_ANDROID && CHECK_ANDROID_DEVICE
        if (GameConfig.Instance.androidDeviceLevel.enableCheck)
        {
            bool check_os_valid = false;
            bool check_mem_valid = false;
            string osSTR = SystemInfo.operatingSystem; // "Android OS 5.1 / API-22 (LMY47I/2134)"; //
            int startID = osSTR.IndexOf("API-");
            int endID = osSTR.IndexOf(" (");
            if (startID != -1 && endID != -1)
            {
                startID += 4;
                string os = osSTR.Substring(startID, endID - startID);
                int osLV = int.Parse(os);
                // 小于5.1的系统
                if (osLV < GameConfig.Instance.androidDeviceLevel.minAndroidOSVersion)
                {
                    MessageBox.ShowMsgBox(282, () =>
                    {
                        Application.Quit();
                    });
                }
                else
                    check_os_valid = true;
            }
            if (check_os_valid)
            {
                int memsize = SystemInfo.systemMemorySize + SystemInfo.graphicsMemorySize;
                if (memsize < GameConfig.Instance.androidDeviceLevel.minRAMSize)
                {
                    MessageBox.ShowMsgBox(282, () =>
                    {
                        Application.Quit();
                    });
                }
                else
                    check_mem_valid = true;
            }
            yield return new WaitUntil(() => check_mem_valid == true);
        }
        else
        {
            yield return null;
        }
#else
        yield return null;

#endif
        }
    
    }

}
