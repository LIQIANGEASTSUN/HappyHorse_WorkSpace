-- IAP预先启动
local RequestIAPProcessor = {}

function RequestIAPProcessor.Start(OnSuccessed, OnFailed)
    -- 未激活IAP
    if not RuntimeContext.IAP_ENABLE then
        local description = Runtime.Translate("ui_not_open")
        AppServices.UITextTip:Show(description)
        return Runtime.InvokeCbk(OnFailed)
    end

    -- 检查商品列表是否拉取成功，失败了则重拉
    if not AppServices.ProductManager:CheckFetch() then
        local description = Runtime.Translate("UI_wait_shop_initialize")
        AppServices.UITextTip:Show(description)
        return Runtime.InvokeCbk(OnFailed)
    end

    return Runtime.InvokeCbk(OnSuccessed)
end

return RequestIAPProcessor