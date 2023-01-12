local Mail = require "Game.System.Mail.Mail"
---@class MailManager
local MailManager = {}

function MailManager:Init()
    if self.inited then
        return
    end
    self.inited = true
    ---@type Mail[] Dictionary<id,Mail>
    self.mails = {}

    -- file at http://10.0.102.202:9010/share/zOSHp9tw
    --local Config = require "Game.System.Mail.MailConfigTemplate"
    --self:InitMailList(Config)

    self.queue = PopupQueue:Create()
    -- self.rewardQueue = PopupQueue:Create()

    --过期邮件数据
    if App.response and App.response.expireMailRewards then
        self.outofDateRewards = self:DecodeItemMsg(App.response.expireMailRewards or {})
    end
end

---@return Mail[]
function MailManager:GetMailList()
    return self.mails
end

function MailManager:InitMailList(mailList)
    mailList = self:DecodeMailMsg(mailList)
    self.mails = {}
    for i, v in pairs(mailList) do
        ---@type Mail
        local mail = Mail.new(v)
        self.mails[mail.id] = mail
    end

    self:RefreshUI()
end

function MailManager:RefreshUI()
    local scene = App.scene
    if not scene then
        return
    end

    local widget = scene:GetWidget(CONST.MAINUI.ICONS.MailButton)
    if widget then
        widget:RefreshRedDot()
    end
end

function MailManager:UpdateMailList(mailList)
    mailList = self:DecodeMailMsg(mailList)

    --find removed mails
    local t_remove = {}
    for i, v in pairs(self.mails) do
        if
            not table.existsIf(
                mailList,
                function(a)
                    return a.id == v.id
                end
            )
         then
            table.insert(t_remove, i)
        end
    end

    for i = 1, #t_remove do
        self.mails[t_remove[i]] = nil
    end

    --find new mails
    for i, v in pairs(mailList) do
        local find = false
        for key, value in pairs(self.mails) do
            if value.id == v.id then
                value:CopyFrom(v)
                find = true
                break
            end
        end

        if not find then
            local mail = Mail.new(v)
            self.mails[v.id] = mail
        end
    end
    self:RefreshUI()
end

-- function MailManager:GetMailAttachmentString(mail)
--     local attachment = ''
--     if #mail.rewards > 0 then
--         attachment = v.ItemId..'|'..v.Amount
--     end
--     for i = 2, #mail.rewards do
--         attachment = attachment ..','.. v.ItemId..'|'..v.Amount
--     end
--     return attachment
-- end

function MailManager:GetData(id)
    return self.mails[id]
end

function MailManager:UpdateReadState(id)
    ---@type Mail
    local mail = self.mails[id]
    if mail then
        mail:SetReadState(true)
    end
end

--region 即将要删除的邮件，为什么不能直接删除呢？跟用的ScrollListRender组件有关系
function MailManager:RemoveSingleMail(id)
    self:MarkToBeDelete(id)
    sendNotification(MailMainPanelNotificationEnum.RemoveSingleMail, id)
end

---标记需要清理的过期邮件数据
function MailManager:MarkToBeDelete(id)
    self.toBeDelete = self.toBeDelete or {}
    table.insert(self.toBeDelete, id)
end

---执行清理过期邮件
function MailManager:ExecuteDeleteData()
    self.toBeDelete = self.toBeDelete or {}
    for i, v in pairs(self.toBeDelete) do
        self.mails[v] = nil
    end
end
function MailManager:IsToBeDelete(id)
    self.toBeDelete = self.toBeDelete or {}
    return table.exists(self.toBeDelete, id)
end
--endregion

function MailManager:RemoveAllReadMail()
    --------------------------------------
    local doDelete = function()
        local ids = {}
        for i, v in pairs(self.mails) do
            if v.beRead then
                table.insert(ids, v.id)
            end
        end

        if #ids <= 0 then
            return
        end
        self:RequestDeleteMail(
            ids,
            function()
                sendNotification(MailMainPanelNotificationEnum.ResetMailList, ids)
            end
        )
    end
    -----------------------------------------------------
    local rewardedIds = {}
    for i, v in pairs(self.mails) do
        if v.hasGift and v.beRead then
            table.insert(rewardedIds, v.id)
        end
    end
    if #rewardedIds > 0 then
        self:FetchAllMailAttachments(
            rewardedIds,
            function()
                doDelete()
            end
        )
    else
        doDelete()
    end
end

