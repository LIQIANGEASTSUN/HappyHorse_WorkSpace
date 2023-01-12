---@class PoolEntity
local PoolEntity = class()

function PoolEntity:ctor(path, rootTransform)
    self.gameObject = BResource.InstantiateFromAssetName(path)
    if self.gameObject == nil then
        console.lj(path .. "cant Instantiate ")--@DEL
    end
    self.path = path
    self.rootTransform = rootTransform
    self.transform = self.gameObject.transform
    self:SetParent(rootTransform)

    self.dirty = false
    self.hideCallBack = nil
end

function PoolEntity:SetParent(parent)
    if Runtime.CSValid(self.transform) then
        self.transform:SetParent(parent, false)
    end
end

function PoolEntity:Show(_beforeCall, _afterCall)
    if _beforeCall ~= nil then
        Runtime.InvokeCbk(_beforeCall)
    end
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(true)
    end

    if _afterCall ~= nil then
        Runtime.InvokeCbk(_afterCall)
    end
end

function PoolEntity:Hide()
    if self.hideCallBack ~= nil then
        self.hideCallBack()
    end
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(false)
    end
end

--销毁之后补
function PoolEntity:Destroy()
    Runtime.CSDestroy(self.gameObject)

    self.path = nil
    self.rootTransform = nil
    self.transform = nil
    self.dirty = nil
    self.hideCallBack = nil
end

local ResetOption = {
    ["doTween"] = function(entity)
        DOTween.Kill(entity.transform)
    end,
    ["parent"] = function(entity)
        entity:SetParent(entity.rootTransform)
    end,
    ["postion"] = function(entity)
        entity.transform.localPosition = Vector3.zero
    end
}

function PoolEntity:Reset(params)
    if not params then
        return
    end

    for _, value in pairs(params) do
        Runtime.InvokeCbk(ResetOption[value], self)
    end
end

return PoolEntity
