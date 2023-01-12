---@class ItemCostManager
local ItemCostManager = {}

function ItemCostManager:IsItemEnougth(dataGroup)
    local result = true
    local missing = {}
    if not dataGroup then
        return result, missing
    end
    for _, data in pairs(dataGroup) do
        local itemkey = tonumber(data[1])
        local count = data[2]
        local ownerCount = AppServices.User:GetItemAmount(itemkey)
        if count > ownerCount then
            missing[itemkey] = {needCount = count, ownerCount = ownerCount}
            result = false
        end
    end

    return result, missing
end


return ItemCostManager