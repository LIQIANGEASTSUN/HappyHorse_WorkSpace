---@class PetReward
local PetReward = class(nil, "PetReward")

local offset = Vector3(0, 0.55, 0)
local threshold = 150

function PetReward:ctor(character)
    ---@type Character
    self.owner = character
    self.active = true
    self.syncAvailable = false --标记是否已与服务器同步并确认可领取
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.OnDramaStarted, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Over, self.OnDramaEnded, self)
end

function PetReward:CreateGameObject()
    if self.isLoading then
        return
    end
    self.isLoading = true

    local assetPath = "Prefab/UI/CollectionBubble/PetReward.prefab"
    local function onLoaded()
        self.gameObject = BResource.InstantiateFromAssetName(assetPath)
        Util.UGUI_AddButtonListener(
            self.gameObject:FindGameObject("BG"),
            function()
                self:OnClick()
            end
        )
        if self.inUse and not self:IsInDrama() and self:IsUnlocked() then
            self:Show()
        else
            self:Hide()
        end
    end
    App.buildingAssetsManager:LoadAssets({assetPath}, onLoaded)
end

function PetReward:Show()
    self.inUse = true
    if not self.syncAvailable then
        return self:SendSyncRequest()
    end
    if Runtime.CSNull(self.gameObject) then
        self:CreateGameObject()
        return
    end
    self.gameObject:SetActive(true)

    local follower = self.gameObject:GetOrAddComponent(typeof(BoneFollower))
    follower.target = self.owner:GetGameObject()
    follower.bone = "Bip001/Bip001 Pelvis/Bip001 Spine"
    follower.distance = 0
    follower.offset = offset
end

function PetReward:Hide()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(false)
    end
    self.inUse = false
end

function PetReward:OnReceived(response)
    self:Hide()
    self.syncAvailable = false
    if not response then
        return self:SendSyncRequest()
    end
    AppServices.User:SetUsedCount(ItemId.ENERGY, 0)
    local from = self.gameObject:GetPosition()
    local itemId = response.itemTemplateId
    AppServices.User:AddItem(itemId, response.count, ItemGetMethod.petDragonReward)
    UITool.ShowPropsAni(itemId, response.count, from)
end

function PetReward:SendRequest(onResponse)
    local function funcFailedCbk(errorCode)
        onResponse(false)
    end
    local function funcSuccessCbk(response)
        local data = Net.Converter.ConvertPetRewardResponse(response)
        onResponse(data)
    end
    Net.Magicalcreaturemodulemsg_24017_PetReward_Request({}, funcFailedCbk, funcSuccessCbk, nil, true)
end
function PetReward:SendSyncRequest()
    if self.isSyncing then
        return
    end
    self.isSyncing = true

    local function funcFailedCbk(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode) --@DEL
        self.isSyncing = false
    end
    local function funcSuccessCbk(response)
        self.isSyncing = false
        local consumeEnergyCnt = response.consumeEnergyCnt
        if consumeEnergyCnt >= threshold then
            self.syncAvailable = true
            if self.inUse and not self:IsInDrama() and self:IsUnlocked() then
                self:Show()
            else
                self:Hide()
            end
        else
            self:Hide()
            self.syncAvailable = false
        end

        local recordCount = AppServices.User:GetUsedCount(ItemId.ENERGY)
        AppServices.User:SetUsedCount(ItemId.ENERGY, consumeEnergyCnt)

        if not self.syncAvailable and recordCount ~= consumeEnergyCnt then
            console.warn(nil, "服务器统计体力消耗数据:[", consumeEnergyCnt, "]和前端统计数据:[", recordCount, "]不一致") --@DEL
        end
    end
    Net.Magicalcreaturemodulemsg_24020_GetConsumeEnergy_Request({}, funcFailedCbk, funcSuccessCbk, nil, true)
end

---判断功能是否已经开启
function PetReward:IsUnlocked()
    --Mission2_004Savethenino
    local ret = AppServices.Task:IsTaskFinish("Mission2_004Savethenino")
    return ret
end

---是否在剧情中
function PetReward:IsInDrama()
    if self.inDrama then
        return true
    end

    return App.screenPlayActive
end

function PetReward:OnDramaStarted()
    self.inDrama = true
    if self.active and self.inUse then
        self:Hide()
    end
end
function PetReward:OnDramaEnded()
    self.inDrama = false
    if self.active then
        local count = AppServices.User:GetUsedCount(ItemId.ENERGY)
        if count < threshold then
            return
        end

        if self:IsUnlocked() then
            self:Show()
        end
    end
end

-- function PetReward:LateUpdate()
--     if not self.inUse or not self.active then
--         return
--     end
--     if self.owner then
--         self:SetPosition(self.owner:GetPosition() + offset)
--     end
-- end

function PetReward:SetPosition(position)
    if not self.active then
        return
    end
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetPosition(position)
    end
end

function PetReward:RefreshUI()
    self:Hide()
    --[[
    local itemId
    if string.isEmpty(itemId) then
        self:Hide()
        return
    end

    local sprite = AppServices.ItemIcons:GetSprite(itemId)
    self.icon = self.icon or find_component(self.gameObject, "Icon", Image)
    self.icon.sprite = sprite
    ]]
end

function PetReward:OnClick()
    if self.isRequesting then
        return
    end
    self.isRequesting = true

    self:SendRequest(
        function(response)
            self:OnReceived(response)
            self.isRequesting = false
        end
    )
end

function PetReward:Destroy()
    MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Start, self.OnDramaStarted, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Over, self.OnDramaEnded, self)
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
    self.inUse = false
    self.active = false
end

return PetReward
