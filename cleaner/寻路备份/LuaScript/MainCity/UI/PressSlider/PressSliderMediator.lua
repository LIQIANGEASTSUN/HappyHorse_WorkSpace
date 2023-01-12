---@class PressSliderMediator
local PressSliderMediator = MVCClass('PressSliderMediator', pureMVC.Mediator)

---@param inst PressSlider
function PressSliderMediator:ctor(url, inst)
    PressSliderMediator.super.ctor(self, url, inst)
    self.inst = inst
end

function PressSliderMediator:onRegister()
end

function PressSliderMediator:onRemove()
end

function PressSliderMediator:listNotificationInterests()
    return {
        CONST.GLOBAL_NOFITY.BUILDING_PRESS_PROGRESS,
        CONST.GLOBAL_NOFITY.BUILDING_PRESS_PROGRESS_END
    }
end

function PressSliderMediator:handleNotification(notification)
    local name = notification:getName() --消息名字
    --local type = notification:getType() --消息类型 --->推荐为模块名字
    local body = notification:getBody() --消息携带数据

    if (name == CONST.GLOBAL_NOFITY.BUILDING_PRESS_PROGRESS) then
        self.inst:Show(body.position, body.progress)
    elseif name == CONST.GLOBAL_NOFITY.BUILDING_PRESS_PROGRESS_END then
        self.inst:Hide()
    end
end

return PressSliderMediator
