local Character = require 'MainCity.Character.Base.Character'
local ShowTextAction = class(BaseFrameAction, "ShowTextAction")

function ShowTextAction:Create(params, finishCallback)
    local instance = ShowTextAction.new(params, finishCallback)
    return instance
end

function ShowTextAction:ctor(params, finishCallback)
    self.name = "ShowTextAction"
    local text = params["Text"]
    local delay = params["Delay"]
    local dir = params["Dir"]
    local width = params["Width"]
    local time = params["Time"]
    local person = params.person
    if width == nil then width = 200 end
    if dir == nil then
        dir = ""
    end

    self.delay = delay
    self.duration = time or 1
    self.person = person
    self.text = text
    self.dir = dir
    self.width = width
    self.finishCallback = finishCallback
    self.started = false
    self.reverse = params.Reverse or false

    local defaultX, defaultY = Character.GetTalkOffset(self.person)
    self.replace = params["Replace"] or {}
    self.offsetX = params["OffsetX"] or defaultX
    self.offsetY = params["OffsetY"] or defaultY

end

local function CalcDuration(stringLength)
    local currentLanguage = AppServices.User:GetLanguage()

    if currentLanguage ~= 'zh' then
        stringLength = stringLength / 2
    end
    if stringLength <= 5 then
        return 1
    elseif stringLength <= 20 then
        return 2
    else
        return 2.5
    end
end

function ShowTextAction:Awake()
    -- self.time = Time.time
    local text = Runtime.Translate(self.text, self.replace)
    local textLength = GameUtil.GetLocalizationCharCount(text)
    local duration = CalcDuration(textLength)
    GetPers(self.person):AddTalkAction(text, duration, self.offsetX, self.offsetY, self.reverse, self.delay, function()
        self.isFinished = true
    end )
end

function ShowTextAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function ShowTextAction:Reset()
    self.started = false
    self.isFinished = false
    -- self.time = Time.time
end

return ShowTextAction