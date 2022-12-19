---@class ChatDB
local ChatDB = class()

function ChatDB.Create(zoneId, comicsId)
    local instance = ChatDB.new()
    instance:Init(zoneId, comicsId)
    return instance
end

function ChatDB:Init(zoneId, comicsId)
    self.zoneId = zoneId
    self.comicsId = comicsId
    print(zoneId, comicsId) --@DEL

    local comicsData = self:Load(zoneId, comicsId)
    self.bgImage = comicsData.BgImage
    self.ctxData = comicsData.Dialogues
    self.ctxIter = 1
end

function ChatDB:Load(zoneId, comicsId)
    local model_name = "Configs.ScreenPlays.Comics." ..zoneId .."." ..comicsId
    local dt = include(model_name)
    return dt
end

function ChatDB:Next()
    local dt = self.ctxData[self.ctxIter]
    self.ctxIter = self.ctxIter + 1
    return dt
end

function ChatDB:CurrentIndex()
    return self.ctxIter - 1
end

return ChatDB