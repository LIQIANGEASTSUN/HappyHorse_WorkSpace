local requiredAssets = {}
local requiredBundle = {}
local function AddAsset(asset, bundle)
    if type(asset) == "table" then
        for _, v in pairs(asset) do
            table.insertIfNotExist(requiredAssets, v)
        end
    else
        table.insertIfNotExist(requiredAssets, asset)
    end
    if bundle then
        table.insertIfNotExist(requiredBundle, bundle)
    end
end
local function AddCharacterAssets(person, params)
    local asset, bundle = CharacterManager.Instance():GetCharacterPrefab(person, params)
    AddAsset(asset, bundle)
end

local AllDramaAssets = {}
local IS_CALC_ASSETS = false
function StartCalcAssets(value)
    IS_CALC_ASSETS = value
end

function GetAndClearAllDramaAssets()
    local ret = AllDramaAssets
    AllDramaAssets = {}
    return ret
end

---正在播放的drama名字
---@private
local _playingDramaName
local _playDramaStartTime = {}
local _playDramaCallback = nil

function PlayDrama(dramaName, zoneId, callback)
    console.lzl("Drama_LOG Director 开始播放", dramaName) --@DEL
    if _playingDramaName then
        console.error("Play New Drama", dramaName, "When playing Drama", _playingDramaName) --@DEL
    end
    if _playDramaCallback then
        Runtime.InvokeCbk(_playDramaCallback)
    end
    _playingDramaName = dramaName
    _playDramaStartTime[dramaName] = TimeUtil.ServerTime()
    zoneId = zoneId or SceneMode.home.name
    DcDelegates:Log(SDK_EVENT.start_drama, {name = dramaName})
    local func = CONST.RULES.LoadDrama(zoneId, dramaName)
    _playDramaCallback = callback
    Runtime.InvokeCbk(func)
end

---单独播放一个对话
function PlayComics(comicsId, callback)
    console.lzl("Comics_LOG 开始播放", comicsId)
    if _playingDramaName then
        -- TODO 强制结束
    end
    if _playDramaCallback then
        Runtime.InvokeCbk(_playDramaCallback)
    end
    _playingDramaName = comicsId
    _playDramaCallback = callback
    local function func()
        GetScene():AcceptMessage(Message('PlayScreenplay'))
        BeginTimeline()
        BeginSequence()
        --%播放蒙版和动画
        ShowUI(false,false)
            BeginParallel()
                ComicsImagesManage(true)
                StartComics({Chapter="zone1",Id=comicsId})
            EndParallel()
            ComicsImagesManage(false)
            ShowUI(true,false)
        EndSequence()
        EndTimeline()
        GetScene():AddEndMessageToLastAction(Message('StopScreenplay'))
    end
    Runtime.InvokeCbk(func)
end

function GetPlayingDramaName()
    return _playingDramaName
end

PredefinedCameraSize = {
    CloseUp = 2,
    ZoomClosest = 2,
    ZoomFarthest = 15,
    Normal = 3.0
}

FBX_FADE_DURATION = 0.7

local Stack = require "Game.Common.Stack"
---@type Stack
local _stack = Stack:Create()
---@type Sequence
local _stackTop
local _rootAction

function AddAction(action)
    console.assert(_stackTop, action.name) --@DEL
    _stackTop:Append(action)
end

function BeginSequence(func)
    local sequence = Sequence:Create(func)
    if _stackTop then
        _stackTop:Append(sequence)
    end
    _stackTop = sequence
    _stack:push(_stackTop)
    if not _rootAction then
        _rootAction = _stackTop
    end
end

function EndSequence()
    _stack:pop()
    _stackTop = _stack:Top()
end

function BeginParallel(func)
    local spawn = Spawn:Create(func)
    if _stackTop then
        _stackTop:Append(spawn)
    end
    _stackTop = spawn
    _stack:push(_stackTop)
    if not _rootAction then
        _rootAction = _stackTop
    end
end

function EndParallel()
    _stack:pop()
    _stackTop = _stack:Top()
