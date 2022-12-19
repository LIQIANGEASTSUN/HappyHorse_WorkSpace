local Character = require 'MainCity.Character.Base.Character'

local AvatarItem = require "UI.ScreenPlays.UI.AvatarItem"

---@class ComicsPanel 剧情对话面板
local ComicsPanel = class(nil, "ComicsPanel")
function ComicsPanel.Create(params, OnFinished)
    local inst = ComicsPanel.new(params, OnFinished)
    inst:_Init()
    return inst
end

function ComicsPanel:ctor(params, OnFinished)
    self.render = nil
    self.textCom = nil
    self.chapter = params.chapter
    self.name = params.name
    self.OnFinishedCbk = OnFinished
    self.dontSetNpcIdle = params.dontSetNpcIdle or false
    self.bgImage = params.BgImage
    if params.dontKill then
        self.dontKill = true
    end
    self.render = params.render

    self.avatarItems = {}
    self.allAnimationAvatars = {}
    self.allTalkingAvatars = {}
    self.leftIn = false
    self.inAnim = false
end

function ComicsPanel:_Init()
    local ChatDB = require "UI.ScreenPlays.Data.ChatDB"
    self.db = ChatDB.Create(self.chapter, self.name)

    self.render.name = "ComicsPanel"
    self.render.gameObject:SetParentRect(App.scene.panelLayer.gameObject)

    local subPanel = self.render.transform:Find("SubPanel")
    Util.UGUI_AddButtonListener(subPanel, function()
        self:OnClickNext()
    end)
    subPanel:SetActive(true)

    self.go_text = subPanel:Find("go_text").gameObject
    self.animator_text = self.go_text:GetComponent(typeof(Animator))
    local txContent = self.go_text.transform:Find("txContent")
    self.textCom = txContent:GetComponent(typeof(Text))
    self.textCom.text = ""
    self.typeWriter = txContent:GetComponent(typeof(NS.TypeWriter))

    for i = 1, 3 do
        self.avatarItems[i] = AvatarItem.Create(subPanel, i)
    end

    local btnNext = self.go_text.transform:Find("btnNext")
    btnNext:GetComponent(typeof(Button)).onClick:AddListener(
        function()
            print("Click Comics") --@DEL
            self:NextComics()
        end
    )

    local showSkip = true -- AppServices.Meta:GetComicsSkipable()
    local btnSkip = find_component(self.render, "btnSkip")
    if showSkip then
        local skipText = find_component(btnSkip, "Text")
        Runtime.Localize(skipText, "UI_ComicsSkip_button")
        Util.UGUI_AddButtonListener(btnSkip, self.OnClickSkip, self)
        btnSkip:SetActive(true)
    else
        btnSkip:SetActive(false)
    end

    self.nameLabels = {}
    table.insert(self.nameLabels, self.go_text:FindComponentInChildren("Text1", typeof(Text)))
    table.insert(self.nameLabels, self.go_text:FindComponentInChildren("Text2", typeof(Text)))

    self.nameLabelBgs = {}
    table.insert(self.nameLabelBgs, self.go_text.transform:Find("AvatarBrand1"))
    table.insert(self.nameLabelBgs, self.go_text.transform:Find("AvatarBrand2"))

    self.bubbleImageObjects = {}
    for i = 1, 3 do
        table.insert(self.bubbleImageObjects, subPanel:Find("go_av" .. i .. "/bubble"))
    end

    for _, v in pairs(self.bubbleImageObjects) do
        v:SetActive(false)
    end

    self.bubbleSpines = {}
    self.bubbleImages = {}
    for i = 1, 3 do
        table.insert(self.bubbleSpines, self.bubbleImageObjects[i]:Find("Bubble"):GetComponent(typeof(SkeletonGraphic)))
        table.insert(self.bubbleImages, self.bubbleImageObjects[i]:Find("Image"):GetComponent(typeof(Image)))
    end

    -- self.atlas = AssetLoaderUtil.GetAsset("Prefab/SpriteAtlas/BubbleImageAtlas.spriteatlas")
    self:Enter()
end

function ComicsPanel:Enter()
    self.canClick = true
    self:NextComics(true)
end

function ComicsPanel:KillAllActions()
    print("KillAllActions", self.name, self.dontKill) --@DEL
    if self.allAnimationAvatars then
        for k, v in pairs(self.allAnimationAvatars) do
            App.scene.director:KillAllActionsByTag(self:GetTag(k))
            --GetPers(k):StopAllActionsAndBeginIdle(Character.defaultIdleName, self.dontKill)
            GetPers(k):PlayAnimation(Character.defaultIdleName)
        end
        self.allAnimationAvatars = {}
    end
end

