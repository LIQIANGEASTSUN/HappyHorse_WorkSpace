---@class PoolManage
local PoolManage = {
    poolList = {},
    parent = nil,
    registry = {
        FlyClickEffect = {path = CONST.UIEFFECT_ASSETS.FloaterClick, maxCount = 4},
        FlyProps = {path = CONST.ASSETS.G_REWARD_PROPS_FLY_ITEM, maxCount = 8},
        PanelMask = {path = "Prefab/UI/HomeScene/PanelMask.prefab", maxCount = 16}
    }
}
---@return Pool
function PoolManage:GetPool(poolid)
    if not self.poolList[poolid] then
        self.poolList[poolid] = self:CreatePool(self.registry[poolid])
    end
    return self.poolList[poolid]
end

function PoolManage:CreatePool(params)
    if not self.parent then
        local root = GameObject.Find("__EngineRoot__")
        local inst = GameObject("PoolManager")
        inst:SetParent(root, false)
        self.parent = inst
    end
    local Pool = require("ObjectPool.Pool")
    local pool = Pool.new()
    pool:Init(params, self.parent)
    return pool
end

return PoolManage
