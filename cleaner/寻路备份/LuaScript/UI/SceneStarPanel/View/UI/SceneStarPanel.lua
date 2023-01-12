--insertWidgetsBegin
--    btn_rewardMask    text_get2    text_tip1    text_tip2
--    text_tip3    text_tip4    text_tip5    c2_title
--    text_title    c2_rightTop    btn_rewardTip    img_starProcess
--    c2_time    text_time    c2_outTime    text_outTime
--    text_starCount    c2_rewardRoot    text_tip6    text_tip7
--    btn_get1    btn_get2    btn_close    go_get1
--    go_get2    text_get1    go_flyRewardPos    c2_get
--    text_get
--insertWidgetsEnd

--insertRequire
local _SceneStarPanelBase = require "UI.SceneStarPanel.View.UI.Base._SceneStarPanelBase"
local SceneStarItem = require("UI.SceneStarPanel.View.UI.StarItem")
local SceneStarRewardItem = require("UI.SceneStarPanel.View.UI.SceneStarRewardItem")

---@class SceneStarPanel:_SceneStarPanelBase
local SceneStarPanel = class(_SceneStarPanelBase)

function SceneStarPanel:ctor()
    self.updateTimeId = nil
end

function SceneStarPanel:onAfterBindView()
    self:SetData()
end

function SceneStarPanel:SetData()
    local sceneId = App.scene:GetCurrentSceneId()
    local mapStarManager = AppServices.MapStarManager
    local taskConfig = mapStarManager:GetSceneTaskConfig(sceneId)
    self.boxRoot = self.gameObject.transform:Find("boxRoot").gameObject
    ---@type SceneStarItem[]
    self.taskAry = {}
    for i = 1, 3 do
        local go = self.gameObject.transform:Find("c2_stars/star"..i).gameObject
        if i > #taskConfig then
            go:SetActive(false)
        else
            self.taskAry[i] = SceneStarItem.new(go, taskConfig[i], i)
        end
    end
    self.titleStarAry = {}
    for i = 1, 3 do
        self.titleStarAry[i] = {}
        --self.titleStarAry[i].go_starLight = self.gameObject.transform:Find(string.format("star%s/go_starLight", i)).gameObject
        --self.titleStarAry[i].go_starGrey = self.gameObject.transform:Find(string.format("star%s/go_starGrey", i)).gameObject
        self.titleStarAry[i].anim = self.gameObject.transform:Find(string.format("star%s/go_starLight", i)):GetComponent(typeof(Animator))
        --self.titleStarAry[i].anim:ResetTrigger()
    end
    local sceneCfg = AppServices.Meta:GetSceneCfg(sceneId)
    --[[self.rewardAry1 = {}
    for i = 1, 4 do
        local go = self.gameObject.transform:Find("totalRewards/reward"..i).gameObject
        if i > #sceneCfg.allStarReward then
            go:SetActive(false)
        else
            self.rewardAry1[i] = SceneStarRewardItem.new(go, {ItemId = sceneCfg.allStarReward[i][1], Amount = sceneCfg.allStarReward[i][2]})
        end
    end--]]
    self.rewardAry2 = {}
    for i = 1, 4 do
        local go = self.c2_rewardRoot.transform:Find("timeRewards/reward"..i).gameObject
        if i > #sceneCfg.timeLimitedReward then
            go:SetActive(false)
        else
            self.rewardAry2[i] = SceneStarRewardItem.new(go, {ItemId = sceneCfg.timeLimitedReward[i][1], Amount = sceneCfg.timeLimitedReward[i][2]}, false)
        end
    end
    local limitTime = mapStarManager:GetLimitTime(sceneId) / 1000
    local difftime
    local setLimitTime = function()
        difftime = math.floor(limitTime - TimeUtil.ServerTime())
        if not AppServices.MapStarManager:IsLimitTimeRewarded(sceneId) and difftime >= 0 then
            local hour = math.floor(difftime / 3600)
            local min = math.floor((difftime - hour * 3600) / 60)
            local sec = math.fmod(difftime, 60)
            self.text_time.text = string.format("%02d:%02d:%02d", hour, min, sec)
            --[[if hour < 1 then
                self.text_time.color = Color.red
            end--]]
        else
            if self.updateTimeId ~= nil then
                WaitExtension.CancelTimeout(self.updateTimeId)
                self.updateTimeId = nil
            end
            self:SetTimeRewardState(sceneId, difftime)
        end
    end
    setLimitTime()
    if difftime >= 0 then
        self.updateTimeId = WaitExtension.InvokeRepeatingNextFrame(setLimitTime, 1)
    end
    --[[if mapStarManager:IsCompleteRewarded(sceneId) then
        self.btn_get1.gameObject:SetActive(false)
        self.go_get1.gameObject:SetActive(false)
        self.text_get1.gameObject:SetActive(true)
    else
        local canGetCompleteReward = mapStarManager:CanGetCompleteReward(sceneId)
        self.btn_get1.gameObject:SetActive(canGetCompleteReward)
        self.go_get1.gameObject:SetActive(not canGetCompleteReward)
        self.text_get1.gameObject:SetActive(false)
    end--]]
    self:SetTimeRewardState(sceneId, difftime)
    --local starCount = mapStarManager:GetSceneStar(sceneId)
    WaitExtension.InvokeDelay(function ()
        local lightCount = 0
        for i = 1, #self.titleStarAry do
            local titleStar = self.titleStarAry[i]
            local isStarRewarded = mapStarManager:IsStarRewarded(sceneId, i)
            --titleStar.go_starLight:SetActive(isStarRewarded)
            --titleStar.go_starGrey:SetActive(not isStarRewarded)
            if isStarRewarded then
                titleStar.anim:SetTrigger("repaired")
                lightCount = lightCount + 1
            else
                titleStar.anim:SetTrigger("ruined")
            end
        end
        self.img_starProcess.fillAmount = lightCount / SCENE_STAR_NUM
        self.text_starCount.text = lightCount .. "/" .. SCENE_STAR_NUM
    end)
    --GameUtil.FitTextContentSize(self.text_title)
    self.text_title.text = Runtime.Translate("UI_star_name", {name = Runtime.Translate(sceneCfg.nameStr)})
    self.text_tip7.text = Runtime.Translate("UI_star_reward_limit")
    self.text_tip6.text = Runtime.Translate("UI_star_reward_limit_desc")
    self.text_outTime.text = Runtime.Translate("UI_star_reward_time_out")

    DcDelegates:Log(SDK_EVENT.scene_star_show,{
        sceneID = sceneId
    })
