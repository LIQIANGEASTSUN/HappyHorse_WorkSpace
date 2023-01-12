---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@class UnitTipsBase
local UnitTipsBase = class(nil, "UnitTipsBase")

function UnitTipsBase:ctor(unitId)
    self.unitId = unitId
    self.instanceId = -1
    self.shwo = false
    self.go = nil
    self.offsetPos = Vector3(0, 3, 0)
    self.positionRefreshTime = 1
    self.isloading = false
    self.lastRefreshPosTime = 0

    self.unit = AppServices.UnitManager:GetUnit(unitId)
    self:SetTipsType(TipsType.None)
    self:SetUseUpdate(false)
    self:SetTipsFollowType(UnitTipsInfo.TipsFollowType.Unit)
    self:SetTipsPath("")
end

function UnitTipsBase:GetUnitId()
    return self.unitId
end

function UnitTipsBase:SetTipsType(type)
    self.tipsType = type
end

function UnitTipsBase:GetTipsType()
    return self.tipsType
end

function UnitTipsBase:SetTipsFollowType(type)
    self.followType = type
end

function UnitTipsBase:GetTipsFollowType()
    return self.followType
end

function UnitTipsBase:SetTipsPath(path)
    self.tipsPrefabPath = path
end

function UnitTipsBase:SetInstanceId(instanceId)
    self.instanceId = instanceId
    self.tipsName = string.format("Tips_%d", self.instanceId)
end

function UnitTipsBase:GetInstanceId()
    return self.instanceId
end

function UnitTipsBase:SetUseUpdate(value)
    self.useUpdate = value
end

function UnitTipsBase:GetUseUpdate()
    return self.useUpdate
end

function UnitTipsBase:TipsName()
    return self.tipsName
end

function UnitTipsBase:Refresh()

end

function UnitTipsBase:Show(tipsData)
    self.tipsData = tipsData
    self.show = true
    if not Runtime.CSValid(self.go) then
        self:Instantiate()
    end

    self:Refresh()
    self:SetActive(true)
end

function UnitTipsBase:Hide()
    self.show = false
    self:SetActive(self.show)
end

function UnitTipsBase:SetActive(value)
    if Runtime.CSValid(self.go) then
        self.go:SetActive(value)
    end
end

function UnitTipsBase:Click()

end

function UnitTipsBase:Instantiate()
    if self.isloading then
        return
    end

    self.isloading = true
    local function onLoaded()
        self.go = BResource.InstantiateFromAssetName(self.tipsPrefabPath)
        self.go.name = self:TipsName()
        self:LoadFinish()
        self.isloading = false
    end
    App.buildingAssetsManager:LoadAssets({self.tipsPrefabPath}, onLoaded)
end

function UnitTipsBase:LoadFinish()
    self.lastRefreshPosTime = -1
    self:SetActive(self.show)
    local mainCamera = Camera.main
    self.go.transform.rotation = mainCamera.transform.rotation
end

function UnitTipsBase:GetTargetPosition()
    return self.unit:GetPosition()
end

function UnitTipsBase:CalculatePosition()
    if Time.realtimeSinceStartup - self.lastRefreshPosTime < self.positionRefreshTime then
        return
    end
    self.lastRefreshPosTime = Time.realtimeSinceStartup

    if not Runtime.CSValid(self.go) then
        return
    end

    if self.followType == UnitTipsInfo.TipsFollowType.Unit then
        self:FollowUnit()
    elseif self.followType == UnitTipsInfo.TipsFollowType.Unit_And_Camera then
        self:FollowUnitAndCamera();
    end
end

function UnitTipsBase:FollowUnit()
    local position = self:GetTargetPosition()
    self.go.transform.position = position + self.offsetPos
end

function UnitTipsBase:FollowUnitAndCamera()
    local position = self:GetTargetPosition()
    local cameraPosition = Camera.main.transform.position
    local offset = cameraPosition - position
    offset = offset.normalized
    self.transform.position = position + self.offsetPos + offset * 3
end

function UnitTipsBase:LateUpdate()
    self:CalculatePosition()
end

function UnitTipsBase:GetItemSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function UnitTipsBase:Destroy()
    if Runtime.CSValid(self.go) then
        GameObject.Destroy(self.go)
    end
    self.go = nil
end

return UnitTipsBase