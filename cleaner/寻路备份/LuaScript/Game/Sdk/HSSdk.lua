local HSSdk = {}

-- local function safe_call_cs_function(func,...)
--     if func ~= nil and type(func)  == "function" then
--         return func(...)
--     end
-- end

function HSSdk:Init()
    -- self.sdk = CS.HSSdk
    -- self.sdk.Init()
    self.msgCount = 0
    self.campaignsMsgCount = 0
    self:RegisterMsgCountCallback(function(count)
        self.msgCount = tonumber(count)
    end)
    self:RegisterCampaignsMsgCountCallback(function(count)
        self.campaignsMsgCount = tonumber(count)
    end)
end

function HSSdk:GetHSMsgCount()
    return self.msgCount
end

function HSSdk:GetCampaignsMsgCount()
    return self.campaignsMsgCount
end

function HSSdk:ShowFAQ()
    -- local lang = AppServices.User:GetLanguage()
    -- if lang == "zh" then
    --     lang = "zh-Hans"
    -- end
    -- self.sdk.SetLanguage(lang)
    -- self.sdk.ShowFAQ()
end

function HSSdk:UserLogin(userId)
    -- self.sdk.UserLogin(userId)
end

function HSSdk:UserLogout()
    -- self.sdk.UserLogout()
end

function HSSdk:RegisterMsgCountCallback(cb)
    -- if cb and self.sdk  then
    --     safe_call_cs_function(self.sdk.RegisterHSSdkMessageCountCallback,cb)
    --     -- self.sdk.RegisterHSSdkMessageCountCallback(cb)
    -- end
end

function HSSdk:UnregisterMsgCountCallback(cb)
    -- if cb and self.sdk then
    --     safe_call_cs_function(self.sdk.UnregisterHSSdkMessageCountCallback,cb)
    --     -- self.sdk.UnregisterHSSdkMessageCountCallback(cb)
    -- end
end

function HSSdk:RegisterCampaignsMsgCountCallback(cb)
    -- if cb and self.sdk then
    --     safe_call_cs_function(self.sdk.RegisterCampaignsMessageCountCallback,cb)
    --     -- self.sdk.RegisterCampaignsMessageCountCallback(cb)
    -- end
end

function HSSdk:UnregisterCampaignsMsgCountCallback(cb)
    -- if cb and self.sdk then
    --     safe_call_cs_function(self.sdk.UnregisterCampaignsMessageCountCallback,cb)
    --     -- self.sdk.UnregisterCampaignsMessageCountCallback(cb)
    -- end
end

return HSSdk