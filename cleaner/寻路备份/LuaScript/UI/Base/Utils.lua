Util = {}

function Util.ScaleCanvasToScreen(canvas, sortingLayer, planeDistance)
    local canvasComp = canvas:GetComponent(typeof(Canvas))
    canvasComp.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceCamera
    canvasComp.worldCamera = CS.UnityEngine.Camera.main
    canvasComp.planeDistance = planeDistance or 1
    canvasComp.sortingLayerName = sortingLayer or "SCENE_BG"
    local canvasScaler = canvas:GetOrAddComponent(typeof(CanvasScaler))
    canvasScaler.uiScaleMode = "ScaleWithScreenSize"
    canvasScaler.referenceResolution = Vector2(1280, 720)
    canvasScaler.screenMatchMode = "MatchWidthOrHeight"
    local height, width = CS.UnityEngine.Screen.height, CS.UnityEngine.Screen.width
    local ratio = width / height
    local designRation = 1280 / 700
    if ratio > designRation then
        canvasScaler.matchWidthOrHeight = 1
    else
        canvasScaler.matchWidthOrHeight = 0
    end
end

function Util.AddBiParameters(params)
    if not params then
        params = {}
    end

    params.playLevelId = AppServices.User:GetCurrentLevelId()
    params.diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND) or 0
    params.goldCount = AppServices.User:GetItemAmount(ItemId.COIN) or 0
    params.energyCount = AppServices.User:GetItemAmount(ItemId.ENERGY) or 0
    params.sceneId = App.scene:GetCurrentSceneId()
    --params.hammerCount = AppServices.User:GetItemAmount(PropType.CROSS_PROP)
    --params.pregameAreaCount = AppServices.User:GetItemAmount(PropType.PREGAME_AREA_PROP)

    params.playerid = LogicContext.UID

    --增加一个firebase的参数
    local firebase = DcDelegates:GetDelegate(DelegateNames.Firebase)
    if firebase then
        params.app_instance_id = firebase:GetAppInstanceId()
    end

    return params
end

function Util.AddUserStatsParams(params)
    if not params then
        params = {}
    end

    -- 防止崩溃
    if not App or not App.loginLogic or not App.loginLogic.gameEntered then
        return params
    end
    params.heart = AppServices.User:GetItemAmount(ItemId.ENERGY)
    params.fbConnected = App.loginLogic:IsFbAccount()
    params.onlineTime = RuntimeContext.IN_GAME_DURATION

    -- User
    local UserMgr = AppServices.User
    params.levelId = UserMgr:GetCurrentLevelId()
    params.diamondCount = UserMgr:GetItemAmount(ItemId.DIAMOND) or 0
    params.playerid = LogicContext.UID
    params.coinCount = UserMgr:GetItemAmount(ItemId.COIN)

    return params
end

function Util.AddUserStatsParamsForPayment(params)
    if not params then
        params = {}
    end

    params.levelId = AppServices.User:GetCurrentLevelId()
    params.diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND) or 0
    params.playerid = LogicContext.UID
    params.playLevelId = AppServices.User:GetCurrentLevelId()
    return params
end

Util.LastButtonTime = 0
---@param eventname UIEventName
---@param takeButton boolean 是否监听自身以及子物体上button按钮的点击事件
---@param NotAllowEveryTime boolean 默认不屏蔽物体同时点击事件
function Util.UGUI_AddEventListener(obj, eventname, handler, takeButton, NotAllowEveryTime)
    if takeButton == nil then
        takeButton = false
    end
    local function onEvent(params)
        if UI.Context:IsScreenLocked() then
            print("[ScreenLocked]:" .. obj.name .. " By " .. UI.Context:ScreenLockedReason()) -- 敏感代码不要屏蔽
            return
        end
        --console.lj("App.buttonBlock" .. tostring(App.buttonBlock)) --@DEL
        if NotAllowEveryTime then
            if App.buttonBlock then
                return
            end
            App.buttonBlock = true
        end

        if eventname == UIEventName.onClick then
            App.mapGuideManager:OnGuideFinishEvent(GuideEvent.TargetButtonClicked, obj)
        elseif eventname == UIEventName.onDown then
            App.mapGuideManager:OnGuideFinishEvent(GuideEvent.TargetDown, obj)
        end
        if eventname == UIEventName.onDown then
            CS.Bridge.Feature.PlayPreset()
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_Click, false)
        end
        Runtime.InvokeCbk(handler, params)
    end

    local listener = UIEventListener.Get(obj, takeButton)
    if listener then
        listener[eventname] = onEvent
    end
