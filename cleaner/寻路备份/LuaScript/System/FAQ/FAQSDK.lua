---@class FAQSDK
local FAQSDK = {
    delegate = CS.BetaGame.MainApplication.faqDelegate,
    musicOn = false,
    gameObject = nil,
    isInit = false,
}

--提前到开启游戏就初始化
function FAQSDK:Init()
    if not self.delegate then
        return
    end

    if not RuntimeContext.FAQ_ENABLE then
        return
    end
    if Runtime.CSNull(self.gameObject) then
        self.gameObject = BResource.InstantiateFromAssetName("Prefab/UI/zendesk/Zendesk.prefab")
        GameObject.DontDestroyOnLoad(self.gameObject)
        self.delegate:InitSDK(self.gameObject,function (result)
            if result then
                self:FinishInit()
            end
        end)
        self:SetPlayerName()
        self:SetDeviceInfo()
    end
end

function FAQSDK:FinishInit()
    self.isInit = true
    self.delegate:Regiset_GetRequestUpdatesCallback(function (result)
        self:RequestNewMessageResult(result)
    end)

    self.delegate:Regiset_CloseUICallback(function (newComment)
        self:CloseFAQ(newComment)
    end)
    self.delegate:GetRequestUpdates()
    sendNotification("LoginScenePanelNotificationEnum_FAQ_INIT_TRUE")
end

function FAQSDK:SetPlayerName()
    local name = LogicContext.UID
    local email = RuntimeContext.DEVICE_ID
    if name == "" or name == "UID" then
        name = email
    end
    self.delegate:SetAnonymousIdentity(email,name)
end

function FAQSDK:SetDeviceInfo()
    --playerId
    self.delegate:AddCustomFields(5538605271055,LogicContext.UID)
    --deviceId
    self.delegate:AddCustomFields(5539355123471,RuntimeContext.DEVICE_ID)
    --platform
    self.delegate:AddCustomFields(5543308170383,DcDelegates.Legacy:GetPlatform())
    --version
    self.delegate:AddCustomFields(5543316629519,RuntimeContext.BUNDLE_VERSION)
    --devicemodel
    local deviceInfo = DcDelegates.Legacy:GetDeviceInfo()
    if deviceInfo and deviceInfo.devicemodel then
        self.delegate:AddCustomFields(5543317240463,deviceInfo.devicemodel)
    end
end

function FAQSDK:ShowFAQ()
    --self.gameObject:SetActive(true)
    self.musicOn = App.audioManager:IsMusicEnable()
    App.audioManager:SetMusicEnable(false)
    self:SetPlayerName()
    self.delegate:GetRequestUpdates()
    self.delegate:OpenFAQ()
end

function FAQSDK:CloseFAQ(newComment)
    App.audioManager:SetMusicEnable(self.musicOn)
    --退出开始检测反馈消息
    --self.delegate:GetRequestUpdates()
    self:RequestNewMessageResult(newComment > 0)
end

function FAQSDK:RequestNewMessageResult(result)
    --console.lj("faq 来新消息了"..tostring(result)) --DEL
    --self.delegate:MarkRequestAsRead()
    local hasRed = AppServices.RedDotManage:GetRed("FAQ")
    if result then
        --console.lj("该加红点了，并停止刷新接收消息"..tostring(result)) --DEL
        if not hasRed then
            AppServices.RedDotManage:FreshDate_Count("FAQ",1)
        end
    else
        --console.lj("删除红点，开始启动消息接收器"..tostring(result)) --DEL
        if hasRed then
            AppServices.RedDotManage:ClearCount("FAQ")
        end
        WaitExtension.SetTimeout(function ()
            self.delegate:GetRequestUpdates()
        end, 5)
    end
end

return FAQSDK
