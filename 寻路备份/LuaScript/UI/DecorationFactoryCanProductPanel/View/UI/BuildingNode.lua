---@class BuildingNode
local BuildingNode = class(nil, "BuildingNode")
---@return BuildingNode
function BuildingNode.Create(parentPanel)
    local instance = BuildingNode.new(parentPanel)
    local assetPath = "Prefab/UI/DecorationFactory/BuildingNode.prefab"
    local go = BResource.InstantiateFromAssetName(assetPath)
    instance:InitWithGameObject(go)
    return instance
end

function BuildingNode:ctor(parentPanel)
    self.parentPanel = parentPanel
end

function BuildingNode:InitWithGameObject(go)
    self.gameObject = go
    self.img_Icon = find_component(go, "Icon", Image)
end

function BuildingNode:SetData(itemId)
    AppServices.ItemIcons:SetItemIcon(self.img_Icon, itemId)
end


return BuildingNode