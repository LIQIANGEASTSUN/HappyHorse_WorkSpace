---@class AUDIO
local AUDIO = {

    -- new audio system
    Interface_Click = CS.JSAM.Sounds.UIClick,                                 --button点击

    --Music
    Music_MainCity = "Prefab/Audio/Music/MainCityMusic.mp3",

    --Interface
    Interface_GetEnergy = "Prefab/Audio/Interface/getStar.wav",                           --获取体力
    Interface_PayStar = "Prefab/Audio/Interface/payStar.wav",                             --消耗星星
    Interface_GetCoin = "Prefab/Audio/Interface/getCoin.wav",                             --获取金币
    Interface_PayCoin = "Prefab/Audio/Interface/payCoin.wav",                             --消耗金币
    Interface_GetDiamond = "Prefab/Audio/Interface/getDiamond.wav",                       --获取钻石
    Interface_PayDiamond = "Prefab/Audio/Interface/payDiamond.wav",                       --消耗钻石

    Interface_OpenPanel = "Prefab/Audio/Interface/openPanel.wav",                         --面板开启
    Interface_ClosePanel = "Prefab/Audio/Interface/closePanel.wav",                       --面板关闭
    Interface_OpenBox = "Prefab/Audio/Interface/openBox.wav",                             --宝箱及礼盒开启音效
    Interface_Celebrate = "Prefab/Audio/Interface/celebrate.wav",                         --烟花音效

    Interface_ClickObstacle = "Prefab/Audio/Interface/clickStatue.wav",                   --选中障碍物
    Interface_PlaceBuilding = "Prefab/Audio/Interface/placeStatue.wav",                   --放置建筑
    Interface_BuildingCompose = "Prefab/Audio/Interface/merge.wav",                       --建筑合成
    Interface_BuildingUnlock = "Prefab/Audio/Interface/unlock.wav",                       --建筑解锁

    Interface_NewTask = "Prefab/Audio/Interface/newTask.wav",                             --新任务出现
    Interface_finishTask = "Prefab/Audio/Interface/finishTask.wav",                       --完成任务

    Interface_sound_clear_stones = "Prefab/Audio/Interface/sound_clear_stones.wav", --挖石头  如挖石头时有石子碰撞的声音
    Interface_sound_clear_wood = "Prefab/Audio/Interface/sound_clear_wood.wav", --砍木头  砍木头需要砍木头声音
    Interface_sound_clear_grass = "Prefab/Audio/Interface/sound_clear_grass.wav", --挖草  有割草声效
    Interface_sound_clear_plants = "Prefab/Audio/Interface/sound_clear_plants.wav", --挖其它植物或障碍  统一种挖地声效
    Interface_sound_acquire_Nino = "Prefab/Audio/Interface/sound_acquire_Nino.wav", --获得第一个龙-尼诺  尼诺从蛋里出来,有破壳生效
    Interface_sound_acquire_dragons = "Prefab/Audio/Interface/sound_acquire_dragons.wav", --获得其它龙  统一煽动翅膀声效
    Interface_sound_acquire_coins = "Prefab/Audio/Interface/sound_acquire_coins.wav", --获得金币  获得金币时有砸进钱袋的声音
    Interface_sound_acquire_gems = "Prefab/Audio/Interface/sound_acquire_gems.wav", --获得钻石  获得钻石时有钻石碰撞的声效
    Interface_sound_ui_interface = "Prefab/Audio/Interface/sound_ui_interface.wav", --各界面打开或者关闭  打开/关闭界面声效
    Interface_sound_story_restoring_building = "Prefab/Audio/Interface/sound_story_restoring_building.wav", --修复建筑  修好建筑后,buling一声的庆祝音(不需要很长)
    Interface_sound_story_drop_stuff = "Prefab/Audio/Interface/sound_story_drop_stuff.wav", --点击建筑-掉落物资  清脆的dingling一声,有东西获得的感觉
    Interface_sound_story_bounce_bubbles = "Prefab/Audio/Interface/sound_story_bounce_bubbles.wav", --弹气泡  弹气泡时,冒泡的声音(类似于bulu/pu一声)
    Interface_sound_acquire_resource = "Prefab/Audio/Interface/sound_acquire_resource3.wav"
}
-- setmetatable(AUDIO, {
--     __index = function(t, k)
--         --获取其它物资  统一声效,物资进入背包的声音(可参考竞品,会提供视频)
--         if k == "Interface_sound_acquire_resource" then
--             -- local index = math.random(1, 3)
--             -- local path = string.format("Prefab/Audio/Interface/sound_acquire_resource_%s.wav", index)
--             return path
--         end
--     end
-- })
return AUDIO
