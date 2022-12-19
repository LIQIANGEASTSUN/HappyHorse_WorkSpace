---@class PanelMask
PanelMask = class(nil, "PanelMask")
function PanelMask:ctor()
    self.entity_Mask = nil
    self.gameObject = nil
end

local defaultFade = 0.6
local defaultBetween = 0.433
function PanelMask:init(_panelVO,panelGo)
    self.panelVO = _panelVO

    local maskPool = AppServices.PoolManage:GetPool("PanelMask")
    self.entity_Mask = maskPool:GetEntity(true)
    self.gameObject = self.entity_Mask.gameObject
    self.transform = self.gameObject.transform
    self.gameObject.name = self.panelVO.panelName .. "mask"
    self.bgImg = self.gameObject:GetComponent(typeof(Image))

    if App.scene and App.scene.panelLayer then
        self.entity_Mask:SetParent(App.scene.panelLayer.transform, false)
        local index = panelGo.transform:GetSiblingIndex()
        self.entity_Mask.transform:SetSiblingIndex(index)
    end

    if self.panelVO.showFlag and not string.isEmpty(self.panelVO.showFlag.background) then
        self:SetBG(self.panelVO.showFlag.background)
        self.bgImg.color = Color(1,1,1,1)
    else
        self.bgImg.color = Color(0,0,0,0)
        self.bgImg.sprite = nil
        self:fadeIn()
    end

    Util.UGUI_AddEventListener(self.gameObject, "onClick", function()
        sendNotification(CONST.GLOBAL_NOFITY.Click_PanelMask, self.panelVO.panelName)
    end)
end

function PanelMask:SetBG(bgPath)
    AppServices.ItemIcons:LoadSpriteAsync(bgPath,function(spr)
        if spr and Runtime.CSValid(self.bgImg) then
            self.bgImg.sprite = spr
        end
    end)
end
--

function PanelMask:destroy()
    if not self.entity_Mask then
        return
    end

    --self.bgImg.sprite = nil
    local pool = AppServices.PoolManage:GetPool("PanelMask")
    pool:RecycleEntity(self.entity_Mask,{"parent","doTween"})
    self.entity_Mask = nil
end

function PanelMask:fadeIn(fade,between)
    if not self.entity_Mask then
        return
    end

    local tween = GameUtil.DoFade(self.entity_Mask.gameObject, fade or defaultFade, between or defaultBetween)
    tween:SetEase(Ease.Linear)
end

function PanelMask:fadeOut(fade,between)
    if not self.entity_Mask then
        return
    end

    local tween = GameUtil.DoFade(self.entity_Mask.gameObject, fade or 0,  between or defaultBetween)
    tween:OnComplete(
        function ()
            self:destroy()
        end
    )
    tween:SetEase(Ease.Linear)
end

return PanelMask
