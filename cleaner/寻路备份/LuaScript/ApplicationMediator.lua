local ApplicationMediator = MVCClass("ApplicationMediator", pureMVC.Mediator)

function ApplicationMediator:ctor(url, inst)
    ApplicationMediator.super.ctor(self, url, inst)
    self.inst = inst
end

--ApplicationMediator 注册完成
--注册成功时：面板资源已经全部准备好
function ApplicationMediator:onRegister()
    --registerMediator("ui.starNotice.mediator.NoticeMainPanelMediator")
    --只注册不销毁的资源mediator
end

function ApplicationMediator:onRemove()
end

function ApplicationMediator:listNotificationInterests()
    return {
        CONST.GLOBAL_NOFITY.LATEUPDATE,
        CONST.GLOBAL_NOFITY.Open_Panel,
        --CONST.GLOBAL_NOFITY.Init_Part,
        CONST.GLOBAL_NOFITY.USER_UID_CHANGED,
        CONST.GLOBAL_NOFITY.Lock_Camera
    }
end

function ApplicationMediator:handleNotification(notification)
    local name = notification:getName() --消息名字
    local type = notification:getType() --消息类型 --->推荐为模块名字
    local body = notification:getBody() --消息携带数据

    if (name == CONST.GLOBAL_NOFITY.Open_Panel) then
        PopupManager:CallWhenIdle(function ()
            PanelManager.showPanel(body, type)
        end)
    elseif (name == CONST.GLOBAL_NOFITY.USER_UID_CHANGED) then
        CS.BetaGame.MainApplication.Instance:SetUid(tostring(body.uid))
        AppServices.User.Default:Init()
        AppServices.ProductManager:UpdateUser(body.uid)
    elseif name == CONST.GLOBAL_NOFITY.Lock_Screen then
        UI.Context:LockScreen(body[2], body[1])
    end
end

return ApplicationMediator
