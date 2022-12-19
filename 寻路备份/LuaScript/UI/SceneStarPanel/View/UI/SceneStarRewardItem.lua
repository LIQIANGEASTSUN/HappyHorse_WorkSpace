---
--- Created by Betta.
--- DateTime: 2022/1/17 16:53
---
---@class SceneStarRewardItem
local SceneStarRewardItem = class(nil, "SceneStarRewardItem")

function SceneStarRewardItem:ctor(go, data, isGet)
    self:InitView(go)
    self.img_icon.sprite = AppServices.ItemIcons:GetSprite(data.ItemId)
    self.text_count.text = data.Amount
    self.go_done:SetActive(isGet)
end

function SceneStarRewardItem:InitView(go)
    self.img_icon = go.transform:Find("img_icon"):GetComponent(typeof(Image))
    self.text_count = go.transform:Find("text_count"):GetComponent(typeof(Text))
    self.go_done = go.transform:Find("go_done").gameObject
end

function SceneStarRewardItem:SetGetReward()
    self.go_done:SetActive(true)
end

return SceneStarRewardItem
