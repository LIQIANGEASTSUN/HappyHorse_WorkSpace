---@class DescriptionTip
local DescriptionTip = class(PanelItemBase, "DescriptionTip")

function DescriptionTip.Create(parentPanel)
    local instance = DescriptionTip.new(parentPanel)
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_COMMON_DESCRIPTIONTIP)
    instance:InitWithGameObject(go)
    return instance
end

function DescriptionTip:InitWithGameObject(go)
    self.gameObject = go
    self.go_bg = find_component(go, 'img_bg')
    self.label_descNode = find_component(go, "img_bg/label_descNode")
    self.btn_topMask = find_component(go, "btn_topMask", Button)
    Util.UGUI_AddButtonListener(
        self.btn_topMask,
        function()
            self:setActive(false)
        end
    )
    self.gameObject.transform:SetParent(self.parentPanel.gameObject.transform, false)
end

function DescriptionTip:ctor(parentPanel)
    self.parentPanel = parentPanel
end

---@param title string 翻译好的标题
---@param desc string 翻译好的描述内容
function DescriptionTip:SetData(descs, parentGameObject, offsetHeight)
   local nodes = self:CopyComponent(self.label_descNode, self.go_bg, #descs)
   for i, go in ipairs(nodes) do
        local label_desc = go:GetComponent(typeof(Text))
        label_desc.text = descs[i]
    end
    self:SetComponentVisible(self.btn_topMask, true)
    local pposition = parentGameObject:GetPosition()
    local startPos = GOUtil.WorldPositionToLocal(self.parentPanel.gameObject, pposition) + Vector3(0, offsetHeight, 0)
    self.gameObject:SetLocalPosition(startPos)
    self.btn_topMask.transform:SetLocalPosition(Vector3.zero)
    self:setActive(true)
end

return DescriptionTip
