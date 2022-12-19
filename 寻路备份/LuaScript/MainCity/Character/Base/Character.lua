---@class Character
local Character = class(IDestroy, "Character")

Character.defaultIdleName = "defaultIdle"
Character.idleSuffix = "Idle"

function Character:ctor(name, playerdata, params)
    ---@type PlayerData
    self.playerdata = playerdata
    self.name = name or playerdata.name
    self.pramas = params
    ---@type GameObject
    self.renderObj = nil
    self.maskObj = nil
    ---@type Transform
    self.transform = nil
    self.controller = nil

    self.idlePaused = false

    self.birthPosition = params.position or self.playerdata.position
    self.birthRotation = params.rotation or self.playerdata.rotation

    self.talkOffsetX = 0.5
    self.talkOffsetY = 1.5
    self.alive = true
    -- AppServices.SkinLogic:RegisterObject(self.name, self)
    local pattern = string.find(self.playerdata.name, "dragon_%w+_lv%d")
    if pattern then
        self.isDragon = true
    end
end

function Character:Destroy()
    CharacterManager.Instance():DestroyAttached(self.name)
    if self.talkMsg then
        self.talkMsg:Destroy()
        self.talkMsg = nil
    end
    self.alive = false
    Runtime.CSDestroy(self.renderObj)
    IDestroy.Destroy(self)
    -- AppServices.SkinLogic:UnregisterObject(self.name, self)
end

---删除的时候不渐隐
function Character:NoDestoryHide()
    return false
end

function Character:Init()
    -- local skinLogic = AppServices.SkinLogic
    -- local assetPaths = skinLogic:GetModel(self.name)
    -- if table.isEmpty(assetPaths) then
    --     table.insert(assetPaths, self.playerdata.modelName)
    -- end
    local assetPath = self.playerdata.modelName
    -- if skinLogic:IsUsingSkinSet(self.name) then
    --     assetPath = assetPaths[1]
    -- else
    --     assetPath = self.playerdata.modelName
    -- end
    local gameObject = BResource.InstantiateFromAssetName(assetPath)
    console.trace("角色已被创建：", self.name, "  path:", assetPath) --@DEL
    self:CreateWithGameObject(gameObject)
    if not self.playerdata.usePrefabPosition then
        self.transform.position = Vector3(self.birthPosition.x, self.birthPosition.y, self.birthPosition.z)
        if self.birthRotation then
            self.transform.rotation = Quaternion.Euler(self.birthRotation.x, self.birthRotation.y, self.birthRotation.z)
        end
    end

    -- local ids = skinLogic:GetUsingSkin(self.name)
    -- for _, id in pairs(ids) do
    --     local meta = skinLogic:GetSkinMeta(id)
    --     self:ChangePart(meta)
    -- end
end

function Character:CreateWithGameObject(gameObject)
    self.renderObj = gameObject
    self.transform = self.renderObj.transform
    GameUtil.ResetCullMode(self.renderObj)
    local collider = self.renderObj:GetComponentInChildren(typeof(Collider))
    if Runtime.CSValid(collider) then
        collider.name = self.playerdata.name
    end

    self:BindAnimatorCtrl()

    self.renderObj.name = self.playerdata.name
    if self.playerdata.tag and string.len(self.playerdata.tag) > 0 then
        self.renderObj.tag = self.playerdata.tag
    end
    self.maskObj = self.renderObj:FindGameObject("mask")

    sendNotification(CONST.GLOBAL_NOFITY.MODEL_LOADED, {self.playerdata.name})
    CharacterManager.Instance():Add(self)
    self:AfterBindView()
end

function Character:BindAnimatorCtrl()
    if self.isDragon then
        self.animatorCtrl = self.renderObj:GetOrAddComponent(typeof(CS.DragonDynamicAnimatorCtrl))
    else
        self.animatorCtrl = self.renderObj:GetOrAddComponent(typeof(CS.DynamicAnimatorCtrl))
    end
end

function Character:Awake()
    self:ResetTalkMsg()
end

function Character:ResetTalkMsg()
    if not self.talkMsg then
        local TalkMsg = require "UI.Misc.TalkMsg"
        self.talkMsg = TalkMsg:Create()
    -- self.talkMsg:SetRenderTarget(self.renderObj)
    end
    self.talkMsg:SetRenderTarget(self.renderObj)
end

