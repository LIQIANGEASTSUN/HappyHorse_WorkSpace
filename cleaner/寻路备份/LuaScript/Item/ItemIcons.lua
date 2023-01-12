---@class ItemIcons
local ItemIcons = {}

local PackTexture = CS.DynamicAtlasUtil.PackTexture
local ChangeComponent = CS.DynamicAtlasUtil.ChangeComponent
-- local G_ICONS_BUBBLES_URI = "Prefab/RuntimeIcons/Bubble/%s.png"

local function GetBuildingIconPath(name)
    return string.format(CONST.ASSETS.G_ICONS_BUILDINGS_URI, name)
end

local AtlasNames = {
    Building = "BuildingIcons",
    Mission = "MissionIcons",
    Bubble = "BubbleImages",
}

function ItemIcons:Initialize()
    self.itemAtlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    self.taskAtlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_TASK_ICONS)
end

function ItemIcons:GetAtlas()
    return self.itemAtlas
end

function ItemIcons:GetFriendIconSprite(spriteName)
    return self.itemAtlas:GetSprite(spriteName)
end

function ItemIcons:GetSprite(itemId)
    local spriteName = AppServices.Meta:GetItemIcon(itemId)
    local sprite = self.itemAtlas:GetSprite(spriteName)
    if sprite == nil then
        console.error("GetSprite ======> No sprite found! id:", itemId, "  name:", spriteName) --@DEL
        local iconPath = GetBuildingIconPath("default")
        sprite = App.uiAssetsManager:GetAsset(iconPath)
    end
    return sprite
end

function ItemIcons:GetSpriteByName(spriteName)
    local sprite = self.itemAtlas:GetSprite(spriteName)
    if Runtime.CSNull(sprite) then
        console.error("GetSpriteByName ======> ", spriteName, " has no sprite found") --@DEL
        local iconPath = GetBuildingIconPath(spriteName)
        sprite = App.uiAssetsManager:GetAsset(iconPath)
    -- sprite = self.buildingAtlas:GetSprite("default")
    end
    return sprite
end

---根据传入参数动态打建筑图标图集
---@param itemId string 建筑id
---@param viewCom Component 渲染组件 [Image, RawImage, SpriteRenderer, MeshRenderer]
---@return Component 新的渲染组件
function ItemIcons:PackBuildingIcon(spriteName, viewCom)
    if Runtime.CSNull(viewCom) then
        return
    end
    local assetPath = GetBuildingIconPath(spriteName)
    self:SetIcon(viewCom, assetPath)
    -- return self:PackIcon(viewCom, assetPath, AtlasNames.Building, 2048)
end

---动态加在sprite
function ItemIcons:LoadSpriteAsync(assetPath, onGet)
    if not App.iconsLoader:AssetExist(assetPath) then
        Runtime.InvokeCbk(onGet)
        return
    end
    local function onLoaded()
        local tex = App.iconsLoader:GetAsset(assetPath)
        local rect = Rect(0, 0, tex.width or 64, tex.height or 64)
        local spr = Sprite.Create(tex,rect,Vector2.zero)
        Runtime.InvokeCbk(onGet,spr)
    end
    if App.iconsLoader:HasAsset(assetPath) then
        onLoaded()
    else
        App.iconsLoader:LoadAssets({assetPath}, onLoaded)
    end
end

-- ---根据传入参数动态打任务图标图集
-- ---@param icon_name string 图片名不带png结尾
-- ---@param viewCom Component 渲染组件 [Image, RawImage, SpriteRenderer, MeshRenderer]
-- ---@return Component 新的渲染组件
-- function ItemIcons:PackMissionIcon(icon_name, viewCom)
--     if Runtime.CSNull(viewCom) then
--         return
--     end
--     if icon_name:find('Deafault') then
--         console.assert(false, icon_name)
--     end
--     local assetPath = string.format(CONST.ASSETS.G_ICONS_MISSIONS_URI, icon_name)
--     -- return self:PackIcon(viewCom, assetPath, AtlasNames.Mission, 1024)
--     self:SetIcon(viewCom, assetPath)
-- end

