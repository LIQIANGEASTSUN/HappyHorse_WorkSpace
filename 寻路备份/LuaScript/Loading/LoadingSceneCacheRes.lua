local Assets = CONST.ASSETS
return {
    assets = {
        -- Cleaner
        Assets.G_UI_HOMESCENE_USERINFO,
        Assets.G_UI_HOMESCENE_PROPS,
        Assets.G_UI_HOMESCENE_SHOP,
        Assets.G_UI_HOMESCENE_CLEANER,
        Assets.G_UI_HOMESCENE_ANIMALS,
        Assets.G_UI_HOMESCENE_PET_INFO,
        Assets.G_UI_HOMESCENE_GM_BUTTON,


        Assets.G_ISLAND_SPRITE,
        Assets.G_ITEM_ICONS,
        Assets.G_TASK_ICONS,
        Assets.G_COMMONS_SPRITE,
        -- Assets.G_UI_HOMESCENE_HEARTITEM,
        Assets.G_UI_HOMESCENE_DIAMONDITEM,
        Assets.G_UI_HOMESCENE_EXPITEM,
        Assets.G_UI_HOMESCENE_COINITEM,

        Assets.G_UI_HOMESCENE_RETURN_HOME_BUTTON,
        Assets.G_UI_HOMESCENE_BAG_BUTTON,
        Assets.G_UI_HOMESCENE_TASK_BUTTON,
        Assets.G_UI_HOMESCENE_BUILDINGREPAIR_BUTTON,
        Assets.G_UI_HOMESCENE_UPDATINGBUTTON,
        Assets.G_UI_GAMEPLAYSCENE_PAUSE_BUTTON,    -- CHECK
        "Prefab/UI/Buildin/CanvasScreenPlay.prefab",
        Assets.G_UI_HOMESCENE_WIDGETS_MENU,
        -------------------------------
        Assets.G_UI_BUILDING_INFO_UI_IMAGE_TIP,
        --==============================

        Assets.G_UI_FULL_SCREEN_CLICK_MASK,
        Assets.G_UI_ERROR_MESSAGE_PANEL,
        Assets.G_UI_NOTICE_PANEL,

        Assets.G_UI_GUIDE_MOVING_HAND,
        Assets.G_UI_GUIDE_SHAKE_MOBILE,
        Assets.G_UI_GUIDE_ARROW,

        Assets.G_EFFECT_BUILDING_REWARD_PTC,
        -- Assets.G_UI_FLY_BUFF_ICON,
        -- character model need preload
        Assets.G_UI_CANVAS_CHANGESCENE,
        --UI

        Assets.G_CONNECTING_PANEL,
        Assets.G_CONNECTING_PAY_PANEL,

        Assets.G_ANIMATOR_PANEL,
        Assets.G_ANIMATOR_BUTTON,
        Assets.G_SAFE_AREA_PANEL,

        Assets.G_UI_Text_Tip_Panel,
        Assets.G_REWARD_PROPS_FLY_ITEM,
        ---
        Assets.G_UI_HOMESCENE_ActivityTask_BUTTON,
        Assets.G_UI_HOMESCENE_SPEED_UP_BUTTON,
        Assets.G_UI_HOMESCENE_MAIL,

        --Guide
        Assets.G_UI_GUIDE_MASK,
        Assets.G_UI_GUIDE_POINT,
        Assets.G_UI_GUIDE_POINT2,
        Assets.G_UI_GUIDE_CONTINUE_TEXT,
        Assets.G_UI_GUIDE_SPINE_GUIDE_HAND,
        Assets.G_UI_GUIDE_SKIP_BUTTON,
        Assets.G_UI_GUIDE_TIPS,
        Assets.G_UI_GUIDE_TIPS_TOP_RIGHT,
        Assets.G_UI_GUIDE_TIPS_BOTTOM_LEFT,
        Assets.G_UI_GUIDE_TIPS_BOTTOM_RIGHT,
        ---

        "Prefab/UI/HomeScene/PanelMask.prefab",
        "Prefab/UI/Common/fly_tween_item.prefab",
        "Prefab/UI/Common/System/GameExitCanvas.prefab",
        "Prefab/UI/Common/System/ShutDownServerNoticeCanvas.prefab",
        "Prefab/UI/zendesk/Zendesk.prefab"
    },
    bundles = function(prefetch_all)
        return {
            "prefab/buildin.x",
            "prefab/scenesbuildin.x",
            "prefab/audio/interface.x",
            "prefab/runtimeicons.x",
            "prefab/ui/common.x",
            "prefab/ui/guide.x",
            "prefab/ui/buildin.x",
            "prefab/ui/homescene.x",
            "prefab/art/characters.x",
            "prefab/spriteatlas/commons.x",
            "prefab/spriteatlas/code.items.x"
        }
    end
}