end

function SceneStarPanel:RefreshTask(starIndex, taskId)
    if self.taskAry[starIndex] ~= nil then
        self.taskAry[starIndex]:RefreshTask(taskId)
    end
end

function SceneStarPanel:SetTimeRewardState(sceneId, difftime)
    if AppServices.MapStarManager:IsLimitTimeRewarded(sceneId) then
        --self.btn_get2.gameObject:SetActive(false)
        --self.go_get2.gameObject:SetActive(true)
        self.c2_outTime.gameObject:SetActive(false)
        self.c2_get.gameObject:SetActive(true)
        self.c2_time:SetActive(false)
        self.c2_rightTop:SetActive(false)
    elseif difftime > 0 then
        self.c2_time:SetActive(true)
        self.c2_get.gameObject:SetActive(false)
        self.c2_outTime.gameObject:SetActive(false)
        self.c2_rightTop:SetActive(true)
    else
        --local canGetCompleteReward = AppServices.MapStarManager:CanGetLimitTimeReward(sceneId)
        --self.btn_get2.gameObject:SetActive(canGetCompleteReward)
        --self.go_get2.gameObject:SetActive(not canGetCompleteReward and difftime > 0)
        --self.text_outTime.gameObject:SetActive(not canGetCompleteReward and difftime <= 0)
        self.c2_get.gameObject:SetActive(false)
        self.c2_outTime.gameObject:SetActive(true)
        self.c2_time:SetActive(false)
        self.c2_rightTop:SetActive(true)
    end