---根据传入参数动态打气泡图标图集
---@param spriteName string 图标名
---@param viewCom Component 渲染组件 [Image, RawImage, SpriteRenderer, MeshRenderer]
---@return Component 新的渲染组件
function ItemIcons:PackBubbleImages(spriteName, viewCom)
    if Runtime.CSNull(viewCom) then
        return
    end

    local assetPath = string.format(CONST.ASSETS.G_ICONS_BUBBLES_URI, spriteName)
    return self:PackIcon(viewCom, assetPath, AtlasNames.Bubble, 512)
end

------>>>处理因加载出现的先调用后执行的逻辑bug, 表现为图片显示不匹配 >>>
function ItemIcons:AddTask(viewCom, tag)
    self.tasks = self.tasks or {}
    local key = viewCom:GetInstanceID()
    local task = self.tasks[key]
    if not task then
        task = {
            ref = 0
        }
        self.tasks[key] = task
    end
    task.tag = tag
    task.ref = task.ref + 1
end

function ItemIcons:CheckTask(viewCom, tag)
    local key = viewCom:GetInstanceID()
    local task = self.tasks[key]
    if not task.tag == tag then
        console.terror(viewCom, "a previous call of change texture is prevented") --@DEL
    end
    return task.tag == tag
end

function ItemIcons:DelTask(viewCom)
    local key = viewCom:GetInstanceID()
    local task = self.tasks[key]
    task.ref = task.ref - 1
    if task.ref == 0 then
        -- console.terror(viewCom, "clear task") --@DEL
        self.tasks[key] = nil
    end
end

function ItemIcons:ChangeIcon(viewCom)
    return ChangeComponent(viewCom)
end
------<<<处理因加载出现的先调用后执行的逻辑bug, 表现为图片显示不匹配 <<<
---@private
function ItemIcons:PackIcon(viewCom, assetPath, atlasName, size, noPack)
    viewCom = self:ChangeIcon(viewCom)
    self:AddTask(viewCom, assetPath)

    if App.iconsLoader:HasAsset(assetPath) then
        local tex = App.iconsLoader:GetAsset(assetPath)
        if self:CheckTask(viewCom, assetPath) then
            PackTexture(viewCom, tex, atlasName, size)
        end
        self:DelTask(viewCom)
    else
        local canvasGroup = viewCom.gameObject:GetOrAddComponent(typeof(CanvasGroup))
        canvasGroup.alpha = 0
        local function onLoaded()
            if Runtime.CSValid(viewCom) then
                if Runtime.CSValid(canvasGroup) then
                    GameUtil.DoFade(canvasGroup, 1, 6 / 30)
                end
                if self:CheckTask(viewCom, assetPath) then
                    local tex = App.iconsLoader:GetAsset(assetPath)
                    PackTexture(viewCom, tex, atlasName, size)
                end
                self:DelTask(viewCom)
            end
        end
        App.iconsLoader:LoadAssets({assetPath}, onLoaded)
    end
    return viewCom
end

---@private
function ItemIcons:SetIcon(viewCom, assetPath)
    viewCom = self:ChangeIcon(viewCom)
    self:AddTask(viewCom, assetPath)
    if App.iconsLoader:HasAsset(assetPath) then
        if self:CheckTask(viewCom, assetPath) then
            local tex = App.iconsLoader:GetAsset(assetPath)
            if viewCom.texture then
                viewCom.texture = tex
            elseif viewCom.sprite then
                --viewCom.sprite = tex
            end
        end
        self:DelTask(viewCom)
    else
        local canvasGroup = viewCom.gameObject:GetOrAddComponent(typeof(CanvasGroup))
        canvasGroup.alpha = 0
        local function onLoaded()
            if Runtime.CSValid(viewCom) then
                if Runtime.CSValid(canvasGroup) then
                    GameUtil.DoFade(canvasGroup, 1, 6 / 30)
                else
                    -- console.lzl('-------canvas error------', assetPath)
                end
                if self:CheckTask(viewCom, assetPath) then
                    local tex = App.iconsLoader:GetAsset(assetPath)
                    viewCom.texture = tex
                end
                self:DelTask(viewCom)
            end
        end
        App.iconsLoader:LoadAssets({assetPath}, onLoaded)
    end
    return viewCom
end

