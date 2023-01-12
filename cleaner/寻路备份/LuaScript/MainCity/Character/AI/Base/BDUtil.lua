local BDUtil = {}
local AIInteractiveTemplate = {}

function BDUtil.RandomGetTargetIAGId(name, targetName)
    local temp = {}
    local tempFlag = {}
    for _, v in pairs(AIInteractiveTemplate) do
        if not tempFlag[v.groupId] and v.promoterName == name and v.receiverName == targetName then
            table.insert(temp, v.groupId)
            tempFlag[v.groupId] = true
        end
    end
    if #temp == 0 then
        return -1
    else
        return temp[math.random(1, #temp)]
    end
end

function BDUtil.IsLastFinishedTaskMuteAI()
    return false
end

function BDUtil:LastFinisednTaskHasAI()
    return false
end

return BDUtil
