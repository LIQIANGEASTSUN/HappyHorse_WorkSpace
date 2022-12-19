--- 按照名字分组, 把有相同指定名的物体归类
---@class ChangeableCollection
local ChangeableCollection = class(nil, "ChangeableObject")

function ChangeableCollection:ctor(name)
    self.name = name
    self.objects = {}
end

function ChangeableCollection:AddObject(obj)
    if not obj.ChangeSkin then --@DEL
        console.error("object must have a function:ChangeSkin!!!") --@DEL
    end --@DEL
    table.insertIfNotExist(self.objects, obj)
end
function ChangeableCollection:RemoveObject(obj)
    table.removeIfExist(self.objects, obj)
end

function ChangeableCollection:ChangeSkin(skin, callback)
    local total = #self.objects
    local cnt = 0
    local function onFinished()
        cnt = cnt + 1
        if cnt == total then
            Runtime.InvokeCbk(callback)
        end
    end
    local type = skin.type
    for k, obj in pairs(self.objects) do
        if type == SkinType.FemalePlayer or type == SkinType.Pet then
            obj:ChangeSkin(skin, onFinished)
            MessageDispatcher:SendMessage(MessageType.Global_After_Character_ChangeSkin, self.name, skin)
        else
            obj:ChangePart(skin, onFinished)
        end
    end
end

return ChangeableCollection