function Character:ChangeToTransparent(val)
    if Runtime.CSNull(self.renderObj) then
        console.warn(nil,"character object is null")
        return
    end

    if val then
        --XGE.EffectExtension.SetShaderParams(self.materials, "_TintColor", Color(0.5, 0.5, 0.5, 1))
        self.originalShaderNames, self.materials =
            XGE.EffectExtension.SetMaterialShaderForCharacter(self.renderObj, "HomeLand/CharacterTransparency", 3000)
    else
        XGE.EffectExtension.SetMaterialShaderForCharacter(self.renderObj, self.originalShaderNames, 3000)
    end
end

function Character:StopAllActionsAndBeginIdle(idleName, noFadeIn)
    if self.isDragon and name == "defaultIdle" then
        idleName = "idle"
    end
    if Runtime.CSValid(self.renderObj) then
        self.animatorCtrl:Play(idleName, noFadeIn and 0 or 0.2)
    else
        console.error("Character:StopAllActionsAndBeginIdle  character object is null! Name:", self.name)
    end
end

function Character:PlayAnimation(name, force)
    if self.isDragon and name == "defaultIdle" then
        name = "idle"
    end
    if Runtime.CSValid(self.renderObj) then
        return self.animatorCtrl:Play(name, 0.2, force or false)
    else
        console.error("Character:PlayAnimation  character object is null! Name:", self.name)
    end
end

function Character:MoveToDirect(wayPoints, OnDestination, onWayPoint, walkName, doNotIdle, speed, linearPathType)
    if Runtime.CSNull(self.renderObj) then
        console.error("Character:MoveToDirect character object is null! Name:", self.name)
        Runtime.InvokeCbk(OnDestination)
    end

    walkName = walkName or "walk"
    linearPathType = linearPathType == true
    if not speed or speed <= 0 then
        speed = 1
    end

    local function complete_callback()
        Runtime.InvokeCbk(OnDestination)
        if doNotIdle ~= true then
            self:PlayAnimation(Character.defaultIdleName)
        end
    end

    self:PlayAnimation(walkName)
    -- AnimatorEx.SetFloat(self.renderObj, "walk_speed", speed)

    local path = Vector3List()
    path:AddItem(self.renderObj.transform.position)
    for _, v in ipairs(wayPoints) do
        local p = Vector3(v.x, v.y, v.z)
        path:AddItem(p)
    end
    BPath.MoveToDirect(
        self.renderObj.transform,
        path:ToArray(),
        self.playerdata.movespeed * 2 * speed,
        complete_callback,
        onWayPoint,
        linearPathType
    )
end

function Character:LateUpdate(dt)
end

function Character:GetGameObject()
    return self.renderObj
end

function Character:AfterBindView()
end

-- interface for screen plays
function Character:GetName()
    return self.name or self.playerdata.modelName
end

function Character:IsSameName(name)
    local myName = self:GetName()
    return myName == name
end

function Character:GetSpeed()
    return self.playerdata.movespeed
end

function Character:GetPosition()
    if Runtime.CSValid(self.renderObj) then
        return self.transform.position
    end
    return self:BirthPosition()
end

function Character:BirthPosition()
    return Vector3(self.birthPosition.x, self.birthPosition.y, self.birthPosition.z)
end

function Character.GetTalkOffset(person)
    local defaultY = 0.6
    local defaultX = 0.3
    if person == "Petdragon" then
        defaultY = 0.45
        defaultX = 0.3
    end
    return defaultX, defaultY
end

function Character:EnableDotsMode(isDots)
    self.talkMsg:EnableDotsMode(isDots)
end

function Character:AddTalkAction(text, duration, offsetX, offsetY, reverse, delay, callback)
    if not text or not self.talkMsg then
        return
    end

    delay = delay or 0

    self.talkMsg:RemoveMutter()

    Runtime.InvokeCbk(self.finishCallback)

    self.finishCallback = callback

    self.talkOffsetX = offsetX or 0
    self.talkOffsetY = offsetY or 0
    if reverse then
        self.talkOffsetX = -1 * self.talkOffsetX - 0.5
        self.talkOffsetY = self.talkOffsetY - 0.5
    end

    if self.showTimerId then
        WaitExtension.CancelTimeout(self.showTimerId)
        self.showTimerId = nil
    end

    self.showTimerId =
        WaitExtension.SetTimeout(
        function()
            if self.talkMsg then
                self.talkMsg:Mutter(text, duration, reverse, self.renderObj, self.talkOffsetX, self.talkOffsetY)
            end
            self.showTimerId = nil
        end,
        delay
    )

    if self.finishTimerId then
        WaitExtension.CancelTimeout(self.finishTimerId)
        self.finishTimerId = nil
    end
    self.finishTimerId =
        WaitExtension.SetTimeout(
        function()
            self.finishTimerId = nil
            if self.finishCallback ~= nil then
                Runtime.InvokeCbk(self.finishCallback)
                self.finishCallback = nil
            end
        end,
        delay + duration
    )