function ComicsPanel:StopAllTalkingDots()
    if self.allTalkingAvatars then
        for k, v in pairs(self.allTalkingAvatars) do
            local person = GetPers(k)
            if person then
                person:InterruptTalkAction()
                person:EnableDotsMode(false)
            end
        end
    end
end

function ComicsPanel:SetName(index, str)
    if str ~= nil then
        self.nameLabels[index].text = str
        self.nameLabels[index]:SetActive(true)
        self.nameLabelBgs[index]:SetActive(true)
    else
        self.nameLabels[index].text = ""
        self.nameLabels[index]:SetActive(false)
        self.nameLabelBgs[index]:SetActive(false)
    end
end

function ComicsPanel:OnClickNext()
    if Runtime.CSNull(self.typeWriter.gameObject) then
        return
    end
    if not self.canClick then
        return
    end

    if self.inAnim then
        return
    end

    if self.typeWriter:IsFinished() then
        --self.go_text_fader:SetAlpha(0)
        --self.go_text_fader:FadeIn(0.35)
        self:NextComics()
    else
        self.typeWriter:HandleClick()
    end
end

local function GetNpcName(avatar)
    local getName = function(avatar_)
        if avatar_.Alias and string.len(avatar_.Alias) > 0 then
            return avatar_.Alias
        else
            local alias = CONST.GAME.NpcAlias[avatar_.Avatar]
            return alias or avatar_.Avatar
        end
    end

    local name = getName(avatar)
    local keyname = "dialog.name." .. name

    local localName = Runtime.Translate(keyname)
    if (localName == keyname) then
        return name
    else
        return localName
    end
end

local originalY = nil
local originalX = {}