end

function BeginRepeat(times)
    console.assert(times > 0) --@DEL
    local sequence = Sequence:Create()
    local repeatAction = Repeat:Create(times or 1)
    -- 为了简化，Repeat总是只放一个Sequence做容器
    repeatAction:SetInnerAction(sequence)
    -- 栈顶Append
    if _stackTop then
        _stackTop:Append(repeatAction)
    end
    -- 后续action全都加到sequence里面，而不是repeat里面
    _stackTop = sequence
    _stack:push(_stackTop)
    if not _rootAction then
        _rootAction = _stackTop
    end
end

function EndRepeat()
    _stack:pop()
    _stackTop = _stack:Top()
end

function BeginTimeline()
    -- 清除director里面的action，防止产生后续影响
    App.scene.director:Clear()
    _stackTop = nil
    _stack:Clear()
    _rootAction = nil
end

function EndTimeline()
    console.assert(_rootAction) --@DEL
    console.assert(_stack:size() == 0) --@DEL
    _rootAction:Append(
        CallFunc:Create(
            function()
                App.scene.director:RemoveAllActors()
                MoveCameraLogic.Instance():StopFollow()
                Resources.UnloadUnusedAssets()
            end
        )
    )

    Util.BlockAll(-1, "Drama_EndTimeline")
    local function assetsLoaded()
        console.lzl("Drama_LOG Director 加载完成") --@DEL
        Util.BlockAll(0, "Drama_EndTimeline")
        requiredAssets = {}
        requiredBundle = {}
        App.scene.director:AppendFrameAction(_rootAction)
    end

    if IS_CALC_ASSETS then
        Util.BlockAll(0, "Drama_EndTimeline")
        for k, v in pairs(requiredAssets) do
            table.insertIfNotExist(AllDramaAssets, v)
        end
        requiredAssets = {}
    else
        if #requiredAssets > 0 then
            if #requiredBundle > 0 then
                local BundleManager = require("Manager.BundleManager")
                BundleManager:LoadBundles(
                    requiredBundle,
                    function()
                        App.dramaAssetManager:LoadAssets(requiredAssets, assetsLoaded, nil)
                    end
                )
            else
                App.dramaAssetManager:LoadAssets(requiredAssets, assetsLoaded, nil)
            end
        elseif #requiredBundle > 0 then
            local BundleManager = require("Manager.BundleManager")
            BundleManager:LoadBundles(requiredBundle, assetsLoaded)
        else
            Runtime.InvokeCbk(assetsLoaded)
        end
    end
end

function AddActionNow(action)
    App.scene.director:AppendFrameAction(action)
end

function ShowText(personage, params, isTimeline, func)
    params.person = personage
    if isTimeline then
        AddActionNow(Actions.ShowTextAction:Create(params, func))
    else
        AddAction(Actions.ShowTextAction:Create(params, func))
    end
end

function SetPositionToPoint(personage, params, func)
    params.person = personage
    AddAction(Actions.SetPositionToPointAction:Create(params, func))
end

function FaceToFace(lhs, rhs, func)
    local spawn = Spawn:Create(func)
    spawn:Append(Actions.LookAtPerson:Create(lhs, rhs, 0.4))
    spawn:Append(Actions.LookAtPerson:Create(rhs, lhs, 0.4))
    AddAction(spawn)
end

function LootAtPosition(person, params, func)
    local destPerson = params.Person
    local destPoint = params.Point
    local destEuler = params.Euler

    if destPerson then
        return AddAction(Actions.LookAtPerson:Create(person, destPerson, 0.4, func))
    elseif destEuler then
        return AddAction(Actions.LookAtRotate:Create(person, destEuler, 0.4, func))
    elseif destPoint then
        return AddAction(Actions.LookAtPositionAction:Create(person, destPoint, 0.4, func))
    else
        console.assert(false, "You must have either Person or Point or Building ")
    end
end

