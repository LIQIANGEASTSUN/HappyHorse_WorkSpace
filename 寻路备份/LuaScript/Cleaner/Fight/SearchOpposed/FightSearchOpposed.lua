---@type TargetSearchResult
local TargetSearchResult = require "Cleaner.Fight.SearchOpposed.TargetSearchResult"

---@class FightSearchOpposed
local FightSearchOpposed = class(nil, "FightSearchOpposed")

-- 搜索角色 FightUnitBase
function FightSearchOpposed:ctor(FightUnitBase)
    ---@type FightUnitBase
    self.fightUnit = FightUnitBase
    self.searchDistance = 1
    self:PetStartAttackRoleDistance()
end

function FightSearchOpposed:SetSearchDistance(searchDistance)
    self.searchDistance = searchDistance
end

function FightSearchOpposed:GetSearchDistance()
    return self.searchDistance
end

function FightSearchOpposed:GetPlayer()
    if not self.playerCharacter then
        self.playerCharacter = CharacterManager.Instance():Find("Player")
    end
end

function FightSearchOpposed:PetStartAttackRoleDistance()
    if self.petStartAttackRoleDistance then
        return
    end
    local config = AppServices.Meta:Category("ConfigTemplate")
    local value = config["petStartAttackRoleDistance"].value
    self.petStartAttackRoleDistance = tonumber(value)
end

-- 搜索距离 searchDistance

-- [技能可以攻击的 fightUnit] ：根据技能作用阵营关系(自己、友方、敌方)，判断 fightUnit 与自己的阵营关系
-- 技能作用阵营关系为 敌方 ，如果 fightUnit 是自己的敌方，则 判定为技能可以攻击该 fightUnit

-- 搜索与自己距离小于 searchDistance 的所有 fightUnits
-- 遍历 fightUnits， 从 所有技能中 并且 [技能可以攻击的 fightUnit] 选择 距离最近的一个 fightUnit
function FightSearchOpposed:SearchWithFightUnit(skillMap)
    local distanceFunc = function(other)
        return self:SpriteWithSpriteDistance(self.fightUnit, other, self.searchDistance)
    end

    return self:Search(distanceFunc, skillMap)
end

function FightSearchOpposed:SearchWithPlayer(skillMap)
    local distanceFunc = function(other)
        return self:SpriteWithPlayerDistance(other, self.petStartAttackRoleDistance)
    end

    return self:Search(distanceFunc, skillMap)
end

function FightSearchOpposed:Search(distanceFunc, skillMap)
    local targetSearchResult = TargetSearchResult.new(self.fightUnit)
    targetSearchResult.spriteDistance = 100000000

    local sprites = AppServices.UnitManager:GetUnitWithType(UnitType.FightUnit)
    for _, other in pairs(sprites) do
        local result, distance = distanceFunc(other)
        if result then
            self:CheckSkill(other, targetSearchResult, distance, skillMap)
        end
    end

    return targetSearchResult
end

-- 根据 两个 FightUnit 判断距离
function FightSearchOpposed:SpriteWithSpriteDistance(oneFight, otherFight, range)
    local result = false
    local distance = 0
    if not otherFight:EnableAttack() then
        return result, distance
    end

    result, distance = self:SpriteDistance(oneFight, otherFight, range)
    return result, distance
end

function FightSearchOpposed:SpriteDistance(oneFight, otherFight, range)
    local selfPos = oneFight:GetPosition()
    local otherPos = otherFight:GetPosition()
    local distance = (selfPos - otherPos).magnitude

    local result = distance <= range
    return result, distance
end

-- 宠物攻击与 Player 距离小于 ConfigTemplate 表 petStartAttackRoleDistance 字段的怪物
-- 排除掉超出距离的怪物
function FightSearchOpposed:SpriteWithPlayerDistance(otherFight, range)
    local result = false
    local distance = 0
    if not otherFight:EnableAttack() then
        return result, distance
    end

    self:GetPlayer()
    if not self.playerCharacter then
        return result, distance
    end

    local playerPos = self.playerCharacter:GetPosition()
    local otherPos = otherFight:GetPosition()
    distance = (playerPos - otherPos).magnitude

    result = distance <= range
    return result, distance
end

-- 根据技能攻击距离、锁敌距离判断
function FightSearchOpposed:CheckSkill(other, targetSearchResult, distance, skillMap)
    local skillController = self.fightUnit:SkillController()
    local skillIds = skillController:GetAllSkillID()

    for _, skillId in pairs(skillIds) do
        local skill = skillController:GetSkill(skillId)
        local result = skill:IsValidCampRelation(other)

        local valid = (not skillMap) or (nil ~= skillMap[skillId])

        if result and valid then
            if nil == targetSearchResult.other or targetSearchResult.spriteDistance > distance then
                targetSearchResult.other = other
                targetSearchResult.skillId = skillId
                targetSearchResult.spriteDistance = distance
            end
        end
    end
end

-- 根据技能作用阵营关系判断有效的技能
function FightSearchOpposed:GetSkillsWithCamp(other)
    local skillController = self.fightUnit:SkillController()
    local skillIds = skillController:IsValidCampRelation(other)
    return skillIds
end

-- 根据攻击阵营关系所搜
function FightSearchOpposed:SearchCamp(campRelation, distance)
    local results = {}

    local sprites = AppServices.UnitManager:GetUnitWithType(UnitType.FightUnit)
    for _, other in pairs(sprites) do
        local selfCamp = self.fightUnit:GetCamp()
        local otherCamp = other:GetCamp()
        local isSelf = self.fightUnit:GetInstanceId() == other:GetInstanceId()
        local value = CampType.IsValidCampRelation(campRelation, selfCamp, otherCamp, isSelf)
        if value then
            local distanceValid = self:SpriteDistance(self.fightUnit, other, distance)
            if distanceValid then
                table.insert(results, other)
            end
        end
    end

    return results
end

return FightSearchOpposed