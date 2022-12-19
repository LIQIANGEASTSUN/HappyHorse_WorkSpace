---@class CartoonPanel
local CartoonPanel = class(nil, 'CartoonPanel')

function CartoonPanel:Create(CartoonName, chapter, name, OnFinished)
    local inst = CartoonPanel.new(CartoonName, chapter, name, OnFinished)
    inst:_Init()
    return inst
end

function CartoonPanel:ctor(CartoonName, chapter, name, OnFinished)
    self.render = nil
    self.textCom = nil
    self.OnFinishedCbk = OnFinished

    self.CartoonName = string.format("Prefab/Animation/%s.prefab", CartoonName)
    self.chapter = chapter
    self.name = name

    self.idx = 0
    self.animCtrl = nil
    self.signP = false

    --self.btnNext = nil
    self.ImgDown = nil
end

function CartoonPanel:_Init()
    self:BlockCanvas(true)

    -- data sections
    local ChatDB = require "UI.ScreenPlays.Data.ChatDB"
    self.db = ChatDB.Create(self.chapter, self.name)

    local function OnLoadFinished(sender)
        -- UI
        self.render = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_SCREENPLAY_CARTOON)
        self.render.name = "CartoonPanel"

        self.ImgDown = self.render.transform:Find('ImgDown')

        local subPanel = self.render.transform:Find('SubPanel')
        self.subPanel = subPanel

        local txContent = subPanel.transform:Find('bg/txContent')
        self.textCom = txContent:GetComponent(typeof(Text))

        --self.btnNext = subPanel.transform:Find('bg/btnNext')
        --self.btnNext:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnNext() end)
        --self.btnNext:SetActive(false)

        self.btnTouchLayer = self.render.transform:Find('btnTouchLayer')
        self.btnTouchLayer:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnTouched() end)

        -- Cartoon
        self.Cartoon = BResource.InstantiateFromAssetName(self.CartoonName)

        --self.Cartoon.gameObject:SetParentAlign(self.render.gameObject)
        self.Cartoon:SetParent(self.render, false)
        self.Cartoon.transform:SetAsFirstSibling()

        -- Animation Ctrl
        self.animCtrl = self.Cartoon.gameObject:GetOrAddComponent(typeof(NS.CartoonCtrl))
        if self.animCtrl then
            self:OnNext()
        end
    end
    App.buildingAssetsManager:LoadAssets({G_UI_SCREENPLAY_CARTOON, self.CartoonName}, OnLoadFinished, nil, nil)
end

function CartoonPanel:BlockCanvas(block)
    local canvas = GameObject.Find('Canvas')
    local component = canvas.gameObject:GetComponent(typeof(GraphicRaycaster))
    component.enabled = not block
end

function CartoonPanel:OnTouched()
    --if self.signP then
        self.signP = false
        --self.btnNext:SetActive(false)
        self:OnNext()
    --end
end

function CartoonPanel:OnNext()
    if not self.render then
        return
    end

    self.idx = self.idx + 1
    --if self.idx ~= 2 or true then
        -- dialogue
        local dialogue = self.db:Next()
        if dialogue then
            self.subPanel:SetActive(true)
            self.ImgDown:SetActive(true)
            self.textCom.text = Runtime.Translate(dialogue.Paragraphs[1].TextKey)
        else
            self.subPanel:SetActive(false)
            self.ImgDown:SetActive(false)
        end
    --else
    --    self.subPanel:SetActive(false)
    --    self.ImgDown:SetActive(false)
    --end

    if self.idx >= 3 then
        WaitExtension.SetTimeout(function ()
            if not self.render then return end
            Runtime.InvokeCbk(self.OnFinishedCbk)
            self:Destroy()
        end, 1)
    end

    self.animCtrl:Play(function()
        self:OnNext()
    end)
end

function CartoonPanel:Destroy()
    self:BlockCanvas(false)
    Runtime.CSDestroy(self.render)   --zhukaixy: fix it later
    self.render = nil
end

return CartoonPanel