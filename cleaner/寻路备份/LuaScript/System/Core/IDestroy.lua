IDestroy = class()

function IDestroy:ctor()
	self.name = nil

    self.isDestroyed = false;
    self.className = "IDestroy"
end

function IDestroy:toString()
	return string.format("IDestroy [%s]", self.name and self.name or "nil")
end

function IDestroy:Destroy()
    self.isDestroyed = true;
end