function ItemIcons:SetItemIcon(iconComp, itemId)
    local function TryDeleteComp(iconcom, type)
        local viewCom = iconcom.gameObject:GetComponent(type)
        if not viewCom then
            return
        end
        GameObject.Destroy(viewCom)
    end
    TryDeleteComp(iconComp, typeof(RawImage))
    TryDeleteComp(iconComp, typeof(CS.RuntimeTextureAtlas.RawImageAgent))
    iconComp = iconComp.gameObject:GetOrAddComponent(typeof(Image))
    iconComp.sprite = self:GetSprite(itemId)
end

function ItemIcons:SetTaskIcon(iconComp, iconName)
    local function TryDeleteComp(iconcom, type)
        local viewCom = iconcom.gameObject:GetComponent(type)
        if not viewCom then
            return
        end
        GameObject.Destroy(viewCom)
    end
    TryDeleteComp(iconComp, typeof(RawImage))
    TryDeleteComp(iconComp, typeof(CS.RuntimeTextureAtlas.RawImageAgent))
    iconComp = iconComp.gameObject:GetOrAddComponent(typeof(Image))
    local sprite = self.taskAtlas:GetSprite(iconName)
    iconComp.sprite = sprite
end

function ItemIcons:GetSceneIconSprite(sceneId)
    local iconName = AppServices.Meta:GetSceneIcon(sceneId)
    local sprite = self.itemAtlas:GetSprite(iconName)
    return sprite
end

function ItemIcons:SetSceneIcon(iconComp, sceneId)
    iconComp.sprite = self:GetSceneIconSprite(sceneId)
end

function ItemIcons:SetItemCollectionIcon(viewCom, iconName)
    local assetPath = string.format("Prefab/RuntimeIcons/Collection/%s.png", iconName)
    self:SetIcon(viewCom, assetPath)
end

function ItemIcons:SetOrderTaskIcon(viewCom, iconName)
    local assetPath = string.format("Prefab/RuntimeIcons/Order/%s.png", iconName)
    self:SetIcon(viewCom, assetPath)
end

function ItemIcons:SetDragonIcon(viewCom, iconName)
    local assetPath = string.format("Prefab/RuntimeIcons/Dragons/%s.png", iconName)
    return self:SetIcon(viewCom, assetPath)
end

---设置技能图标 TODO 决定方式
function ItemIcons:SetSkillIcon(iconName, onGet)
    local assetPath = string.format("Prefab/RuntimeIcons/Skill/%s.png", iconName)
    self:LoadSpriteAsync(assetPath, onGet)
end

function ItemIcons:AsyncLoadSpriteFromAtlas(atlasPath, spriteName, img_com)
    self.asyncLoadAtlas = self.asyncLoadAtlas or {}
    self.isLoadingAtlas = self.isLoadingAtlas or {}
    local atlas = self.asyncLoadAtlas[atlasPath]
    if atlas then
        if Runtime.CSValid(img_com) then
            img_com.sprite = atlas:GetSprite(spriteName)
        end
        return
    end
    if self.isLoadingAtlas[atlasPath] then
        table.insert(self.isLoadingAtlas[atlasPath], {spriteName, img_com})
        return
    end
    local function onLoaded()
        atlas = App.uiAssetsManager:GetAsset(atlasPath)
        self.asyncLoadAtlas[atlasPath] = atlas
        if self.isLoadingAtlas[atlasPath] and #self.isLoadingAtlas[atlasPath] > 0 then
            for _, v in ipairs(self.isLoadingAtlas[atlasPath]) do
                if Runtime.CSValid(v[2]) then
                    v[2].sprite = atlas:GetSprite(v[1])
                end
            end
        end
        self.isLoadingAtlas[atlasPath] = nil
        if Runtime.CSValid(img_com) then
            img_com.sprite = atlas:GetSprite(spriteName)
        end
    end
    self.isLoadingAtlas[atlasPath] = {}
    App.iconsLoader:LoadAssets({atlasPath}, onLoaded)
end

function ItemIcons:SetActivityImg(rawImgCom, img_name)
    if Runtime.CSNull(rawImgCom) then
        return
    end
    local assetPath = string.format(CONST.ASSETS.G_IMG_ACTIVITY_URI, img_name)
    self:SetIcon(rawImgCom, assetPath)
end

function ItemIcons:Gc()
    App.iconsLoader:DestroyAllAssets()
end

return ItemIcons