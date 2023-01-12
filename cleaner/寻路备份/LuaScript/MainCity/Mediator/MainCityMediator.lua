require "MainCity.Mediator.MainCityNotificationEnum"

local MainCityMediator = MVCClass("MainCityMediator", pureMVC.Mediator)

function MainCityMediator:ctor(url, inst)
    MainCityMediator.super.ctor(self, url, inst)
    self.inst = inst
end

function MainCityMediator:onRegister()
end

function MainCityMediator:onRemove()
end

function MainCityMediator:listNotificationInterests()
    return {
        MainCityNotificationEnum.ShowAllIconButtons,
        MainCityNotificationEnum.HideAllIconButtons,
        MainCityNotificationEnum.BuildMedalButton,
        MainCityNotificationEnum.PlayRightBarAnim,
        CONST.GLOBAL_NOFITY.PreLoadAds,
        MainCityNotificationEnum.ShowShopBalloon,
        MainCityNotificationEnum.RefreshRedDot
    }
end

function MainCityMediator:handleNotification(notification)
    local name = notification:getName() --消息名字
    --local type = notification:getType() --消息类型 --->推荐为模块名字
    local body = notification:getBody() --消息携带数据
    ---@type MainCity
    local mainCity = self:getViewComponent()

    if name == MainCityNotificationEnum.ShowAllIconButtons then
        mainCity:ShowAllIcons()
    elseif name == MainCityNotificationEnum.HideAllIconButtons then
        mainCity:HideAllIcons()
    elseif name == MainCityNotificationEnum.PlayRightBarAnim then
        mainCity:CheckRightBarBlockAnim(body)
    elseif name == MainCityNotificationEnum.RefreshRedDot then
        mainCity:RefreshRedDot(body)
    end
end

return MainCityMediator
