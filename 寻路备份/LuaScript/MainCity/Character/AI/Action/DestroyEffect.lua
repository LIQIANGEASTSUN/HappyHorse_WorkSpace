--[[
    @ Action Desc:移除模型
    @ Require Params:
        string:{模型名称}
        int:{}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local DestroyEffect = class(superCls, "DestroyEffect")

local SpineType = typeof(SkeletonAnimation)
local SpriteRendererType = typeof(SpriteRenderer)
local SkinnedMeshRendererType = typeof(SkinnedMeshRenderer)
local MeshRendererType = typeof(MeshRenderer)
local RenderHandlers = {
    ---spine
    [SpineType] = function(render, toValue)
        render.Skeleton.A = toValue
    end,
    ---skinnedMesh
    [SkinnedMeshRendererType] = function(render, toValue)
        local mat = render.material
        GameUtil.SetShader(mat, "HomeLand/FbxTransparency")
        mat:SetFloat("_Alpha", toValue)
    end,
    [MeshRendererType] = function(render, toValue)
        local mat = render.material
        GameUtil.SetShader(mat, "HomeLand/FbxTransparency")
        mat:SetFloat("_Alpha", toValue)
    end,
    ---sprite
    [SpriteRendererType] = function(render, toValue)
        local color = render.color
        color.a = toValue
        render.color = color
    end
}

local Id2Type = {}
local function ResetRender(gameObject, id)
    local renderType = Id2Type[id]
    local render
    if renderType then
        render = gameObject:GetComponentInChildren(renderType)
        Runtime.InvokeCbk(RenderHandlers[renderType], render, 1)
        return true
    end

    for renderType, _ in pairs(RenderHandlers) do
        render = gameObject:GetComponentInChildren(renderType)
        if render then
            Id2Type[id] = renderType
            Runtime.InvokeCbk(RenderHandlers[renderType], render, 1)
            return true
        end
    end
end
function DestroyEffect:OnUpdate()
    local id = self:GetStringParam(0)
    local go = self.treeBlackboard[id]
    if Runtime.CSValid(go) then
        go:SetActive(false)
        ResetRender(go, id)
        return BDTaskStatus.Success
    end
    return BDTaskStatus.Failure
end

return DestroyEffect
