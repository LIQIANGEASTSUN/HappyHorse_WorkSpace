---@class CharacterManager
CharacterManager = class(nil, "CharacterManager")

---@type CharacterManager
local instance
function CharacterManager.Instance()
    if not instance then
        instance = CharacterManager.new()
    end
    return instance
end

function CharacterManager.Destroy()
    if instance then
        instance:OnDestroy()
    end
end

function CharacterManager:ctor()
    -- self.animatableObjects = {}
    self.npcs = {}
    self.attachedObjects = {}
end

function CharacterManager:Init(params)
    local playerParams = {}
    if params then
        playerParams = params.Player or playerParams
    end

    --self:CreateByName("Player", playerParams)
end

function CharacterManager:CreateByName(name, params)
    local character
    local cfg = self.LoadConfig(name)
    local path = cfg.luaPath
    if string.isEmpty(path) then
        path = "MainCity.Character.Base.Character"
    end
    local cls = include(path)
    character = cls.new(name, cfg, params or {})
    character:Init()
    self:Add(character)
    return character
end

function CharacterManager.LoadConfig(name)
    local model_name = "Configs.ScreenPlays.Characters." .. name
    return include(model_name)
end

function CharacterManager:RemoveByName(name)
    print("CharacterManager:RemoveByName ", name) --@DEL
    for i, v in ipairs(self.npcs) do
        if v:GetName() == name then
            local target = self.npcs[i]
            table.remove(self.npcs, i)
            return target:Destroy()
        end
    end
end

function CharacterManager:Awake()
    for i = 1, #self.npcs do
        self.npcs[i]:Awake()
    end
end

function CharacterManager:LateUpdate(dt)
    for i = 1, #self.npcs do
        local npc = self.npcs[i]
        if not npc.isDestroyed then
            npc:LateUpdate(dt)
        end
    end
end

function CharacterManager.ActorEffectEnabled(name)
    return name == "Femaleplayer" or name == "Maleplayer"
end

function CharacterManager:Add(npc)
    -- console.assert(not self:Find(npc:GetName()))
    table.insertIfNotExist(self.npcs, npc)
    if self.ActorEffectEnabled(npc:GetName()) then
        XGE.EffectExtension.ActorSpotEffect_AddTarget(npc.renderObj)
    end
end

function CharacterManager:Remove(npc)
    for i, v in ipairs(self.npcs) do
        if v == npc then
            if self.ActorEffectEnabled(npc:GetName()) then
                XGE.EffectExtension.ActorSpotEffect_RemoveTarget(npc.renderObj)
            end
            self.npcs[i]:Destroy()
            return table.remove(self.npcs, i)
        end
    end
end

function CharacterManager:Get(name, params)
    for i = 1, #self.npcs do
        if self.npcs[i]:IsSameName(name, params) then
            return self.npcs[i]
        end
    end
    -- console.warn(nil, "character not found: " .. (name or "empty")) --@DEL
    local character = self:CreateByName(name, params)
    character:Awake()
    return character
end

function CharacterManager:Find(name)
    for i = 1, #self.npcs do
        if self.npcs[i]:GetName() == name then
            return self.npcs[i]
        end
    end
end

function CharacterManager:OnDestroy()
    instance = nil

    -- 被attach的东西需要提前释放
    for parent, attached in pairs(self.attachedObjects) do
        print("@@@@@@@@@@@@ DESTROY", parent, attached) --@DEL
        for _, v in pairs(attached) do
            self:RemoveByName(v)
        end
    end
    self.attachedObjects = {}

    for i, _ in ipairs(self.npcs) do
        self.npcs[i]:Destroy()
    end
    self.npcs = {}

    -- for i, v in ipairs(self.animatableObjects) do
    --     self.animatableObjects[i]:Destroy()
    -- end
    -- self.animatableObjects = {}
end

function CharacterManager:DestroyAttached(parent)
    if self.attachedObjects[parent] then
        for _, v in pairs(self.attachedObjects[parent]) do
            self:RemoveByName(v)
        end
        self.attachedObjects[parent] = nil
    end
end

function CharacterManager:RegisterAttached(parent, child)
    if not self.attachedObjects[parent] then
        self.attachedObjects[parent] = {}
    end
    table.insert(self.attachedObjects[parent], child)
end

function CharacterManager:Detached(parent, child)
    local childList = self.attachedObjects[parent]
    if not childList then return end
    for i = 1, #childList do
        if (childList[i] == child) then
            table.remove(self.attachedObjects[parent], i)
            return
        end
    end
end

function CharacterManager:GetCharacterPrefab(person, params)
    local assetPath = AppServices.SkinLogic:GetModel(person)
    local config = CONST.RULES.LoadCharacter(person, params)
    local bundlePath = nil
    if table.isEmpty(assetPath) and not string.isEmpty(config.modelName) then
        table.insert(assetPath, config.modelName)
    end
    if table.isEmpty(assetPath) then
        assetPath, bundlePath = self.getCharacterPrefabByParams(person, params)
    end

    if string.isEmpty(bundlePath) then
        if config.prewarmAnimBundle then
            bundlePath = string.format("prefab/magicalcreatures/animation/%s.x", string.lower(person))
        end
    end
    return assetPath, bundlePath
end

function CharacterManager.getCharacterPrefabByParams(person, params)
    local config = CONST.RULES.LoadCharacter(person, params)
    local pt = config.personType
    if not pt then
        return nil
    end

    local characherPrefabGetFunction = {
        Dragon = function(params_)
            local templateId = params_.DragonId
            local meta = AppServices.Meta:Category("MagicalCreaturesTemplate")[templateId]
            local path = string.format("Prefab/MagicalCreatures/%s.prefab", meta.model)
            local bundleName = string.format("prefab/magicalcreatures/animation/%s.x", string.lower(meta.model))
            return {path}, bundleName
        end,
        DramaDragon = function(params_)
            local path = string.format("Prefab/Art/Characters/%s.prefab", params_.DramaDragonAsset)
            local bundleName = string.format("prefab/magicalcreatures/animation/%s.x", string.lower(params_.DramaDragonAsset))
            return {path}, bundleName
        end,
    }
    if characherPrefabGetFunction[pt] then
        return characherPrefabGetFunction[pt](params)
    end
    console.assert(false, 'No Get Char Prefab Func for type', pt)
    return nil
end
