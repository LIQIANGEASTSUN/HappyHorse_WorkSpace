local AvatarItem = class(nil, "AvatarItem")

function AvatarItem.Create(render, Id)
    local inst = AvatarItem.new()
    inst:Init(render, Id)
    return inst
end

function AvatarItem:ctor()
    self.render = nil
    self.textCom = nil
    self.imgAvatar = nil
end

function AvatarItem:Init(render, Id)
    self.Id = Id or 1
    self.render = render

    self.transform = self.render.transform:Find("go_av" .. tostring(self.Id))
    self.imageRectTransform = self.transform:GetComponent(typeof(RectTransform))
    self.image = self.transform:Find("image")
    self.image.gameObject:SetActive(false)
    self.bubble = self.transform:Find("bubble")
    self.spineParent = self.transform:Find("spineParent")
    self.oScale = self.image.localScale / 0.8
    self.grayScale = Vector3(0.875, 0.875, 0.875)
    self.mormalScale = Vector3(0.85, 0.85, 0.85)
    self.imgAvatar = self.image:GetComponent(typeof(Image))

    self.fader = self.transform:GetComponent(typeof(CS.BetaGame.BaseFader))

    self.enterPosLeft = Vector2(-513, 0)
    self.enterPosRight = Vector2(682, 0)

    if self.Id == 1 then
        self.startPos = self.enterPosLeft
    else
        self.startPos = self.enterPosRight
    end
    self.finalPos = Vector2(0, 0)
end

function AvatarItem:SetVisible(vis)
    self.imgAvatar:SetActive(vis)
end

local colorWhite = Color(1, 1, 1, 1)
local colorGrey = Color(126 / 255, 126 / 255, 126 / 255, 1)

function AvatarItem:SetTakeItemActive(active, isInit)
    if not self.takeItem or Runtime.CSNull(self.takeItem) then
        return
    end

    local images = self.takeItem:GetComponentsInChildren(typeof(Image))
    for i = 0, images.Length - 1 do
        local img = images[i]
        if active then
            if isInit then
                img.color = colorWhite
            else
                self.colorTween = img:DOColor(colorWhite, 0.25):SetEase(Ease.InSine)
            end
        else
            if isInit then
                img.color = colorGrey
            else
                self.colorTween = img:DOColor(colorGrey, 0.35):SetEase(Ease.InSine)
            end
        end
    end

    local offset = self.takeItem.transform:Find("offset")
    if active then
        if isInit then
            offset.localScale = self.mormalScale
        else
            self.scaleTween = offset:DOScale(self.mormalScale, 0.25)
        end
    else
        if isInit then
            offset.localScale = self.grayScale * 0.8
        else
            self.scaleTween = offset:DOScale(self.grayScale * 0.8, 0.35)
        end
    end
end

function AvatarItem:SetActive(active, isInit)
    if self.avatarType == AvatarType.Spine then
        if active then
            XGE.TweenExtension.ScreenPlayNormalSpine(self.spineParent.gameObject, self.oScale, isInit)
        else
            XGE.TweenExtension.ScreenPlayGreySpine(self.spineParent.gameObject, self.oScale, isInit)
        end
    elseif self.avatarType == AvatarType.Image then
        if active then
            XGE.TweenExtension.ScreenPlayNormalSpine(self.imgAvatar.gameObject, self.mormalScale, isInit)
        else
            XGE.TweenExtension.ScreenPlayGreySpine(self.imgAvatar.gameObject, self.grayScale, isInit) --这里C#里会缩放0.8倍
        end
        self:SetTakeItemActive(active, isInit)
    else
        if active then
            XGE.TweenExtension.ScreenPlayNormalGameObject(self.spineParent.gameObject, self.oScale, isInit)
        else
            XGE.TweenExtension.ScreenPlayGreyGameObject(self.spineParent.gameObject, self.oScale, isInit)
        end
    end
    if active then
        self.transform:SetSiblingIndex(2)
    end
end

function AvatarItem:SetPrefabMode(isPrefab)
    if isPrefab then
        self.image.gameObject:SetActive(false)
        self.spineParent:SetActive(true)
        self.isPrefab = true
    else
        self.image.gameObject:SetActive(true)
        self.spineParent:SetActive(false)
        self.isPrefab = false
    end
end

function AvatarItem:SetTakeItem(takeItemPath, takeItemOffset)
    if not takeItemPath or takeItemPath == "" or not self.imgAvatar then
        self.takeItem = nil
        return
    end
    local sg = self.imgAvatar:GetComponent(typeof(SkeletonGraphic))
    if not sg then
        return
    end

    self.takeItem = BResource.InstantiateFromAssetName(takeItemPath)
    self.takeItem.transform:SetParent(self.spineParent.transform, false)
    local offset = self.takeItem.transform:Find("offset")
    if takeItemOffset then
        offset.localPosition = Vector3(takeItemOffset.x, takeItemOffset.y, 0)
        offset.localRotation = Quaternion.Euler(0, 0, takeItemOffset.z)
    end
    local follower = self.takeItem:AddComponent(typeof(CS.Spine.Unity.BoneFollowerGraphic))
    follower.SkeletonGraphic = sg
    follower:SetBone("take_icon")
end

function AvatarItem:SetAvatar(avatar_uri, avatarType, spineAnimation, loop)
    self.avatarType = avatarType or AvatarType.Image
    local isPrefab = avatarType == AvatarType.Image or avatarType == AvatarType.Animator
    self:SetPrefabMode(isPrefab)
    if avatarType == AvatarType.Image then
        self.spineParent:RemoveAllChildren()
        self.spine = nil
        self.imgAvatar = BResource.InstantiateFromAssetName(avatar_uri)
        self.imgAvatar.transform:SetParent(self.spineParent.transform, false)
        GameUtil.PlaySpineAnimation(self.imgAvatar, spineAnimation, loop or false)
    else
        self.spineParent:RemoveAllChildren()
        local spine = BResource.InstantiateFromAssetName(avatar_uri)
        spine.transform:SetParent(self.spineParent, false)
        self.spine = spine
        if avatarType == AvatarType.Spine then
            GameUtil.PlaySpineAnimation(spine, spineAnimation, loop or false)
        elseif avatarType == AvatarType.Animator then
            spine:PlayAnim(spineAnimation)
        else
        end
    end
end

function AvatarItem:SetPerson(person)
    if self.person ~= person then
        self.hasReset = true
    end
    self.person = person
end

function AvatarItem:Enter(onFinish)
    if self.hasReset then
        self.fader:FadeIn(0, onFinish)
    else
        self.fader:FadeIn(0)
    end
end

function AvatarItem:PlayOutAnimation()
    local moveTime = 1
    self.fadeTween = GameUtil.DoFade(self.transform, 0, moveTime/2)
    if self.Id == 1 then
        self.anchorTween = self.imageRectTransform:DOAnchorPosX(self.imageRectTransform.anchoredPosition.x - 500, moveTime)
    else
        self.anchorTween = self.imageRectTransform:DOAnchorPosX(self.imageRectTransform.anchoredPosition.x + 500, moveTime)
    end
end

function AvatarItem:Destroy()
    if self.colorTween then
        self.colorTween:Kill()
        self.colorTween = nil
    end
    if self.scaleTween then
        self.scaleTween:Kill()
        self.scaleTween = nil
    end
    if self.anchorTween then
        self.anchorTween:Kill()
        self.anchorTween = nil
    end
    if self.fadeTween then
        self.fadeTween:Kill()
        self.fadeTween = nil
    end
end

return AvatarItem
