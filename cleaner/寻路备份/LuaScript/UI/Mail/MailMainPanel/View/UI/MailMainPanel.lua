local MailItem = require "UI.Mail.MailMainPanel.View.UI.MailItem"
local _MailMainPanelBase = require "UI.Mail.MailMainPanel.View.UI.Base._MailMainPanelBase"
---@class MailMainPanel:_MailMainPanelBase
local MailMainPanel = class(_MailMainPanelBase)

function MailMainPanel:ctor()
    ---@type MailItem[]
    self.mailItems = {}
end

function MailMainPanel:onAfterBindView()
    --todo: 或者在获取到数据 的时候刷新？
    --self:refreshUI()
    self.itemTemplate = find_component(self.gameObject, "mail_list_item")
end

function MailMainPanel:refreshUI()
    self:FillBaseInfo()
    self:FillMainList()
end

function MailMainPanel:FillBaseInfo()
    self.txt_title.text = Runtime.Translate("ui_mail_title")
    self.txt_btn_remove_all.text = Runtime.Translate("ui_mail_remove_all")
    self.txt_btn_fetch_all.text = Runtime.Translate("ui_mail_fetch_all")

    self.txt_noMail.text = Runtime.Translate("ui_mail_no_message")
end

function MailMainPanel:RefreshButtons()
    local mailList = AppServices.MailManager:GetMailList()
    local hasGift = false
    local hasData = false
    for key, value in pairs(mailList) do
        hasData = true
        if value.hasGift then
            hasGift = true
            break
        end
    end

    self.btn_fetch_all:SetActive(hasGift)
    self.btn_remove_all:SetActive(hasData)
end

function MailMainPanel:FillMainList()
    if Runtime.CSValid(self.scroll_list) then
        self.scroll_list:Destroy()
    end
    local mailList = AppServices.MailManager:GetMailList()
    ----------判断服务器是否发过fb绑定的奖励--------------------------------------------
    if mailList.title then
        local isBindReward = AppServices.MailManager:ConstainsFBBindReward(mailList.title)
        if isBindReward then
            --AppServices.FacebookAccountData:SetFacebookBindStatus(true)
            sendNotification(MainCityNotificationEnum.RefreshRedDot, "SettingButton")
        end
    end
    ------------------------------------
    local data = {}
    for key, value in pairs(mailList) do
        table.insert(data, value)
    end

    self:RefreshButtons()

    --sort mail
    --只按接收到的时间排序
    table.sort(
        data,
        function(a, b)
            --按阅读状态排序
            --if a.beRead and not b.beRead then
            --    return 1
            --elseif not a.beRead and b.beRead then
            --    return -1
            --else
            if a.startTime == b.startTime then
                return a.id > b.id
            else
                return a.startTime > b.startTime
            end
            --end
        end
    )

    local onCreateItemCallback = function(key)
        local item = MailItem.new(self.itemTemplate)
        self.mailItems[key] = item
        return item.gameObject
    end

    local onUpdateInfoCallback = function(key, index)
        ---@type MailItem
        local item = self.mailItems[key]
        item:SetData(data[index])
    end

    if Runtime.CSValid(self.scroll_list) then
        self.mailItems = {}
        self.scroll_list:InitList(#data, onCreateItemCallback, onUpdateInfoCallback)
    end

    if Runtime.CSValid(self.txt_noMail) then
        self.txt_noMail.gameObject:SetActive(#data <= 0)
    end
end

--做局部刷新，不重新填充面板
function MailMainPanel:RefillMainList()
    local mailList = AppServices.MailManager:GetMailList()
    local t_remove = {}
    ---@param v MailItem
    for i, v in pairs(self.mailItems) do
        ---强行弹公告的时候，可能会data为nil，因为这个时候这个公告在MailList面板中还没创建出来
        if v.data then
            local data = mailList[v.data.id]
            if data then
                v:SetData(data)
            else
                table.insert(t_remove, i)
            end
        end
    end

    self:RefreshButtons()
    --这里原始代码有问题  i是什么? 居然没发现bug 先注释
    -- for key, value in pairs(t_remove) do
    --     self.scroll_list:RemoveItem(i)
    -- end
end

function MailMainPanel:RefillSingleMail(id)
    local data = AppServices.MailManager:GetData(id)
    if not data then
        self:RemoveSingleMail(id)
        return
    end
    ---@param v  MailItem
    for i, v in pairs(self.mailItems) do
        if Runtime.CSValid(v.gameObject) and v.data and v.data.id == id then
            v:SetData(data)
            break
        end
    end

    self:RefreshButtons()
end

function MailMainPanel:RemoveSingleMail(id)
    local result = {}
    for i, v in pairs(self.mailItems) do
        if v.data and v.data.id == id then
            result = i
            self.mailItems[i] = nil
            break
        end
    end

    self.scroll_list:RemoveItem(result)
end

function MailMainPanel:FlyRewards(rewards)
    -- for key, value in pairs(self.mailItems) do
    --     value:FlyRewards()
    -- end

    local flyRewards = {}
    for index, value in ipairs(rewards) do
        table.insert(flyRewards, {ItemId = value.itemTemplateId, Amount = value.count})
    end
    local time = 0.5
    AppServices.RewardAnimation.FlyReward(
        flyRewards,
        self.gameObject.transform.position,
        0,
        0,
        time,
        false,
        1,
        Ease.InCirc
    )
end

return MailMainPanel
