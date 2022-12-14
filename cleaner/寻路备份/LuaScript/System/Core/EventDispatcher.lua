-------------------------------------------------------------------------
--  Class include: DisplayEvents, DisplayEvent, EventDispatcher, GlobalEventDispatcher
-------------------------------------------------------------------------
--
-- Event ---------------------------------------------------------
--
local Event = class()
function Event:ctor(name, data, observerObj)
    self.name = name
    self.data = data
    self.observerObj = observerObj
end
function Event:dispose()
    self.name = nil
    self.observerObj = nil
    self.data = nil
end

function Event:toString()
    return string.format("Event [%s]", self.name and self.name or "nil")
end

-- members
---@class EventDispatcher
local EventDispatcher = class()

-- initialize
function EventDispatcher:ctor()
    self.class = EventDispatcher
    self.eventHandlers = {} -- of <{function,function...}>
end

-- public methods
function EventDispatcher:toString()
    return "EventDispatcher"
end

--Dispatches an event into the event flow.
function EventDispatcher:dispatchEvent(eventName, params)
    -- print("[EventDispatcher] dispatchEvent", eventName) --@DEL
    local handlers = self.eventHandlers[eventName]
    if (not handlers) or type(handlers) ~= "table" then
        return
    end

    -- by default, iterator throw a table is a non-atom operation,
    -- to avoid modify table while iteration (by callback), we need a atom-table or just clone the old one as I did.
    local cachedHandlers = {}
    for observer, callback in pairs(handlers) do
        cachedHandlers[observer] = callback
    end

    for observer, callback in pairs(cachedHandlers) do
        Runtime.InvokeCbk(callback, Event.new(eventName, params, observer))
    end
end

function EventDispatcher:addObserver(observer, eventName, handler)
    -- print("[EventDispatcher] addObserver", eventName) --@DEL
    local eventHandler = self.eventHandlers[eventName] or {}
    eventHandler[observer] = handler
    self.eventHandlers[eventName] = eventHandler
end

function EventDispatcher:removeObserver(observer, eventName)
    -- print("[EventDispatcher] removeObserver", eventName) --@DEL
    local eventHandler = self.eventHandlers[eventName] or {}
    eventHandler[observer] = nil
end

--atlis
--EventDispatcher.dp = EventDispatcher.dispatchEvent
--EventDispatcher.he = EventDispatcher.hasEventListener
--EventDispatcher.hn = EventDispatcher.hasEventListenerByName
--EventDispatcher.ad = EventDispatcher.addEventListener
--EventDispatcher.rm = EventDispatcher.removeEventListener
--EventDispatcher.rma = EventDispatcher.removeAllEventListeners
--

GlobalEvents = {
    MAIN_CITY_FULLY_LOADED = "GlobalEvents_MAIN_CITY_FULLY_LOADED",
    DRAMA_STARTED = "GlobalEvents_DRAMA_STARTED",
    SHOWING_PANEL = "GlobalEvents_SHOWING_PANEL",
    CLOSING_PANEL = "GlobalEvents_CLOSING_PANEL",
    CAMERA_ZOOM = "GlobalEvents_CAMERA_ZOOM",
    MODIFY_NAME = "GlobalEvents_MODIFY_NAME",
    DAY_SPAN = "GlobalEvents_DAY_SPAN", -- ?????????????????????????????????19??????????????????????????????
    SWITCH_SCENECAMERA = "GlobalEvents_SWITCH_SCENECAMERA", -- ???????????????????????????
    ShutdownActivity = "GlobalEvents_ShutdownActivity", -- ????????????
    OpenActivity = "GlobalEvents_OpenActivity", -- ????????????
    LoginIn = "GlobalEvents_LoginIn", -- ????????????
    USE_PROP = "GlobalEvents_USE_PROPS",
    ACTIVE = "GlobalEvents_ACTIVE", -- ???????????????????????????????????????
    PAY_SUCCESS = "GlobalEvents_PAY_SUCCESS",
    USE_BUFF = "GlobalEvents_USE_BUFF",
    RECT_CHANGED = "GlobalEvents_RECT_CHANGED",
    COMBINE_SUC = "GlobalEvents_COMBINE_SUC", --????????????
    COLLECT_BUILDING_REWARD = "GlobalEvents_COLLECT_BUILDING_REWARD", --??????????????????
    GUIDE_COMPLETE = "GlobalEvents_GUIDE_COMPLETE", --????????????(??????????????????????????????????????????, ?????????????????????????????????)
    ShowBindingTip = "GlobalEvents_ShowBindingTip",
    HideBindingTip = "GlobalEvents_HideBindingTip",
    DoubleClickCollider = "GlobalEvents_DoubleClickCollider",
    ClickNothing = "GlobalEvents_ClickNothing",
    --????????????
    ReissuePurchase = "GlobalEvents_ReissuePurchase",
    TEAM_JOIN = "GlobalEvents_TEAM_JOIN",
    TEAM_QUIT = "GlobalEvents_TEAM_QUIT"
}

local GlobalEventDispatcher = class(EventDispatcher)

return GlobalEventDispatcher.new()
