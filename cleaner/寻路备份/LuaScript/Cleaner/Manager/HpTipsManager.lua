---@type HpItem
local HpItem = require "UI.HpPanel.HpItem"

-- HpTipsManager
---@type HpTipsManager
local HpTipsManager = class(nil, "HpTipsManager")


--[[
    AppServices.EventDispatcher:addObserver(self, HP_INFO_EVENT.HP_ENABLE, function(eventData)
        self:FightUnit():NotifyHp(0, TipsType.UnitPetHpType1Tips, true)
        AppServices.EventDispatcher:removeObserver(self, HP_INFO_EVENT.HP_ENABLE)
    end)

--]]

local instance
---@return HpTipsManager
function HpTipsManager.Instance()
    if not instance then
        instance = HpTipsManager.new()
    end
    return instance
end

function HpTipsManager.Destroy()
    if not instance then
        return
    end
    instance:OnDestroy()
    instance = nil
end

function HpTipsManager:ctor()
    self:Init()

    self.go = nil
    self.hpMap = {}

end

function HpTipsManager:Init()
    local canvas = App.scene.sceneCanvas
    if Runtime.CSValid(canvas) then
        self:Instantiate(canvas)
    else
        console.error(nil, "No canvas found in scene!!!") --@DEL
    end
end

function HpTipsManager:Instantiate(parent)
    local function onLoaded()
        local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_SPRITE_TIPS)
        if Runtime.CSValid(go) then
            self.go = go
            self.go.transform:SetParent(parent.transform, false)
            self.go.transform:SetLocalScale(1, 1, 1)
            self:LoadFinish()
        end
    end
    App.buildingAssetsManager:LoadAssets({CONST.ASSETS.G_UI_SPRITE_TIPS}, onLoaded)
end

function HpTipsManager:LoadFinish()
    self.waitExtensionId = WaitExtension.InvokeRepeating(function() self:Update() end, 0, 0)

    self.hpParent = self.go.transform:Find("Panel")
    self.parentRect = self.hpParent:GetComponent(typeof(RectTransform))
    self.hpTr = self.go.transform:Find("Panel/Hp")

    --self:RegisetEvent()

    AppServices.EventDispatcher:dispatchEvent(HP_INFO_EVENT.HP_ENABLE)
end

function HpTipsManager:GetHp(instanceId)
    return self.hpMap[instanceId]
end

function HpTipsManager:RemoveHp(instanceId)
    local hpItem = self:GetHp(instanceId)
    if hpItem then
        hpItem:Destroy()
        self.hpMap[instanceId] = nil
    end
end

function HpTipsManager:HpInfo(eventData)
    local data = eventData.data
    local instanceId = data.instanceId

    local hpItem = self:GetHp(instanceId)
    if not hpItem then
        hpItem = HpItem.new(self.parentRect, self.hpTr, data)
        self.hpMap[instanceId] = hpItem
    end

    hpItem:refresh(data)
end

function HpTipsManager:Hide()
    self:UnRegisetEvent()

    for _, hp in pairs(self.hpMap) do
        hp:Destroy()
    end
    self.hpMap = {}
end

function HpTipsManager:SpriteDestroy(eventData)
    local instanceId = eventData.data
    self:RemoveHp(instanceId)
end

function HpTipsManager:RegisetEvent()
	AppServices.EventDispatcher:addObserver(self, HP_INFO_EVENT.HP_INFO, function(eventData)
		self:HpInfo(eventData)
	end)

    AppServices.EventDispatcher:addObserver(self, HP_INFO_EVENT.HP_DESTROY, function(eventData)
		self:SpriteDestroy(eventData)
	end)
end

function HpTipsManager:UnRegisetEvent()
    AppServices.EventDispatcher:removeObserver(self, HP_INFO_EVENT.HP_INFO)
    AppServices.EventDispatcher:removeObserver(self, HP_INFO_EVENT.HP_DESTROY)
end

function HpTipsManager:Update()
    for _, hp in pairs(self.hpMap) do
        hp:Update()
    end
end

function HpTipsManager:OnDestroy()
    if Runtime.CSValid(self.go) then
       Runtime.CSDestroy(self.go)
    end
    self.go = nil
    --self:UnRegisetEvent()
end

return HpTipsManager