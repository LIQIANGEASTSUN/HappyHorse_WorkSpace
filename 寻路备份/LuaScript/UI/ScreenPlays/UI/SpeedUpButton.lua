---@class SpeedUpButton
local SpeedUpButton = class()

function SpeedUpButton:Create(gameObject, speed)
    local instance = SpeedUpButton.new(gameObject, speed)
    return instance
end

function SpeedUpButton:ctor(gameObject, speed)
    self.gameObject = gameObject
    self.go_speed1 = self.gameObject:FindGameObject("img_speed1")
    self.go_speed2 = self.gameObject:FindGameObject("img_speed2")
    self.text_speed1 = self.go_speed1:FindComponentInChildren("Text", typeof(Text))
    self.text_speed2 = self.go_speed2:FindComponentInChildren("Text", typeof(Text))

    self.speedMutiple = speed

    if not self:Enabled() then
        return
    end

    Util.UGUI_AddButtonListener(self.gameObject, self.onClick, self)
end

function SpeedUpButton:Enabled()
    return CONST.RULES.IsDramaSpeedupEnabled()
end

function SpeedUpButton:Show()
    if not self:Enabled() then
        return
    end
    self.text_speed1.text = Runtime.Translate("ui.play_speed_normal")
    self.text_speed2.text = Runtime.Translate("ui.play_speed_high")
    self.gameObject:SetActive(true)
    self:SetTimeScale(self.speedMutiple)
end

function SpeedUpButton:Hide()
    self.gameObject:SetActive(false)
    self:SetTimeScale(1)
end

function SpeedUpButton:SetTimeScale(speed)
    if not self:Enabled() then
        return
    end
    Time.timeScale = speed
    self.go_speed1:SetActive(speed > 1)
    self.go_speed2:SetActive(speed <= 1)
end

function SpeedUpButton:onClick()
    if self.speedMutiple == 1 then
        self.speedMutiple = 3.5
    else
        self.speedMutiple = 1
    end
    self:SetTimeScale(self.speedMutiple)
    AppServices.User.Default:SetKeyValue("dramaSpeed", self.speedMutiple, true)
end

function SpeedUpButton:Destroy()
    self:onDestroy()
end

function SpeedUpButton:onDestroy()
    self.speedMutiple = nil
    Runtime.CSDestroy(self.gameObject)
    Time.timeScale = 1
end

return SpeedUpButton
