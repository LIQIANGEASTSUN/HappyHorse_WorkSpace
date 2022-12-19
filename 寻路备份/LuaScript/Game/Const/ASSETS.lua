local mt = {
    __index = function(t, k)
        return CONST.ASSETS[k]
    end
}
setmetatable(_G, mt)

---@class ASSETS
local ASSETS = {

    G_UI_VIRTUAL_JOYSTICK = "Prefab/UI/Common/VirtualJoystickCanvas.prefab",
    G_UI_SPRITE_TIPS = "Prefab/UI/Common/SpriteTipsPanel.prefab",
    G_UI_PRESS_SLIDER = "Prefab/UI/Common/PressSlider.prefab",
    G_UI_ERROR_MESSAGE_PANEL = "Prefab/UI/Common/ErrorPanel.prefab",
    G_UI_CANVAS_CHANGESCENE = "Prefab/UI/Common/ChangeScene/ChangeSceneCanvas.prefab",

    G_PRODUCT_FINISH_TIPS = "Prefab/UI/Common/TipsProductFinish.prefab",
    G_PRODUCT_DOING_TIPS = "Prefab/UI/Common/TipsProductDoing.prefab",
    G_MONSTER_HP_TIPS = "Prefab/UI/Common/TipsHpMonster.prefab",
    G_PET_HP_TYPE1_TIPS = "Prefab/UI/Common/TipsHpPetType1.prefab",
    G_PET_HP_TYPE2_TIPS = "Prefab/UI/Common/TipsHpPetType2.prefab",
    G_BOSS_TIPS = "Prefab/UI/Common/TipsBoss.prefab",

    G_ISLAND_SPRITE = "Prefab/SpriteAtlas/island.spriteatlas",
    G_COMMONS_SPRITE = "Prefab/SpriteAtlas/commons.spriteatlas",
    G_ITEM_ICONS = "Prefab/SpriteAtlas/code.items.spriteatlas",
    G_TASK_ICONS = "Prefab/SpriteAtlas/code.tasks.spriteatlas",
    -- ScreenPlays
    G_UI_REWARD_BUILDING_ITEM = "Prefab/ScreenPlays/UnlockBuildingItem.prefab",
    G_UI_ACTOR_BUBBLE_TEXT = "Prefab/UI/Common/Tips/BubbleText.prefab",
    G_UI_SCREENPLAY_CARTOON = "Prefab/UI/Common/ScreenPlays/Cartoon.prefab",
    G_UI_HOMESCENE_SPEED_UP_BUTTON = "Prefab/UI/Common/ScreenPlays/btnSpeed.prefab",

    ---------------Clener----------
    G_UI_HOMESCENE_USERINFO = "Prefab/UI/HomeScene/UserInfoWidget.prefab",
    G_UI_HOMESCENE_PROPS = "Prefab/UI/HomeScene/PropsWidget.prefab",
    G_UI_HOMESCENE_SHOP = "Prefab/UI/HomeScene/ShopButton.prefab",
    G_UI_HOMESCENE_ANIMALS = "Prefab/UI/HomeScene/AnimalsButton.prefab",
    G_UI_HOMESCENE_CLEANER = "Prefab/UI/HomeScene/CleanerButton.prefab",
    G_UI_HOMESCENE_BAG_BUTTON = "Prefab/UI/HomeScene/BagButton.prefab",
    G_UI_HOMESCENE_PET_INFO = "Prefab/UI/HomeScene/PetInfoButton.prefab",
    G_UI_HOMESCENE_GM_BUTTON = "Prefab/UI/HomeScene/GMButton.prefab",
    G_UI_HOMESCENE_TASK_BUTTON = "Prefab/UI/HomeScene/TaskButton.prefab",

    -- HomeScene
    G_UI_HOMESCENE_WIDGETS_MENU = "Prefab/UI/HomeScene/HRWidgetsMenu.prefab",
    -- G_UI_HOMESCENE_HEARTITEM = "Prefab/UI/HomeScene/HeartItem.prefab",
    -- G_UI_HOMESCENE_SETTINGBUTTON = "Prefab/UI/HomeScene/SettingButton.prefab",
    G_UI_HOMESCENE_UPDATINGBUTTON = "Prefab/UI/HomeScene/UpdatingButton.prefab",
    G_UI_HOMESCENE_DIAMONDITEM = "Prefab/UI/HomeScene/DiamondItem.prefab",
    G_UI_HOMESCENE_EXPITEM = "Prefab/UI/HomeScene/ExpItem.prefab",
    G_UI_HOMESCENE_COINITEM = "Prefab/UI/HomeScene/CoinItem.prefab",
    G_UI_HOMESCENE_TASKDETAILINFO = "Prefab/UI/HomeScene/Task/TaskDetailInfo.prefab",
    G_UI_HOMESCENE_REMAINSBACK_BUTTON = "Prefab/UI/HomeScene/RemainsBackButton.prefab",
    G_UI_HOMESCENE_REMAINSDRAGON_BUTTON = "Prefab/UI/HomeScene/RemainsDragonButton.prefab",
    G_UI_HOMESCENE_SHAKE_BUTTON = "Prefab/UI/HomeScene/ShakeButton.prefab",
    G_UI_HOMESCENE_DRAGONBAG_BUTTON = "Prefab/UI/HomeScene/DragonBagButton.prefab",
    G_UI_HOMESCENE_BOMB_BUTTON = "Prefab/UI/HomeScene/BombEntryIcon.prefab",
    G_UI_HOMESCENE_MAIL = "Prefab/UI/HomeScene/MailButton.prefab",
    G_UI_HOMESCENE_ENERGYDISCOUNT = "Prefab/UI/HomeScene/EnergyDiscountIcon.prefab",
    G_UI_HOMESCENE_Dragon_ENERGYDISCOUNT = "Prefab/UI/HomeScene/DragonEnergyDiscountIcon.prefab",
    G_UI_Text_Tip_Panel = "Prefab/UI/Common/TextTipPanel.prefab",
    G_UI_Scene_Text_Tip_Panel = "Prefab/UI/Common/SceneTextTipPanel.prefab",
    G_UI_SceneStar_BUTTON = "Prefab/UI/HomeScene/SceneStarButton.prefab",
    G_E_Clickground = "Prefab/ScreenPlays/DragonEffect/E_Clickground.prefab",
    G_E_Click = "Prefab/ScreenPlays/DragonEffect/E_Click.prefab",
    -- CityBuilder Models
    G_MODEL_PLAYER = "Prefab/Art/Characters/Maleplayer.prefab",
    G_CONNECTING_PANEL = "Prefab/UI/Common/Connection/ConnectingPanelCanvas.prefab",
    G_CONNECTING_PAY_PANEL = "Prefab/UI/Common/Connection/ConnectPayPanelCanvas.prefab",
    G_UI_NOTICE_PANEL = "Prefab/UI/Common/NoticePanel.prefab",
    G_REWARD_CONTAINER = "Prefab/UI/Common/RewardContainer.prefab",
    G_REWARD_ITEM = "Prefab/UI/Common/RewardItem.prefab",
    G_REWARD_ITEM_BIG_TEXT = "Prefab/UI/Common/RewardItemBigTxet.prefab",
    G_REWARD_PROPS_FLY_ITEM = "Prefab/UI/Common/FlyProps.prefab",
    G_REWARD_PROPS_FLY_TEXT = "Prefab/UI/Common/FlyText.prefab",
    G_REWARD_PROPS_FLY_TEXT_WITH_ICON = "Prefab/UI/Common/FlyTxtWithIcon.prefab",
    G_REWARD_TRAIL_ITEM = "Prefab/UI/Common/Trail.prefab",
    G_MODEL_PREVIEW_ITEM = "Prefab/UI/Common/ModelPreviewItem.prefab",
    G_ITEM_FLY_TAIL_BLUE = "Prefab/ScreenPlays/Other/E_Tail_blue.prefab",
    G_ITEM_FLY_TAIL_GOLD = "Prefab/ScreenPlays/Other/E_Tail_gold.prefab",
    G_MAP_TIP_ITEM = "Prefab/UI/MapCursor/MapTipItem.prefab",
    G_MAP_TIP_CANVAS = "Prefab/UI/MapCursor/MapCursorCanvas.prefab",
    G_STAR_GUIDE_PANEL = "Prefab/UI/StarGuidePanel/StarGuidePanel.prefab",
    -- Guide
    G_UI_GUIDE_MASK = "Prefab/UI/Guide/GuideMask.prefab",
    G_UI_GUIDE_POINT = "Prefab/UI/Guide/GuidePoint.prefab",
    G_UI_GUIDE_POINT2 = "Prefab/UI/Guide/GuidePoint2.prefab",
    G_UI_GUIDE_SKIP_BUTTON = "Prefab/UI/Guide/GuideSkipButton.prefab",
    G_UI_GUIDE_SPINE_GUIDE_HAND = "Prefab/UI/Guide/SpineGuideHand.prefab",
    G_UI_GUIDE_MOVING_HAND = "Prefab/UI/Guide/GuideMovingHand.prefab",
    G_UI_GUIDE_SHAKE_MOBILE = "Prefab/UI/Guide/GuideShake.prefab",
    G_UI_GUIDE_ARROW = "Prefab/UI/Guide/GuideArrow.prefab",
    G_UI_GUIDE_TIPS = "Prefab/UI/Guide/GuideTips.prefab",
    G_UI_GUIDE_TIPS_TOP_RIGHT = "Prefab/UI/Guide/GuideTipsTopRight.prefab",
    G_UI_GUIDE_TIPS_BOTTOM_LEFT = "Prefab/UI/Guide/GuideTipsBottomLeft.prefab",
    G_UI_GUIDE_TIPS_BOTTOM_RIGHT = "Prefab/UI/Guide/GuideTipsBottomRight.prefab",

    G_UI_FULL_SCREEN_CLICK_MASK = "Prefab/UI/Guide/FullScreenClickMask.prefab",
    G_ANIMATOR_PANEL = "Prefab/Buildin/Animator/Panel.controller",
    G_ANIMATOR_BUTTON = "Prefab/Buildin/Animator/Button.controller",
    -- G_UI_FLY_BUFF_ICON = "Prefab/UI/HomeScene/FlyBuffIcon.prefab",
    G_UI_FLY_BUILDING_ICON_NO_TAIL = "Prefab/UI/HomeScene/FlyBuildingIcon_No_Tail.prefab",
    G_UI_FLY_DIAMOND_ICON = "Prefab/UI/HomeScene/FlyDiamondIcon.prefab",
    G_SAFE_AREA_PANEL = "Prefab/UI/HomeScene/SafeAreaPanel.prefab",
    --场景障碍物提示窗
    G_BINDINGTIP_PREFAB = "Prefab/UI/Common/BindingTipPanel.prefab",
    -- Shop
    G_SPRITES_SHOP_ICON = "Prefab/SpriteAtlas/code.items.spriteatlas",
    ---通用
    ---弹出类似对话框的道具奖励提示
    G_UI_COMMON_ITEMGFITTIP = "Prefab/UI/Common/ItemGiftTip.prefab",
    ---弹出类似对话框的道具描述提示
    G_UI_COMMON_DESCRIPTIONTIP = "Prefab/UI/Common/DescriptionTip.prefab",
    ---建筑修复弹窗
    G_UI_COMMON_BUILDINGTASKTIP = "Prefab/UI/Common/BuildingTaskTip.prefab",
    G_ICONS_MISSIONS_URI = "Prefab/RuntimeIcons/Mission/%s.png",
    G_AVATAR_URI = "Prefab/Animation/Avatar_spine/%s.prefab",
    G_AVATAR_SPINE_URI = "Prefab/ScreenPlays/avatar_spine/%s/%s.prefab",
    G_ICONS_BUBBLES_URI = "Prefab/RuntimeIcons/Bubble/%s.png",
    ---建筑
    G_ICONS_BUILDINGS_URI = "Prefab/RuntimeIcons/Buildings/%s.png",
    -- EXP_ICON_NAME = 'icon_exp',
    G_ICONS_MISSIONCOMMON_URI = "Prefab/RuntimeIcons/Mission/common/%s.png",
    --地图气泡
    G_MAP_BUBBLE = "Prefab/UI/CollectionBubble/CollectionBubbleCanvas.prefab",
    G_GIFT_ICON_ATLAS = "Prefab/SpriteAtlas/code.items.spriteatlas",
    G_GIFT_ICON_PREFAB = "Prefab/UI/Common/GiftIcon/GiftIcon.prefab",
    G_CHRACTER_SHADOW = "Prefab/Art/Items/ActorShadow.prefab",
    ---活动加载散图
    G_IMG_ACTIVITY_URI = "Prefab/RuntimeIcons/Activities/%s.png",
    ---拖尾特效
    G_UI_EFFECT_JIFEN_TAIL = "Prefab/UI/Common/JiFen_trail.prefab",
    ---诈弹spine
    G_UI_SPINE_TIMEBOMB = "Prefab/UI/Common/ui_public_icon_timebomb.prefab",

    ---简单通用的活动
    G_UI_ACTIVITYTASKRANK_RANKITEM = "Prefab/Activities/Common/Panels/ActivityTaskRankPanel/rankItem.prefab",
    G_UI_ACTIVITYTASKRANK_WORLDRANKITEM = "Prefab/Activities/Common/Panels/ActivityTaskRankPanel/worldRankItem.prefab",
    G_UI_ACTIVITYTASKRANK_TASKNODE = "Prefab/Activities/Common/Panels/ActivityTaskRankPanel/ActivityTaskRankPanelTaskNode.prefab",

    G_UI_CONSUME_ITEM = "Prefab/UI/ConsumeItems/ConsumeItem.prefab",
}
return ASSETS
