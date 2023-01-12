--insertWidgetsBegin
--    btn_close
--insertWidgetsEnd

--insertRequire
local _FiveStarPanelBase = require "UI.FiveStar.View.UI.Base._FiveStarPanelBase"

---@class FiveStarPanel:_FiveStarPanelBase
local FiveStarPanel = class(_FiveStarPanelBase)

function FiveStarPanel:ctor()
end

function FiveStarPanel:onAfterBindView()
    Util.UGUI_AddButtonListener(
        self.goodButton,
        function()
            self:OnGood()
        end
    )

    Util.UGUI_AddButtonListener(
        self.badButton,
        function()
            self:OnBad()
        end
    )

    Util.UGUI_AddButtonListener(
        self.okButton,
        function()
            self:OnOK()
        end
    )
end

function FiveStarPanel:OnGood()
    PanelManager.closePanel(GlobalPanelEnum.FiveStarPanel)
    AppServices.FiveStarManager:OpenStore()
    DcDelegates.Legacy:Log_web_user_eva_game(1, AppServices.FiveStarManager.data.showCount, self.arguments.scene_name)
end

function FiveStarPanel:OnBad()
    self.root:SetActive(false)
    self.root1:SetActive(true)
    AppServices.FiveStarManager:SetDone()
    DcDelegates.Legacy:Log_web_user_eva_game(2, AppServices.FiveStarManager.data.showCount, self.arguments.scene_name)
end

function FiveStarPanel:OnOK()
    PanelManager.closePanel(GlobalPanelEnum.FiveStarPanel)
end

function FiveStarPanel:refreshUI()
end

return FiveStarPanel
