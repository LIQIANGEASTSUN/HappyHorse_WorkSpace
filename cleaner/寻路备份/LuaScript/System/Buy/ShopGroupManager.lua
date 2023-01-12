---@class ShopGroupManager
local ShopGroupManager = {}
function ShopGroupManager:Init()
    self.cacheList = {}
    self.cacheTypeList = {}
    self.groupMeta = AppServices.Meta:Category("ShopGroupTemplate")
end

function ShopGroupManager:GetShopGoods(shopId,group)
    --如果为解析过，解析一次
    group = group or AppServices.User:GetUserGroup()
    if  table.isEmpty(self.cacheList[shopId]) or table.isEmpty(self.cacheList[shopId][group]) then
        local config = self.groupMeta[shopId]
        if not config then
            console.lj("当前商城分组信息缺失"..shopId) ---@DEL
            return
        end

        if not self.cacheList[shopId] then
            self.cacheList[shopId] = {}
        end
        if not self.cacheList[shopId][group] then
            self.cacheList[shopId][group] = {}
        end

        local shopConfig
        if config.templateID == 0 then
            shopConfig = AppServices.Meta:Category("ShopTemplate")
        elseif config.templateID == 1 then
            shopConfig = AppServices.Meta:Category("DiamondShopTemplate")
        end


        local groupGoods = config["group"..group]
        for _, goodsId in ipairs(groupGoods) do
            table.insert(self.cacheList[shopId][group], shopConfig[tostring(goodsId)])
        end
    end

    return self.cacheList[shopId][group]
end

function ShopGroupManager:GetShopGoodsByType(shopId,goodType)
    local list = self:GetShopGoods(shopId)
    local id = shopId.."_"..goodType
    if not self.cacheTypeList[id] then
        for _, value in ipairs(list) do
            local newID = shopId.."_"..value.shopType
            if not self.cacheTypeList[newID] then
                self.cacheTypeList[newID] = {}
            end
            table.insert(self.cacheTypeList[newID], value)
        end
    end
    return self.cacheTypeList[id]
end

--0 货币支付 1 钻石支付
function ShopGroupManager:GetShopCostType(shopId)
    return self.groupMeta[shopId].templateID
end

ShopGroupManager:Init()
return ShopGroupManager
