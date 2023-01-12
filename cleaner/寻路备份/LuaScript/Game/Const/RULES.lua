---@class RULES
local Rules = {}

function Rules.GetOsType()
    local osType = 0
    if RuntimeContext.UNITY_IOS then
        osType = 1
    elseif RuntimeContext.PLATFORM_NAME == "StandaloneWindows64" then
        osType = 2
    end
    return osType
end

function Rules.LoadMapLayout(name)
    local modelName = string.format("Configs.Maps.%s.layout", name)
    local ret = require(modelName)
    return ret
end

function Rules.LoadSceneConfig(name)
    local url = string.format("Game.Const.Scenes.%sConfig", name)
    local ret = require(url)
    return ret
end

function Rules.LoadObjectData(name)
    local model_name = string.format("Configs.Maps.%s.objects", name)
    local dt = require(model_name)
    return dt
end

function Rules.LoadPath(name)
    local model_name = "Configs.ScreenPlays.Paths." .. name
    local dt = include(model_name)
    return dt
end

function Rules.LoadCharacter(name)
    local model_name = "Configs.ScreenPlays.Characters." .. name
    local dt = include(model_name)
    return dt
end

function Rules.LoadDrama(zoneId, dramaId)
    local model_name = "Configs.ScreenPlays.Dramas.Zone" .. zoneId .. "." .. dramaId
    local dt = include(model_name)
    return dt
end

--@parmam FBuid 大图还是小图
function Rules.GetFBUrl(FBUid, FbAccessToken)
    return string.format("https://graph.fb.gg/%s/picture?access_token=%s", FBUid, FbAccessToken)
end

function Rules.GetMissionIconUrl(sprites, name)
    local sprite = sprites:GetSprite(name)
    if not sprite then
        sprite = sprites:GetSprite(string.sub(name, 1, #name - 1))
    end
    return sprite
end

function Rules.GetDramaName(zoneId, dramaId)
    return "Configs.ScreenPlays.Dramas.Zone" .. zoneId .. "." .. dramaId
end

function Rules.IsPlayerAppeared()
    return AppServices.Task:IsTaskFinish("MIssion1_Opening003Mysteriousfootprints")
end

function Rules.IsDragonAppeared()
    return AppServices.Task:IsTaskFinish("MIssion1_Opening002MeetDragon")
end

function Rules.GetSceneBundleDeps()
    if (RuntimeContext.UNITY_EDITOR) then
        local names = {"buildin", "scenesbuildin"}
        local rets = {}
        for i=1, #names do
            rets[i] = string.format("bundles/scenes/dependences/%s/%s.x", RuntimeContext.PLATFORM_NAME, names[i])
        end
        return rets
    end
    return {}
end

function Rules.GetSceneBundleName(name)
    name = string.lower(name)
    if (RuntimeContext.UNITY_EDITOR) then
        return string.format("bundles/scenes/%s/%s.x", name, RuntimeContext.PLATFORM_NAME)
    end
    return string.format("bundles/scenes/%s.x", name)
end

function Rules.IsDramaSpeedupEnabled()
    if RuntimeContext.VERSION_DEVELOPMENT then
        return true
    end
    return true
end

function Rules.SceneUnlocked(sceneId)
    local scenecfg = AppServices.Meta:Category("SceneTemplate")[sceneId]

    if not scenecfg then
        return false
    end
    local validators = {
        -- 初始解锁
        [0] = function()
            return true
        end,
        -- 完成指定任务
        [1] = function()
            local result = false
            local function _IsEnable()
                result = AppServices.Task:IsTaskFinish(scenecfg.param)
            end
            local ret, _ = pcall(_IsEnable)
            if not ret then
                return false
            end
            return result
        end,
        -- 达到一定角色等级
        [2] = function()
            return false
        end,
        -- 拥有特定类型的龙x个
        [3] = function()
            return false
        end,
        [-1] = function()
            return false
        end,
    }
    setmetatable(
        validators,
        {
            __index = function(t, k)
                return function()
                    return true
                end
            end
        }
    )
    return validators[scenecfg.unlockCondition]()
end

function Rules.isDungeon(sceneId)
    local scenecfg = AppServices.Meta:Category("SceneTemplate")[sceneId]
    return scenecfg.type == 5
end

-- 场景是否需要支持主角发光
function Rules.ActorEffectEanbled()
    local sceneId = App.scene:GetCurrentSceneId()
    return sceneId == "12"
end

---自动适配打点的道具 返回打点要求的格式的道具数组
function Rules.ConvertLogItem(items)
    local logItemArray = {}
    local ok, err =
        pcall(
        function()
            for _, v in ipairs(items) do
                local itemId = v.id or v.Id or v.itemId or v.itemTemplateId or v.ItemId or v[1]
                local count = v.num or v.count or v.amount or v.Amount or v[2]
                logItemArray[#logItemArray + 1] = {tostring(itemId), count}
            end
        end
    )
    if not ok then
        console.error(err)
    end
    return table.serialize(logItemArray)
end

function Rules.IsActivityScene(sceneType)
    return sceneType == SceneType.Activity
        or sceneType == SceneType.LevelMapActivity
        or sceneType == SceneType.GoldPanning
end

return Rules