function MailManager:FetchAllMailAttachments(ids, callback)
    --ids为nil，就是要获取所有有奖励的邮件的奖励
    if not ids then
        ids = {}
        for i, v in pairs(self.mails) do
            if v.hasGift and not v:OutOfTime() then
                table.insert(ids, v.id)
            end
        end
    end

    if #ids <= 0 then
        Runtime.InvokeCbk(callback, false)
        return
    end

    --请求成功的回调
    local success = function(rewards)
        if rewards and #rewards > 0 then
            Runtime.InvokeCbk(callback, true, rewards)
        else
            --如果没有奖励直接回调
            Runtime.InvokeCbk(callback, true)
        end
        for i, v in pairs(ids) do
            self:RequestReadMail(v)
        end
    end

    if not Runtime.GetNetworkState() then
        ErrorHandler.ShowErrorMessage(
            Runtime.Translate("ui_mail_error_network"),
            function()
                Runtime.InvokeCbk(callback, false)
            end
        )
    else
        -- success({{itemTemplateId = "1001", count = 10}})
        self:RequestRewardMail(
            ids,
            success,
            function()
                Runtime.InvokeCbk(callback, false)
            end
        )
    end
end

--- 过期奖励强弹
function MailManager:CheckPopExpireMailReward()
    if RuntimeContext.DISABLE_MAIL_SYSTEM then  --如果被禁用，直接出队列
        return false
    end

    return self.outofDateRewards and #self.outofDateRewards > 0
end

function MailManager:DoPopExpireMailReward(callback)
    for index, value in ipairs(self.outofDateRewards) do
        if value.itemTemplateId ~= ItemId.ENERGY then
            AppServices.User:AddItem(value.itemTemplateId, value.count, ItemGetMethod.rewardMail)
        end
    end
    PanelManager.showPanel(
        GlobalPanelEnum.MailCollectPanel,
        {rewards = self.outofDateRewards},
        PanelCallbacks:Create(
            function()
                self.outofDateRewards = {}
                Runtime.InvokeCbk(callback)
            end
        )
    )
end
--- 检测公告的强制弹出
function MailManager:CheckForcePop(callback)
        local pcb =
            PanelCallbacks:Create(
            function()
                self.needPopList = {}
                Runtime.InvokeCbk(callback)
            end
        )
        pcb:onAfterShowPanel(
            function ()
                local function finishNode()
                    QueueLineManage.Instance():FinishNode()
                end

                local function ShowDetailMail(v)
                    local function mailDetailNode()
                        self:RequestReadMail(
                            v.id,
                            function()
                                sendNotification(MailMainPanelNotificationEnum.RefillMailList)
                            end
                        )
                        PanelManager.showPanel(
                            GlobalPanelEnum.MailDetailPanel,
                            {data = v},
                            PanelCallbacks:Create(finishNode)
                        )
                    end

                    QueueLineManage.Instance():CreateNode("mailDetailNode", mailDetailNode)
                end

                QueueLineManage.Instance():Start(
                    "PopMailDetailPanel",
                    function()
                        for _, v in ipairs(self.needPopList) do
                            ShowDetailMail(v)
                        end
                        finishNode()
                    end,
                    function()
                        finishNode()
                    end
                )
            end
        )
        PanelManager.showPanel(GlobalPanelEnum.MailMainPanel, nil, pcb)
end

function MailManager:CheckPop()
    if RuntimeContext.DISABLE_MAIL_SYSTEM then  --如果被禁用，直接出队列
        return false
    end

    --??为啥队列里会播放剧情
    if App.screenPlayActive then
        return false
    end

    self.needPopList = {}
    ---@param v Mail
    for i, v in pairs(self.mails) do
        --邮件类型 0：指定玩家 1：全服邮件 2：公告
        if v.type == 2 and not v.beRead then
            table.insert(self.needPopList, v)
            --应该放到弹窗前
            self:UpdateReadState({v.id})
        end
    end
    if #self.needPopList > 0 then
        return true
    end

    return false
end


function MailManager:NeedShowRedDot()
    for i, v in pairs(self.mails) do
        if not v.beRead then
            return true
        end
        if v.hasGift then
            return true
        end
    end
    return false
end
--[[
function MailManager:ReceiveOutOfDateMailAttachments(rewards)
    rewards = self:DecodeItemMsg(rewards)
    self.outofDateRewards = rewards
end
]]
--region messages

function MailManager:RequestMailList(finishCallback)
    local onFail = function(errorCode)
        --Runtime.InvokeCbk(fail)
        --ErrorHandler.ShowErrorMessage(errorCode)
        Runtime.InvokeCbk(finishCallback)
    end

    local onSuccess = function(msg)
        self:InitMailList(msg)
        Runtime.InvokeCbk(finishCallback)
    end
    Net.Mailmodulemsg_16001_MailList_Request({}, onFail, onSuccess, nil, false)
