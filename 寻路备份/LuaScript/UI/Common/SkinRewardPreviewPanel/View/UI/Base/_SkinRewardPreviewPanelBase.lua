--insertRequire

---@class _SkinRewardPreviewPanelBase:BasePanel
local _SkinRewardPreviewPanelBase = class(BasePanel)

function _SkinRewardPreviewPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.text_continue = nil
    self.btn_hitLayer = nil
    self.onClick_btn_hitLayer = nil
end

function _SkinRewardPreviewPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _SkinRewardPreviewPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.btn_hitLayer = find_component(self.gameObject, "btn_hitLayer")
        self.title = find_component(self.gameObject, "title", Text)
        self.desc = find_component(self.gameObject, "desc", Text)
        self.dragonDress = find_component(self.gameObject, "dragonDress", Transform)

        self.goQuality = find_component(self.gameObject, "quality")
		local skills = {}
		for k=1, 3 do
			local go = find_component(self.gameObject, string.format("skillAttribute/skill_%d", k))
			skills[k] = {
				gameObject = go,
				imgIcon = find_component(go, "icon", Image),
				txt = find_component(go, "txt", Text)
			}
		end
		self.skills = skills
        --insertInitComp
        --insertOnClick
        local function OnClick_btn_hitLayer(go)
            sendNotification(SkinRewardPreviewPanelNotificationEnum.Click_btn_hitLayer)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_hitLayer, OnClick_btn_hitLayer)
    end
end

--insertSetTxt

return _SkinRewardPreviewPanelBase