function PlayAnimation(personage, params, func)
    local action = Actions.PlayAnimationAction:Create(personage, params["Animation"], func)
    if params.DontIdle then
        action:DontIdle(true)
    else
        action:DontIdle(false)
    end
    AddAction(action)
end

function ScreenEffect_CircleWipeCircle(duration, lhsPosition, rhsPosition, htmlStringRGBA, content)
    local dur = duration or 1.0
    local lhs = lhsPosition or Vector3(0, 0, 0)
    local rhs = rhsPosition or Vector3(0, 0, 0)
    local color = htmlStringRGBA or "#000000"
    AddAction(
        CallFunc:Create(
            function()
                local lbcontent = Runtime.Translate(content or "drama_effect_sometimeslater")
                XGE.EffectExtension.AddCircleWipeCircleWithPosition("Prefab/UI/Common/ScreenPlays/CircleWipeCircleText.prefab", dur, lhs, rhs, lbcontent, color)
            end
        )
    )
    AddAction(Actions.DelayS:Create(dur + 3))
end

function AddDelayTime(seconds)
    AddAction(Actions.DelayS:Create(seconds or 1))
end

-- Mission -------------------------------------------------------------------
local MissionRef = class(DataRef)
function MissionRef:ctor(src)
    self.region = ""
    self.day = ""
    self.id = ""
    if src ~= nil then
        self:fromLua(src)
    end
end

function AddMission(params)
    local function OnFinished()
        MissionManager:Instance():AddMission(MissionRef.new(params))
    end
    AddAction(CallFunc:Create(OnFinished))
end

function OpenMissionPanel()
    local function OnFinished()
        sendNotification(CONST.GLOBAL_NOFITY.Open_Panel, GlobalPanelEnum.MissionPanel)
    end
    AddAction(CallFunc:Create(OnFinished))
end

function MoveCamera(params)
    AddAction(Actions.CameraMoveByTimeAction:Create(params))
end

function MoveCameraByTime(params)
    AddAction(Actions.CameraMoveByTimeAction:Create(params))
end
function MoveCameraByTimeWithCameraSize(params)
    AddAction(Actions.CameraMoveWithCameraSizeByTimeAction:Create(params))
end

function CameraFocusOn(avatarName, size, duration)
    local params = {Moves = {{Person = avatarName, CameraSize = size, Duration = duration}}}
    AddAction(Actions.CameraMoveByTimeAction:Create(params))
end

function CameraFocusOnBuilding(buildingName, size, duration)
    local params = {Moves = {{Building = buildingName, CameraSize = size, Duration = duration}}}
    AddAction(Actions.CameraMoveByTimeAction:Create(params))
end

--TODO redundance
function RestoreCameraFocus()
    local function OnCallback()
        MoveCameraLogic.Instance():ZoomCamera(PredefinedCameraSize.ZoomClosest)
    end
    AddAction(CallFunc:Create(OnCallback))
end

function CameraFollow(person, size)
    AddAction(Actions.CameraFollowAction:Create({person = person, size = size}))
end

function StartComics(params)
    local newParams = {
        chapter = params.Chapter,
        name = params.Id,
        dontIdle = params.DontIdle,
        dontKill = params.DontKill
    }
    AddAction(Actions.StartComic:Create(newParams))
end

function StartCartoons(params)
    AddAction(Actions.StartCartoon:Create(params.Cname, params.Chapter, params.Id))
end

