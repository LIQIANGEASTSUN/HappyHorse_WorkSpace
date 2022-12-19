---@class HomeSceneTopIconBase:LuaUiBase
HomeSceneTopIconBase = class(LuaUiBase, "HomeSceneTopIconBase")

function HomeSceneTopIconBase:ctor()
    self.isHided = false
    self.addValueUpdate = nil
end

function HomeSceneTopIconBase:ShowExitAnim(instant, finishCallback)
    DOTween.Kill(self.rectTransform)
    local tarPos = self:GetOutsideAnchoredPosition()
    if instant then
        self.isHided = true
        self.rectTransform.anchoredPosition = tarPos
        Runtime.InvokeCbk(finishCallback)
    else
        GameUtil.DoAnchorPos(self.rectTransform, tarPos, 0.5, function()
            self.isHided = true
                Runtime.InvokeCbk(finishCallback)
                if self.autoHideAfterExitOnce then
                    self.gameObject:SetActive(false)
                    self.autoHideAfterExitOnce = nil
                end
        end)
    end
    self.isShowing = false
end

function HomeSceneTopIconBase:ShowEnterAnim(instant, finishCallback)
    DOTween.Kill(self.rectTransform, false)
    local tarPos = self:GetInsideAnchoredPosition()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(true)
        --self:Refresh()    --经测试已经可以在flyAnimation中正确刷新。
    end
    if instant then
        self.isHided = false
        self.rectTransform.anchoredPosition = tarPos
        Runtime.InvokeCbk(finishCallback)
    else
        GameUtil.DoAnchorPos(self.rectTransform, tarPos, 0.2)
        self.isHided = false
        if finishCallback and type(finishCallback) == "function" then
            WaitExtension.SetTimeout(finishCallback, 0.2)
        end
    end
    self.isShowing = true
end

function HomeSceneTopIconBase:SetParent(parent)
    self.gameObject:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function HomeSceneTopIconBase:GetInsideAnchoredPosition()
    if not self.originalAnchoredPos then
        self.originalAnchoredPos = self.rectTransform.anchoredPosition
    end
    return self.originalAnchoredPos
end
function HomeSceneTopIconBase:GetOutsideAnchoredPosition()
    if not self.outsideAnchoredPos then
        local orgPos = self:GetInsideAnchoredPosition()
        self.outsideAnchoredPos = Vector2(orgPos.x, orgPos.y + 200)
    end
    return self.outsideAnchoredPos
end

-- 主要用于和HeadInfoView的互斥
function HomeSceneTopIconBase:SetActive(val)
    self.gameObject:SetActive(val)
end

--一点也不能动，猜猜都发生了什么
function HomeSceneTopIconBase:SetAnchorPositionOffset(offsetVec2)
    local y = self.rectTransform.anchoredPosition.y
    local newPosition = self:GetInsideAnchoredPosition() + offsetVec2

    self.originalAnchoredPos.y = newPosition.y
    self.originalAnchoredPos.x = newPosition.x
    newPosition.y = y
    self.rectTransform.anchoredPosition = newPosition
end

function HomeSceneTopIconBase:ShowValueWithAnimation(text_number, fromValue, toValue, delay, animFinishCallback)
    delay = delay or 0
    local t = 0
    local speed = 2
    local interval = 0.025
    local function set()
        t = t + interval * speed
        local newValue = math.lerp(fromValue, toValue, t)

        if Runtime.CSValid(text_number) then
            text_number.text = tostring(math.floor(newValue))
        else
            t = 2
        end
        if t >= 1 then
            WaitExtension.SetTimeout(function()
                Runtime.InvokeCbk(animFinishCallback)
            end,0.5)
            self:StopValueWithAnimation()
        end
    end

    -- 首先要释放掉旧的定时器
    self:StopValueWithAnimation()
    self.addValueUpdate = WaitExtension.InvokeRepeating(set, delay, interval)
end

function HomeSceneTopIconBase:StopValueWithAnimation()
    if self.addValueUpdate then
        WaitExtension.CancelTimeout(self.addValueUpdate)
        self.addValueUpdate = nil
    end
end

function HomeSceneTopIconBase:Refresh(valueWithAnimation)
end
function HomeSceneTopIconBase:TweenToCount(toValue)
end
function HomeSceneTopIconBase:TweenToCurrentCount()
end
function HomeSceneTopIconBase:SetValue(value)
end

function HomeSceneTopIconBase:SetInteractable(interactable)
    self.interactable = interactable
end

function HomeSceneTopIconBase:Unload()
end

function HomeSceneTopIconBase:GetMainIconGameObject()
    console.assert(false, "Not Implement Exception!!!")
end

function HomeSceneTopIconBase:NeedChangeParent()
    return false
end

return HomeSceneTopIconBase