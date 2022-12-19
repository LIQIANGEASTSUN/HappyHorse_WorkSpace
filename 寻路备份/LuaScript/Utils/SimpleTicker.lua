local createInstance = function()
    ---@class SimpleTicker
    local SimpleTicker = {
        observers = {}
    }

    function SimpleTicker:Start(delay, interval)
        self:Stop()
        self.tickId =
            WaitExtension.InvokeRepeating(
            function()
                self:Tick()
            end,
            delay,
            interval
        )
    end

    function SimpleTicker:Tick()
        for index, value in ipairs(self.observers) do
            value:Tick()
        end
    end

    function SimpleTicker:AddObserver(observer)
        table.insert(self.observers, observer)
    end

    function SimpleTicker:RemoveObserver(observer)
        table.removeIf(
            self.observers,
            function(o)
                return o == observer
            end
        )
    end

    function SimpleTicker:Stop()
        if self.tickId then
            WaitExtension.CancelTimeout(self.tickId)
            self.tickId = nil
        end
    end

    return SimpleTicker
end

return createInstance