function CreateCharacter(params)
    local function OnCallback()
        --local type = kCharacterName2Type[params.Person] or kCharacterType.kPlayer
        local position = params.Position
        local instance = GetPers(params.Person, params)
        local defaultIdleName = "defaultIdle"
        local idleName = params.IdleName or defaultIdleName
        local NoFadeIn = params.NoFadeIn or false
        if not instance then
            instance = CharacterManager.Instance():CreateByName(params.Person)
        end
        if not NoFadeIn then
            XGE.EffectExtension.FbxFadeIn(instance.renderObj, FBX_FADE_DURATION)
        end

        if position.z == nil then
            instance:SetPosition(Vector3(position.x, 0, position.y))
        else
            instance:SetPosition(position)
        end
        instance:StopAllActionsAndBeginIdle(idleName, NoFadeIn)
        instance:ModifyDirect(params)
        if params.Active == false then
            instance.renderObj:SetActive(false)
        end
        if params.Transparent == true then
            instance:ChangeToTransparent()
            if RuntimeContext.IS_IN_DREAM_EFFECT then
                instance.renderObj.tag = "Untagged"
                XGE.EffectExtension.AddRenderAfterPostEffect(instance.renderObj)
            end
        else
            if RuntimeContext.IS_IN_DREAM_EFFECT then
                instance.renderObj.tag = "Player"
                XGE.EffectExtension.AddRenderAfterPostEffect(instance.renderObj)
            end
        end
    end
    AddCharacterAssets(params.Person, params)
    AddAction(CallFunc:Create(OnCallback))
end

function DestroyCharacter(params)
    local function OnCallback()
        local person = GetPers(params.Person, params)
        console.assert(person, "Character不存在 " .. params.Person)
        if person:NoDestoryHide() then
            CharacterManager.Instance():RemoveByName(params.Person)
        else
            XGE.EffectExtension.FbxFadeOut(
                person.renderObj,
                FBX_FADE_DURATION,
                function()
                    CharacterManager.Instance():RemoveByName(params.Person)
                end
            )
        end
    end
    AddAction(CallFunc:Create(OnCallback))
end

function Attach(person, object, join, params)
    console.assert(person and object and join)
    AddCharacterAssets(object)
    AddAction(Actions.AttachAction:Create(person, object, join, params))
end

function AttachGameObject(person, object, join, params)
    console.assert(person and object and join)
    local prefabName = string.format("Prefab/Art/Characters/%s.prefab", object)
    AddAsset(prefabName)
    -- AddCharacterAssets(object)
    AddAction(Actions.AttachGameObjectAction:Create(person, object, join, params))
end

function Detach(persion, object)
    console.assert(persion and object)

    AddAction(
        CallFunc:Create(
            function()
                local host = GetPers(persion)
                host.renderObj.transform:ClearInDeep(object)
                CharacterManager.Instance():Detached(persion, object)
                CharacterManager.Instance():RemoveByName(object)
            end
        )
    )
end

function CastSpell(person, params, isTimeline, func)
    params.Person = person
    if isTimeline then
        params.IsTimeline = true
        AddActionNow(Actions.CastSpellAction:Create(params, func))
    else
        AddAction(Actions.CastSpellAction:Create(params, func))
    end
end

function CastDestroySpell(person, params, isTimeline, func)
    params.Person = person
    if isTimeline then
        params.IsTimeline = true
        AddActionNow(Actions.CastDestroySpellAction:Create(params, func))
    else
        AddAction(Actions.CastDestroySpellAction:Create(params, func))
    end
end

function BeginAcceptMessage()
    console.assert(_stack:size() == 0, "检查你的Begin/End命令是否完全配对")
end

function EndAcceptMessage()
    console.assert(_stack:size() == 0, "检查你的Begin/End命令是否完全配对")
end

function SetCharacterIdle(playerName, value)
    AddAction(
        CallFunc:Create(
            function()
                local person = GetPers(playerName)
                if person then
                    person:SetIdlePaused(value == false)
                end
            end
        )
    )
end

function SetRootMotion(playerName, value)
    AddAction(
        CallFunc:Create(
            function()
                local person = GetPers(playerName)
                if person then
                    person:ApplyRootMotion(value)
                end
            end
        )
    )
end

local isDragonHiding = false
function SetDragonHide(isHide)
    if isHide then
        isDragonHiding = true
        AppServices.MagicalCreatures:HideAllDragon()
    else
        isDragonHiding = false
        AppServices.MagicalCreatures:ShowHideDragon()
    end
end

--TODO redundance
function PlayIdleAnimation(playerName, idleName)
    AddAction(
        CallFunc:Create(
            function()
                local person = GetPers(playerName)
                person:StopAllActionsAndBeginIdle(idleName)
            end
        )
    )
