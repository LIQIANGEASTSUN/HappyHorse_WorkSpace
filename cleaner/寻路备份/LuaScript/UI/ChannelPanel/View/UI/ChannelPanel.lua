--insertWidgetsBegin
--    btn_panel
--insertWidgetsEnd

--insertRequire
local _ChannelPanelBase = require "UI.ChannelPanel.View.UI.Base._ChannelPanelBase"

---@class ChannelPanel:_ChannelPanelBase
local ChannelPanel = class(_ChannelPanelBase)

function ChannelPanel:ctor()
end

function ChannelPanel:onAfterBindView()
end

function ChannelPanel:refreshUI()
    local function refreshChannel(name)
        local group = self.gameObject:FindGameObject("Connect_platform/"..name)
        local logic = App.loginLogic.LoginLogicMap[name]
        group:SetActive(logic)
        if not logic then
            return
        end

        local accountType = AppServices.AccountData:GetLastAccountType()
        local hasBind = logic:CheckBind(accountType)

        local btn_UnBind = group:FindGameObject("btn2")
        btn_UnBind:SetActive(not hasBind)

        local btn_Bind = group:FindGameObject("btn3")
        btn_Bind:SetActive(hasBind)
    end


    refreshChannel("fb")
    refreshChannel("ios")
end
--[[
function ChannelPanel:GetSignInWithApple()
    local appleGroup = self.gameObject.transform:Find("Connect_platform/ios").gameObject
    return appleGroup:GetComponent(typeof(CS.UnityEngine.SignInWithApple.SignInWithApplePlugin))
end
]]
return ChannelPanel
