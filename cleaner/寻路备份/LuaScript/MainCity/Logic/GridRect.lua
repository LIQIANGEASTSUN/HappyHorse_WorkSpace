---@class GridRect
local GridRect = class(nil, "GridRect")
local GlobalGridOffset = Vector3(-0.5, 0, -0.5)

function GridRect:ctor(xMin, zMin, xMax, zMax)
    self.xMin = xMin
    self.zMin = zMin
    self.xMax = xMax
    self.zMax = zMax
end

function GridRect:SetAnchor()
    if Runtime.CSValid(self.renderObj) then
        local position = App.scene.mapManager:ToWorld(self.xMin, self.zMin) + GlobalGridOffset
        self.renderObj:SetPosition(position)
    end
end

function GridRect:SetSize()
    if Runtime.CSValid(self.renderObj) then
        local sr = self.renderObj:GetComponent(typeof(Image))
        local size = Vector2(self.xMax - self.xMin + 1, self.zMax - self.zMin + 1)
        sr.transform.sizeDelta = size * 100
    end
end

---@param other GridRect
function GridRect:Merge(other)
    local ret
    if self.xMin == other.xMin and self.xMax == other.xMax then
        if other.zMin - self.zMax == 1 or self.zMin - other.zMax == 1 then
            self.zMin = math.min(self.zMin, other.zMin)
            self.zMax = math.max(self.zMax, other.zMax)
            ret = true
        end
    elseif self.zMin == other.zMin and self.zMax == other.zMax then
        if other.xMin - self.xMax == 1 or self.xMin - other.xMax == 1 then
            self.xMin = math.min(self.xMin, other.xMin)
            self.xMax = math.max(self.xMax, other.xMax)
            ret = true
        end
    end

    if ret and self.initialized then
        self:SetAnchor()
        self:SetSize()
    end
    return ret
end

function GridRect:Initialize(path, root)
    if self.initialized then
        return
    end
    self.initialized = true

    local asset = BResource.InstantiateFromAssetName(path, root, false)
    if Runtime.CSNull(asset) then
        return
    end

    self.renderObj = asset
    self:SetAnchor()
    self:SetSize()
end

function GridRect:Destroy()
    Runtime.CSDestroy(self.renderObj)
    self.renderObj = nil
end

return GridRect