end

--[[
function MailManager:RequestMailList(success, fail)
    local onFail = function(errorCode)
        Runtime.InvokeCbk(fail)
        --ErrorHandler.ShowErrorMessage(errorCode)
    end

    local onSuccess = function(msg)
        self:InitMailList(msg)
        Runtime.InvokeCbk(success)
    end
    Net.Mailmodulemsg_16001_MailList_Request({}, onFail, onSuccess, nil, false)
end
]]
function MailManager:RequestDeleteMail(ids, _success, _fail)
    local fail = function(errorCode)
        Runtime.InvokeCbk(_fail)
    end
    local success = function(msg)
        self:InitMailList(msg)
        Runtime.InvokeCbk(_success)
    end

    if Runtime.GetNetworkState() then
        Net.Mailmodulemsg_16002_DeleteMail_Request({ids = ids}, fail, success)
    else
        ErrorHandler.ShowErrorMessage(
            Runtime.Translate("ui_mail_error_network"),
            function()
                Runtime.InvokeCbk(_fail, false)
            end
        )
    end
end

function MailManager:RequestRewardMail(ids, _success, _fail)
    local fail = function(errorCode)
        Runtime.InvokeCbk(_fail)
    end
    local success = function(msg)
        self:UpdateMailList(msg)
        sendNotification(MailMainPanelNotificationEnum.RefillSingleMail, ids)
        local rewards = self:DecodeItemMsg(msg.items)
        for index, value in ipairs(rewards) do
            local itemId = value.itemTemplateId
            local count = value.count
            if ItemId.IsDragon(itemId) then
                ConnectionManager:block()
                for _ = 1, count do
                    AppServices.MagicalCreatures:AddDragonByItem(itemId)
                end
                ConnectionManager:flush(false)
            else
                AppServices.User:AddItem(itemId, count, ItemGetMethod.rewardMail)
            end
        end
        Runtime.InvokeCbk(_success, rewards)
    end
    if Runtime.GetNetworkState() then
        Net.Mailmodulemsg_16003_RewardMail_Request({ids = ids}, fail, success)
    else
        ErrorHandler.ShowErrorMessage(
            Runtime.Translate("ui_mail_error_network"),
            function()
                Runtime.InvokeCbk(_fail, false)
            end
        )
    end
end

function MailManager:RequestReadMail(id, success, fail)
    local onFail = function(errorCode)
        Runtime.InvokeCbk(fail)
    end
    local onSuccess = function(msg)
        self:UpdateMailList(msg)
        self:UpdateReadState(id)
        sendNotification(MailMainPanelNotificationEnum.RefillSingleMail, {id})
        Runtime.InvokeCbk(success)
    end
    Net.Mailmodulemsg_16004_ReadMail_Request({id = id}, onFail, onSuccess)
end

function MailManager:DecodeMailMsg(msg)
    if msg then
        local item = {}
        for i, v in ipairs(msg.mailList) do
            local data = {}
            data.id = v.id
            data.type = v.type
            data.startTime = v.startTime
            data.endTime = v.endTime
            data.label = v.label
            data.content = v.content
            data.picture = v.picture
            data.read = v.read
            data.reward = v.reawrd

            data.attachment = self:DecodeItemMsg(v.attachment)

            table.insert(item, data)
        end
        return item
    end
end

function MailManager:DecodeItemMsg(msg)
    local data = {}
    if msg then
        for i, v in ipairs(msg) do
            local item = {}
            item.itemTemplateId = v.itemTemplateId
            item.count = v.count
            item.cdTimes = v.cdTimes
            table.insert(data, item)
        end
    end
    return data
end

function MailManager:Localize(jsonInfo)
    local info = table.deserialize(jsonInfo)
    if type(info) ~= "table" or info == nil or info.localize == nil or info.content == nil then
        return jsonInfo
    end
    local str,strProduct
    if info.localize then
        if info.productID then
            local config = AppServices.ProductManager:GetProductMeta(info.productID)
            strProduct = Runtime.Translate( config.remarks)
            str = Runtime.Translate(info.content, {name = strProduct})
        else
            str = Runtime.Translate(info.content, info.values)
        end
    else
        str = info.content
    end
    return str
end

-- 用来判断服务器是否发过绑定facebook的奖励
function MailManager:ConstainsFBBindReward(jsonInfo)
    local info = table.deserialize(jsonInfo)
    if info.content then
        if info.contnet == "mailbox_fb_bindreward_title" then
            return true
        end
    else
        return false
    end
end
--endregion

MailManager:Init()
return MailManager
