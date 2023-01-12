
local Variables = class(nil, "Variables")

function Variables:ctor()
	self.con = {}
end

function Variables:setString(key, val)
	self.con[key] = val
end
function Variables:setFloat(key, val)
	self.con[key] = val
end
function Variables:setPoint(key, val)
	self.con[key] = val
end
function Variables:setInt(key, val)
	self.con[key] = val
end

local Message = class(nil, "Message")

function Message:ctor(name, body, type)
	self.name = name
	self.body = body
	self.type = type

	self.variables = Variables.new()
end
--[[
 * Get the name of the Message instance
 *
 * @return {string}
 *  The name of the Message instance
]]
function Message:getName()
	return self.name
end
--[[
 * Set this Messages body.
 * @param {Object} body
 * @return {void}
]]
function Message:setBody(body)
	self.body = body
end
--[[
 * Get the Message body.
 *
 * @return {Object}
]]
function Message:getBody()
	return self.body
end

function Message:getVariables()
	return self.variables;
end
--[[
 * Set the type of the Message instance.
 *
 * @param {Object} type
 * @return {void}
]]
function Message:setType(type)
	self.type = type
end
--[[
 * Get the type of the Message instance.
 *
 * @return {Object}
]]
function Message:getType()
	return self.type
end
--[[
 * Get a string representation of the Message instance
 *
 * @return {string}
]]
function Message:toString()
	local msg = "Message Name: " .. self:getName()
	msg = msg .. "\nBody: " .. tostring(self:getBody())
	msg = msg .. "\nType: " .. self:getType()
	return msg
end

return Message