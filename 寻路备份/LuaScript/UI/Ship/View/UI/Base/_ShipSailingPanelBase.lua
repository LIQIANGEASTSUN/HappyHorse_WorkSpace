--insertRequire

---@class _ShipSailingPanelBase:BasePanel
local _ShipSailingPanelBase = class(BasePanel)
local ScrollRect = CS.UnityEngine.UI.ScrollRect

function _ShipSailingPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
	self.txt_title = nil
	self.IslandGroupTr = nil
    self.islandItem = nil

	self.selectIsland = nil
	self.txt_island = nil
	self.txt_progress = nil
	self.txt_distance = nil
	self.txt_island_goods = nil
	self.btn_go = nil
	self.txt_go = nil
end

function _ShipSailingPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _ShipSailingPanelBase:bindView()
	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
		self.txt_title = self.gameObject.transform:Find("txt_title").gameObject:GetComponent(typeof(Text))

        self.IslandGroupTr = find_component(self.gameObject,'ScrollView/Viewport/Content/IslandGroup',Transform)
		self.mapScrollRect = find_component(self.gameObject,'ScrollView',ScrollRect)

		self.homelandTr = find_component(self.IslandGroupTr.gameObject,'HomelandItem',Transform)
		self.homelandRect = self.homelandTr.gameObject:GetComponent(typeof(RectTransform))

		self.txt_name_homeland = self.IslandGroupTr:Find("HomelandItem/txt_island").gameObject:GetComponent(typeof(Text))
		self.islandItemTr = find_component(self.IslandGroupTr.gameObject,'IslandItem',Transform)

		--self.islandItem = find_component(self.gameObject,'IslandGroup/IslandItem',Transform)
		self.pathParent = find_component(self.IslandGroupTr.gameObject,'Path',Transform)
		self.btn_reset = self.gameObject.transform:Find("Bottom/MapCenter/btn_reset").gameObject:GetComponent(typeof(Button))

        self.selectIsland = find_component(self.gameObject,'Bottom/IslandInfo',Transform)
		local selectGo = self.selectIsland.gameObject
		self.txt_dock_level = find_component(selectGo,'DockInfo/txt_level',Text)
		self.txt_island = find_component(selectGo,'txt_island',Text)
		self.txt_progress = find_component(selectGo,'txt_progress',Text)
        self.txt_distance = find_component(selectGo,'txt_distance',Text)
		self.txt_island_goods = find_component(selectGo,'txt_island_goods',Text)
		self.btn_go = find_component(selectGo,'btn_go',Button)
		self.txt_go = find_component(selectGo,'btn_go/txt_go',Text)
		self.btn_disable = find_component(selectGo,'btn_disable',Button)
		self.txt_go_disable = find_component(selectGo,'btn_disable/txt_go',Text)

		self.petParent = find_component(selectGo,'AnimalInfo/ScrollView/Viewport/Content',Transform)
		self.petCloneTr = find_component(self.petParent.gameObject,'Item',Transform)

		self.materialParent = find_component(selectGo,'MaterialInfo/ScrollView/Viewport/Content',Transform)
		self.materialTr = find_component(self.materialParent.gameObject,'Item',Transform)

		self.costParent = find_component(selectGo,'CostInfo/ScrollView/Viewport/Content',Transform)
		self.costTr = find_component(self.costParent.gameObject,'Item',Transform)

	--insertInitComp
	--insertOnClick
        local function OnClick_btn_close(go)
            sendNotification(ShipSailingPanelNotificationEnum.Click_btn_close)
        end

		local function OnClick_btn_go(go)
			sendNotification(ShipSailingPanelNotificationEnum.Click_btn_go)
		end

		local function OnClick_btn_disable(go)
			sendNotification(ShipSailingPanelNotificationEnum.Click_btn_disable)
		end

		local function OnClick_btn_reset(go)
			sendNotification(ShipSailingPanelNotificationEnum.Click_btn_reset)
		end

	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
		Util.UGUI_AddButtonListener(self.btn_go.gameObject, OnClick_btn_go)
		Util.UGUI_AddButtonListener(self.btn_disable.gameObject, OnClick_btn_disable)
		Util.UGUI_AddButtonListener(self.btn_reset.gameObject, OnClick_btn_reset)
	end
end
--insertSetTxt

return _ShipSailingPanelBase