end

---@param allowEveryTime boolean 默认屏蔽按钮同时点击事件
function Util.UGUI_AddButtonListener(obj, handler, args, allowEveryTime)
    UIEventListener.GetButton(
        obj,
        function()
            if UI.Context:IsScreenLocked() then
                print("[ScreenLocked]:" .. obj.name .. " By " .. UI.Context:ScreenLockedReason()) -- 敏感代码不要屏蔽
                return
            end

            if not allowEveryTime then
                if App.buttonBlock then
                    return
                end
                App.buttonBlock = true
            end

            App.mapGuideManager:OnGuideFinishEvent(GuideEvent.TargetButtonClicked, obj)
            if not (args and type(args) == "table" and args.noAudio) then
                App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_Click, false)
            end
            CS.Bridge.Feature.PlayPreset()

            local confirmItem = AppServices.DiamondConfirmUIManager.confirmItem
            Runtime.InvokeCbk(handler, args)
            AppServices.DiamondConfirmUIManager:OnClick(confirmItem)
        end
    )
end

------------------PROTOBUF CONVERTER---------------------

Runtime = {}
-- params = {num = tostring(num)} 别忘了要tostring
function Runtime.Translate(key, params)
    local value = Localization.Instance:GetText(key, params)
    if string.isEmpty(value) then
        return key
    end
    return value
end

function Runtime.InvokeCbk(func, ...)
    if type(func) ~= "function" then
        return
    end

    local stacktrace, info
    local function error_handler(err)
        info = err .. RuntimeContext.FUNC_DESC(func)
        stacktrace = RuntimeContext.TRACE_BACK()
    end
    local status = xpcall(func, error_handler, ...)
    if not status then
        console.error(string.format("[InvokeCbk]:<info>%s</info>\n<stacktrace>:%s</stacktrace>", info, stacktrace))
        return
    end
    return true
end

function Runtime.InvokeAsync(func)
    if type(func) ~= "function" then
        return
    end
    App.nextFrameActions:Add(func)
end

function Runtime.CSNull(cs_obj)
    if not cs_obj then
        return true
    end
    return BCore.IsNull(cs_obj)
end

function Runtime.CSValid(cs_obj)
    if cs_obj then
        return not BCore.IsNull(cs_obj)
    end
    return false
end

function Runtime.CSDestroy(cs_obj, delay)
    if Runtime.CSNull(cs_obj) then
        return
    end

    local function _safe_release(cs_inst, delay_time)
        BCore.Destroy(cs_inst, delay_time or 0)
        xlua.release(cs_inst)
    end
    local status, info = pcall(_safe_release, cs_obj, delay)
    if not status then
        console.warn(nil, "Runtime.CSDestroy:", info)
    end
end

function Runtime.CSCollectGarbage(isForce)
    if isForce then
        collectgarbage("collect")
    end
    BCore.GC()
end

function Runtime.GetNetworkState()
    return BCore.GetNetworkReachability() > 0
end

---按照数量格式化
---@return string xxx/xxx格式的数字
---@param have int 当前有的数量
---@param need int 需要的数量
function Runtime.formartCount(have, need)
    local color = have >= need and UICustomColor.green or UICustomColor.red
    return string.format("<color=#%s>%d</color>/%d", color, have, need)
end

function Runtime.formatStringColor(str, color)
    return string.format("<color=#%s>%s</color>", color, str)
end