end

function ShowUI(show, isFirstTime)
    if show then
        local spawn = Spawn:Create()
        if isFirstTime then
            spawn:Append(
                CallFunc:Create(
                    function()
                        -- Util.BlockAll(-1, "first_drama_guide_block")
                    end
                )
            )
        end
        spawn:Append(
            CallFunc:Create(
                function()
                    -- App.scene:ShowAllIcons(isFirstTime)
                    App.scene:HideMask()
                    App:setScreenPlayActive(false)
                    if _playDramaCallback then
                        local cbk = _playDramaCallback
                        _playDramaCallback = nil
                        Runtime.InvokeCbk(cbk)
                    end
                    -- TODO LZL 任务后的引导
                    App.mapGuideManager:CheckIfStartGuideAfterTask(_playingDramaName) --任务过后检查是否开始引导
                    -- App.mapGuideManager:StartSeries(GuideConfigName.GuideCleanObstacle,_playingDramaName)
                    local btnSpeedup = App.scene:GetSpeedUpButton()
                    if btnSpeedup then
                        btnSpeedup:Hide()
                    end
                    local startTime = _playDramaStartTime[_playingDramaName]
                    local dramaTime = 0
                    if startTime then
                        dramaTime = TimeUtil.ServerTime() - startTime
                    end
                    -- console.error('播放剧情耗时', dramaTime)
                    DcDelegates:Log(SDK_EVENT.end_drama, {name = _playingDramaName, dramaTime = dramaTime})
                    if isDragonHiding then
                        isDragonHiding = false
                        AppServices.MagicalCreatures:ShowHideDragon()
                    end
                    MessageDispatcher:SendMessage(MessageType.Global_Drama_Over, _playingDramaName)
                    _playingDramaName = nil
                    App.mapGuideManager:OnGuideFinishEvent(GuideEvent.DramaEvent, "Finish")
                end
            )
        )
        AddAction(spawn)
    else
        AddAction(
            CallFunc:Create(
                function()
                    -- App.scene:HideAllIcons(isFirstTime)
                    App.scene:ShowMask(isFirstTime)

                    local btnSpeedup = App.scene:GetSpeedUpButton()
                    if btnSpeedup then
                        btnSpeedup:Show()
                    end
                    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.DRAMA_STARTED)
                    MessageDispatcher:SendMessage(MessageType.Global_Drama_Start, _playingDramaName)
                    App.mapGuideManager:OnGuideFinishEvent(GuideEvent.DramaEvent, "Start")
                    --App.scene:TryFreshAllBalloon()
                end
            )
        )
    end
end

--TODO redundance
function PlayerStartFloat()
    AddAction(Actions.PlayerFloatSelfAction:Create())
end

function PlayerExitFloat()
    AddAction(Actions.PlayerExitFloatSelfAction:Create())
end

function PlayerStartFirstFloat()
    AddAction(Actions.PlayerBeginFirstFloatAction:Create())
end

function PlayerPlayBigDrop(idleWaitTime)
    AddAction(Actions.PlayerBigOrLittleDropAction:Create(false, idleWaitTime))
end

function PlayerPlayLittleDrop(idleWaitTime)
    AddAction(Actions.PlayerBigOrLittleDropAction:Create(false, idleWaitTime))
end

function RepairBuilding(buildingId, level)
    local function callback()
        AppServices.BuildingRepair.PlayBuildingRepaireAnima(buildingId, level)
    end
    AddAction(CallFunc:Create(callback))
end

function PlayBuildingAnimation(buildingId, animaName, finishIdle)
    local function callback()
        AppServices.BuildingRepair.PlayBuildingRepaireAnimaByAnimaName(buildingId, animaName, finishIdle)
    end
    AddAction(CallFunc:Create(callback))
end

