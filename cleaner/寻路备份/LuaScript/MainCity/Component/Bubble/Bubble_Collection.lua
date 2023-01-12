require("MainCity.Component.Bubble.Bubble_base")
---@class Bubble_Collection
local Bubble_Collection = class(Bubble_Interface, "Bubble_Collection")

function Bubble_Collection:ctor()
    self.type = BubbleType.Collection
    self.canClick = true
end

function Bubble_Collection:BindView(go)
    local bg = find_component(go, "bg")
    self.btnGo = bg
    self.bgTrans = bg.transform
    self.iconGo = find_component(bg, "icon")
    self.dragonCollect = find_component(bg, "dragonCollect")
end

function Bubble_Collection:InitData(param)
    local agentId = param.agentId
    local data = param.data
    if data then
        local agent = App.scene.objectManager:GetAgent(agentId)
        if not agent then
            return
        end
        local pos = agent:GetAnchorPosition()
        if not pos then
            pos = agent:GetWorldPosition()
        end
        self:SetPosition(pos)
        if data.showId then
            self:SetRewardInfo(data.showId)
            self.clickFun = data.clickFun
            self.dragonCollect:SetActive(false)
            return
        end
        local len = #data
        if len > 0 then
            -- local showId = data[1].itemTemplateId
            local rewardId = agent.data:GetDragonRewardId()
            if rewardId then
                self:SetRewardInfo(tostring(rewardId))
            end
            if self.itmInfo then
                self.itmInfo.gameObject:SetActive(rewardId ~= nil)
            end
            self.dragonCollect:SetActive(not rewardId)

        -- local infos = agent:GetDragonReward()
        -- for i = 1, len do
        --     if infos[data[i].itemTemplateId] then
        --         showId = data[i].itemTemplateId
        --         break
        --     end
        -- end
        -- self:SetRewardInfo(showId)
        end
        self.bubbleAgent = agent
    end
end

function Bubble_Collection:onBubbleClick()
    if self.bubbleAgent then
        self.bubbleAgent:StartCollectHangupReward()
    else
        if self.clickFun then
            Runtime.InvokeCbk(self.clickFun)
        end
    end
end

function Bubble_Collection:SetRewardInfo(id, num)
    if not self.itmInfo then
        self.itmInfo = self:GetInfoItem()
    end
    local spr = AppServices.ItemIcons:GetSprite(id)

    if spr then
        local ratio = spr.rect.width / spr.rect.height
        self.itmInfo.img.sprite = spr
        self.itmInfo.transform.sizeDelta = Vector2(40, 40 / ratio)
    end
    if not num or num <= 0 then
        self.itmInfo.txt.text = ""
    else
        self.itmInfo.txt.text = tostring(num)
    end
    self.itmInfo.gameObject:SetActive(true)
    self.itmInfo.transform:SetParent(self.bgTrans, false)
    self.itmInfo.transform.anchoredPosition = Vector2(0, 52)
end

function Bubble_Collection:GetInfoItem()
    local go = BResource.InstantiateFromGO(self.iconGo)
    local infoItm = {
        img = find_component(go, "", Image),
        txt = find_component(go, "num", Text),
        transform = go.transform,
        gameObject = go
    }
    go.transform:SetParent(self.bgTrans, false)
    return infoItm
end

function Bubble_Collection:ClearState()
    self.clickFun = nil
    self.bubbleAgent = nil
end

function Bubble_Collection:GetGuideObj()
    return self.btnGo
end

function Bubble_Collection:GetShowedBg()
    if self.itmInfo then
        return self.itmInfo.gameObject
    else
        return self.dragonCollect
    end
end
return Bubble_Collection