---16进制颜色转RGB color 例如：#FF55AA
---@param strHexColor string
function Runtime.HexToRGB(strHexColor)
    if not strHexColor then
        error("the hex color format is error", 2)
    end
    strHexColor = string.upper(strHexColor)
    local nums = {}
    for num in string.gmatch(strHexColor, "(%w%w)") do
        nums[#nums + 1] = tonumber(num, 16)
    end
    for i = 1, #nums do
        if nums[i] then
            nums[i] = nums[i] / 255
        end
    end
    return Color(nums[1], nums[2], nums[3], nums[4] or 1)
end

local TextType = typeof(Text)
function Runtime.Localize(obj, key, params)
    local text = obj:GetComponent(TextType)
    text.text = Runtime.Translate(key, params)
end

function Util.OpenAppShopPage()
    if RuntimeContext.UNITY_IOS then
        CS.UnityEngine.Application.OpenURL("https://apps.apple.com/au/app/dragon-farm-adventure-fun-game/id1563159261")
    elseif RuntimeContext.UNITY_ANDROID then
        CS.UnityEngine.Application.OpenURL(
            "https://play.google.com/store/apps/details?id=com.dragonmonster.idlefarmadventure.free"
        )
    end
end

function Util.CALLBACKTRIGGER(obj, name, callback, recursively)
    recursively = not (not recursively)
    local traceback = RuntimeContext.TRACE_BACK()
    AnimatorEx.CallbackTrigger(obj, name, callback, recursively, traceback)
end

function Util.BlockAll(duration, id)
    console.print("BLOCKALL", duration, id) --@DEL
    if RuntimeContext.VERSION_DISTRIBUTE then
        GameUtil.BlockAll(duration, id)
    else
        local stackTrace = RuntimeContext.TRACE_BACK()
        GameUtil.BlockAll(duration, id, stackTrace)
    end
end

function Util.LogServerToAf()
    local function OnSuccess(resourceMsg)
        local eventList = {}
        for key, eventName in ipairs(resourceMsg.eventnames) do
            if not string.isEmpty(eventName) then
                if not Util.AfIsLoged(eventName) then
                    table.insert(eventList, eventName)
                end
            end
        end
        local function onFinalSuc()
            for key, eventName in ipairs(eventList) do
                DcDelegates:Log("front_" .. eventName)
                table.insertIfNotExist(App.aFReportHistoryList, eventName)
            end
        end
        PopupManager:CallWhenIdle(function ()
            if #eventList > 0 then
                Net.Rechargemodulemsg_3006_AFReportConfirm_Request({eventnames = eventList}, nil, onFinalSuc,nil,false)
            end
        end)
    end
    Net.Rechargemodulemsg_3005_AFReportList_Request(nil, nil, OnSuccess,nil,false)
end
function Util.LogPayLevel()
    Util.LogServerToAf()
end

function Util.RequestAFReportHistoryList()
    App.aFReportHistoryList = {}
    local function OnSuccess(msg)
        if table.count(msg.eventnames) > 0 then
            for key, eventName in ipairs(msg.eventnames) do
                if not string.isEmpty(eventName) then
                    table.insert(App.aFReportHistoryList, eventName)
                end
            end
        end

        PopupManager:CallWhenIdle(function ()
            Util.LogServerToAf()
        end)
    end
    Net.Rechargemodulemsg_3007_AFReportHistoryList_Request(nil, nil, OnSuccess,nil,false)
end

function Util.AfIsLoged(str)
    return table.indexOf(App.aFReportHistoryList, str)
end

function Util.LogFirstGetDragon(dragonId)
    local function qualityTostring(quality)
        if quality == 1 then
            return "co"
        elseif quality == 2 then
            return "ra"
        elseif quality == 3 then
            return "ep"
        elseif quality == 4 then
            return "lg"
        end
    end
    local itemConfig = AppServices.Meta:GetMagicalCreateuresConfigById(dragonId)
    local str = "dragon_get_" .. qualityTostring(itemConfig.quality) .. itemConfig.level
    if not Util.AfIsLoged(str) then
        Util.LogServerToAf()
    end
end

function Util.LogFisrtBuyPack(productId)
    Util.LogServerToAf()
end

function find_component(go, url, comp, canBeNil)
    if Runtime.CSNull(go) then
        console.terror(go, "error:find component failed , go is null! type is ", comp and typeof(comp) or "null") --@DEL
        return nil
    end

    local target
    if string.isEmpty(url) then
        target = go
    else
        target = go:FindGameObject(url)
    end
    if not target then
        if not canBeNil then
            console.trace("error:find component failed , url = " .. url .. " go = " .. go.name) --@DEL
        end
        return nil
    end
    if not comp then
        return target
    else
        return target:GetComponent(typeof(comp))
    end
end

-----------------------------不要再在这里添加全局方法了----------------------------------
