---@class MetaManager
local MetaManager = {}

local ProcessMeta = {
    ["MagicalCreaturesTemplate"] = function(meta)
        for key, value in pairs(meta) do
            setmetatable(
                value,
                {
                    __index = function(t, k)
                        if k == "name" then
                            return "dragon_name_" .. t.id
                        elseif k == "desc" then
                            return "dragon_desc_" .. t.id
                        end
                    end
                }
            )
        end
    end
}

function MetaManager:Init()
    self.caches = {}
    self.metas = {}
    setmetatable(
        self.metas,
        {
            --__mode = "v",
            __index = function(t, k)
                local data = include("Configs.Meta." .. k)
                if ProcessMeta[k] then
                    ProcessMeta[k](data)
                end
                rawset(t, k, data)
                return data
            end
        }
    )
end

function MetaManager:Category(catagory)
    return self.metas[catagory]
end

function MetaManager:LoadConfig(model_name)
    return include(model_name)
end

function MetaManager:LoadConfigAndSortById(model_name)
    return self:SortConfigById(self:Category(model_name))
end

function MetaManager:GetItemName(itemId)
    local name = self.metas.ItemTemplate[tostring(itemId)].name
    return Runtime.Translate(name)
end

function MetaManager:GetItemMeta(itemId)
    return self.metas.ItemTemplate[tostring(itemId)]
end

function MetaManager:GetAllItemMeta()
    return self.metas.ItemTemplate
end

function MetaManager:GetItemType(itemId)
    itemId = tostring(itemId)
    console.assert(itemId and self.metas.ItemTemplate[itemId], "ID:" .. tostring(itemId) .. " => Type:" .. type(itemId)) --@DEL
    if self.metas.ItemTemplate[itemId] then
        return self.metas.ItemTemplate[itemId].type
    end
    return 0
end

function MetaManager:GetItemIdByType(type)
    local metas = self.metas.ItemTemplate
    local ids = {}
    for id, cfg in pairs(metas) do
        if cfg.type == type then
            table.insert(ids, id)
        end
    end
    return ids
end

function MetaManager:GetItemDesc(itemId)
    itemId = tostring(itemId)
    if self.metas.ItemTemplate[itemId] then
        return self.metas.ItemTemplate[itemId].desc
    end
end

function MetaManager:GetItemFuncType(itemId)
    itemId = tostring(itemId)
    console.assert(itemId and self.metas.ItemTemplate[itemId], "ID:" .. tostring(itemId) .. " => Type:" .. type(itemId))
    if self.metas.ItemTemplate[itemId] then
        return self.metas.ItemTemplate[itemId].funcType
    end
    return 0
end

function MetaManager:GetItemFuncParam(itemId)
    itemId = tostring(itemId)
    console.assert(itemId and self.metas.ItemTemplate[itemId], "ID:" .. tostring(itemId) .. " => Type:" .. type(itemId))
    if self.metas.ItemTemplate[itemId] then
        return self.metas.ItemTemplate[itemId].funcParam[1]
    end
    return 0
end

function MetaManager:GetItemFuncParamById(itemId)
    itemId = tostring(itemId)
    local meta = self.metas.ItemTemplate[itemId]
    console.assert(itemId and meta, "ID:" .. tostring(itemId) .. " => Type:" .. type(itemId))
    if meta then
        return meta.funcParam
    end
end

function MetaManager:GetItemLimit(itemId)
    itemId = tostring(itemId)
    console.assert(itemId and self.metas.ItemTemplate[itemId], "ID:" .. tostring(itemId) .. " => Type:" .. type(itemId))
    if self.metas.ItemTemplate[itemId] then
        return self.metas.ItemTemplate[itemId].itemLimit
    end
    return 0
end

function MetaManager:GetItemIcon(itemId)
    itemId = tostring(itemId)
    if not self.metas.ItemTemplate[itemId] then
        console.error("物品:", itemId, "图标不存在, 使用钻石图标") --@DEL
        itemId = "5001001"
    end
    return self.metas.ItemTemplate[itemId].icon