function ShowGetDragon(dragonId, num)
    local finished = false
    local function finishCallback()
        finished = true
    end
    local function checkFinish()
        return finished
    end
    local function startFunc()
        local item = {{ItemId = tostring(dragonId), Amount = num or 1, IsCreature = true}}
        PanelManager.showPanel(
            GlobalPanelEnum.CommonRewardPanel,
            {rewards = item, notFlyRewards = true, isEntity = true},
            PanelCallbacks:Create(finishCallback)
        )
    end
    AddAction(Actions.WaitFinishAction:Create(startFunc, checkFinish))
end

---显示建筑修复给龙
function ShowBuildingRewardDragon(templateId)
    local finished = false
    local function finishCallback()
        finished = true
    end
    local function checkFinish()
        return finished
    end
    local function startFunc()
        -- PanelManager.showPanel(
        --     GlobalPanelEnum.ExchangeSingleRewardPanel,
        --     {type = "buildingTask", templateId = templateId},
        --     PanelCallbacks:Create(finishCallback)
        -- )
        AppServices.BuildingRepair:ShowBuildingRepairReward(templateId, finishCallback)
    end
    AddAction(Actions.WaitFinishAction:Create(startFunc, checkFinish))
end

function ShowPhotoPuzzle(duration)
    AddAction(Actions.PhotoPuzzleAction:Create(duration))
    AddAsset("Prefab/Animation/ScreenPlay/Photos.prefab")
end

function PlayUnlockRegion(regionId, cameraCenterPos, cameraSize, duration)
    AddAction(
        Actions.UnlockRegionAnimationAction:Create(
            {RegionId = regionId, CameraPos = cameraCenterPos, CameraSize = cameraSize, Duration = duration}
        )
    )
end

function AutoCompleteMission(zoneId, missionId)
    MissionManager.Instance():CompleteZoneMission(zoneId, missionId)
    local mission = MissionManager.Instance():GetMissionConfig(zoneId, missionId)
    local drama = mission.DramaId
    local func = CONST.RULES.LoadDrama(zoneId, drama)
    PlayDrama(drama, func)
end

function ComicsImagesManage(isShow)
    if isShow then
        ShowComicsImages()
    else
        HideComicsImages()
    end
end

function ShowComicsImages()
    AddAction(
        CallFunc:Create(
            function()
                App.scene.view:ShowComicsImages()
            end
        )
    )
    AddAction(Actions.DelayS:Create(0.2))
end

function HideComicsImages()
    AddAction(
        CallFunc:Create(
            function()
                App.scene.view:HideComicsImages()
            end
        )
    )
    AddAction(Actions.DelayS:Create(0.2))
end

function AddSquareMask(isAdd)
    if isAdd then
        AddAction(Actions.NaiNaiSquareMaskAction:Create())
        AddAsset("Prefab/ScreenPlays/bookfader.prefab")
    else
        AddAction(Actions.NaiNaiSquareMaskRemoveAction:Create())
    end
end
function DelSquareMask()
    AddAction(Actions.NaiNaiSquareMaskRemoveAction:Create())
end

function MaskAction(isShow, params)
    if (isShow) then
        AddMask(params)
    else
        RemoveMask(params)
    end
end

function AddMask(params)
    AddAction(Actions.AddMaskAction:Create(params))
end
function RemoveMask(params)
    AddAction(Actions.RemoveMaskAction:Create(params))
end

function AddSmoke(position, scale)
    AddAction(
        Actions.PlaySmokeAction:Create(
            {Position = position or Vector3(0, 0, 0), Scale = Vector3(scale or 1, scale or 1, scale or 1)}
        )
    )
    AddAsset("Prefab/ScreenPlays/E_clear_common.prefab")
end

function CheckMissionGuideStep1()
    local function callback()
    end
    AddAction(CallFunc:Create(callback))
end

function CheckGuideForName(name)
    local function callback()
        if not App.mapGuideManager:HasCompleteSeries(name) then
            App.mapGuideManager:StartSeries(name)
        end
    end
    AddAction(CallFunc:Create(callback))
end

