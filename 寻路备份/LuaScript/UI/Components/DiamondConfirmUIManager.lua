---
--- Created by Betta.
--- DateTime: 2021/10/22 10:59
---
---@class DiamondConfirmUIItem
local DiamondConfirmUIItem = class(nil, "DiamondConfirmUIItem")

DiamondConfirmUIItem.State =
{
    State1 = 1,
    State2 = 2,
}

function DiamondConfirmUIItem:ctor(btnImage, btnTF)
    self.state = DiamondConfirmUIItem.State.State1
    self.btnImage = btnImage
    self.btnTF = btnTF
    --GameUtil.SetShader(self.btnImage.material, "UI/Button") --GameObject.Instantiate(self.btnImage.material)
    self.btnImage.material = GameUtil.CreateMaterial(self.btnImage.material, "UI/Button")
    --self.btnImageColor = btnImage.materialForRendering:GetColor("_HighLight")
end

function DiamondConfirmUIItem:Click(ClickCallback, ...)
    if AppServices.User.Default:GetKeyValue(UserDefaultKeys.KeyDiamondConfirm, false) and self.state == DiamondConfirmUIItem.State.State1 then
        self:DoState2()
        UITool.ShowContentTipAni(Runtime.Translate("Diamond.Confirm.Tips"), self.btnTF.position + Vector3(0, 0.49, 0))
        return false
    else
        self:DoState1()
        Runtime.InvokeCbk(ClickCallback, ...)
        return true
    end
end

function DiamondConfirmUIItem:DoState1()
    if Runtime.CSNull(self.btnImage) then
        console.dk("self.btnImage 已经被销毁") --@DEL
        return
    end
    self.btnImage.materialForRendering:DOColor(Color.black, "_HighLight", 0.1)
    --self.btnImage.material:SetColor("_HighLight", Color.black)
    self.state = DiamondConfirmUIItem.State.State1
end

function DiamondConfirmUIItem:DoState2()
    if Runtime.CSNull(self.btnImage) then
        console.dk("self.btnImage 已经被销毁") --@DEL
        return
    end
    self.btnImage.materialForRendering:DOColor(Color(0.25, 0.25, 0.25, 1), "_HighLight", 0.1)
    --self.btnImage.material:SetColor("_HighLight", Color(0.25, 0.25, 0.25, 1))
    self.state = DiamondConfirmUIItem.State.State2
end

function DiamondConfirmUIItem:Reset()
    if Runtime.CSNull(self.btnImage) then
        console.dk("self.btnImage 已经被销毁") --@DEL
        return
    end
    self.btnImage.material:SetColor("_HighLight", Color.black)
    self.state = DiamondConfirmUIItem.State.State1
end

---@class DiamondConfirmUIManager
local DiamondConfirmUIManager = {}

function DiamondConfirmUIManager:Init()
    ---@type table<DiamondConfirmUIItem, number>
    self.ItemSet = {}
    self.confirmItem = nil
end

function DiamondConfirmUIManager:Release()
    if self.confirmItem ~= nil then
        self.confirmItem:Reset()
        self.confirmItem = nil
    end
end

function DiamondConfirmUIManager:UndoClick(btnTF)
    if self.confirmItem ~= nil then
        if btnTF == nil or self.confirmItem.btnTF == btnTF then
            self.confirmItem:DoState1()
            self.confirmItem = nil
        end
    end
end

function DiamondConfirmUIManager:OnClick(preItem)
    if self.confirmItem ~= nil and self.confirmItem == preItem then
        --if self.confirmItem.btnTF ~= obj.transform then
            self.confirmItem:DoState1()
            self.confirmItem = nil
        --end
    end
end

function DiamondConfirmUIManager:Click(go_image, ClickCallback, ...)
    if go_image == nil then
        console.error("创建二次确认 go_image 为空")
        Runtime.InvokeCbk(ClickCallback, ...)
        return
    end
    self:Click2(go_image:GetComponent(typeof(Image)), go_image.transform, ClickCallback, ...)
end

function DiamondConfirmUIManager:Click2(btnImage, btnTF, ClickCallback, ...)
    if btnImage == nil then
        console.error("创建二次确认 btnImage 为空")
        Runtime.InvokeCbk(ClickCallback, ...)
        return
    end
    if btnTF == nil then
        console.error("创建二次确认 位置 为空")
        Runtime.InvokeCbk(ClickCallback, ...)
        return
    end
    if self.confirmItem ~= nil and self.confirmItem.btnTF ~= btnTF then
        self.confirmItem:DoState1()
        self.confirmItem = nil
    end
    if self.confirmItem == nil then
        self.confirmItem = DiamondConfirmUIItem.new(btnImage, btnTF)
    end
    if self.confirmItem:Click(ClickCallback, ...) then
        self.confirmItem = nil
    end
end

DiamondConfirmUIManager:Init()

return DiamondConfirmUIManager