end

function MetaManager:GetItemPrice(itemId)
    console.assert(itemId)
    if self.metas.ItemTemplate[itemId] then
        return self.metas.ItemTemplate[itemId].price
    end
end

function MetaManager:GetBuffMeta(buffId)
    return self.metas.BuffTemplate[buffId]
end

function MetaManager:GetConfigMetaValue(key, default)
    local info = self.metas.ConfigTemplate[key]
    if not info then
        console.error("no key:[" .. tostring(key) .. "] found in ConfigTemplate") --@DEL
        return default
    end
    return info.value or default
end

function MetaManager:GetConfigMetaValueNumber(key, default)
    local value = self:GetConfigMetaValue(key)
    if value then
        return tonumber(value) or default
    end
    return default
end

--[[
---@param shopType int
function MetaManager:GetShopMetasByShopType(shopType)
    local ret = {}
    for _, v in pairs(self.metas.ShopTemplate) do
        if v.shopType == shopType then
            table.insert(ret, v)
        end
    end
    return ret
end
]]
---@return ObjectMeta
function MetaManager:GetBindingMeta(tid)
    tid = tostring(tid)
    return self.metas.BuildingTemplate[tid]
end

---@return ObjectMeta
function MetaManager:GetBindingMetaByType(t)
    local metas = self.metas.BuildingTemplate
    for _, cfg in pairs(metas) do
        if cfg.type == t then
            return cfg
        end
    end
end

function MetaManager:GetItemsByFuncType(funcType)
    local items = {}
    if funcType == 0 then
        return items
    end
    for _, value in pairs(self.metas.ItemTemplate) do
        if value.funcType == funcType then
            table.insert(items, value)
        end
    end
    return items
end

function MetaManager:GetItemsWithSameFuncType(itemId)
    local funcType = self:GetItemFuncType(itemId)
    return self:GetItemsByFuncType(funcType)
end

--摇一摇触发阈值
function MetaManager:GetShakeThreshold()
    local shakethreshold = self.metas.ConfigTemplate.shakethreshold or {}
    local value = shakethreshold.value or 1
    return tonumber(value)
end

function MetaManager:SortConfigById(config)
    return self:SortConfig(config, "id")
end

function MetaManager:SortConfig(config, sortBy)
    local sortedConfig = {}
    for _, value in pairs(config) do
        table.insert(sortedConfig, value)
    end
    table.sort(
        sortedConfig,
        function(data1, data2)
            return tonumber(data1[sortBy]) < tonumber(data2[sortBy])
        end
    )
    return sortedConfig
end

function MetaManager:GetLevelConfig(level)
    level = tostring(level)
    return self.metas.LevelTemplate[level]
end

function MetaManager:GetMaxLevel()
    if self.caches.max_level then
        return self.caches.max_level
    end

    local cfg = self.metas.LevelTemplate
    local maxLevel = 1
    for _, v in pairs(cfg) do
        local num_k = tonumber(v.sn)
        if maxLevel < num_k then
            maxLevel = num_k
        end
    end
    self.caches.max_level = maxLevel
    return maxLevel
end

---获取体力回复时间
function MetaManager:GetEnergyCdTime()
    return tonumber(self.metas.ConfigTemplate.energyValueCdTime.value)
end

--按等级获得可带协助龙数量
function MetaManager:GetDragonHelpNum(level)
    level = tostring(level)
    local cfg = self.metas.LevelTemplate[level]
    return cfg.dragonHelpNum
end

---获取龙的一条配置
---@param dragonId string 龙id
function MetaManager:GetMagicalCreateuresConfigById(dragonId)
    dragonId = tostring(dragonId)
    return self.metas.MagicalCreaturesTemplate[dragonId]
end

