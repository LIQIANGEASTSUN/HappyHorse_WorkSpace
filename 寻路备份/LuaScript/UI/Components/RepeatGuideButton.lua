local RepeatGuideButton = class(LuaUiBase)

function RepeatGuideButton:Create(gameObject)
    local instance = RepeatGuideButton.new()
    instance:Init(gameObject)
    return instance
end

function RepeatGuideButton:Init(gameObject)
    self.gameObject = gameObject
    self.fader = gameObject:GetComponent(typeof(CS.BetaGame.BaseFader))
end

function RepeatGuideButton:Show(value, instant)
    if self.isInAnim then return end
    self.isInAnim = true
    if instant then
        self.isInAnim = false
        self.gameObject:SetActive(value == true)
    else
        if value then
            self.fader:FadeIn(0.3, function()
                self.isInAnim = false
                self.gameObject:SetActive(true)
            end)

        else
            self.fader:FadeOut(0.3, function()
                self.isInAnim = false
                self.gameObject:SetActive(false)
            end)
        end
    end

end

return RepeatGuideButton