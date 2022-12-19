local BoxColliderType = typeof(BoxCollider)

local SuperCls = require("MainCity.Render.AgentRender")
---@type NinoAgentRender:AgentRender
local NinoAgentRender = class(SuperCls, "NinoAgentRender")

---@param data AgentData 物体信息
---@param position Vector3 @创建后的建筑世界坐标
---@param callback function @创建结果回调
function NinoAgentRender:Init(data, callback)
    if callback then
        table.insert(self.createCallbacks, callback)
    end

    if self.initialized and Runtime.CSValid(self.gameObject) then
        self:Trigger(true)
        return
    end
    if self.initializing then
        return
    end

    if Runtime.CSValid(self.gameObject) then
        self:Trigger(true)
        return
    end

    self.name = data:GetId()
    self.tId = data.meta.id
    self.position = data:GetPosition()
    self.rawEuler = data:GetRawEulerAngle()
    self.rawScale = data:GetRawLocalScale()
    local defaultConfig = data:GetIdleAnimaName()
    self.idleAnimaName = defaultConfig.animation
    self.idleEffect = defaultConfig.effect
    self:CreateGameObject(self.sourcePath)
end


function NinoAgentRender:CreateGameObject(assetPath)
    self.initializing = true
    if string.isEmpty(assetPath) then
        console.error('障碍物资源路径为空', self.tId, self.name) --@DEL
    end
    local function OnLoadFinished()
        if not self.isAlive then
            self:Trigger(false)
            return
        end

        self.initialized = true
        self.initializing = false

        self.gameObject = BResource.InstantiateFromAssetName(assetPath)
        if Runtime.CSValid(self.gameObject) then
            local BuildingRootGo = App.scene.objectManager:GetRoot()
            self.gameObject:SetParent(BuildingRootGo)
            self.collider = self.gameObject:GetComponentInChildren(BoxColliderType)

            self:GenRenderType(self.tId)
            self:SetName(self.name)
            self:SetLocalScale(self.rawScale)
            self:SetPosition(self.position)
            self:SetEulerAngles(self.rawEuler)
            self:SetClickable(self.clickable)
            if self.alpha then
                self:SetTransparency(self.alpha)
            end
            if self.isVisible ~= nil then
                local isVisible = self.isVisible
                self.isVisible = nil
                self:SetVisible(isVisible)
            end

            self:_initNinoRender()
            WaitExtension.InvokeDelay(
                function()
                    self:InitDefaultAnimation(self.idleAnimaName)
                end
            )
            self:Trigger(true)
        else
            self:Trigger(false)
        end
        if self.loadedCallback then
            WaitExtension.InvokeDelay(
                function()
                    self.loadedCallback(self.gameObject)
                    self.loadedCallback = nil
                end
            )
        end
        App.mapGuideManager:OnGuideFinishEvent(GuideEvent.ObstacleValid, self.name)
    end
    local assets = {assetPath}
    local skinAsset = self:GetSkinAsset()
    if skinAsset then
        table.insert(assets, skinAsset)
    end
    if self.idleEffect and self.idleEffect.res then
        table.insert(assets, self.idleEffect.res)
    end
    App.buildingAssetsManager:LoadAssets(assets, OnLoadFinished)
end

local _ninoName = "Petdragon"
function NinoAgentRender:GetNinoName()
    return _ninoName
end

function NinoAgentRender:GetPlayerData()
    if not self.playerdata then
        local model_name = "Configs.ScreenPlays.Characters." .. self:GetNinoName()
        self.playerdata = include(model_name)
    end
    return self.playerdata
end

function NinoAgentRender:GetSkinAsset()
    local name = self:GetNinoName()
    local skinLogic = AppServices.SkinLogic
    local playerdata = self:GetPlayerData()
    local assetPaths = skinLogic:GetModel(name)
    if table.isEmpty(assetPaths) then
        table.insert(assetPaths, playerdata.modelName)
    end
    local assetPath
    if skinLogic:IsUsingSkinSet(name) then
        assetPath = assetPaths[1]
    else
        assetPath = playerdata.modelName
    end
    return assetPath
end

function NinoAgentRender:_initNinoRender()
    local assetPath = self:GetSkinAsset()
    local gameObject = BResource.InstantiateFromAssetName(assetPath)
    console.lzl("尼诺类型建筑被创建  path:", assetPath) --@DEL
    self:CreateWithGameObject(gameObject)
end

function NinoAgentRender:CreateWithGameObject(gameObject)
    self.renderObj = gameObject
    self.transform = self.renderObj.transform
    GameUtil.ResetCullMode(self.renderObj)
    local collider = self.renderObj:GetComponentInChildren(typeof(Collider))
    if Runtime.CSValid(collider) then
        collider.name = self.playerdata.name
    end
    self.animatorCtrl = self.renderObj:GetOrAddComponent(typeof(CS.DynamicAnimatorCtrl))
    self.renderObj.name = self.playerdata.name
    -- self.maskObj = self.renderObj:FindGameObject("mask")
    self.renderObj:SetParent(self.gameObject, false)

    if self.idleEffect then
        local idleEffectGo = BResource.InstantiateFromAssetName(self.idleEffect.res)
        if self.idleEffect.bone then
            local parent = self.renderObj:FindGameObject(self.idleEffect.bone)
            idleEffectGo:SetParent(parent, false)
        else
            idleEffectGo:SetParent(self.renderObj, false)
        end
        idleEffectGo.name = self.idleEffect.name
        self.idleEffectGo = idleEffectGo
    end
end

function NinoAgentRender:removeDefaultEffect()
    if Runtime.CSValid(self.idleEffectGo) then
        Runtime.CSDestroy(self.idleEffectGo)
        self.idleEffectGo = nil
    end
end

---@param skin SkinMeta
function NinoAgentRender:ChangePetdragonSkin(skin, callback)
    local assetPath = skin.model
    local function onLoaded()
        local go = BResource.InstantiateFromAssetName(assetPath)
        if Runtime.CSValid(go) then
            Runtime.CSDestroy(self.renderObj)
            self:CreateWithGameObject(go)
        else
            console.warn(nil, "change skin failed Go is invalid") --@DEL
        end
        Runtime.InvokeCbk(callback)
    end
    App.dramaAssetManager:LoadAssets({assetPath}, onLoaded)
end

function NinoAgentRender:PlayAnimation(animaName, _, callback, isLvUp)
    if not self.isAlive then
        Runtime.InvokeCbk(callback, false)
        return
    end

    local length = self.animatorCtrl:Play(animaName, 0, true)
    if callback then
        if length <= 0 then
            length = 1.618
        end
        WaitExtension.SetTimeout(function()
            if Runtime.CSValid(self.gameObject) then
                Runtime.InvokeCbk(callback, true)
            end
        end, length)
    end
    if isLvUp then
        self:removeDefaultEffect()
    end
end

return NinoAgentRender