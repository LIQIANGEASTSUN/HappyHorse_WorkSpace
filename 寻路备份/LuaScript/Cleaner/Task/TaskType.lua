local _TypesToName = {
    -- [TaskEnum.Login] = "Login",
    [TaskEnum.LevelUp] = "LevelUp",
    [TaskEnum.GetPet] = "GetPet",
    [TaskEnum.HavePet] = "HavePet",
    [TaskEnum.PetLevel] = "PetLevel",
    [TaskEnum.ProductItem] = "ProductItem",
    -- [TaskEnum.ProductItemByType] = "ProductItemByType",
    [TaskEnum.ProductDecoration] = "ProductDecoration",
    [TaskEnum.LinkIsland] = "LinkIsland",
    [TaskEnum.RecycleItem] = "RecycleItem",
    [TaskEnum.GetItem] = "GetItem",
    [TaskEnum.FindAgent] = "FindAgent",
}

setmetatable(
    _TypesToName,
    {
        __index = function(t, k)
            return k
        end
    }
)
---@class TaskTypes
local TaskTypes =
    setmetatable(
    {},
    {
        __index = function(t, k)
            local name = _TypesToName[k]
            if name then
                local path = "Cleaner.Task.Conditions." .. name
                local v = include(path)
                rawset(t, k, v)
                return v
            else
                console.error("Task of Type:[" .. tostring(k) .. "] Not Found!")
            end
        end
    }
)
return TaskTypes