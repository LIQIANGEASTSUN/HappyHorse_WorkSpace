------------------for screen actions register-------------------
Actions = { }

local mt = {
	__index = function(t, k)
		local ret = include("ScreenPlays.Actions." ..k)
		t[k] = ret
		return ret
	end
}
setmetatable(Actions, mt)

-----------------------------------------------------------------
---@return Character
function GetPers(name, params)
	local person = CharacterManager.Instance():Get(name, params)
	console.assert(person, name)  --@DEL
	return person
end
---@return MainCity
function GetScene()
	return App.scene
end

function GetPosition(val)
	local elements = string.split(val, ',')
	console.assert(#elements == 3)
	return Vector3(tonumber(elements[1]), tonumber(elements[2]), tonumber(elements[3]))
end
-----------------------------------------------------------------

require 'ScreenPlays.ScreenPlays'

local MessageCls = require 'ScreenPlays.Base.Message'
function Message(...)
    return MessageCls.new(...)
end

function PointWithArrow(pt, ...)
    return pt
end