---根据道具ID获取龙的ID
function MetaManager:GetDragonIdByItemId(itemId)
    itemId = tostring(itemId)
    local id, minLv
    for dragonId, cfg in pairs(self.metas.MagicalCreaturesTemplate) do
        if tostring(cfg.productivity[1]) == itemId then
            -- return dragonId
            if not minLv or minLv > cfg.level then
                minLv = cfg.level
                id = dragonId
            end
        end
    end
    return id
end

---根据道具ID获取产出此道具的所有龙的ID
function MetaManager:GetAllDragonIdByItemId(itemId)
    itemId = tostring(itemId)
    local ids = nil
    for dragonId, cfg in pairs(self.metas.MagicalCreaturesTemplate) do
        if tostring(cfg.productivity[1]) == itemId then
            ids = ids or {}
            table.insert(ids, dragonId)
        end
    end
    return ids
end

---获取建筑修复的配置
function MetaManager:GetBuildingRepair(templateId)
    return self.metas.TaskBuildingTemplate[templateId]
end

function MetaManager:GetSceneCfg(sceneId)
    local cfgs = self:Category("SceneTemplate")
    if sceneId then
        return cfgs and cfgs[sceneId]
    else
        return cfgs
    end
end
---获取当前场景地图的名字
function MetaManager:GetCurSceneName()
    local cfg = self:Category("SceneTemplate")
    if cfg then
        local id = App.scene:GetCurrentSceneId()
        local mapName = Runtime.Translate(cfg[id].nameStr)
        return mapName
    end
end

---获取scene的icon
function MetaManager:GetSceneIcon(sceneId)
    local cfg = self:Category("SceneTemplate")[sceneId]
    if not cfg then
        console.error("场景:", sceneId, " 配置不存在, 使用city场景图标") --@DEL
        cfg = self:Category("SceneTemplate")["city"]
    end
    local icon = cfg.icon
    if not icon then
        console.error("场景图标:", sceneId, "图标不存在, 使用city场景图标") --@DEL
        icon = self:Category("SceneTemplate")["city"].icon
    end
    return icon
end

function MetaManager:GetTurntabaleEnergyMeta(id)
    return self.metas.TurntableTemplate[id]
end

---获取商人配置
function MetaManager:GetTraderConfig(traderId)
    if not traderId then
        return
    end

    local cof = self.metas.ExchangeTemplate
    if cof then
        return cof[tostring(traderId)]
    end
end
---获取商人普通兑换信息
function MetaManager:GetTraderNormalItems(traderId)
    local cof = self:GetTraderConfig(traderId)
    if cof then
        local info = cof.exchangeNormalNeed
        local normalNeed = {}
        for k, v in ipairs(info) do
            normalNeed[k] = {itemId = v[1], count = v[2]}
        end
        local normalReward = {}
        info = cof.exchangeNormalReward
        for k, v in ipairs(info) do
            normalReward[k] = {itemId = v[1], count = v[2]}
        end
        local result = {normalNeed = normalNeed, normalReward = normalReward}
        return result
    end
end
---获取商人特惠兑换信息
function MetaManager:GetTraderSpecialItems(traderId)
    local cof = self:GetTraderConfig(traderId)
    if cof then
        local info = cof.exchangeSpecialNeed
        local specialNeed = {itemId = info[1], count = info[2]}
        info = cof.exchangeSpecialReward
        local specialReward = {itemId = info[1], count = info[2]}
        info = cof.exchangeSpecialBox
        local specialBox = {}
        for k, v in ipairs(info) do
            specialBox[k] = {itemId = v[1], count = v[2]}
        end
        local result = {
            specialNeed = specialNeed,
            specialReward = specialReward,
            specialBox = specialBox,
            specialTime = cof.exchangeSpecialTime
        }
        return result
    end
end
---获取商人完成奖励信息
function MetaManager:GetTraderCompleteItems(traderId)
    local cof = self:GetTraderConfig(traderId)
    if cof then
        local completeReward = {}
        for k, v in ipairs(cof.exchangeComplete) do
            completeReward[k] = {itemId = v[1], count = v[2]}
        end
        return completeReward
    end
