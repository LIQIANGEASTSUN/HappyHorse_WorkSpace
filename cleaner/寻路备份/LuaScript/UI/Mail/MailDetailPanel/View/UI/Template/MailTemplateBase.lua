---@class MailTemplateBase
local MailTemplateBase = class(nil, "MailTemplateBase")
local mailStatus = {
    Null = 0,
    --普通文本
    Common = 1,
    --包含奖励
    Reward = 2,
    --礼包跳转
    ProductJump = 3,
    --礼包不跳转
    ProductReward = 4
}
function MailTemplateBase:InitComponent(gameObject)
    self.gameObject = gameObject
    if Runtime.CSValid(self.gameObject) then
        self.txt_title = find_component(self.gameObject, "txt_title", Text)
        self.txt_reward = find_component(self.gameObject, "txt_reward", Text)
        -- self.tran_reward_list = find_component(self.gameObject, "reward_list", Transform)
        self.tran_reward_list = find_component(self.gameObject, "itemRoot/Viewport/Content", Transform)
        self.txt_content = find_component(self.gameObject, "Scroll View/Viewport/Content/Text", Text)

        self.btn_ok = find_component(self.gameObject, "btn_ok", Button)
        self.txt_btn_ok = find_component(self.btn_ok, "BText", Text)

        self.tran_reward_item = find_component(self.gameObject, "../reward_item", Transform)
        --self:AfterInitComponent()
    end

    --self:Translate()
end


function MailTemplateBase:BindEvent()
    if Runtime.CSValid(self.btn_ok) then
        Util.UGUI_AddButtonListener(
            self.btn_ok,
            function()
                sendNotification(MailDetailPanelNotificationEnum.OnOkButtonClick, {data = self.data,mailStatus = self.mailStatus})
            end
        )
    end
    --[[
    self.txt_content.transform:GetComponent(typeof(CS.EmojiText)).onHrefClick = function (url)
        -- console.assert(string.isEmpty(url), 'url is invalid ,mail info : '..table.tostring(data))
        GameUtil.OpenUrl(url)
    end
    --]]
    Util.UGUI_AddButtonListener(
        self.txt_title.gameObject,
        function()
            PanelManager.closePanel(GlobalPanelEnum.MailDetailPanel)
        end
    )
end
---@param data Mail
function MailTemplateBase:SetData(_data)
    self.gameObject:SetActive(true)
    self.data = _data

    local JumpType = {2,7,9,11}
    local function GetStatus(data)
        if table.isEmpty(data) then
            return mailStatus.Null
        end
        if data.hasGift and #data.rewards > 0 then
            return mailStatus.Reward
        end

        local info = table.deserialize(data.content)
        if type(info) == "table" and not table.isEmpty(info) and info.productID then
            data.productID = info.productID
        end

        if data.productID then
            local package = AppServices.ProductManager:GetProductMeta(self.data.productID)
            if table.indexOf(JumpType, package.shopType) then
            --if table.count(package.itemIds) == 0 and package.shopType ~= 13 then
                return mailStatus.ProductJump
            end
            return mailStatus.ProductReward
        end
        return mailStatus.Common
    end
    self.mailStatus = GetStatus(_data)
    self:RefreshUI()
    self:BindEvent()
end

