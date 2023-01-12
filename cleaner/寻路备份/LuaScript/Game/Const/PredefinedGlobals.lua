local ns = CS.BetaGame
local UE = CS.UnityEngine

NS = ns
XGE = CS.XEngine

Vector2 = UE.Vector2
Vector3 = UE.Vector3
Vector4 = UE.Vector4
Vector2Int = UE.Vector2Int
Vector3Int = UE.Vector3Int
Quaternion = UE.Quaternion
Rect = UE.Rect
Color = UE.Color
Random = UE.Random
Animator = UE.Animator
Camera = UE.Camera

GameObject = UE.GameObject

Time = UE.Time
Resources = UE.Resources
SceneManager = UE.SceneManagement.SceneManager
LoadSceneMode = UE.SceneManagement.LoadSceneMode

Transform = UE.Transform
SpriteRenderer = UE.SpriteRenderer
SkinnedMeshRenderer = UE.SkinnedMeshRenderer
MeshRenderer = UE.MeshRenderer
TextMeshPro = CS.TMPro.TextMeshPro
-- SpriteAlign = CS.SpriteAlign
SortingGroup = UE.Rendering.SortingGroup
TrailRenderer = UE.TrailRenderer
RectTransform = UE.RectTransform
BoxCollider = UE.BoxCollider
Collider = UE.Collider
-- EventSystem = UE.EventSystems.EventSystem
-- RaycastHit = UE.RaycastHit
Sprite = UE.Sprite

Animation = UE.Animation
AnimationEventHandler = ns.AnimationEventHandler
UIEventListener = ns.UIEventListener

-- UI Section
Canvas = UE.Canvas
CanvasGroup = UE.CanvasGroup
CanvasScaler = UE.UI.CanvasScaler
GraphicRaycaster = UE.UI.GraphicRaycaster
Text = UE.UI.Text
Outline = UE.UI.Outline
Button = UE.UI.Button
MaskableGraphic = UE.UI.MaskableGraphic
Image = UE.UI.Image
RawImage = UE.UI.RawImage
Toggle = UE.UI.Toggle
Scrollbar = UE.UI.Scrollbar
ScrollRect = UE.UI.ScrollRect
Slider = UE.UI.Slider
ScrollListRenderer = ns.UI.ScrollListRenderer

--ToggleGroup = UE.UI.ToggleGroup
UIGray = CS.UIGray

-- XEngine
AssetLoaderUtil = ns.AssetLoaderUtil
GameUtil = ns.GameUtil
AnimatorEx = XGE.AnimatorExtension
Localization = ns.Localization

-- Utils
StringList = XGE.LuaType.StringList
Vector3List = XGE.LuaType.Vector3List
GOUtil = ns.GOUtil

-- Bridge
BCore = CS.Bridge.Core
BPath = CS.Bridge.Path
BResource = CS.Bridge.Resource

-- Game
LuaHelper = ns.LuaHelper
-- RewardItem = ns.RewardItem
RewardContainer = ns.RewardContainer
ProgressHandler = ns.ProgressHandler
BoneFollower = CS.BoneFollower

SkeletonAnimation = CS.Spine.Unity.SkeletonAnimation
SkeletonGraphic = CS.Spine.Unity.SkeletonGraphic
SkeletonAnimationCtrl = ns.SkeletonAnimationCtrl

-- Third part
DOTween = CS.DG.Tweening.DOTween
Ease = CS.DG.Tweening.Ease
LoopType = CS.DG.Tweening.LoopType
RotateMode = CS.DG.Tweening.RotateMode
Screen = UE.Screen
--------App---------------------
XDebug = CS.XDebug
LogicContext = CS.LogicContext.Instance

function include(name)
    local dt = require(name)
    package.loaded[name] = nil
    return dt
end
-----------------------------------------------------------

CONST = {
    ---@type BreedEvent
    BreedEvent = nil,
    ---@type ASSETS
    ASSETS = nil,
    ---@type GAME
    GAME = nil,
    ---@type MAINUI
    MAINUI = nil,
    ---@type RULES
    RULES = nil,
    ---@type AUDIO
    AUDIO = nil,
}
setmetatable(
    CONST,
    {
        --__mode = "v",
        __index = function(t, k)
            local data = include("Game.Const." .. k)
            rawset(t, k, data)
            return data
        end
    }
)

HUD_ICON_ENUM = {
    AUTO = 1,
    HEAD = 2,
    ITEM = 3
}