end

function SceneStarPanel:ShowFlyStar(starIndex)
    local titleStar = self.titleStarAry[starIndex]
    titleStar.anim:SetTrigger("repairing")
end

function SceneStarPanel:Release()
    if self.updateTimeId ~= nil then
        WaitExtension.CancelTimeout(self.updateTimeId)
        self.updateTimeId = nil
    end
end

function SceneStarPanel:refreshUI()

end

function SceneStarPanel:ShowAllDone()
    if not self.arguments.isAuto then
        return
    end
    self.stars:SetActive(false)
    local sceneId = App.scene:GetCurrentSceneId()
    local isLimitDone = AppServices.MapStarManager:CanGetLimitTimeReward(sceneId)
    if isLimitDone then
        self.mapInfo_limitreward:SetActive(true)
        self.mapInfo_normal:SetActive(false)
        self.items:SetActive(true)
        AppServices.ItemIcons:SetSceneIcon(self.map_icon1, sceneId)
        local sceneConfig = AppServices.Meta:GetSceneCfg(sceneId)
        local rewards = sceneConfig.timeLimitedReward
        local coms = self:CopyComponent(self.limitreward_itemNode, self.layout_items, #rewards)
        for i, go in ipairs(coms) do
            local reward = rewards[i]
            local itemId, count = tostring(reward[1]), reward[2]
            local icon = find_component(go, "img_icon", Image)
            AppServices.ItemIcons:SetItemIcon(icon, itemId)
            local txt_num = find_component(go, "txt_num", Text)
            txt_num.text = "x".. count
        end
    else
        self.mapInfo_limitreward:SetActive(false)
        self.mapInfo_normal:SetActive(true)
        self.items:SetActive(false)
        AppServices.ItemIcons:SetSceneIcon(self.map_icon2, sceneId)
    end
    self.go_alldone:SetActive(true)
end

function SceneStarPanel:ShowAllDoneMapInfo()
    --[[if not self.arguments.isAuto then
        return
    end--]]
    self.btn_ok.gameObject:SetActive(false)
    local sceneId = App.scene:GetCurrentSceneId()
    local isLimitDone = AppServices.MapStarManager:CanGetLimitTimeReward(sceneId)
    if isLimitDone then
        self.mapInfo_limitreward:SetActive(true)
        self.mapInfo_normal:SetActive(false)
        self.items:SetActive(false)
        AppServices.ItemIcons:SetSceneIcon(self.map_icon1, sceneId)
    else
        self.mapInfo_limitreward:SetActive(false)
        self.mapInfo_normal:SetActive(true)
        self.items:SetActive(false)
        AppServices.ItemIcons:SetSceneIcon(self.map_icon2, sceneId)
    end
    self.go_alldone:SetActive(true)
end

function SceneStarPanel:ShowAllDoneReward()
    --[[if not self.arguments.isAuto then
        return {}
    end--]]
    local sceneId = App.scene:GetCurrentSceneId()
    local isLimitDone = AppServices.MapStarManager:CanGetLimitTimeReward(sceneId)
    if isLimitDone then
        self.items:SetActive(true)
        local sceneConfig = AppServices.Meta:GetSceneCfg(sceneId)
        local rewards = sceneConfig.timeLimitedReward
        local coms = self:CopyComponent(self.limitreward_itemNode, self.layout_items, #rewards)
        for i, go in ipairs(coms) do
            local reward = rewards[i]
            local itemId, count = tostring(reward[1]), reward[2]
            local icon = find_component(go, "img_icon", Image)
            AppServices.ItemIcons:SetItemIcon(icon, itemId)
            local txt_num = find_component(go, "txt_num", Text)
            txt_num.text = "x".. count
            go.transform.localScale = Vector3.zero
        end
        return coms
    end
    return {}
end

return SceneStarPanel
