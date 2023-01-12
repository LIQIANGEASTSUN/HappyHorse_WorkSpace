---@class RoleSkinParts
local RoleSkinParts = {}

local Tags = {
    ["all"] = -1,
    ["fashion"] = 2,
    ["head"] = 10,
    ["upper"] = 11,
    ["lower"] = 12,
    ["shoe"] = 13,
}

local UserName = "Femaleplayer"
local reddotName = "newRoleSkin"
local DefaultColor = Color(1,1,1,1)
local FadeColor = Color(1,1,1,0)

function RoleSkinParts.Create(parent, pos)
    local itm = {}
    setmetatable(itm, {__index = RoleSkinParts})
    local go = BResource.InstantiateFromAssetName("Prefab/UI/UserInfo/skin_parts.prefab")
    go:SetParent(parent, false)
    go.transform.anchoredPosition = pos
    itm:Bind(go)
    itm:InitDatas()
    return itm
end

function RoleSkinParts:Bind(go)
    self.gameObject = go
    self.transform = go.transform
    local togs = {}
    for k, v in pairs(Tags) do
        local skinType = v
        local togGo = find_component(go, string.format("bg/togs/%s", k))
        local toggle = find_component(togGo, "", Toggle)
        local defaultBg = find_component(togGo, "", Image)
        local selectBg = find_component(togGo, "selectBg", Image)
        local defaultIcon = find_component(togGo, "icon", Image)
        local selecIcon = find_component(togGo, "iconSelect", Image)
        toggle.onValueChanged:AddListener(function(val)
            if val then
                defaultBg.color = FadeColor
                defaultIcon.color = FadeColor
                selectBg.color = DefaultColor
                selecIcon.color = DefaultColor
                App.mapGuideManager:OnGuideFinishEvent(GuideEvent.TargetButtonClicked, togGo)
                self:OnSwitchTag(skinType)
            else
                defaultBg.color = DefaultColor
                defaultIcon.color = DefaultColor
                selectBg.color = FadeColor
                selecIcon.color = FadeColor
            end
        end)
        togs[v] = toggle
    end
    self.toggles = togs
    self.bgTrans = find_component(go, "bg").transform
    self.itemScrollList = find_component(go, "bg/viewBg/itemView", ScrollListRenderer)
    self.tipTrans = find_component(go, "bg/tip").transform
    self.tipContent = find_component(go, "bg/tip/content", Text)
    self.tipChecker = find_component(go, "bg/tip", CS.UITipChecker)
    self.tipCanvasGroup = find_component(go, "bg/tip", CanvasGroup)
    self.tipChecker:SetCallback(function()
        self.tipChecker:SetRaycastEnable(false)
        self.tipCanvasGroup.alpha = 0
        -- DOTween.Kill(self.tipTrans)
        -- DOTween.Kill(self.tipCanvasGroup)
        -- self.tipTrans.localScale = Vector3.zero
    end)
    self.inputMgr = CS.InputManager.Instance
end

function RoleSkinParts:Init(selectType, targetId)
    self.showed = true
    self.itemList = {}
    self.newList = AppServices.User.Default:GetKeyValue(reddotName, {})
    -- self.orginWearList = {}
    selectType = selectType or -1
    self.targetId = targetId
    self.toggles[selectType].isOn = true
end

function RoleSkinParts:Show()
    if self.showed then
        return
    end
    self.showed = true
    self.gameObject:SetActive(true)
end

function RoleSkinParts:Hide()
    if not self.showed then
        return
    end
    self.showed = false
    self.gameObject:SetActive(false)
end

function RoleSkinParts:ShowSkinTip(info)
    self.tipCanvasGroup.alpha = 1
    self.tipChecker:SetRaycastEnable(true)
    local tpos = GameUtil.WorldToUISpace(self.bgTrans, info.pos)
    self.tipTrans.anchoredPosition = Vector2(tpos.x + 64, tpos.y - 20)
    self.tipContent.text = Runtime.Translate(info.key)
