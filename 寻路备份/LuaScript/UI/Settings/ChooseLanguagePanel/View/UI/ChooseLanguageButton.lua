---@class ChooseLanguageButton
local button = class(nil, "ChooseLanguageButton")

function button:ctor(lang,sprites, go)
    self.lang = lang

    self.gameObject = go
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(true)

        self.btn_lang = self.gameObject:GetComponent(typeof(Button))
        self.go_select = self.btn_lang.transform:Find("text_select").gameObject
        self.go_notSelect = self.btn_lang.transform:Find("text_notSelect").gameObject
        self.duihao = self.btn_lang.transform:Find('duihao').gameObject

        self.img_select = find_component(self.go_select,'zh',Image)
        self.img_notSelect = find_component(self.go_notSelect,'zh',Image)

         self.img_select.sprite = sprites.normal
         self.img_notSelect.sprite = sprites.grey

         self.img_select:SetNativeSize()
         self.img_notSelect:SetNativeSize()

        self.img_select.gameObject:SetActive(true)
        self.img_notSelect.gameObject:SetActive(true)
        self:EventListener()
    end
end

function button:OnCheck(language)
    if Runtime.CSValid(self.gameObject) then
        local checked = self.lang == language
        self.go_notSelect:SetActive(not checked)
        self.go_select:SetActive(checked)
        self.duihao:SetActive(checked)
    end
end

function button:EventListener()
    Util.UGUI_AddButtonListener(self.btn_lang, function (go)
        sendNotification(ChooseLanguagePanelNotificationEnum.Click_btn,self.lang)
    end)
end

return button
