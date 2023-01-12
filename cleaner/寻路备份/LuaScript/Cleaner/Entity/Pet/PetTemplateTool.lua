---@class PetTemplateTool
local PetTemplateTool = {
    -- Dictionary<type, Dictionary<level, id>>
    map = nil,
    -- Dictionary<type, level>
    levelMap = nil
}

function PetTemplateTool:Getkey(type, level)
    self:Statistics()
    local typeInfo = self.map[type]
    if not typeInfo then
        return 0
    end

    if typeInfo.levelKeys[level] then
        return typeInfo.levelKeys[level]
    end

    return 0
end

function PetTemplateTool:GetMaxLevel(type)
    local typeInfo = self.map[type]
    if not typeInfo then
        return 0
    end

    return typeInfo.maxLevel
end

function PetTemplateTool:GetMaxStage(type)
    local typeInfo = self.map[type]
    if not typeInfo then
        return 0
    end

    return typeInfo.maxStage
end

function PetTemplateTool:GetStageMaxLelel(type, stage)
    local typeInfo = self.map[type]
    if not typeInfo then
        return 0
    end

    if typeInfo.stageMaxLevel[stage] then
        return  typeInfo.stageMaxLevel[stage]
    end

    return self:GetMaxLevel(type)
end

function PetTemplateTool:Statistics()
    if nil ~= self.map then
        return
    end

    self.map = {}
    local cfg = AppServices.Meta:Category("PetTemplate")
    for _, v in pairs(cfg) do
        local type = v.type
        local typeInfo = self.map[type]
        if not typeInfo then
            typeInfo = {}
            typeInfo.type = type
            typeInfo.maxLevel = 0
            typeInfo.maxStage = 0
            typeInfo.levelKeys = {}
            typeInfo.stageMaxLevel = {}
            self.map[type] = typeInfo
        end

        if typeInfo.maxLevel < v.level then
            typeInfo.maxLevel = v.level
        end

        if typeInfo.maxStage < v.stage then
            typeInfo.maxStage = v.stage
        end

        if not typeInfo.stageMaxLevel[v.stage] or typeInfo.stageMaxLevel[v.stage] < v.level then
            typeInfo.stageMaxLevel[v.stage] = v.level
        end

        typeInfo.levelKeys[v.level] = v.sn
    end
end

return PetTemplateTool
