local _registry={}

function class(super, classname)

	local class_type = { ctor = false, super = super}    -- 'ctor' field must be here
	local vtbl = {}
	_registry[class_type] = vtbl

    -- class_type is one proxy indeed. (return class type, but operate vtbl)
	setmetatable(class_type, {
		__newindex= function(t,k,v)
            vtbl[k] = v
		end,
		__index = function(t,k)
            return vtbl[k]
		end
	})

	if super then
		setmetatable(vtbl, {
			__index= function(t, k)

				-- Then Check Parent
				if k and _registry[super] then
				    local ret = _registry[super][k]
				    vtbl[k] = ret                      -- remove this if lua running on back-end server
				    return ret
				else return nil end
			end
		})
	end

	class_type.classname = classname

    class_type.new = function(...)
        local obj = { class = class_type }
        setmetatable(obj, {
			__index = _registry[class_type],
			__tostring = class_type.__tostring
		})

        -- deal constructor recursively
        local inherit_list = {}
		local class_ptr = class_type
		while class_ptr do
			if class_ptr.ctor then table.insert(inherit_list, class_ptr) end
			class_ptr = class_ptr.super
		end
		local inherit_length = #inherit_list
		if inherit_length > 0 then
		    for i = inherit_length, 1, -1 do inherit_list[i].ctor(obj, ...) end
		end

		obj.class = class_type              -- must be here, because some class constructor change class property.
		obj.super = super 					-- zhukai

        return obj
    end

	return class_type
end