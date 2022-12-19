--[[
    @ Action Desc: 附加特效
    @ Require Params:
        string:{特效名称,挂点名称}
        int:{pos.x,pos.y,pos.z}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local PlayEffect = class(superCls, "AI.Action.PlayEffect")

function PlayEffect:OnStart()
    self.alive = true
    self.loading = false
end

function PlayEffect:OnUpdate()
    if self.loading then
        return BDTaskStatus.Running
    elseif Runtime.CSValid(self.effect) then
        self:BindGameObject()
        return BDTaskStatus.Success
    end

    local id = self:GetStringParam(2)
    self.effect = self.treeBlackboard[id]
    if Runtime.CSValid(self.effect) then
        self:BindGameObject()
        return BDTaskStatus.Success
    end

    self.loading = true
    local prefabName = self:GetStringParam(0)
    local list = StringList()
    list:AddItem(prefabName)
    AssetLoaderUtil.LoadAssets(
        list,
        function()
            if not self.alive then
                return
            end
            self.loading = false
            self.effect = BResource.InstantiateFromAssetName(prefabName)
            self.treeBlackboard[id] = self.effect
            self:BindGameObject()
        end
    )

    return BDTaskStatus.Running
end

function PlayEffect:BindGameObject()
    local bone = self:GetStringParam(1)
    local paths = string.split(bone, "/")
    local name = paths[#paths]
    local avatar = self:GetGameObject()
    local parent = avatar:FindInDeep(name)
    self.effect:SetParent(parent, false)
    self.effect:SetLocalPosition(0, 0, 0)
    self.effect:SetLocalEulerAngle(0, 0, 0)
    self.effect:SetLocalScale(1, 1, 1)
    self.effect:SetActive(true)
end

function PlayEffect:OnPause(paused)
    if paused then
        if Runtime.CSValid(self.effect) then
            self.effect:SetActive(false)
        end
    end
end

function PlayEffect:OnDestroy()
    self.alive = nil
    superCls.OnDestroy(self)
    if self.effect then
        Runtime.CSDestroy(self.effect)
        self.effect = nil
    end
end

return PlayEffect
