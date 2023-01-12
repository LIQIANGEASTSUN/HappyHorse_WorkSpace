--insertRequire

local _DebugPanelBase = class(BasePanel)

function _DebugPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.btn_level = nil
	self.onClick_btn_level = nil
	self.go_level = nil
	self.go_mission = nil
	self.btn_mission = nil
	self.onClick_btn_mission = nil
	self.btn_close = nil
	self.onClick_btn_close = nil
	self.btn_gc = nil
	self.onClick_btn_gc = nil
	self.ClearDynamicResource = nil
	self.onClick_ClearDynamicResource = nil
	self.btnCrashlyticsTester = nil
	self.onClick_btnCrashlyticsTester = nil
end

function _DebugPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _DebugPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
		self.btn_level = self.gameObject.transform:Find("btn_level").gameObject:GetComponent(typeof(Button))
		self.go_level = self.gameObject:FindGameObject("go_level")

		self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
		self.btn_gc = self.gameObject.transform:Find("btn_gc").gameObject:GetComponent(typeof(Button))
		self.btn_TestAds = self.gameObject.transform:Find("btn_TestAds").gameObject:GetComponent(typeof(Button))
		self.btn_ShowCurQueue = self.gameObject.transform:Find("btn_ShowCurQueue").gameObject:GetComponent(typeof(Button))

		self.ClearDynamicResource = self.gameObject.transform:Find("btn_clearDynamicResource").gameObject:GetComponent(typeof(Button))
		self.btnCrashlyticsTester = self.gameObject.transform:Find("btnCrashlyticsTester").gameObject:GetComponent(typeof(Button))
		self.btnRestart = find_component(self.gameObject, 'btnRestart', Button)

		self.btn_orderTask = find_component(self.gameObject, 'btn_orderTask', Button)
		self.btn_CollectionItem = find_component(self.gameObject, 'btn_CollectionItem', Button)
		self.btn_TimeOrder = find_component(self.gameObject, 'btn_TimeOrder', Button)
		self.btn_NoDrama = find_component(self.gameObject, 'btn_NoDrama', Button)
		self.label_NoDrama = find_component(self.gameObject, 'btn_NoDrama/Text', Text)
		self.Dropdown_Map = find_component(self.gameObject, 'Dropdown_Map', CS.UnityEngine.UI.Dropdown)
		self.Dropdown_Task = find_component(self.gameObject, 'Dropdown_Task', CS.UnityEngine.UI.Dropdown)
		self.go_mission = self.gameObject:FindGameObject("go_mission")
		self.go_autodigdis = self.gameObject:FindGameObject("go_autodigdis")
		self.btn_mission = self.gameObject.transform:Find("btn_mission").gameObject:GetComponent(typeof(Button))
		self.label_taskName = find_component(self.gameObject, 'label_taskName', Text)
		self.btn_unlockmap = find_component(self.gameObject, 'btn_unlockmap', Button)
		self.btn_autodig = find_component(self.gameObject, 'btn_autodig', Button)
		self.btn_lab = find_component(self.gameObject, 'btn_lab')
		self.btn_goldpanning = find_component(self.gameObject, 'btn_goldpanning')
	--insertInitComp
	--insertOnClick

		self.onClick_btn_level = function()
			sendNotification(DebugPanelNotificationEnum.Click_btn_level)
		end

		local function OnClick_btn_level(go)
			if(self.onClick_btn_level ~=  nil) then
				self.onClick_btn_level()
			end
		end

		self.onClick_btn_mission = function()
			sendNotification(DebugPanelNotificationEnum.Click_btn_mission)
		end

		local function OnClick_btn_mission(go)
			if(self.onClick_btn_mission ~=  nil) then
				self.onClick_btn_mission()
			end
		end

		self.onClick_btn_close = function()
			sendNotification(DebugPanelNotificationEnum.Click_btn_close)
		end

		local function OnClick_btn_close(go)
			if(self.onClick_btn_close ~=  nil) then
				self.onClick_btn_close()
			end
		end

		self.onClick_btn_gc = function()
			sendNotification(DebugPanelNotificationEnum.Click_btn_gc)
		end

		local function OnClick_btn_gc(go)
			if(self.onClick_btn_gc ~=  nil) then
				self.onClick_btn_gc()
			end
		end

		local function OnClick_btn_TestAds(go)
			if(self.onClick_btn_gc ~=  nil) then
				AppServices.AdsManager:ShowTestView()
			end
		end

		local function OnClick_btn_ShowCurQueue(go)
			if(self.onClick_btn_gc ~=  nil) then
				QueueLineManage.Instance():ShowLog()
			end
		end

		self.onClick_ClearDynamicResource = function()
			sendNotification(DebugPanelNotificationEnum.Click_ClearDynamicResource)
		end

		local function OnClick_ClearDynamicResource(go)
			if(self.onClick_ClearDynamicResource ~=  nil) then
				self.onClick_ClearDynamicResource()
			end
		end

		self.onClick_btnCrashlyticsTester = function()
			sendNotification(DebugPanelNotificationEnum.Click_btnCrashlyticsTester)
		end

		local function OnClick_btnCrashlyticsTester(go)
			if(self.onClick_btnCrashlyticsTester ~=  nil) then
				self.onClick_btnCrashlyticsTester()
			end
		end

		local function OnClick_btn_orderTask()
			sendNotification(DebugPanelNotificationEnum.Click_btn_orderTask)
		end
		local function OnClick_btn_CollectionItem()
			sendNotification(DebugPanelNotificationEnum.Click_btn_CollectionItem)
		end
		local function OnClick_btn_unlockmap()
			sendNotification(DebugPanelNotificationEnum.Click_btn_unlockallmap)
		end
		local function OnClick_btn_autodig()
			sendNotification(DebugPanelNotificationEnum.Click_btn_autodig)
		end
		local function OnClick_btn_goldpanning()
			AppServices.Jump.changeSceneById(
				"30001",
				function()
					console.hjs("change to goldpanning scene!")
				end
			)
		end

	--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_level.gameObject, OnClick_btn_level)
		Util.UGUI_AddButtonListener(self.btn_mission.gameObject, OnClick_btn_mission)
		Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
		Util.UGUI_AddButtonListener(self.btn_gc.gameObject, OnClick_btn_gc)
		Util.UGUI_AddButtonListener(self.btn_TestAds.gameObject, OnClick_btn_TestAds)
		Util.UGUI_AddButtonListener(self.btn_ShowCurQueue.gameObject, OnClick_btn_ShowCurQueue)
		Util.UGUI_AddButtonListener(self.ClearDynamicResource.gameObject, OnClick_ClearDynamicResource)
		Util.UGUI_AddButtonListener(self.btnCrashlyticsTester.gameObject, OnClick_btnCrashlyticsTester)
		Util.UGUI_AddButtonListener(self.btnRestart, function()
			sendNotification(DebugPanelNotificationEnum.Click_btnRestart)
		end)
		Util.UGUI_AddButtonListener(self.btn_orderTask, OnClick_btn_orderTask)
		Util.UGUI_AddButtonListener(self.btn_CollectionItem, OnClick_btn_CollectionItem)
		Util.UGUI_AddButtonListener(self.btn_TimeOrder, function()
			sendNotification(DebugPanelNotificationEnum.Click_btn_TimeOrder)
		end)
		Util.UGUI_AddButtonListener(self.btn_NoDrama, function()
			sendNotification(DebugPanelNotificationEnum.Click_btn_NoDrama)
		end)
		Util.UGUI_AddButtonListener(self.btn_unlockmap.gameObject, OnClick_btn_unlockmap)
		Util.UGUI_AddButtonListener(self.btn_autodig.gameObject, OnClick_btn_autodig)
		Util.UGUI_AddButtonListener(self.btn_goldpanning, OnClick_btn_goldpanning)

		Util.UGUI_AddButtonListener(self.btn_lab, function ()
			PanelManager.closePanel(GlobalPanelEnum.DebugPanel)
			PanelManager.showPanel(GlobalPanelEnum.LabMainPanel)
		end)
	end

end

--insertSetTxt

return _DebugPanelBase