function ComicsPanel:NextComics(isInit)
    if not self.canClick then
        return
    end

    if self.isLoading then
        return
    end

    if isInit == nil then
        isInit = false
    end

    local dialogue = self.db:Next()

    if self.db.bgImage and self.db.bgImage.IsEnabled and self.db:CurrentIndex() == self.db.bgImage.Start then
        if not self.hasImage then
            self.hasImage = true
            self.isLoading = true -- prevent fast clicks
            local asset_name = "Prefab/UI/ScreenPlays/Comics/Bgs/" .. self.db.bgImage.Name .. ".prefab"
            App.uiAssetsManager:LoadAssets({asset_name},
                function()
                    local img = BResource.InstantiateFromAssetName(asset_name)
                    img.transform:SetParent(self.render.transform, false)
                    img.transform:SetAsFirstSibling()
                    self.img = img
                    self.isLoading = false -- prevent fast clicks
                    if self.db.bgImage.IsSpine ~= false then
                        self.img:FindComponentInChildren("Image", typeof(CS.BetaGame.BaseFader)):FadeIn(0.5)
                        GameUtil.PlaySpineAnimation(
                            self.img.transform:Find("Spine").gameObject,
                            self.db.bgImage.InAnim,
                            false,
                            function()
                                GameUtil.PlaySpineAnimation(
                                    self.img.transform:Find("Spine").gameObject,
                                    self.db.bgImage.IdleAnim,
                                    self.db.bgImage.IdleLoop ~= false
                                )
                            end
                        )
                    else
                        self.img:PlayAnim(self.db.bgImage.InAnim)
                    end
                end
            )
        end
    elseif
        self.db.bgImage and self.db.bgImage.IsEnabled and
            (self.db:CurrentIndex() >= self.db.bgImage.End or not dialogue)
     then
        if self.hasImage then
            if self.db.bgImage.IsSpine ~= false then
                GameUtil.PlaySpineAnimation(
                    self.img.transform:Find("Spine").gameObject,
                    self.db.bgImage.OutAnim,
                    false,
                    function()
                        --Runtime.CSDestroy(self.img)
                    end
                )
                self.img:FindComponentInChildren("Image", typeof(CS.BetaGame.BaseFader)):FadeOut(0.5)
            else
                self.img:PlayAnim(self.db.bgImage.OutAnim)
            end
            self.hasImage = false
        end
    end

    if not dialogue then
        if self.dontSetNpcIdle == false then
            self:KillAllActions()
        end
        self:StopAllTalkingDots()
        Runtime.InvokeCbk(self.OnFinishedCbk)
        self.animator_text:SetTrigger("Out")
        -- avatar
        for i = 1, 3 do
            self.avatarItems[i]:PlayOutAnimation()
        end
        self.go_text:SetActive(false)
        WaitExtension.SetTimeout(function()
            self:Destroy()
        end,
        0.333)
        return
    end

    -- avatar
    for i = 1, 3 do
        self.avatarItems[i]:SetVisible(false)
    end

    local sz = math.max(#dialogue.Avatars, 1)
    local name1, name2

    local counter = 0
    local total = 0
    local function onFinish()
        counter = counter + 1
        if counter >= total then
            self.canClick = true
        end
    end
    for i = 1, 3 do
        self.bubbleImageObjects[i]:SetActive(false)
    end
    local leftIn = false

    for idx = 1, sz do
        -- place
        local avatar = dialogue.Avatars[idx]
        local posIndex = avatar.Index or 1
        local item = self.avatarItems[posIndex]

        if posIndex == 1 and avatar.Action == "Active" then
            name1 = GetNpcName(avatar) --avatar.Avatar
            leftIn = true
        elseif posIndex == 2 and avatar.Action == "Active" then
            name2 = GetNpcName(avatar) --avatar.Avatar
        elseif posIndex == 3 and avatar.Action == "Active" and not name2 then
            name2 = GetNpcName(avatar) -- avatar.Avatar
        end

        if avatar.Action == "Active" then
            self.allTalkingAvatars[avatar.Avatar] = true
        else
            self.allTalkingAvatars[avatar.Avatar] = false
        end

        if avatar.BubbleImage and string.len(avatar.BubbleImage) > 0 then
            self.bubbleImageObjects[posIndex]:SetActive(true)
            -- self.bubbleImages[posIndex].sprite = self.atlas:GetSprite(avatar.BubbleImage)
            self.bubbleImages[posIndex] = AppServices.ItemIcons:PackBubbleImages(avatar.BubbleImage, self.bubbleImages[posIndex])
        else
            self.bubbleImageObjects[posIndex]:SetActive(false)
        end

        -- dont blame me... they (you know who) demanded
        if not originalY then
            originalY = self.bubbleImageObjects[posIndex].transform.anchoredPosition.y
        end
        if not originalX[posIndex] then
            originalX[posIndex] = self.bubbleImageObjects[posIndex].transform.anchoredPosition.x
        end

        if avatar.Avatar == "Petdragon" then
            local pos = self.bubbleImageObjects[posIndex].transform.anchoredPosition
            if posIndex == 1 then
                pos.x = originalX[posIndex] - 45
            else
                pos.x = originalX[posIndex] + 45
            end
            pos.y = originalY - 45
            self.bubbleImageObjects[posIndex].transform.anchoredPosition = pos
        else
            local pos = self.bubbleImageObjects[posIndex].transform.anchoredPosition
            pos.x = originalX[posIndex]
            pos.y = originalY
            self.bubbleImageObjects[posIndex].transform.anchoredPosition = pos
        end

        -- deco
        if (avatar and avatar.Avatar) then
            total = total + 1

            local avatarType = avatar.AvatarType
            if not avatarType or string.len(avatarType) == 0 then
                avatarType = AvatarType.Image
            end

            local avatar_uri
            if avatarType == AvatarType.Image then
                -- avatar_uri = string.format(CONST.ASSETS.G_AVATAR_URI, avatar.Avatar, avatar.Emotion)
                avatar_uri = string.format(CONST.ASSETS.G_AVATAR_URI, avatar.Avatar)
            else
                avatar_uri = string.format(CONST.ASSETS.G_AVATAR_SPINE_URI, avatar.Avatar, avatar.Emotion)
            end

            local function OnLoadFinish()
                if self.isDisposed then
                    return
                end
                console.print("LoadFinished:" .. avatar_uri) --@DEL
                item:SetVisible(true)
                if not avatar.AvatarType or avatar.AvatarType == "" then
                    avatar.AvatarType = AvatarType.Image
                end
                if avatar.AvatarType == AvatarType.Image then
                    item:SetAvatar(avatar_uri, avatarType, avatar.Emotion, true)
                    item:SetTakeItem(avatar.takeItemPath, avatar.takeItemOffset)
                else
                    item:SetAvatar(avatar_uri, avatarType, avatar.Animation, avatar.AnimationLoop)
                end
                item:SetPerson(avatar.Avatar)
                -- show
                if (avatar.Action or "") == "Active" then
                    item:SetActive(true, isInit)
                    item:Enter(onFinish)
                else
                    item:SetActive(false, isInit)
                    item:Enter()
                    onFinish()
                end
            end

            local paths = {
                avatar_uri
            }

            --test
            -- if avatar.Avatar == "Player" then
            --     avatar.Emotion = "take"
            --     avatar.takeItem = "take_item1"
            --     avatar.takeItemOffset.x = 100
            --     avatar.takeItemOffset.y = 100
            --     avatar.takeItemOffset.z = 100
            -- end
            --test
            if avatar.takeItem and avatar.takeItem ~= "" then
                avatar.takeItemPath = string.format("Prefab/Animation/take_items/%s.prefab", avatar.takeItem)
                table.insert(paths, avatar.takeItemPath)
            end

            App.comicsTextureLoader:LoadAssets(paths, OnLoadFinish, nil)
        else
            item:SetVisible(false)
        end
    end

    for avatar, talking in pairs(self.allTalkingAvatars) do
        local person = nil --GetPers(avatar)
        if person then
            if talking then
                local defaultX, defaultY = Character.GetTalkOffset(avatar)
                person:AddTalkAction("", 999, defaultX, defaultY)
                person:EnableDotsMode(true)
            else
                person:InterruptTalkAction()
                person:EnableDotsMode(false)
            end
        end
        -- 说完话重置，如果下一个有配置就走配置，没有配置就是false
        self.allTalkingAvatars[avatar] = false
    end

    local function panelAnimFinished()
        if self.isDisposed then
            return
        end
        local paragraphs = {paragraphs = dialogue.Paragraphs}
        self.textCom.gameObject:SetActive(true)
        self.typeWriter:SetParagraphs(table.serialize(paragraphs))

        self:ProcessActions(dialogue.Actions)
        self.inAnim = false
    end

    if isInit or self.leftIn ~= leftIn then
        self.inAnim = true
        self.leftIn = leftIn

        self:SetName(1, name1)
        self:SetName(2, name2)
        self.textCom.gameObject:SetActive(false)

        if self.leftIn then
            self.animator_text:SetTrigger("LeftIn")
        else
            self.animator_text:SetTrigger("RightIn")
        end

        WaitExtension.SetTimeout(panelAnimFinished, 0.367)
    else
        self:SetName(1, name1)
        self:SetName(2, name2)
        panelAnimFinished()
    end
end

function ComicsPanel:ProcessActions(actions)
    if not actions then
        return
    end
    for i = 1, #actions do
        local action = actions[i]
        local type = string.lower(action.Type)
        if type == "animation" then
            self:ProcessAnimation(action)
        end
    end
end

function ComicsPanel:GetTag(person)
    return string.format("Comics_%s_Animation", person)
end

function ComicsPanel:ProcessAnimation(anim)
    local animations = anim.Animations
    local repeatTimes = anim.RepeatTimes or 0
    if not App.scene.director then
        self:Destroy()
        return
    end
    App.scene.director:KillAllActionsByTag(self:GetTag(anim.Avatar))
    --GetPers(anim.Avatar):StopAllActionsAndBeginIdle(Character.defaultIdleName)

    local outerAction = Spawn:Create()
    outerAction:SetTag(self:GetTag(anim.Avatar))
    if anim.LookTarget and anim.LookTarget.Type ~= "None" then
        local position
        if anim.LookTarget.Type == "Person" then
            print("***************************", anim.LookTarget.Name, "***************************") --@DEL
            local person = GetPers(anim.LookTarget.Name)
            console.assert(person, "not found " .. anim.LookTarget.Name)
            position = person:GetPosition()
        else
            position = Vector3(anim.LookTarget.Position.x or 0, 0, anim.LookTarget.Position.y or 0)
        end
        outerAction:Append(Actions.LookAtPositionAction:Create(anim.Avatar, position, 0.4))
    end

    if #animations > 0 then
        local sequence = Sequence:Create()
        for i, v in ipairs(animations) do
            self.allAnimationAvatars[anim.Avatar] = true
            sequence:Append(Actions.PlayAnimationAction:Create(anim.Avatar, v))
            print("Playing ", anim.Avatar, v) --@DEL
        end

        if repeatTimes > 0 then
            local repeatAction = Repeat:Create(repeatTimes)
            repeatAction:SetInnerAction(sequence)
            outerAction:Append(repeatAction)
        else
            outerAction:Append(sequence)
        end
        App.scene:AddFrameAction(outerAction)
    end
end

function ComicsPanel:OnClickSkip()
    if not self.canClick then
        return
    end
    if self.isLoading then
        return
    end
    ---comics_skip
    local params = {
        comicsid = self.name
    }
    DcDelegates:Log(SDK_EVENT.comics_skip, params)
    if self.dontSetNpcIdle == false then
        self:KillAllActions()
    end
    self:StopAllTalkingDots()
    Runtime.InvokeCbk(self.OnFinishedCbk)
    if Runtime.CSValid(self.animator_text) then
        self.animator_text:SetTrigger("Out")
    end
    -- avatar
    for i = 1, 3 do
        self.avatarItems[i]:PlayOutAnimation()
    end
    if Runtime.CSValid(self.go_text) then
        self.go_text:SetActive(false)
    end
    WaitExtension.SetTimeout(function()
        self:Destroy()
    end,
    0.333)
end

function ComicsPanel:Destroy()
    if Runtime.CSValid(self.typeWriter) then
        self.typeWriter:Destroy()
    end

    self.isDisposed = true

    for i = 1, 3 do
        self.avatarItems[i]:Destroy()
    end
    Runtime.CSDestroy(self.render)
    self.render = nil
end

return ComicsPanel
