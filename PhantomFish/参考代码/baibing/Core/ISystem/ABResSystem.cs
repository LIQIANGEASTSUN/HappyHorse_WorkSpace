using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using Cookgame.ABResource;
using UnityEngine;

namespace Cookgame
{
    public class AbResSystem : ISystem
    {
        private BaseResource[] allResourceList;
        public Dictionary<string, BaseResource> mResourcesMap = new Dictionary<string, BaseResource>();
        private Dictionary<IconsAtlasType, BaseResource> mAtlasResMap = new Dictionary<IconsAtlasType, BaseResource>();
        private ShaderResource _shaderResource;

        private List<IAbSystem> _systems = new List<IAbSystem>();

        public ABResChecker AbResChecker { get; private set; }

        public ABResLoaderManager AbResLoader { get; private set; }

        public ABResBackDownloader AbResDownloader { get; private set; }

        //public ABResThreadPoll AbResThreadPoll { get; private set; }

        private static AbResSystem _instance;
        private AbResSystem() { }
        public static AbResSystem Instance
        { get { return _instance ?? (_instance = new AbResSystem()); } }

        private BaseResource _tempResource;

        public string LuaCodePath { get; private set; }
        public void InitSystem()
        {
            _systems.Add(AbResChecker = new ABResChecker());
            _systems.Add(AbResLoader = new ABResLoaderManager());
            _systems.Add(AbResDownloader = new ABResBackDownloader());
            //_systems.Add(AbResThreadPoll = new ABResThreadPoll());

            for (int i = 0; i < _systems.Count; i++)
            {
                _systems[i].InitSystem();
            }
        }

        public void InitData()
        {
            
        }

        public void DoFixedUpdate()
        {

        }

        public void DoLateUpdate()
        {

        }

