---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by DKSS.
--- DateTime: 2022/6/1 13:58
---
local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionUserGroup : GiftPreConditionBase
local GiftPreconditionUserGroup = class(Base, "GiftPreconditionUserGroup")

function GiftPreconditionUserGroup:ctor(userGroupIDAry)
    self.userGroupIDAry = userGroupIDAry
end

function GiftPreconditionUserGroup:Check()
    local group = AppServices.User:GetUserGroup()
    for _, id in ipairs(self.userGroupIDAry) do
        if id == group then
            console.dk(group, "组id正确： true") --@DEL
            return true
        end
    end
    console.dk(group, "组id正确： false") --@DEL
    return false
end

return GiftPreconditionUserGroup