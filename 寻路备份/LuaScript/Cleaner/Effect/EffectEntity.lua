local UE = CS.UnityEngine
local ParticleSystem = UE.ParticleSystem

---@type EffectEntity
local EffectEntity = class(nil, "EffectEntity")

---@type EffectInfo
local EffectInfo = require "Cleaner.Effect.EffectInfo"

function EffectEntity:ctor(instanceId, data, finishCallBack)
    self.instanceId = instanceId
    self.data = data
    self.finishCallBack = finishCallBack
    self.createCallbacks = {}
    self.loop = false
    self.createTime = Time.time
    -- 临时按时间销毁
    self.destroyTime = self.createTime + 2
    self:CreateEffectGo()

    self.funcMap = {
        [EffectInfo.WorldPosition] = self.SetPosition,
        [EffectInfo.TargetLocal] = self.SetTargetLocal,
        [EffectInfo.TargetBone] = self.SetTargetBone,
    }
end

function EffectEntity:GetInstanceId()
    return self.instanceId
end

function EffectEntity:GetCreateTime()
    return self.createTime
end

function EffectEntity:SetPosition()
    self:SetWorldPosition(self.data.position)
end

function EffectEntity:SetTargetLocal()
    if self.data.follow then
        local parent = self.data.targetTr
        local localPosition = self.data.localPosition
        self:SetParent(parent, localPosition)
    else
        local position = self.data.targetTr:TransformPoint(self.data.localPosition)
        self:SetWorldPosition(position)
    end
end

function EffectEntity:SetTargetBone()
    local boneTr = self:GetBone(self.data.bone)
    if self.data.follow then
        local parent = boneTr
        local localPosition = Vector3(0, 0, 0)
        self:SetParent(parent, localPosition)
    else
        local position = boneTr.position
        self:SetWorldPosition(position)
    end
end

function EffectEntity:SetWorldPosition(position)
    self.go.transform.position = position
end

function EffectEntity:SetParent(parent, localPosition)
    self.go:SetParent(parent)
    self.go:SetLocalEulerAngle(0, 0, 0)
    --self.go:SetLocalPosition(0,0,0)
    self.go:SetLocalPosition(localPosition)
end

function EffectEntity:GetBone(boneName)
    local bag_dummy = self.go.transform:FindInDeep(boneName)
    return bag_dummy
end

function EffectEntity:CreateEffectGo()
    if self.data.effectName == "" then
        return
    end
    local path = string.format("Prefab/Art/Effect/Prefab/%s.prefab", self.data.effectName)
    local function onLoadFinish()
        self.go = BResource.InstantiateFromAssetName(path)
        self.initialized = true
        self:LoadGo(self.go)
        self:Trigger(self.go)
    end
    AssetLoaderUtil.LoadAssets({path}, onLoadFinish)
end
function EffectEntity:WaitEffectGo(callback)
    self:AddInstantiateListener(callback)
end
function EffectEntity:AddInstantiateListener(listener)
    if listener then
        if self.initialized then
            Runtime.InvokeCbk(listener, self.go)
            return
        end
        table.insert(self.createCallbacks, listener)
    end
end
function EffectEntity:Trigger(gameObject)
    local cbs = self.createCallbacks
    if not cbs or #cbs == 0 then
        return
    end

    self.createCallbacks = {}
    for _, call in ipairs(cbs) do
        Runtime.InvokeCbk(call, gameObject)
    end
end

function EffectEntity:LoadGo(go)
    self.go:SetActive(true)

    local type = self.data.type
    local func = self.funcMap[type]
    if func then
        func(self)
    end

    self.particleSystem = self.go:GetComponentInChildren(typeof(ParticleSystem))
    local main = self.particleSystem.main
    self.loop = main.loop
    self.duration = main.duration
    self.startDelay = main.startDelay.constant

    -- 临时按时间销毁
    self.destroyTime = self.createTime + self.startDelay + self.duration + 0.5

    self.particleSystem:Play()
end

function EffectEntity:LateUpdate()

end

function EffectEntity:IsTimeEnd()
    if self.loop then
        return false
    end

    return Time.time > self.destroyTime
end

function EffectEntity:Destroy()
    if Runtime.CSValid(self.go) then
        GameObject.Destroy(self.go)
    end
    self.createCallbacks = {}
end

return EffectEntity