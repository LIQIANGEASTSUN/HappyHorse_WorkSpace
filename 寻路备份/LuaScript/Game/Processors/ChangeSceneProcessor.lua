local ChangeSceneProcessor = {}

function ChangeSceneProcessor.Change(name, onFinish, extraParam, extraAssets)
    local cfg = CONST.RULES.LoadSceneConfig(name)
    local bundleName = CONST.RULES.GetSceneBundleName(cfg.params.sceneId)
    BResource.LoadBundle(bundleName, function()
        ChangeSceneProcessor._changeScene(name, function()
            BResource.ReleaseBundle(bundleName)
            BCore.TrackCustomEvent("scene", cfg.params.sceneId or "")
            Runtime.InvokeCbk(onFinish)
            MessageDispatcher:SendMessage(MessageType.Global_After_ChangeScene, cfg.params.sceneId)
        end, extraParam, extraAssets)
    end)
end

-- 加载场景及场景所依赖的资源文件
function ChangeSceneProcessor.Preload(name, onFinish, onProgress)
    local cfg = CONST.RULES.LoadSceneConfig(name)
    local bundleName = CONST.RULES.GetSceneBundleName(cfg.params.sceneId)
    local _ = require(cfg.class)
    local snames = cfg.name(RuntimeContext.LITE_SCENE)
    local totalNum = #snames
    local loadedNum = 0
    local loadedSceneNum = 0

    local eMode = 0
    if #snames > 1 then
        eMode = 1
    end

    local function onProgressCallback(percent)
        if onProgress ~= nil then
            onProgress(percent)
        end
    end

    local function OnLoadSceneComplete(sceneName, progressNum)
        loadedNum = loadedNum + 1
        onProgressCallback(loadedNum / totalNum)

        loadedSceneNum = loadedSceneNum + 1
        if loadedSceneNum == #snames then
            BResource.ReleaseBundle(bundleName)
            onFinish()
        end
    end

    -- 预取场景
    BResource.LoadBundle(bundleName, function()
        local function OnLoadDependenceComplete()
            -- 载入场景文件
            for _, v in pairs(snames) do
                App.luaSceneManager:LoadSceneAsync(v, eMode, OnLoadSceneComplete, nil, true)
            end
        end

        local function OnLoadDependenceProcess(sender)
            loadedNum = sender:GetValue("curNum")
            onProgressCallback(loadedNum / totalNum)
        end

        -- 加载场景相关的资源
        totalNum = totalNum + cfg:LoadDependenceFunc(OnLoadDependenceComplete, OnLoadDependenceProcess)
    end)
end

function ChangeSceneProcessor._changeScene(name, onFinish, extraParam, extraAssets)
    -- load scene
    local cfg = CONST.RULES.LoadSceneConfig(name)
    local def = require(cfg.class)
    local snames = cfg.name(RuntimeContext.LITE_SCENE, extraParam)

    local function allSceneLoadFinish()
        App.scene = def:create()
        App.scene.sceneMode = SceneId2Mode[cfg.params.sceneId]
        App.scene:init(cfg.params, extraParam or {})
        App.scene._name = snames
        App.scene:Awake()

        Runtime.InvokeCbk(onFinish)
    end

    local function OnLoadDependenceFinish()
        local targetSceneCount = #snames
        local sceneCount = 0
        local function onLoadFinished(sceneName, progressNum)
            sceneCount = sceneCount + 1
            if sceneCount >= targetSceneCount then
                allSceneLoadFinish()
            end
        end

        for i = 1, targetSceneCount do
            local loadSceneMode = 0
            if i > 1 then
                loadSceneMode = 1
            end
            App.luaSceneManager:LoadSceneAsync(snames[i], loadSceneMode, onLoadFinished)
        end
    end

    local function OnTemporarySceneLoadComplete(sceneName, process)
        if sceneName == "TempScene" then
            AppServices.ItemIcons:Gc()
            Runtime.CSCollectGarbage()
        end

        local assets = {}
        -- 加载目标场景
        -- local assets = AppServices.SkinLogic:GetModels()
        -- if extraAssets then
        --     for _, v in pairs(extraAssets) do
        --         table.insert(assets, v)
        --     end
        -- end

        ---加载额外资源
        local function OnExtraAssetsLoaded()
            if assets and #assets > 0 then
                App.commonAssetsManager:LoadAssets(assets, OnLoadDependenceFinish)
            else
                OnLoadDependenceFinish()
            end
        end

        ---加载场景必要资源
        if cfg.LoadDependenceFunc then
            cfg:LoadDependenceFunc(OnExtraAssetsLoaded)
        else
            if cfg.dependences then
                App.commonAssetsManager:LoadAssets(cfg.dependences, OnExtraAssetsLoaded)
            else
                OnExtraAssetsLoaded()
            end
        end
    end

    -- 清理面板
    --PanelManager.RemoveAll()
    --PanelManager.closeAllPanels()
    -- 清理场景
    local curSceneNames = App.scene:Name()
    Runtime.InvokeCbk(App.scene.BeforeUnload, App.scene)
    Runtime.InvokeCbk(App.scene.Destroy, App.scene)

    if extraParam and extraParam.IsFromLoading then
        for i = 1, #curSceneNames do
            App.luaSceneManager:UnloadSceneAsync(curSceneNames[i], OnTemporarySceneLoadComplete)
        end
    else
        -- 加载临时场景
        App.luaSceneManager:LoadSceneAsync("TempScene", 1, OnTemporarySceneLoadComplete)
    end
end

return ChangeSceneProcessor