function FlySpellTo(params)
    local destPosition
    if params.Position then
        destPosition = params.Position
    else
        console.assert(false)
    end
    console.assert(params.Hand == nil or params.Hand == "L" or params.Hand == "R")
    AddAction(
        Actions.SpellFlyTo:Create(
            destPosition,
            params.Duration or 1,
            params.Delay or 0,
            params.Hand or "L",
            params.Person or "Player"
        )
    )
end

function AddEffect(params)
    AddAction(Actions.AddEffectAction:Create(params))
    AddAsset(params.Prefab)
end

function RemoveEffect(params)
    AddAction(Actions.RemoveEffectAction:Create(params))
end

function PlayEffectAnimation(params)
    console.assert(params.Name) --@DEL
    console.assert(params.Animation) --@DEL
    console.assert(params.AnimationType) --@DEL
    AddAction(Actions.PlayEffectAnimationAction:Create(params))
end

function ShowModifyNamePanel(finishCallback)
    AddAction(Actions.ModifyNameAction:Create(finishCallback))
end

function EnableHighlightEffect(params)
    --AddAction(CallFunc:Create(function()
    local default = {
        stencilZBufferDepth = 0,
        downsampleFactor = 4,
        iterations = 2,
        blurMinSpread = 0.65,
        blurSpread = 0.25,
        blurIntensity = 0.3
    }
    params = params or {}

    local effect = Camera.main.gameObject:GetOrAddComponent(typeof(CS.HighlightingEffect))
    effect.stencilZBufferDepth = params.stencilZBufferDepth or default.stencilZBufferDepth
    effect._downsampleFactor = params.downsampleFactor or default.downsampleFactor
    effect.iterations = params.iterations or default.iterations
    effect.blurMinSpread = params.blurMinSpread or default.blurMinSpread
    effect.blurSpread = params.blurSpread or default.blurSpread
    effect._blurIntensity = params.blurIntensity or default.blurIntensity
    --end))
end

function DisableHighlightEffect(gameObjectName)
    AddAction(
        CallFunc:Create(
            function()
                local effect = Camera.main.gameObject:GetComponent(typeof(CS.HighlightingEffect))
                if effect then
                    CS.UnityEngine.Object.Destroy(effect)
                end
            end
        )
    )
end

function AddHighlightEffect(gameObjectName, objectParams)
    AddAction(
        CallFunc:Create(
            function()
                local go = GameObject.Find(gameObjectName)
                console.assert(go, gameObjectName .. " not found")
                local _ = go:GetOrAddComponent(typeof(CS.HighlightableObject))
            end
        )
    )
end

function DoShakeCamera(params, finishCallback)
    AddAction(Actions.DoShakeCameraAction:Create(params, finishCallback))
end

function RemoveHighlightEffect(gameObjectName)
    AddAction(
        CallFunc:Create(
            function()
                local go = GameObject.Find(gameObjectName)
                console.assert(go, gameObjectName .. " not found")
                local highlight = go:GetComponent(typeof(CS.HighlightableObject))
                if highlight then
                    CS.UnityEngine.Object.Destroy(highlight)
                end
            end
        )
    )
end

function SetCharacterTransparent(playerName, val)
    AddAction(
        CallFunc:Create(
            function()
                local person = GetPers(playerName)
                console.assert(person, playerName .. "not found")
                person:ChangeToTransparent(val)
            end
        )
    )
end

function BeginDreamEffect()
    local textureAssetPath, effectAssetPath = GetDreamEffectAssets()
    AddAsset(textureAssetPath)
    AddAsset(effectAssetPath)
    AddAction(
        CallFunc:Create(
            function()
                local camGo = MoveCameraLogic.Instance().CS_CameraLogic.SceneCamera.gameObject
                local switching = camGo:GetOrAddComponent(typeof(CS.CameraFilterPack_Color_Switching))
                switching.Strength = 0
                switching.MaskTex = AssetLoaderUtil.GetAsset(textureAssetPath)
                LuaHelper.FloatSmooth(
                    0,
                    1,
                    2,
                    function(value)
                        switching.Strength = value
                    end
                )
                local effectGo = BResource.InstantiateFromAssetName(effectAssetPath)
                effectGo:SetParent(App.scene.canvas, false)
                effectGo.transform:SetAsFirstSibling()
                effectGo.name = "DreamEffect"
            end
        )
    )