end

function Character:InterruptTalkAction()
    if not self.talkMsg then
        return
    end
    self.talkMsg:HideMutter()
    if self.showTimerId then
        WaitExtension.CancelTimeout(self.showTimerId)
        self.showTimerId = nil
    end
    if self.finishTimerId then
        WaitExtension.CancelTimeout(self.finishTimerId)
        self.finishTimerId = nil
        Runtime.InvokeCbk(self.finishCallback)
        self.finishCallback = nil
    end
end

function Character:AcceptMessage(msg)
    App.scene:AcceptMessage(msg)
end

function Character:AddEndMessageToLastAction()
    App.scene:AddEndMessageToLastAction()
end

function Character:AddStartMessageToLastAction(msg)
end

function Character:ResetBehavior()
end

function Character:SetPosition(pos, smartwalk, speed)
    -- local script
    -- if self.name == "Petdragon" or self.name == "Owl" then
    --     script = self.renderObj:GetComponent(typeof(NS.CrowFly))
    -- else
    --     script = self.renderObj:GetComponent(typeof(NS.NpcPathMove))
    -- end
    -- if script then
    --     script:Stop()
    -- end

    DOTween.Kill(self.renderObj.transform)
    self.transform.position = pos
end

function Character:PlayReversedAnimWithArrowAndTimeScale(anim, count, arrow, speed)
end

function Character:AddIdleAction(delay)
    App.scene:AppendAction(Actions.DelayS:Create(delay))
end

-- ai的开关选项
function Character:SetIdlePaused(value)
    print("Character:SetIdlePaused(value)", value) --@DEL
    self.idlePaused = value
    if self.idlePaused == true then
        self:StopAllActionsAndBeginIdle(Character.defaultIdleName)
    end
    if self.brain then
        self.brain:SetActive(not value)
    -- BDFacade.SetAIEnable(false)
    end
end

function Character:IsIdlePaused()
    return self.idlePaused == true
end

function Character:IsBrainActived()
    return self.brain ~= nil and self.brain.active
end

function Character:GetHandPosition(hand)
    local path =
        "Bip001/Bip001 Pelvis/Bip001 Spine/Bip001 Spine1/Bip001 Neck/Bip001 replace Clavicle/Bip001 replace UpperArm/Bip001 replace Forearm/Bip001 replace Hand"
    local replace = "R"
    if hand == "L" then
        replace = "L"
    end
    path = string.gsub(path, "replace", replace)
    local transform = self.renderObj.transform:Find(path)
    if transform then
        return transform.position
    else
        console.assert(false, "character hand not found: " .. self.name .. " " .. hand)
        return Vector3.zero
    end
end

function Character:ApplyRootMotion(enable)
    enable = enable and true or false
    AnimatorEx.EnableApplyRootMotion(self.renderObj, enable)
end

function Character:SetBeginningPosition()
    local defaultPosition = {}
    local sceneMeta = AppServices.Meta:GetSceneCfg()
    for _, scene in pairs(sceneMeta) do
        defaultPosition[scene.id] = {scene.bornPosition[1], scene.bornPosition[2], scene.bornPosition[3]}
    end
    -- local scPos = nil
    -- AppServices.User.Default:SetKeyValue(self.name, scPos, true)
    self:SetIdlePaused(true)
    local sceneId = App.scene:GetCurrentSceneId()
    local scPos = AppServices.User.Default:GetKeyValue(self.name, {})
    local pos
    if RuntimeContext.SwitchSceneType  == SceneType.Maze then
        pos = {8.568, 0, 10.439}
    elseif App.scene:GetSceneType() == SceneType.GoldPanning then
        pos = defaultPosition[sceneId]
    else
        if type(scPos[sceneId]) == "string" then --应该是数据兼容
            scPos[sceneId] = {}
            AppServices.User.Default:SetKeyValue(self.name, scPos, true)
        end
        if scPos[sceneId] and #scPos[sceneId] > 0 then
            pos = {scPos[sceneId][1], scPos[sceneId][2], scPos[sceneId][3]}
        else
            pos = defaultPosition[sceneId]
            scPos[sceneId] = pos
            AppServices.User.Default:SetKeyValue(self.name, scPos, true)
        end
    end
    if Runtime.CSValid(self.renderObj) then
        self.renderObj:SetPosition(Vector3(pos[1], pos[2], pos[3]))
    end
