---@class ShutDownServerLogic
local ShutDownServerLogic = {
    gameObject = nil,
    panelGo = nil,
}
function ShutDownServerLogic:Initialize()
    local go = BResource.InstantiateFromAssetName("Prefab/UI/Common/System/ShutDownServerNoticeCanvas.prefab")
    self.gameObject = go
    self.gameObject:SetActive(false)
    GameObject.DontDestroyOnLoad(self.gameObject)
end

function ShutDownServerLogic:Check()
    local function OnSuccess(data)
        if string.isEmpty(data) then
            return
        end

        self.gameObject:SetActive(true)
        self:ShowPanel(data)
    end
    local function OnFailed(data)
    end

    App.httpClient:HttpGet(NetworkConfig.shutDownServerUrl, OnSuccess, OnFailed)
end

function ShutDownServerLogic:ShowPanel(data)
    if Runtime.CSNull(self.panelGo) then
        self.panelGo = find_component(self.gameObject, "ShutDownServerNoticePanel")
        local title = find_component(self.panelGo, "bg/title", Text)
        local text1 = find_component(self.panelGo, "text1", Text)
        local text2 = find_component(self.panelGo, "text2", Text)
        self.text3 = find_component(self.panelGo, "text3", Text)
        --self.text32 = find_component(self.panelGo, "text3/text32", Text)
        local text4 = find_component(self.panelGo, "text4", Text)
        local btn_text = find_component(self.panelGo, "btn_conform/Text", Text)

        title.text = Runtime.Translate("UI_maintenance_title")
        text1.text = Runtime.Translate("UI_maintenance_longtext1")
        text2.text = Runtime.Translate("UI_maintenance_longtext2")
        --text31.text = Runtime.Translate("UI_maintenance_longtext3")
        text4.text = Runtime.Translate("UI_maintenance_longtext4")
        btn_text.text = Runtime.Translate("UI_maintenance_button")

        local btn_conform = find_component(self.panelGo, "btn_conform", Button)
        Util.UGUI_AddButtonListener(btn_conform.gameObject, function()
            self.gameObject:SetActive(false)
        end)

        local btnClose = find_component(self.panelGo, "bg/btn_close", Button)
        Util.UGUI_AddButtonListener(btnClose.gameObject, function()
            self.gameObject:SetActive(false)
        end)
    end
    self.text3.text = Runtime.Translate("UI_maintenance_longtext3").."  <color=#D57A4A>"..data.."</color>"
end

ShutDownServerLogic:Initialize()
return ShutDownServerLogic