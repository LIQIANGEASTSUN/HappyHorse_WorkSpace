---@class DataRef ---------------------------------------------------------
DataRef = class()
function DataRef:encode()
	local dst = {}
	for k,v in pairs(self) do
		if k ~="class" and v ~= nil and type(v) ~= "function" then dst[k] = v end
	end
	return dst
end
function DataRef:decode(src)
	self:fromLua(src)
end
function DataRef:dispose()
end
function DataRef:fromLua(src)
	if not src then
		print("  [WARNING] lua data is nil") --@DEL
		return
	end

	for k,v in pairs(src) do
		if type(v) ~= "function" then self[k] = v end
	end
end

