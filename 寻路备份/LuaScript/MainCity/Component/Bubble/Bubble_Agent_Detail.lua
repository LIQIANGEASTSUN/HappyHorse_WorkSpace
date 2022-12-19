require("MainCity.Component.Bubble.Bubble_base")
---@class Bubble_Agent_Detail
local Bubble_Agent_Detail = class(Bubble_Interface, "Bubble_Agent_Detail")

function Bubble_Agent_Detail:ctor()
    self.type = BubbleType.Agent_Detail
    self.canClick = false
    self.needCache = true
    self.infoLis = {}
end

function Bubble_Agent_Detail:BindView(go)
    go = find_component(go, "bg")
    self.bgTrans = go.transform
    self.imgBg = find_component(go, "imgBg")
    self.txtInfo = find_component(go, "imgBg/txt_Info", Text)
    self.txtName = find_component(go, "imgBg/txt_Name", Text)
    self.iconGo = find_component(go, "icon")
    self.infoItemWidth = self.iconGo.transform.rect.width
end

function Bubble_Agent_Detail:InitData(param)
    if not param.agentId then
        return
    end
    local agt = App.scene.objectManager:GetAgent(param.agentId)
    self:SetDetailInfo(agt:GetTemplateId(), agt:GetCleanCosted())
    local pos = agt:GetAnchorPosition()
    if not pos then
        pos = agt:GetWorldPosition()
    end
    self:SetPosition(pos)
end

function Bubble_Agent_Detail:SetDetailInfo(templateId, costed)
    local count = 0
    local cof = AppServices.Meta:GetBindingMeta(templateId)
    if cof then
        local parent = self.bgTrans
        local infoRewards = cof.rewardItem
        for k, v in ipairs(infoRewards) do
            local infoItm = self.infoLis[k]
            if not infoItm then
                infoItm = self:GetInfoItem(parent)
                self.infoLis[k] = infoItm
            end
            local sprite = AppServices.ItemIcons:GetSprite(v[1])
            infoItm.img.sprite = sprite
            local ratio = sprite.rect.width / sprite.rect.height
            infoItm.transform.sizeDelta = Vector2(ratio * 66, 66)
            infoItm.transform:SetParent(parent,false)
            count = count + 1
        end
        self.txtName.text = Runtime.Translate(cof.name)
        costed = costed or 0
        if #cof.consume > 0 then
            self.txtInfo.text = string.format("%s%d", Runtime.Translate("ui_exploit_tip_text"), cof.consume[2] - costed)
        end
    end
    if count > 0 then
        local offset = 10
        self:ResizeBubbleBgWidth(count, offset)
        local start = -(count - 1) * (offset + self.infoItemWidth) / 2
        for i = 1, #self.infoLis do
            local go = self.infoLis[i].gameObject
            if i > count then
                if go.activeSelf then
                    go:SetActive(false)
                end
            else
                if not go.activeSelf then
                    go:SetActive(true)
                end
                local rectTrans = self.infoLis[i].transform
                local width = rectTrans.rect.width
                local x = start + (width + offset) * (i - 1)
                rectTrans.anchoredPosition = Vector2(x, 84)
            end
        end
    end
end

function Bubble_Agent_Detail:ResizeBubbleBgWidth(count, offset)
    local btRect = self.imgBg.transform
    local width = (offset + self.infoItemWidth) * count + offset
    width = math.max(width, 184.7)
    local size = btRect.sizeDelta
    size.x = width
    btRect.sizeDelta = size
end

function Bubble_Agent_Detail:GetInfoItem()
    local go = BResource.InstantiateFromGO(self.iconGo)
    go.transform:SetParent(self.iconGo.transform.parent,false)
    local infoItm = {
        img = find_component(go, "", Image),
        txt = find_component(go, "num", Text),
        transform = go.transform,
        gameObject = go
    }
    return infoItm
end

return Bubble_Agent_Detail
