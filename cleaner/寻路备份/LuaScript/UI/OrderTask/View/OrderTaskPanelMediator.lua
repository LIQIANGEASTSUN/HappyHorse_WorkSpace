require "UI.OrderTask.OrderTaskPanelNotificationEnum"
local OrderTaskPanelProxy = require "UI.OrderTask.Model.OrderTaskPanelProxy"
---@class OrderTaskPanelMediator
local OrderTaskPanelMediator = MVCClass('OrderTaskPanelMediator', BaseMediator)

---@type OrderTaskPanel
local panel
local proxy

function OrderTaskPanelMediator:ctor(...)
	OrderTaskPanelMediator.super.ctor(self,...)
	proxy = OrderTaskPanelProxy.new()
end

function OrderTaskPanelMediator:onRegister()
end

function OrderTaskPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function OrderTaskPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        OrderTaskPanelNotificationEnum.Click_btn_close,
        OrderTaskPanelNotificationEnum.Select_Order,
        OrderTaskPanelNotificationEnum.Submit_Order,
        OrderTaskPanelNotificationEnum.Delete_Order,
        CONST.GLOBAL_NOFITY.Order_On_Order_Refresh,
        CONST.GLOBAL_NOFITY.Order_On_Order_Submit,
        CONST.GLOBAL_NOFITY.Order_On_Order_SubmitFinish,
		CONST.GLOBAL_NOFITY.Order_On_Order_RefreshProgressRewardCd,
		OrderTaskPanelNotificationEnum.ClearCD,
        OrderTaskPanelNotificationEnum.Click_orderTaskProgress,
		OrderTaskPanelNotificationEnum.Click_Ads,
	}
end

function OrderTaskPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType()
	local body = notification:getBody() --message data
	--insertHandleNotificationNames
	local mgr = AppServices.OrderTask
    if(name == "") then
    elseif(name == OrderTaskPanelNotificationEnum.Click_orderTaskProgress) then ---显示预览奖励
		local index = body.index
		local isDone = mgr:IsProgressRewardDone(index)
		if not isDone then
			panel:ShowItemTips(index)
		end
    elseif(name == OrderTaskPanelNotificationEnum.ClearCD) then ---清理CD
		AppServices.DiamondConfirmUIManager:Click(panel.btn_clearCD.gameObject, function()
			AppServices.OrderTask:ClearCD(body.position)
		end)
    elseif(name == OrderTaskPanelNotificationEnum.Order_CdOver) then
		-- AppServices.OrderTask:OnCdOver(body.position)
    elseif(name == CONST.GLOBAL_NOFITY.Order_On_Order_Refresh) then
		local orderTask, orderTaskReward = AppServices.OrderTask:GetShowOrderInfos()
		--暂时不用sel了 原来在那个订单位置就还刷新哪个订单位置
		local showSel = body.selectPosition
		panel:refreshUI(orderTask, orderTaskReward, showSel)
		if body and body.shakePosition then
			panel:TriggerOrderSpine(body.shakePosition, body.oldOrderType, body.newOrderType)
		end
    elseif(name == OrderTaskPanelNotificationEnum.Delete_Order) then
		AppServices.OrderTask:DelOrderTaskRequest(body.position)
    elseif(name == OrderTaskPanelNotificationEnum.Submit_Order) then
		local mgr = AppServices.OrderTask
		if mgr:IsInSubmitCD(body.position) then
			mgr.SubmitCDNotice()
		else
			local vec = panel:GetOrderWorldPos(body.position)
			panel:SetClickBlock('submit')
			if Runtime.CSValid(panel.btn_submit) then
                panel.btn_submit.interactable = false
            end
			mgr:submitOrder(body.position, vec, panel:GetOrderReward(body.position), panel:GetOrderCenterPos(body.position), function(success)
				if not success and Runtime.CSValid(panel.btn_submit) then
					panel.btn_submit.interactable = true
				end
			end)
		end
    elseif(name == CONST.GLOBAL_NOFITY.Order_On_Order_SubmitFinish) then
		panel:RemoveClickBlock()
	elseif name == CONST.GLOBAL_NOFITY.Order_On_Order_RefreshProgressRewardCd then
		panel:RefreshPorgressCD()
    elseif(name == CONST.GLOBAL_NOFITY.Order_On_Order_Submit) then
		panel:ActiveSubmitCd()
    elseif(name == OrderTaskPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(panel.panelVO)
		--App.mapGuideManager:OnGuideFinishEvent(GuideEvent.CustomEvent,"GuideEnergy")
	elseif (name == OrderTaskPanelNotificationEnum.Click_Ads) then
		DcDelegates.Ads:LogEntryClick(AdsTypes.AdsOrder)
		if Runtime.CSValid(panel.btn_ads) then
			panel.btn_ads.interactable = false
		end
		local temp = AppServices.OrderTask:CalOrderRewardAds()
		local reward = {}
		for i, v in ipairs(temp) do
			reward[i] = {itemId = v.itemTemplateId, num = v.count}
		end
		AppServices.AdsManager:PlayAds(AdsTypes.AdsOrder, reward, function(success)
			if success then
				local vec = panel:GetOrderWorldPos(body.position)
				panel:SetClickBlock('ads')

				mgr:submitOrder(body.position, vec, panel:GetOrderReward(body.position), panel:GetOrderCenterPos(body.position), function()
					if Runtime.CSValid(panel.btn_ads) then
						panel.btn_ads.interactable = true
					end
				end)
			else
				if Runtime.CSValid(panel.btn_ads) then
					panel.btn_ads.interactable = true
				end
			end
		end)
    else
    end
end

function OrderTaskPanelMediator:onBeforeLoadAssets()
 -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
	-- Send Request To Server
	local extraAssetsNeedLoad = {}
	table.insert(extraAssetsNeedLoad, "Prefab/UI/OrderTask/spine/OrderTaskItem.prefab")
	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
end

-- function OrderTaskPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function OrderTaskPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function OrderTaskPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function OrderTaskPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function OrderTaskPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function OrderTaskPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function OrderTaskPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function OrderTaskPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function OrderTaskPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function OrderTaskPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return OrderTaskPanelMediator