end

function Character:RecordCharacterPos()
    if App.scene:GetSceneType() == SceneType.Maze then
        return
    end
    if App.scene:GetSceneType() == SceneType.GoldPanning then
        return
    end
    local scId = App.scene:GetCurrentSceneId()
    local cfg = AppServices.Meta:GetSceneCfg(scId)
    if scId and cfg and cfg.whetherRecordPos == 1 then
        local scPos = AppServices.User.Default:GetKeyValue(self.name, {})
        local pos = self:GetPosition()
        scPos[scId] = {pos[0], pos[1], pos[2]}
        AppServices.User.Default:SetKeyValue(self.name, scPos, true)
    end
end

function Character:OnClick()
    --TODO 点击角色
end

function Character:ModifyDirect(params)
    if params.LookAtPosition then
        self.renderObj.transform:LookAt(params.LookAtPosition)
    elseif params.SelfRotation then
        self.renderObj.transform.eulerAngles = params.SelfRotation
    elseif params.LookAtPerson then
        local person = GetPers(params.LookAtPerson)
        console.assert(person, params.LookAtPerson .. "不存在")
        self.renderObj.transform:LookAt(person.renderObj.transform.position)
    elseif params.LookAtBuilding then
        console.terror(self.renderObj, "暂不支持看向建筑")
    end
end

---@param skin SkinMeta
function Character:ChangeSkin(skin, callback)
    local assetPath = skin.model
    local function onLoaded()
        local go = BResource.InstantiateFromAssetName(assetPath)
        if Runtime.CSValid(go) then
            local position = self:GetPosition()
            local rotation = self.transform.rotation
            Runtime.CSDestroy(self.renderObj)
            self:CreateWithGameObject(go)
            self:SetPosition(position)
            self.transform.rotation = rotation
            self:ResetBehavior()
            self:ResetTalkMsg()
        else
            console.warn(nil, "change skin failed Go is invalid") --@DEL
        end
        Runtime.InvokeCbk(callback)
    end
    App.dramaAssetManager:LoadAssets({assetPath}, onLoaded)
end

function Character:ChangePart(skin, callback)
    if skin.getWay == 0 then
        local controller = find_component(self.renderObj, "", CS.MarkupRoleController)
        if controller then
            controller:RemovePart(skin.type)
        end
        Runtime.InvokeCbk(callback)
        return
    end
    local assetPath = skin.model
    local function onLoadPart()
        Runtime.InvokeCbk(callback)
        if not Runtime.CSValid(self.renderObj) then
            return
        end
        local controller = find_component(self.renderObj, "", CS.MarkupRoleController)
        if controller then
            local part = BResource.InstantiateFromAssetName(assetPath)
            controller:ChangePart(skin.type, part)
        end
    end
    App.dramaAssetManager:LoadAssets({assetPath}, onLoadPart)
end

function Character:DoFade(to, time, ease)
    if Runtime.CSNull(self.renderObj) then
        console.error("character object is null")
        return
    end
    -- mask
    if Runtime.CSValid(self.maskObj) then
        self.maskObj:SetActive(to > 0.5)
    end

    local renderAry = self.renderObj:GetComponentsInChildren(typeof(CS.UnityEngine.Renderer))
    local matAry = {}
    local maskMat
    local from
    for index = 1, renderAry.Length do
        local render = renderAry[index - 1]
        local mat = render.material
        if render.name == "mask" then
            maskMat = mat
        else
            if mat.shader.name ~= "HomeLand/FbxTransparency" then
                GameUtil.SetShader(mat, "HomeLand/FbxTransparency")
            end
            table.insert(matAry, mat)
            from = mat:GetFloat("_Alpha")
        end
    end
    local function setter(val)
        if not self.alive then
            return
        end
        for _, mat in ipairs(matAry) do
            mat:SetFloat("_Alpha", val)
        end
        if maskMat then
            maskMat:SetColor("_Color", Color(1,1,1,val))
        end
    end
    local tween = DOTween.To(setter, from, to, time):SetEase(ease or Ease.Linear)
    return tween
end

return Character
