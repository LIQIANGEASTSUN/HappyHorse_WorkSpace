local cfg = {
    name = function(isLegacyDevice)
        return {"LoadingScene"}
    end,
    class = "Loading.LoadingScene",
    uid = "LoadingScene",
	params = {
        sceneId = 1,
        music_bg = CS.JSAM.Music.Loading,
    },
}

return cfg