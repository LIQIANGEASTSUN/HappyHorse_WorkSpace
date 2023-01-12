local function addNecessary(names, params)
    return
end

local cfg = {
    name = function(isLegacyDevice, params)
        local names = {"root", "101"}

        addNecessary(names, params)

        if isLegacyDevice then
            return names
        end
        return names
    end,
    --music_bg = "Music_BG",
    class = "MainCity.CleanerCity",
    uid = "CleanerCity",
    params = {
        sceneId = "101",
        music_bg = CS.JSAM.Music.GameBg,
    },
    farmSupport = true,
    farmGroup = {},
    dependences = {
        "Prefab/Art/Characters/Player.prefab",
        CONST.ASSETS.G_UI_PRESS_SLIDER,
        "Prefab/UI/CityBuilder/BuildingOperator/building_grid.prefab",
        "Prefab/UI/CityBuilder/BuildingOperator/building_move_arrow.prefab",
        "Prefab/UI/CityBuilder/BuildingOperator/Prefabs/bg.prefab",
        "Prefab/UI/CityBuilder/BuildingOperator/Prefabs/movable.prefab"
    },
    AssetLoader = AssetsManager.new()
}

function cfg:LoadDependenceFunc(OnLoadDependenceComplete, OnLoadDependenceProcess)
    self.AssetLoader:LoadAssets(self.dependences, OnLoadDependenceComplete, OnLoadDependenceProcess)
    return #self.dependences
end

return cfg