end

function RoleSkinParts:OnSwitchTag(skinType)
    self.itemList = {}
    local configs = self:GetDatas(skinType)
    self.showConfigs = configs
    if not configs then
        return
    end
    local function onCreate(key)
        local itm = self:GetSkinItem()
        self.itemList[key] = itm
        return itm.gameObject
    end

    local function onUpdate(key, index)
        local itm = self.itemList[key]
        itm:SetData(configs[index])
    end
    local targetIdx = 0
    if self.targetId then
        for i, cfg in ipairs(configs) do
            if cfg.id == self.targetId then
                targetIdx = i
                break
            end
        end
    end
    self.itemScrollList:InitList(#configs, onCreate, onUpdate, nil, targetIdx)

    if self.targetId then
        WaitExtension.SetTimeout(function()
            if Runtime.CSValid(self.itemScrollList) then
                self.targetId = nil
                self:ShowTargetArrow(self.itemList[targetIdx].gameObject)
            end
        end, 0.8)   --时间再短预制位置还没固定，定位坐标会有异常
    end
end

function RoleSkinParts:GetSkinItem()
    local go = BResource.InstantiateFromAssetName("Prefab/UI/UserInfo/item_skin.prefab")
    local itm = {}
    itm.gameObject = go
    itm.transform = go.transform
    itm.selected = false
    itm.redotShowed = false
    itm.txtName = find_component(go, "bg/name", Text)
    itm.imgIcon = find_component(go, "bg/icon", Image)
    itm.imgSelect = find_component(go, "bg/select", Image)
    itm.lockGo = find_component(go, "lock")
    itm.imgRedot = find_component(go, "bg/redot", Image)
    itm.SetData = function(sf, dt)
        local spr = AppServices.ItemIcons:GetSpriteByName(dt.icon)
        sf.imgIcon.sprite = spr
        GameUtil.ShowLimitStringWithDots(sf.txtName, Runtime.Translate(dt.name))
        -- sf.txtName.text = Runtime.Translate(dt.name)
        if dt.locked then
            sf.lockGo:SetActive(true)
        else
            sf.lockGo:SetActive(false)
        end
        if sf.selected ~= dt.selected then
            if sf.selected then
                sf.imgSelect.color = Color(1,1,1,0)
            else
                sf.imgSelect.color = Color(1,1,1,1)
            end
            sf.selected = dt.selected
        end
        if table.indexOf(self.newList, dt.id) then
            if not sf.redotShowed then
                sf.redotShowed = true
                sf.imgRedot.color = Color(1,1,1,1)
            end
        else
            if sf.redotShowed then
                sf.redotShowed = false
                sf.imgRedot.color = Color(1,1,1,0)
            end
        end
        sf.data = dt
    end
    itm.FreshState = function(sf)
        local dt = sf.data
        if not dt then
            return
        end
        if table.indexOf(self.newList, dt.id) then
            if not sf.redotShowed then
                sf.redotShowed = true
                sf.imgRedot.color = Color(1,1,1,1)
            end
        else
            if sf.redotShowed then
                sf.redotShowed = false
                sf.imgRedot.color = Color(1,1,1,0)
            end
        end
        if sf.selected ~= dt.selected then
            if sf.selected then
                sf.imgSelect:DOFade(0, 0.1)
            else
                sf.imgSelect:DOFade(1, 0.1)
            end
            sf.selected = dt.selected
        end
    end
    local bg = find_component(go, "bg")
    Util.UGUI_AddButtonListener(bg, function()
        local dt = itm.data
        if dt.locked then
            self:ShowSkinTip({key = dt.desc, pos = itm.transform.position})
        end
        if not dt.selected then
            dt.selected = true
            self.dataDirty = true
            if table.indexOf(self.newList, dt.id) then
                table.removeIfExist(self.newList, dt.id)
                self.redotDirty = true
            end
            sendNotification(UserInfoPanelNotificationEnum.ChangePart,{name = dt.name, id = dt.id, type = dt.type, model = dt.model, getWay = dt.getWay})
        end
        self:RefreshDatas(dt)
    end)
    return itm
end

function RoleSkinParts:RefreshDatas(dt)
    if self.redotDirty then
        self.redotDirty = false
        AppServices.User.Default:SetKeyValue(reddotName, self.newList,true)
        AppServices.RedDotManage:FreshDate_Count(reddotName,-1)
    end
    if not self.dataDirty then
        return
    end
    self.dataDirty = false
    for _, v in ipairs(self.datas) do
        if dt.type == 2 then
            if dt.id ~= v.id then
                v.selected = false
            end
        else
            if self.lastType ==2 and v.getWay == 0 then
                v.selected = true
            end
            if v.type == 2 then
                v.selected = false
            elseif dt.id ~= v.id and dt.type == v.type then
                v.selected = false
            end
        end
    end
    self.lastType = dt.type
    for _, v in ipairs(self.itemList) do
        v:FreshState()
    end
end

function RoleSkinParts:GetDatas(skinType)
    local datas = {}
    for _, v in ipairs(self.datas) do
        if v.type == skinType or skinType < 0 then
            table.insert(datas, v)
        end
    end
    return datas
end

function RoleSkinParts:InitDatas()
    local metas = AppServices.SkinLogic:GetUserSkinMeta(UserName)
    local datas = {}
    local mgr = AppServices.SkinLogic
    for _, v in pairs(metas) do
        if v.id ~= "27200" then
            local selected = mgr:IsSkinInUse(v.id)
            local openTime = v.openTime
            if string.isEmpty(openTime) or tonumber(openTime) <= TimeUtil.ServerTime() then
                table.insert(datas, {
                    id = v.id,
                    name = v.name,
                    desc = v.desc,
                    type = v.type,
                    icon = v.icon,
                    model = v.model,
                    getWay = v.getWay,
                    sequence = v.sequence,
                    selected = selected,
                    locked = not mgr:IsSkinPurchased(v.id)
                })
            end
            if selected then
                self.lastType = v.type
            end
        end
    end
    table.sort(datas, function(a,b)
        if a and b then
            if a.sequence > b.sequence then
                return true
            end
        end
        return false
    end)
    self.datas = datas
end

function RoleSkinParts:ShowTargetArrow(item, callback)
    local assetPath = "Prefab/UI/BindingTip/arrow.prefab"
    local onLoaded = function()
        local arrowGo = BResource.InstantiateFromAssetName(assetPath)
        arrowGo.transform:SetParent(self.bgTrans, false)
        local tpos = GameUtil.WorldToUISpace(self.bgTrans, item.transform.position)
        arrowGo.transform.anchoredPosition = Vector2(tpos.x + 64, tpos.y - 60)
        arrowGo:SetActive(true)
        self.arrow = arrowGo
        self:StartArrowTimer()
        self.inputMgr:AddClickAnythingListener(function()
            self:CancelArrowTimer()
        end)
        Runtime.InvokeCbk(callback)
    end
    App.uiAssetsManager:LoadAssets({assetPath}, onLoaded)
end

function RoleSkinParts:StartArrowTimer()
    local sec = 0
    self.arrowId = WaitExtension.InvokeRepeating(function()
        sec = sec + 1
        if sec >= 30 then
            self:CancelArrowTimer()
        end
    end,0,1)
end

function RoleSkinParts:CancelArrowTimer()
    Runtime.CSDestroy(self.arrow)
    if self.arrowId then
        WaitExtension.CancelTimeout(self.arrowId)
        self.arrowId = nil
    end
    self.inputMgr:AddClickAnythingListener()
end

function RoleSkinParts:Dispose()
    self:CancelArrowTimer()
end

return RoleSkinParts