local cfg = [====[
{
    "modelName": "Prefab/Art/Characters/Player.prefab",
    "luaPath": "MainCity.Character.PlayerCharacter",
    "name": "Player",
    "position": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "tag": "",
    "movespeed": 0.4000000059604645,
    "usePrefabPosition": false
}
]====]
return table.deserialize(cfg)