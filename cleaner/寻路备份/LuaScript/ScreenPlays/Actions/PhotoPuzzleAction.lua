
---@class PhotoPuzzleAction:BaseFrameAction
local PhotoPuzzleAction = class(BaseFrameAction, "PhotoPuzzleAction")

function PhotoPuzzleAction:Create(duration, finishCallback)
    local instance = PhotoPuzzleAction.new(duration, finishCallback)
    return instance
end

function PhotoPuzzleAction:ctor(duration, finishCallback)
    self.name = "PhotoPuzzleAction"
    self.finishCallback = finishCallback
    self.duration = duration or 3
end

function PhotoPuzzleAction:Awake()
    local path = "Prefab/Animation/ScreenPlay/Photos.prefab"
    local function OnLoadFinish()
        --local canvas = GameUtil.FindOrAddCanvas("PhotoCanvas", "SCENE_BG", true)
        local go = BResource.InstantiateFromAssetName(path)
        Util.ScaleCanvasToScreen(go, "SCENE_BG", 1)
        local photoPuzzle = go.transform:Find("spine").gameObject:GetComponent(typeof(CS.BetaGame.PhotoPuzzle))
        photoPuzzle.finishCallback = function()
            Runtime.CSDestroy(go)
            go = nil
            self.isFinished = true
        end
        photoPuzzle.idleTime = self.duration
        --go.transform:SetParent(canvas.transform, false)
    end
    local assetPathList = StringList()
    assetPathList:AddItem(path)
    AssetLoaderUtil.LoadAssets(assetPathList, OnLoadFinish)
end

function PhotoPuzzleAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PhotoPuzzleAction:Reset()
    self.started = false
    self.isFinished = false
end

return PhotoPuzzleAction