function MailTemplateBase:RefreshUI()
    if self.mailStatus == mailStatus.Null then
        return
    end

    if self.mailStatus == mailStatus.Common then
        self.txt_title.text = AppServices.MailManager:Localize(self.data.title)
        self.txt_content.text = AppServices.MailManager:Localize(self.data.content)
        self.txt_btn_ok.text = Runtime.Translate("ui_mail_detail_IKnow")
        self.txt_reward.gameObject:SetActive(false)
        self.tran_reward_list.gameObject:SetActive(false)
    elseif self.mailStatus == mailStatus.Reward then
        self.txt_title.text = AppServices.MailManager:Localize(self.data.title)
        self.txt_content.text = AppServices.MailManager:Localize(self.data.content)
        self.txt_btn_ok.text = Runtime.Translate("ui_mail_detail_claim")
        self.txt_reward.text = Runtime.Translate("ui_mail_detail_reward")
        self.txt_reward.gameObject:SetActive(true)

        self.rewardGos = {}
        self.tran_reward_list:ClearAllChildren()
        for i, v in ipairs(self.data.rewards) do
            local go = GameObject.Instantiate(self.tran_reward_item.gameObject)
            go.transform:SetParent(self.tran_reward_list, false)

            -- find_component(go,'img_icon',Image).transform.localScale = Vector3.one
            local icon = find_component(go, "img_icon", Image)
            local rawImage = find_component(go, "rawImg_icon", RawImage)
            local itemId = v.ItemId
            if ItemId.IsDragon(itemId) then
                icon:SetActive(false)
                rawImage:SetActive(true)
                local spriteName = AppServices.Meta:GetItemIcon(itemId)
                AppServices.ItemIcons:SetDragonIcon(rawImage, spriteName)
            else
                icon:SetActive(true)
                rawImage:SetActive(false)
                icon.sprite = AppServices.ItemIcons:GetSprite(v.ItemId)
            end
            find_component(go, "txt_num", Text).text = string.format("X%s", v.Amount)
            go:SetActive(true)
            table.insert(self.rewardGos, go)
        end
        self.tran_reward_list.gameObject:SetActive(true)
    elseif self.mailStatus == mailStatus.ProductReward then
        self.txt_title.text = AppServices.MailManager:Localize(self.data.title)
        self.txt_content.text = AppServices.MailManager:Localize(self.data.content)
        self.txt_btn_ok.text = Runtime.Translate("ui_mail_detail_IKnow")
        self.txt_reward.gameObject:SetActive(false)
        self.tran_reward_list.gameObject:SetActive(false)
    elseif self.mailStatus == mailStatus.ProductJump then
        self.txt_title.text = AppServices.MailManager:Localize(self.data.title)
        self.txt_content.text = AppServices.MailManager:Localize(self.data.content)
        self.txt_btn_ok.text = Runtime.Translate("UI_common_go")
        self.txt_reward.gameObject:SetActive(false)
        self.tran_reward_list.gameObject:SetActive(false)
    end

    --[[显示奖励

    if self.data.hasGift then
        self.tran_reward_list:ClearAllChildren()
        for i, v in ipairs(self.data.rewards) do
            local go = GameObject.Instantiate(self.tran_reward_item.gameObject)
            go.transform:SetParent(self.tran_reward_list, false)

            -- find_component(go,'img_icon',Image).transform.localScale = Vector3.one
            local icon = find_component(go, "img_icon", Image)
            icon.sprite = AppServices.ItemIcons:GetSprite(v.ItemId)
            find_component(go, "txt_num", Text).text = string.format("X%s", v.Amount)
            go:SetActive(true)
            table.insert(self.rewardGos, go)
        end
        self.tran_reward_list.gameObject:SetActive(true)
    else
        self.tran_reward_list.gameObject:SetActive(false)
    end]]
end

function MailTemplateBase:FlyRewards(rewards)
    if not rewards then
        return
    end
    local count = #rewards
    if count == 0 then
        return
    end

    local flyRewards = {}
    local haveDragon = false
    for _, value in ipairs(rewards) do
        local itemId = value.itemTemplateId
        if not haveDragon and ItemId.IsDragon(itemId) then
            haveDragon = true
        end
        table.insert(flyRewards, {ItemId = value.itemTemplateId, Amount = value.count})
    end
    if haveDragon then
        local onlyDragon = #flyRewards == 1
        PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = flyRewards, useDragonIcon = not onlyDragon})
        return
    end
    for index = 1, count do
        flyRewards[index].position = self.rewardGos[index].transform.position
    end
    local time = 0.5
    AppServices.RewardAnimation.FlyReward(flyRewards, nil, 0, 0, time, false, 1, Ease.InCirc)
end

function MailTemplateBase:Hide()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(false)
    end
end

function MailTemplateBase:destroy()
    self:Hide()
end
return MailTemplateBase