end

---获取收藏系统的配置
function MetaManager:GetCollectionItem(id)
    id = tostring(id)
    return self.metas.CollectionTemplate[id]
end

---获取采集成就奖励配置
function MetaManager:GetAchivementItem(achievementId)
    if not achievementId then
        return
    end
    local cof = self.metas.ObstacleAchievementTemplate
    if cof then
        return cof[achievementId]
    end
end
---通过MapId 获取采集成就奖励配置
function MetaManager:GetAchievementItemsByMapId(mapId)
    if not mapId then
        return
    end
    local cof = self.metas.ObstacleAchievementTemplate
    if cof then
        mapId = tostring(mapId)
        -- local res = {}
        for _, v in pairs(cof) do
            if v.mapId == mapId then
                -- res[#res+1] = v
                return true
            end
        end
    -- if #res>0 then
    --     return res
    -- end
    end
end

---获取采集目标ItemID列表
function MetaManager:GetAchievementItemsId(achievementId)
    if not achievementId then
        return
    end
    achievementId = tostring(achievementId)
    local cof = self.metas.ObstacleAchievementTemplate
    if cof then
        if not self.achievementItemsId then
            local lis = {}
            for k, v in pairs(self.metas.BuildingTemplate) do
                if v.achievementType > 0 then
                    local tlis = lis[v.achievementType]
                    if tlis then
                        tlis[#tlis + 1] = k
                    else
                        tlis = {k}
                        lis[v.achievementType] = tlis
                    end
                end
            end
            self.achievementItemsId = lis
        end
        local inf = cof[achievementId]
        if inf then
            local tp = inf.obstacleType[1]
            return self.achievementItemsId[tp]
        end
    end
end

--体力兑换装置
function MetaManager:GetConvertFactoryConfig(id)
    if not id then
        return
    end
    local cfg = self.metas.ConvertFactoryTemplate
    if cfg then
        return cfg[tostring(id)]
    end
end

function MetaManager.GetRewardAnimPriority()
    return {
        ["1000"] = 1,
        ["1003"] = 2,
        ["1002"] = 3,
        ["1001"] = 4
    }
end

function MetaManager:GetDropAniRadius()
    local cof = self.metas.ConfigTemplate
    local value = cof.dropAnimationRadius.value
    value = table.deserialize(value)
    return Vector2(value[1], value[2])
end

function MetaManager:GetComicsSkipable()
    if not self._comicsSkippable then
        local value = self.metas.ConfigTemplate.ComicsSkipMission.value
        if not string.isEmpty(value) then
            local finished = AppServices.Task:IsTaskFinish(value)
            self._comicsSkippable = finished
        else
            self._comicsSkippable = false
        end
    end
    return self._comicsSkippable
end

function MetaManager:GetScoreRewards(activityType)
    return self:Category("ActivityScoreRewardTemplate.ActivityScoreRewardTemplate" .. tostring(activityType))
end

local BUILDING_ANCHOR_TABLE
function MetaManager:GetOffset(metaId)
    if not BUILDING_ANCHOR_TABLE then
        BUILDING_ANCHOR_TABLE = include("Configs.Maps.BuildingAnchor")
    end
    local meta = self:GetBindingMeta(tostring(metaId))
    return BUILDING_ANCHOR_TABLE[meta.model]
end

function MetaManager:GetVaccumMeta(type, level)
    if not self.caches.CleanerTemplate then
        local Table = self.metas.CleanerTemplate
        local tlDic = {}
        for key, value in pairs(Table) do
            tlDic[value.type] = tlDic[value.type] or {}
            tlDic[value.type][value.level] = value
        end
        self.caches.CleanerTemplate = tlDic
    end
    local types = self.caches.CleanerTemplate[type]
    return types and types[level]
end

----------------------------

-- 把解析配置的代码尽量放到各自功能模块中去，不要在这里缓存配置信息
MetaManager:Init()
return MetaManager
