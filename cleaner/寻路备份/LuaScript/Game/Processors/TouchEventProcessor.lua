local TouchEventProcessor = {
    goEffect = nil
}

function TouchEventProcessor:Create()
    local CLICK_EFFECT_NAME = "Prefab/UI/Common/System/UIClickEffect.prefab"
    App.uiAssetsManager:LoadAssets({CLICK_EFFECT_NAME}, function()
        self.goEffect = BResource.InstantiateFromAssetName(CLICK_EFFECT_NAME)
        GameObject.DontDestroyOnLoad(self.goEffect)
    end)
    return self
end

-- 添加一个点击特效
function TouchEventProcessor:Update()
    if not CS.UnityEngine.Input.GetMouseButtonDown(0) then
        return
    end
    if Runtime.CSNull(Camera.main) or Runtime.CSNull(self.goEffect) then
        return
    end
    self.goEffect:SetActive(false)
    local worldPos = Camera.main:ScreenToWorldPoint(CS.UnityEngine.Input.mousePosition)
    self.goEffect:SetPosition(worldPos:Flat())
    self.goEffect:SetActive(true)
end

return TouchEventProcessor:Create()