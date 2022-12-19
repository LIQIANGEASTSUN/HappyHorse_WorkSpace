--insertRequire
local button = require "UI.Settings.ChooseLanguagePanel.View.UI.ChooseLanguageButton"
local _ChooseLanguagePanelBase = class(BasePanel)

local mirror = {
    ["en"]=1,--英语
    ["de"]=2,--德语
    ["fr"]=3,--法语
    ["it"]=4, --意大利
    ["ja"]=5, --日语
    ["vi"]=6,  --越南
    ["tu"]=7,  --土耳其
    ["ru"]=8,  --俄罗斯
    ["ko"]=9,  --韩国
    ["sp"]=10,  --西班牙
    ["ar"]=11,  --阿拉伯语
    ["th"]=12,-- 泰语
    ["tc"]=13, -- 繁中
    ["po"]=14,--portugues 葡萄牙
    ["ne"]=15,--nederland 荷兰
    ["zh"]=16,--简中
}
function _ChooseLanguagePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_zh = nil
    self.onClick_btn_zh = nil
    self.btn_rs = nil
    self.onClick_btn_rs = nil
    self.btn_en = nil
    self.onClick_btn_en = nil
    self.btn_fr = nil
    self.onClick_btn_fr = nil
    self.btn_close = nil
    self.onClick_btn_close = nil

	---@type ChooseLanguageButton[]
    self.buttons = {}

    local config = AppServices.Meta:GetConfigMetaValue("LocalizationLanguageConfig")
    self.langs = string.split(config,',')

end
function _ChooseLanguagePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _ChooseLanguagePanelBase:bindView()
    if (self.gameObject ~= nil) then
        self.btn_template = self.gameObject.transform:Find("list/btn_zh")
        self.tran_btn_parent = self.gameObject.transform:Find("list/Viewport/Content")
        self.database = self.tran_btn_parent:GetComponent(typeof(CS.BetaGame.UI.SpriteDatabase)).spriteList

        --insertInit
        for key, value in pairs(self.langs) do
            local gameObject = GameObject.Instantiate(self.btn_template)
            gameObject.name = 'btn_'..value
            gameObject.transform:SetParent(self.tran_btn_parent,false)

            local db1 = self.database[1].sprites
            local db2 = self.database[0].sprites
            local index = math.min(mirror[tostring(value)]-1,db1.Count - 1)

            self.buttons[value] = button.new(value, {normal= db1[index],grey= db2[index]}, gameObject)
        end

        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
        local title = self.gameObject:FindGameObject("txt_title")
        Runtime.Localize(title, "ui_settings_chooselanguage")

        Util.UGUI_AddButtonListener(self.btn_close.gameObject, function()
            sendNotification(ChooseLanguagePanelNotificationEnum.Click_btn_close)
            Runtime.Localize(title, "ui_settings_chooselanguage")
        end)
    end
end

--insertSetTxt

return _ChooseLanguagePanelBase
