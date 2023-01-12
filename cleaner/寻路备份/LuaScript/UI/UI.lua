-----------------------for panel register------------------------
GlobalPanelEnum = { }

local mt = {
    __index = function(t, k)
        include("UI.PanelRegisters.PanelRegister_" ..k)  -- 文件和类不是一对一的关系，一加载不能释放
        return rawget(t, k)
    end
}
setmetatable(GlobalPanelEnum, mt)
-----------------------------------------------------------------

UI = {}
require 'UI.Components.LuaUiBase'
require "UI.Components.PanelCallbacks"
require 'UI.Base.BasePanel'
require 'UI.Base.PanelItemBase'
require 'UI.Base.BaseMediator'
require "UI.UITool"
require "UI.UIContext"