        public void OnDispose()
        {
            for (int i = 0; i < _systems.Count; i++)
            {
                _systems[i].DisposeSystem();
            }
            foreach (var item in mAtlasResMap.Values)
            {
                item.ReduceReferenceCount();
            }
            mAtlasResMap.Clear();
            mAtlasResMap = null;

            if (allResourceList != null)
            {
                int resourceIndex;
                for (resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
                {
                    _tempResource = allResourceList[resourceIndex];
                    if ((_tempResource.AbResMapItem.ABResLoadType & ABResMapScriptObj.AlwaysResourcesType) > 0)
                    {
                        _tempResource.ReduceReferenceCount();
                    }
                    _tempResource.Dispose();
                }
                for (resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
                {
                    _tempResource = allResourceList[resourceIndex];
                    _tempResource.ClearDependList();
                }
            }
            mResourcesMap.Clear();
            mResourcesMap = null;

            if (allResourceList != null)
            {
                for (int i = 0; i < allResourceList.Length; i++)
                {
                    _tempResource = allResourceList[i];
                    if (_tempResource.CurResourceState == BaseResource.ResourceState.Loaded)
                    {
                        DebugLog(string.Format("资源还有引用 {0}", _tempResource.AbResMapItem.AssetBundleName));
                    }
                    allResourceList[i] = null;
                }
                allResourceList = null;
            }
            _tempResource = null;
            _instance = null;
            DebugLog("所有对象置空完毕");
            GC.Collect();
        }

        public void DoUpdate()
        {
            for (int i = 0; i < _systems.Count; i++)
            {
                _systems[i].DoFrameUpdate();
            }
        }


        internal void SetCodePath(string codePath)
        {
            DebugLog($"curLuaRootPath = '{Path.GetFullPath(codePath).Replace("\\", "/")}'");
            LuaCodePath = codePath;
        }
        /// <summary>
        /// 创建所有资源 游戏开始时调用
        /// </summary>
        internal void CreateAllResources(BaseResource[] allResList)
        {
            Array.Sort(allResList, ResourceSort);
            List<BaseResource> mainResourceList = new List<BaseResource>();
            for (int i = 0; i < allResList.Length; i++)
            {
                allResList[i].DependResourceList = FindDependResource(allResList[i], allResList);
                if (allResList[i].AbResMapItem.IsMainAsset)
                {
                    mainResourceList.Add(allResList[i]);
                }
                //else
                //{
                //    //break;
                //    _tempResource = allResList[i];
                //}
            }

            for (int j = 0; j < mainResourceList.Count; j++)
            {
                _tempResource = mainResourceList[j];
                //_tempResource.DependResourceList = FindDependResource(_tempResource, allResList);
                string key = _tempResource.AbResMapItem.AssetBundleName;
                if (mResourcesMap.ContainsKey(key))
                {
                    DebugLog(string.Format("CreateAllResources  SameKey {0}  {1}<=>{2}", _tempResource.AbResMapItem.AssetBundleName,
                        JsonUtility.ToJson(mResourcesMap[key].AbResMapItem.DependAssetBundleName), JsonUtility.ToJson(_tempResource.AbResMapItem.DependAssetBundleName)), true);
                    continue;
                }

                mResourcesMap.Add(key, _tempResource);
                if (_tempResource.AbResMapItem.ABResLoadType == ABResMapScriptObj.ABLoadTypeGuiAtlas)
                {
                    AtlasResource res = _tempResource as AtlasResource;
                    if (res != null && res.AtlasType != IconsAtlasType.None && !mAtlasResMap.ContainsKey(res.AtlasType))
                    {
                        _tempResource.AddReferenceCount();
                        mAtlasResMap.Add(res.AtlasType, res);
                    }
                }
                else if (_tempResource.AbResMapItem.ABResLoadType == ABResMapScriptObj.ABLoadTypeShader)
                {
                    _shaderResource = _tempResource as ShaderResource;
                }

                if ((_tempResource.AbResMapItem.ABResLoadType & ABResMapScriptObj.AlwaysResourcesType) > 0)
                {
                    _tempResource.AddReferenceCount();
                }
            }
            DebugLog("CreateAllResources  mAtlasResMap  " + mAtlasResMap.Count);
            this.allResourceList = allResList;
            mainResourceList.Clear();
            //GC.Collect();
        }

        private static int ResourceSort(BaseResource x, BaseResource y)
        {
            //if (x.abResMapItem.ABResType == y.abResMapItem.ABResType)
            //{
            //    return x.abResMapItem.IsMainAsset ? -1 : 1;
            //}
            return y.AbResMapItem.ABResType - x.AbResMapItem.ABResType;
        }

        private List<BaseResource> FindDependResource(BaseResource mainResource, BaseResource[] allResList)
        {
            List<BaseResource> result = new List<BaseResource>();
            for (int i = 0; i < allResList.Length; i++)
            {
                if (mainResource.AbResMapItem.DependAssetBundleName.Contains(allResList[i].AbResMapItem.AssetBundleName))
                {
                    result.Add(allResList[i]);
                }
            }
            return result;
        }

        /// <summary>
        /// 异步 通过类型加载资源AB (比如只加载UI类型资源AB)
        /// </summary>
        /// <param name="AbLoadType"></param>

        public void GetResourcesByType(int[] loadTypes, Action<List<BaseResource>> allFinishAction, Action<BaseResource> itemFinishAction = null)
        {
            if (allResourceList == null) return;
            List<BaseResource> list = new List<BaseResource>();
            for (int i = 0; i < loadTypes.Length; i++)
            {
                for (int resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
                {
                    _tempResource = allResourceList[resourceIndex];
                    if (_tempResource.AbResMapItem.ABResLoadType == loadTypes[i])
                    {
                        list.Add(_tempResource);
                    }
                }
            }
            AbResLoader.LoadResources(list, allFinishAction, itemFinishAction);
        }

        /// <summary>
        /// 异步 通过类型 下载资源 
        /// </summary>
        /// <param name="loadTypes"></param>
        /// <param name="allFinishAction"></param>
        /// <param name="itemFinishAction"></param>
        public int DownLoadResourceByType(int[] loadTypes, Action<List<BaseResource>> allFinishAction, Action<BaseResource> itemFinishAction = null, List<string> assetBundleNames = null)
        {
            if (allResourceList == null) return 0;
            List<BaseResource> list = new List<BaseResource>();
            for (int i = 0; i < loadTypes.Length; i++)
            {
                for (int resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
                {
                    _tempResource = allResourceList[resourceIndex];
                    if (_tempResource.AbResMapItem.ABResLoadType == loadTypes[i])
                    {
                        if (_tempResource.NeedUpdateFromCdn)
                            list.Add(_tempResource);
                    }
                }
            }

            if (assetBundleNames != null && assetBundleNames.Count > 0)
            {
                for (int i = 0; i < assetBundleNames.Count; i++)
                {
                    string abName = assetBundleNames[i];
                    if (mResourcesMap.ContainsKey(abName))
                    {
                        _tempResource = mResourcesMap[abName];
                        if (_tempResource.NeedUpdateFromCdn && !list.Contains(_tempResource))
                            list.Add(_tempResource);
                    }
                }
            }

            DebugLog(string.Format("DownLoadResourceByType  TotleCount={0}    needDownload={1}", mResourcesMap.Count, list.Count));
            AbResLoader.LoadResources(list, allFinishAction, itemFinishAction, true);
            return list.Count;
        }

        /// <summary>
        /// 异步 通过名称 下载资源
        /// </summary>
        /// <param name="loadTypes"></param>
        /// <param name="allFinishAction"></param>
        /// <param name="itemFinishAction"></param>
        public int DownLoadResourceByName(List<string> assetBundleNames, Action<List<BaseResource>> allFinishAction, Action<BaseResource> itemFinishAction = null)
        {
            List<BaseResource> list = new List<BaseResource>();
            for (int i = 0; i < assetBundleNames.Count; i++)
            {
                string abName = assetBundleNames[i];
                if (mResourcesMap.ContainsKey(abName))
                {
                    _tempResource = mResourcesMap[abName];
                    if (_tempResource.NeedUpdateFromCdn)
                        list.Add(_tempResource);
                }
            }
            AbResLoader.LoadResources(list, allFinishAction, itemFinishAction, true);
            return list.Count;
        }

        public void UnloadResource(int loadType)
        {
            if (allResourceList == null) return;
            DebugLog("卸载资源 loadType == " + loadType);
            for (int resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
            {
                _tempResource = allResourceList[resourceIndex];
                if (_tempResource.AbResMapItem.ABResLoadType == loadType)
                {
                    _tempResource.UnLoad();
                }
            }
            DebugLog("卸载资源完毕 loadType == " + loadType);
        }

        public void UnloadResource(int[] loadTypes)
        {
            if (allResourceList == null) return;
            DebugLog("卸载资源");
            HashSet<int> types = new HashSet<int>(loadTypes);

            for (int resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
            {
                _tempResource = allResourceList[resourceIndex];
                if (types.Contains(_tempResource.AbResMapItem.ABResLoadType))
                {
                    _tempResource.UnLoad();
                }
            }
            DebugLog("卸载资源完毕");
        }

        public void UnloadResource(string[] names)
        {
            for (int i = 0; i < names.Length; i++)
            {
                if (mResourcesMap.TryGetValue(TrimName(names[i]), out var res))
                {
                    UnloadResource(res);
                }
            }
        }

        public void UnloadResource(string name)
        {
            if (mResourcesMap.TryGetValue(TrimName(name), out var res))
            {
                UnloadResource(res);
            }
        }

        public void UnloadResource(BaseResource res)
        {
            res?.UnLoad();
        }

        public void UnloadUnusedAssets()
        {
            DebugLog("卸载无用资源");
            if (allResourceList != null)
            {
                //ProcessResourcesReferenceCount(mAtlasResMap.Values, false);
                //优化 mResourcesMap的前mResourcesMap.Count 是主资源
                for (int i = 0; i < mResourcesMap.Count; i++)
                {
                    allResourceList[i].UnLoad();
                }
                //ProcessResourcesReferenceCount(mAtlasResMap.Values, true);
            }
            DebugLog("卸载资源完毕");
        }

        private void ProcessResourcesReferenceCount(IEnumerable<BaseResource> list, bool add)
        {
            foreach (var item in list)
            {
                if (add)
                {
                    item.AddReferenceCount(true);
                }
                else
                {
                    item.ReduceReferenceCount(true);
                }
            }
        }

        public void DisposeResource(int[] loadTypes)
        {
            HashSet<int> types = new HashSet<int>(loadTypes);
            if (allResourceList == null) return;
            for (int resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
            {
                _tempResource = allResourceList[resourceIndex];
                if (types.Contains(_tempResource.AbResMapItem.ABResLoadType))
                {
                    _tempResource.Dispose();
                }
            }
        }

        public void DisposeResource(int loadType)
        {
            if (allResourceList == null) return;
            for (int resourceIndex = 0; resourceIndex < mResourcesMap.Count; resourceIndex++)
            {
                _tempResource = allResourceList[resourceIndex];
                if (_tempResource.AbResMapItem.ABResLoadType == loadType)
                {
                    _tempResource.Dispose();
                }
            }
        }

        public void DisposeResource(string[] names)
        {
            for (int i = 0; i < names.Length; i++)
            {
                if (mResourcesMap.TryGetValue(names[i], out var res))
                {
                    DisposeResource(res);
                }
            }
        }

        public void DisposeResource(string name)
        {
            if (mResourcesMap.TryGetValue(name, out var res))
            {
                DisposeResource(res);
            }
        }

        public void DisposeResource(BaseResource res)
        {
            res?.Dispose();
        }

        public void DisposeUnusedAssets()
        {
            DebugLog("卸载无用资源");
            if (allResourceList != null)
            {
                //优化 mResourcesMap的前mResourcesMap.Count 是主资源
                for (int i = 0; i < mResourcesMap.Count; i++)
                {
                    allResourceList[i].Dispose();
                }
            }
            DebugLog("卸载资源完毕");
        }

        /// <summary>
        /// 同步加载资源
        /// </summary>
        /// <param name="assetBundleName"></param>
        /// <returns></returns>
        public BaseResource LoadResource(string assetBundleName)
        {
#if UNITY_EDITOR && !USEAB
            assetBundleName = TrimName(assetBundleName);
            if (!mResourcesMap.ContainsKey(assetBundleName))
            {
                ABResMapItemScriptObj obj = new ABResMapItemScriptObj();
                obj.AssetBundleName = assetBundleName;
                obj.ABResType = ABResMapScriptObj.ABResTypeMain;
                _tempResource = AbResChecker.CreateResource(obj, BaseResource.ResourceState.Create, BaseResource.Storage.Internal);
                _tempResource.Load();
                mResourcesMap.Add(assetBundleName, _tempResource);
            }
            return mResourcesMap[assetBundleName];
#else
            assetBundleName = TrimName(assetBundleName);
            if (!mResourcesMap.ContainsKey(assetBundleName))
            {
                DebugLog("资源系统里面没有这个资源 " + assetBundleName, true); 
                    return null;
            }

            _tempResource = mResourcesMap[assetBundleName];
            _tempResource.Load();
            return _tempResource;
#endif
        }

        /// <summary>
        /// 同步加载多个资源
        /// </summary>
        /// <param name="assetBundleNames"></param>
        /// <param name="allFinishAction"></param>
        public List<BaseResource> LoadResource(List<string> assetBundleNames)
        {
#if UNITY_EDITOR && !USEAB
            for (int j = 0; j < assetBundleNames.Count; j++)
            {
                assetBundleNames[j] = TrimName(assetBundleNames[j]);
            }
            List<BaseResource> list = new List<BaseResource>();
            for (int i = 0; i < assetBundleNames.Count; i++)
            {
                if (!mResourcesMap.ContainsKey(assetBundleNames[i]))
                {
                    ABResMapItemScriptObj obj = new ABResMapItemScriptObj();
                    obj.AssetBundleName = assetBundleNames[i];
                    obj.ABResType = ABResMapScriptObj.ABResTypeMain;
                    _tempResource = AbResChecker.CreateResource(obj, BaseResource.ResourceState.Create, BaseResource.Storage.Internal);
                    _tempResource.Load();
                    mResourcesMap.Add(assetBundleNames[i], _tempResource);
                }
                list.Add(mResourcesMap[assetBundleNames[i]]);
            }
            return list;
#else
            for (int j = 0; j < assetBundleNames.Count; j++)
            {
                assetBundleNames[j] = TrimName(assetBundleNames[j]);
            }
            List<BaseResource> list = new List<BaseResource>();
            for (int i = 0; i < assetBundleNames.Count; i++)
            {
                if (!mResourcesMap.ContainsKey(assetBundleNames[i]))
                {
                    DebugLog("没有这个资源" + assetBundleNames[i], true);
                    return null;
                }
                list.Add(mResourcesMap[assetBundleNames[i]]);
            }
            for (int k = 0; k < list.Count; k++)
            {
                list[k].Load();
            }
            return list;
#endif
        }

        /// <summary>
        /// 异步加载资源
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="assetBundleName"></param>
        /// <param name="allFinishAction"></param>
        public void LoadResourceAsync(string assetBundleName, Action<BaseResource> allFinishAction, Action<BaseResource> itemFinishAction = null)
        {
#if UNITY_EDITOR && !USEAB
            assetBundleName = TrimName(assetBundleName);
            if (!mResourcesMap.ContainsKey(assetBundleName))
            {
                ABResMapItemScriptObj obj = new ABResMapItemScriptObj();
                obj.AssetBundleName = assetBundleName;
                obj.ABResType = ABResMapScriptObj.ABResTypeMain;
                _tempResource = AbResChecker.CreateResource(obj, BaseResource.ResourceState.Create, BaseResource.Storage.Internal);
                mResourcesMap.Add(assetBundleName, _tempResource);
            }
            AbResLoader.LoadResource(mResourcesMap[assetBundleName], allFinishAction, itemFinishAction);
#else

            assetBundleName = TrimName(assetBundleName);
            if (!mResourcesMap.ContainsKey(assetBundleName))
            {
                DebugLog("资源系统里面没有这个资源 " + assetBundleName, true);
                try
                {
                    if (itemFinishAction != null) itemFinishAction(null);
                    if (allFinishAction != null) allFinishAction(null);
                }
                catch (Exception e)
                {
                    DebugLog(e.ToString(), true);
                }

                return;
            }

            _tempResource = mResourcesMap[assetBundleName];
            AbResLoader.LoadResource(_tempResource, allFinishAction, itemFinishAction);
#endif
        }

        //加一个加载标记参数  param
        public void LoadResourceAsync(string assetBundleName, Action<BaseResource, object> finishAction, object param)
        {
            LoadResourceAsync(assetBundleName, resource =>
            {
                if (finishAction != null)
                {
                    finishAction(resource, param);
                }
            });
        }

        /// <summary>
        /// 异步加载多个资源
        /// </summary>
        /// <param name="assetBundleNames"></param>
        /// <param name="allFinishAction"></param>
        public void LoadResourceAsync(List<string> assetBundleNames, Action<List<BaseResource>> allFinishAction, Action<BaseResource> itemFinishAction = null)
        {
#if UNITY_EDITOR && !USEAB
            for (int j = 0; j < assetBundleNames.Count; j++)
            {
                assetBundleNames[j] = TrimName(assetBundleNames[j]);
            }
            List<BaseResource> list = new List<BaseResource>();
            for (int i = 0; i < assetBundleNames.Count; i++)
            {
                if (!mResourcesMap.ContainsKey(assetBundleNames[i]))
                {
                    ABResMapItemScriptObj obj = new ABResMapItemScriptObj();
                    obj.AssetBundleName = assetBundleNames[i];
                    obj.ABResType = ABResMapScriptObj.ABResTypeMain;
                    _tempResource = AbResChecker.CreateResource(obj, BaseResource.ResourceState.Create, BaseResource.Storage.Internal);
                    mResourcesMap.Add(assetBundleNames[i], _tempResource);
                }
                list.Add(mResourcesMap[assetBundleNames[i]]);
            }
            AbResLoader.LoadResources(list, allFinishAction, itemFinishAction);
#else
            for (int j = 0; j < assetBundleNames.Count; j++)
            {
                assetBundleNames[j] = TrimName(assetBundleNames[j]);
            }

            List<BaseResource> list = new List<BaseResource>();
            for (int i = 0; i < assetBundleNames.Count; i++)
            {
                if (!mResourcesMap.ContainsKey(assetBundleNames[i]))
                {
                    DebugLog("资源系统里面没有这个资源" + assetBundleNames[i], true);
                    try
                    {
                        if (itemFinishAction != null) itemFinishAction(null);
                    }
                    catch (Exception e)
                    {
                        DebugLog(e.ToString(), true);
                    }

                }
                else
                {
                    list.Add(mResourcesMap[assetBundleNames[i]]);
                }
            }
            AbResLoader.LoadResources(list, allFinishAction, itemFinishAction);
#endif
        }
        public Sprite GetSpriteByAtlasType(IconsAtlasType atlasType, string sprName)
        {
            AtlasResource res = GameWorld.AbRes.GetAtlasResource(atlasType) as AtlasResource;
            if (res != null)
            {
                return res.GetSpriteByName(sprName);
            }
            return null;
        }
        /// <summary>
        /// 同步加载Atlas资源
        /// </summary>
        /// <param name="atlasType"></param>
        /// <returns></returns>
        public BaseResource GetAtlasResource(IconsAtlasType atlasType)
        {
            if (!mAtlasResMap.ContainsKey(atlasType))
            {
#if UNITY_EDITOR && !USEAB
                string pathRoot = "Assets/" + GameAbConfig.AtlasSrcPathRoot + "/" + atlasType;

                ABResMapItemScriptObj obj = new ABResMapItemScriptObj();
                string assetBundleName = TrimName(pathRoot);
                obj.AssetBundleName = assetBundleName;
                AtlasResource resource = new AtlasResource(obj, BaseResource.ResourceState.Create, BaseResource.Storage.Internal);
                resource.Load();
                mResourcesMap.Add(assetBundleName, resource);
                mAtlasResMap.Add(atlasType, resource);
#else

                DebugLog("不包含 " + Enum.GetName(typeof(IconsAtlasType), atlasType) + " 这个类型的Atlas资源", true);
                return null;
#endif
            }
            return LoadResource(mAtlasResMap[atlasType].AbResMapItem.AssetBundleName);
        }

        public Shader FindShader(string shaderName)
        {
            if (_shaderResource != null)
            {
                LoadResource(_shaderResource.AbResMapItem.AssetBundleName);
                return _shaderResource.FindShader(shaderName);
            }
            return null;
        }

        //数据表 读完后 调用
        public void SetBackDownload(List<string> abResList)
        {
            AbResDownloader.names = abResList;
        }

        public void SetBackDownloadState(bool download = true)
        {
            AbResDownloader.ifDownLoadInBG = download;
            if (download)
            {
                AbResDownloader.StartDownLoadResBg();
            }
        }

        private string TrimName(string name)
        {
#if UNITY_EDITOR && !USEAB
            //if (!name.StartsWith("Assets/"))
            //    name = "Assets/" + name;
            //string ext = Path.GetExtension(name);
            //if (string.IsNullOrEmpty(ext))
            //{
            //    if (!name.Contains("/")) return name;
            //    string fileName = Path.GetFileNameWithoutExtension(name);
            //    string fileDic = Path.GetDirectoryName(name);
            //    DirectoryInfo dicInfo = new DirectoryInfo(fileDic);
            //    if (dicInfo.Exists)
            //    {
            //        FileInfo[] fileInfos = dicInfo.GetFiles(fileName + ".*", SearchOption.TopDirectoryOnly);
            //        List<FileInfo> fileList = new List<FileInfo>(fileInfos);
            //        fileList.RemoveAll(item => item.Extension.Equals(".meta"));
            //        if (fileList.Count == 0) return name;
            //        if (fileList.Count > 1)
            //        {
            //            DebugLog("出现同名文件 " + name, true);
            //            return name;
            //        }
            //        if (fileList[0] == null) return name;
            //        return (fileDic + "/" + fileList[0].Name).Replace("\\", "/");
            //    }
            //}
#else
            //name = ProcessABFileKey(name);
#endif
            return CheckAbFileKey(name);
        }


        private const string assetPrefix = "assets/";
        public static string ProcessABFileKey(string assetPath)
        {
            using (CString.Block())
            {
                CString sb = CString.Alloc(512);
                sb.Append(assetPath);
                if (assetPath.StartsWith(assetPrefix, StringComparison.OrdinalIgnoreCase))
                {
                    sb.Remove(0, assetPrefix.Length);
                }

                sb.Replace(" ", "");
                sb.Replace("#", "");
                sb.Replace("\\", "/");

                int index = sb.LastIndexOf(".");
                if (index != -1)
                {
                    sb.Remove(index);
                }
                return CheckAbFileKey(sb.ToLower(CultureInfo.InvariantCulture).ToString());
            }
        }

        private static string CheckAbFileKey(string bundleName)
        {
            return bundleName.EndsWith(GameAbConfig.GameAbSuffix)
                ? bundleName
                : $"{bundleName}{GameAbConfig.GameAbSuffix}";
        }


        [System.Diagnostics.Conditional("DEBUGLOG")]
        public static void DebugLog(string log, bool isError = false)
        {
            if (isError)
            {
                GameLog.LogError("ab", log);
            }
            else
            {
                GameLog.Log("ab", log);
            }
        }
    }
}