end

function EndDreamEffect()
    AddAction(
        CallFunc:Create(
            function()
                local camGo = MoveCameraLogic.Instance().CS_CameraLogic.SceneCamera.gameObject
                local switching = camGo:GetOrAddComponent(typeof(CS.CameraFilterPack_Color_Switching))
                switching.Strength = 1
                local effect = find_component(App.scene.canvas, "DreamEffect")
                GameUtil.DoFade(effect, 0, 2)
                LuaHelper.FloatSmooth(
                    1,
                    0,
                    2,
                    function(value)
                        if Runtime.CSValid(switching) then
                            switching.Strength = value
                        end
                    end,
                    function()
                        Runtime.CSDestroy(switching)
                        Runtime.CSDestroy(effect)
                    end
                )
            end
        )
    )
end

function StartDreamingEffectState()
    local textureAssetPath, effectAssetPath = GetDreamEffectAssets()
    App.dramaAssetManager:LoadAssets(
        {textureAssetPath, effectAssetPath},
        function()
            local SceneCamera = MoveCameraLogic.Instance().CS_CameraLogic.SceneCamera.gameObject
            local switching = SceneCamera:GetOrAddComponent(typeof(CS.CameraFilterPack_Color_Switching))
            switching.MaskTex = AssetLoaderUtil.GetAsset(textureAssetPath)
            switching.Strength = 1

            local effectGo = BResource.InstantiateFromAssetName(effectAssetPath)
            effectGo:SetParent(App.scene.canvas, false)
            effectGo.transform:SetAsFirstSibling()
            effectGo.name = "DreamEffect"
        end
    )
end

function GetDreamEffectAssets()
    local textureAssetPath = "Prefab/Buildin/Texture/yanwu.png"
    local effectAssetPath = "Prefab/ScreenPlays/ScreenEffects/DreamEffect/DreamEffect.prefab"
    return textureAssetPath, effectAssetPath
end

function PlaySound(params, finishCallback)
    AddAction(Actions.PlaySoundAction:Create(params, finishCallback))
end

function StopSound(soundPath)
    AddAction(
        CallFunc.Create(
            function()
                App.audioManager:StopAudio(soundPath)
            end
        )
    )
end

function FbxFadeIn(person, duration)
    local finished = false
    local function finishCallback()
        finished = true
    end
    local function checkFinish()
        return finished
    end
    local function startFunc()
        local per = GetPers(person)
        console.assert(per, person .. " not found")
        XGE.EffectExtension.FbxFadeIn(per.renderObj, duration, finishCallback)
    end
    AddAction(Actions.WaitFinishAction:Create(startFunc, checkFinish))
end

function FbxFadeOut(person, duration)
    local finished = false
    local function finishCallback()
        finished = true
    end
    local function checkFinish()
        return finished
    end
    local function startFunc()
        local per = GetPers(person)
        console.assert(per, person .. " not found")
        XGE.EffectExtension.FbxFadeOut(per.renderObj, duration, finishCallback)
    end
    AddAction(Actions.WaitFinishAction:Create(startFunc, checkFinish))
end

function AddCanvasEffect(params)
    AddAction(Actions.CanvasEffectAction:Create(params))
end

function GainRewards(params)
    AddAction(Actions.GainRewardsAction:Create(params))
end

function ForceCloseDrama()
    -- console.lzl("Drama_LOG Director 调用了强制清理") --@DEL
    App:setScreenPlayActive(false)
    _playingDramaName = nil
    _stackTop = nil
    _stack:Clear()
    _rootAction = nil
    if _playDramaCallback then
        local cbk = _playDramaCallback
        _playDramaCallback = nil
        Runtime.InvokeCbk(cbk)
    end
end
