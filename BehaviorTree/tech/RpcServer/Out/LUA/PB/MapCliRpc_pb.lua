-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
local PublicStruct_pb = require("PublicStruct_pb")
module('MapCliRpc_pb')


local MAPSCENEDATA = protobuf.Descriptor();
local MAPSCENEDATA_MAPID_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_SCENENAME_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_SCENEFILENAME_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_CLIENTSCENENAME_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPSIMPLIFY_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPPOSX_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPPOSY_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPPIVOTX_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPPIVOTY_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_UIWORLDRATIO_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPDETAILED_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_SERVERUIRADIO_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_PVP_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_SPRAYS_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_TEAMS_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_LOWMODEL_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_ALPHASPEED_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_TRANSFERRADIUS_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPEFFECTAURA_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_MAPEFFECTARRIVE_FIELD = protobuf.FieldDescriptor();
local MAPSCENEDATA_PATHGRAPHS_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA = protobuf.Descriptor();
local MAPBASEPLAYMODEDATA_TYPE_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_DESC1_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_DESC2_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_MODENAME_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_UIBG_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_LIFTINGS_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_READYFILE_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_READYTIME_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD = protobuf.FieldDescriptor();
local MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD = protobuf.FieldDescriptor();
local MAPTEAMDATA = protobuf.Descriptor();
local MAPTEAMDATA_GUARD_FIELD = protobuf.FieldDescriptor();
local MAPTEAMDATA_PEDESTAL_FIELD = protobuf.FieldDescriptor();
local MAPTEAMDATA_SPAWNPOINTS_FIELD = protobuf.FieldDescriptor();
local MAPTEAMDATA_LIFTING_FIELD = protobuf.FieldDescriptor();
local MAPTEAMDATA_ID_FIELD = protobuf.FieldDescriptor();
local MAPTEAMDATA_COLOR_FIELD = protobuf.FieldDescriptor();
local MAPTEAMDATA_PEDESTALPOSITION_FIELD = protobuf.FieldDescriptor();
local MAPSPRAYDATA = protobuf.Descriptor();
local MAPSPRAYDATA_NAME_FIELD = protobuf.FieldDescriptor();
local MAPSPRAYDATA_POSITION_FIELD = protobuf.FieldDescriptor();
local MAPSPRAYDATA_DPI_FIELD = protobuf.FieldDescriptor();
local MAPSPRAYDATA_COEFFICIENT_FIELD = protobuf.FieldDescriptor();
local MAPPVPDATA = protobuf.Descriptor();
local MAPPVPDATA_BASEDATA_FIELD = protobuf.FieldDescriptor();
local MAPPVPDATA_ADDHERE_FIELD = protobuf.FieldDescriptor();
local MAPPRS = protobuf.Descriptor();
local MAPPRS_POSITION_FIELD = protobuf.FieldDescriptor();
local MAPPRS_EULARROTATION_FIELD = protobuf.FieldDescriptor();
local MAPPRS_SCALE_FIELD = protobuf.FieldDescriptor();
local MAPCAMERADATA = protobuf.Descriptor();
local MAPCAMERADATA_PATH_FIELD = protobuf.FieldDescriptor();
local MAPCAMERADATA_STARTTIME_FIELD = protobuf.FieldDescriptor();
local MAPCAMERADATA_ENDTIME_FIELD = protobuf.FieldDescriptor();
local MAPLIFTINGCONFIG = protobuf.Descriptor();
local MAPLIFTINGCONFIG_STARTTIME_FIELD = protobuf.FieldDescriptor();
local MAPLIFTINGCONFIG_SPEED_FIELD = protobuf.FieldDescriptor();
local MAPPOSITIONGRAPH = protobuf.Descriptor();
local MAPPOSITIONGRAPH_ID_FIELD = protobuf.FieldDescriptor();
local MAPPOSITIONGRAPH_VERTICES_FIELD = protobuf.FieldDescriptor();
local MAPPOSITIONGRAPH_EDGES_FIELD = protobuf.FieldDescriptor();

MAPSCENEDATA_MAPID_FIELD.name = "MapId"
MAPSCENEDATA_MAPID_FIELD.full_name = ".MapSceneData.MapId"
MAPSCENEDATA_MAPID_FIELD.number = 1
MAPSCENEDATA_MAPID_FIELD.index = 0
MAPSCENEDATA_MAPID_FIELD.label = 1
MAPSCENEDATA_MAPID_FIELD.has_default_value = true
MAPSCENEDATA_MAPID_FIELD.default_value = -1
MAPSCENEDATA_MAPID_FIELD.type = 17
MAPSCENEDATA_MAPID_FIELD.cpp_type = 1

MAPSCENEDATA_SCENENAME_FIELD.name = "SceneName"
MAPSCENEDATA_SCENENAME_FIELD.full_name = ".MapSceneData.SceneName"
MAPSCENEDATA_SCENENAME_FIELD.number = 2
MAPSCENEDATA_SCENENAME_FIELD.index = 1
MAPSCENEDATA_SCENENAME_FIELD.label = 1
MAPSCENEDATA_SCENENAME_FIELD.has_default_value = false
MAPSCENEDATA_SCENENAME_FIELD.default_value = ""
MAPSCENEDATA_SCENENAME_FIELD.type = 9
MAPSCENEDATA_SCENENAME_FIELD.cpp_type = 9

MAPSCENEDATA_SCENEFILENAME_FIELD.name = "SceneFileName"
MAPSCENEDATA_SCENEFILENAME_FIELD.full_name = ".MapSceneData.SceneFileName"
MAPSCENEDATA_SCENEFILENAME_FIELD.number = 20
MAPSCENEDATA_SCENEFILENAME_FIELD.index = 2
MAPSCENEDATA_SCENEFILENAME_FIELD.label = 1
MAPSCENEDATA_SCENEFILENAME_FIELD.has_default_value = false
MAPSCENEDATA_SCENEFILENAME_FIELD.default_value = ""
MAPSCENEDATA_SCENEFILENAME_FIELD.type = 9
MAPSCENEDATA_SCENEFILENAME_FIELD.cpp_type = 9

MAPSCENEDATA_CLIENTSCENENAME_FIELD.name = "ClientSceneName"
MAPSCENEDATA_CLIENTSCENENAME_FIELD.full_name = ".MapSceneData.ClientSceneName"
MAPSCENEDATA_CLIENTSCENENAME_FIELD.number = 19
MAPSCENEDATA_CLIENTSCENENAME_FIELD.index = 3
MAPSCENEDATA_CLIENTSCENENAME_FIELD.label = 1
MAPSCENEDATA_CLIENTSCENENAME_FIELD.has_default_value = false
MAPSCENEDATA_CLIENTSCENENAME_FIELD.default_value = ""
MAPSCENEDATA_CLIENTSCENENAME_FIELD.type = 9
MAPSCENEDATA_CLIENTSCENENAME_FIELD.cpp_type = 9

MAPSCENEDATA_MAPSIMPLIFY_FIELD.name = "MapSimplify"
MAPSCENEDATA_MAPSIMPLIFY_FIELD.full_name = ".MapSceneData.MapSimplify"
MAPSCENEDATA_MAPSIMPLIFY_FIELD.number = 3
MAPSCENEDATA_MAPSIMPLIFY_FIELD.index = 4
MAPSCENEDATA_MAPSIMPLIFY_FIELD.label = 1
MAPSCENEDATA_MAPSIMPLIFY_FIELD.has_default_value = false
MAPSCENEDATA_MAPSIMPLIFY_FIELD.default_value = ""
MAPSCENEDATA_MAPSIMPLIFY_FIELD.type = 9
MAPSCENEDATA_MAPSIMPLIFY_FIELD.cpp_type = 9

MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.name = "MapSimplifyRotate1"
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.full_name = ".MapSceneData.MapSimplifyRotate1"
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.number = 4
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.index = 5
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.label = 1
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.has_default_value = true
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.default_value = -1
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.type = 17
MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD.cpp_type = 1

MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.name = "MapSimplifyRotate2"
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.full_name = ".MapSceneData.MapSimplifyRotate2"
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.number = 5
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.index = 6
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.label = 1
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.has_default_value = true
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.default_value = -1
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.type = 17
MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD.cpp_type = 1

MAPSCENEDATA_MAPPOSX_FIELD.name = "MapPosX"
MAPSCENEDATA_MAPPOSX_FIELD.full_name = ".MapSceneData.MapPosX"
MAPSCENEDATA_MAPPOSX_FIELD.number = 6
MAPSCENEDATA_MAPPOSX_FIELD.index = 7
MAPSCENEDATA_MAPPOSX_FIELD.label = 1
MAPSCENEDATA_MAPPOSX_FIELD.has_default_value = true
MAPSCENEDATA_MAPPOSX_FIELD.default_value = -1
MAPSCENEDATA_MAPPOSX_FIELD.type = 2
MAPSCENEDATA_MAPPOSX_FIELD.cpp_type = 6

MAPSCENEDATA_MAPPOSY_FIELD.name = "MapPosY"
MAPSCENEDATA_MAPPOSY_FIELD.full_name = ".MapSceneData.MapPosY"
MAPSCENEDATA_MAPPOSY_FIELD.number = 7
MAPSCENEDATA_MAPPOSY_FIELD.index = 8
MAPSCENEDATA_MAPPOSY_FIELD.label = 1
MAPSCENEDATA_MAPPOSY_FIELD.has_default_value = true
MAPSCENEDATA_MAPPOSY_FIELD.default_value = -1
MAPSCENEDATA_MAPPOSY_FIELD.type = 2
MAPSCENEDATA_MAPPOSY_FIELD.cpp_type = 6

MAPSCENEDATA_MAPPIVOTX_FIELD.name = "MapPivotX"
MAPSCENEDATA_MAPPIVOTX_FIELD.full_name = ".MapSceneData.MapPivotX"
MAPSCENEDATA_MAPPIVOTX_FIELD.number = 8
MAPSCENEDATA_MAPPIVOTX_FIELD.index = 9
MAPSCENEDATA_MAPPIVOTX_FIELD.label = 1
MAPSCENEDATA_MAPPIVOTX_FIELD.has_default_value = true
MAPSCENEDATA_MAPPIVOTX_FIELD.default_value = -1
MAPSCENEDATA_MAPPIVOTX_FIELD.type = 2
MAPSCENEDATA_MAPPIVOTX_FIELD.cpp_type = 6

MAPSCENEDATA_MAPPIVOTY_FIELD.name = "MapPivotY"
MAPSCENEDATA_MAPPIVOTY_FIELD.full_name = ".MapSceneData.MapPivotY"
MAPSCENEDATA_MAPPIVOTY_FIELD.number = 9
MAPSCENEDATA_MAPPIVOTY_FIELD.index = 10
MAPSCENEDATA_MAPPIVOTY_FIELD.label = 1
MAPSCENEDATA_MAPPIVOTY_FIELD.has_default_value = true
MAPSCENEDATA_MAPPIVOTY_FIELD.default_value = -1
MAPSCENEDATA_MAPPIVOTY_FIELD.type = 2
MAPSCENEDATA_MAPPIVOTY_FIELD.cpp_type = 6

MAPSCENEDATA_UIWORLDRATIO_FIELD.name = "UIWorldRatio"
MAPSCENEDATA_UIWORLDRATIO_FIELD.full_name = ".MapSceneData.UIWorldRatio"
MAPSCENEDATA_UIWORLDRATIO_FIELD.number = 10
MAPSCENEDATA_UIWORLDRATIO_FIELD.index = 11
MAPSCENEDATA_UIWORLDRATIO_FIELD.label = 1
MAPSCENEDATA_UIWORLDRATIO_FIELD.has_default_value = true
MAPSCENEDATA_UIWORLDRATIO_FIELD.default_value = -1
MAPSCENEDATA_UIWORLDRATIO_FIELD.type = 2
MAPSCENEDATA_UIWORLDRATIO_FIELD.cpp_type = 6

MAPSCENEDATA_MAPDETAILED_FIELD.name = "MapDetailed"
MAPSCENEDATA_MAPDETAILED_FIELD.full_name = ".MapSceneData.MapDetailed"
MAPSCENEDATA_MAPDETAILED_FIELD.number = 11
MAPSCENEDATA_MAPDETAILED_FIELD.index = 12
MAPSCENEDATA_MAPDETAILED_FIELD.label = 1
MAPSCENEDATA_MAPDETAILED_FIELD.has_default_value = false
MAPSCENEDATA_MAPDETAILED_FIELD.default_value = ""
MAPSCENEDATA_MAPDETAILED_FIELD.type = 9
MAPSCENEDATA_MAPDETAILED_FIELD.cpp_type = 9

MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.name = "MapDetailedRotate1"
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.full_name = ".MapSceneData.MapDetailedRotate1"
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.number = 12
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.index = 13
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.label = 1
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.has_default_value = true
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.default_value = -1
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.type = 17
MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD.cpp_type = 1

MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.name = "MapDetailedRotate2"
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.full_name = ".MapSceneData.MapDetailedRotate2"
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.number = 13
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.index = 14
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.label = 1
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.has_default_value = true
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.default_value = -1
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.type = 17
MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD.cpp_type = 1

MAPSCENEDATA_SERVERUIRADIO_FIELD.name = "ServerUIRadio"
MAPSCENEDATA_SERVERUIRADIO_FIELD.full_name = ".MapSceneData.ServerUIRadio"
MAPSCENEDATA_SERVERUIRADIO_FIELD.number = 14
MAPSCENEDATA_SERVERUIRADIO_FIELD.index = 15
MAPSCENEDATA_SERVERUIRADIO_FIELD.label = 1
MAPSCENEDATA_SERVERUIRADIO_FIELD.has_default_value = true
MAPSCENEDATA_SERVERUIRADIO_FIELD.default_value = -1
MAPSCENEDATA_SERVERUIRADIO_FIELD.type = 2
MAPSCENEDATA_SERVERUIRADIO_FIELD.cpp_type = 6

MAPSCENEDATA_PVP_FIELD.name = "Pvp"
MAPSCENEDATA_PVP_FIELD.full_name = ".MapSceneData.Pvp"
MAPSCENEDATA_PVP_FIELD.number = 15
MAPSCENEDATA_PVP_FIELD.index = 16
MAPSCENEDATA_PVP_FIELD.label = 1
MAPSCENEDATA_PVP_FIELD.has_default_value = false
MAPSCENEDATA_PVP_FIELD.default_value = nil
MAPSCENEDATA_PVP_FIELD.message_type = MAPPVPDATA
MAPSCENEDATA_PVP_FIELD.type = 11
MAPSCENEDATA_PVP_FIELD.cpp_type = 10

MAPSCENEDATA_SPRAYS_FIELD.name = "Sprays"
MAPSCENEDATA_SPRAYS_FIELD.full_name = ".MapSceneData.Sprays"
MAPSCENEDATA_SPRAYS_FIELD.number = 16
MAPSCENEDATA_SPRAYS_FIELD.index = 17
MAPSCENEDATA_SPRAYS_FIELD.label = 3
MAPSCENEDATA_SPRAYS_FIELD.has_default_value = false
MAPSCENEDATA_SPRAYS_FIELD.default_value = {}
MAPSCENEDATA_SPRAYS_FIELD.message_type = MAPSPRAYDATA
MAPSCENEDATA_SPRAYS_FIELD.type = 11
MAPSCENEDATA_SPRAYS_FIELD.cpp_type = 10

MAPSCENEDATA_TEAMS_FIELD.name = "Teams"
MAPSCENEDATA_TEAMS_FIELD.full_name = ".MapSceneData.Teams"
MAPSCENEDATA_TEAMS_FIELD.number = 17
MAPSCENEDATA_TEAMS_FIELD.index = 18
MAPSCENEDATA_TEAMS_FIELD.label = 3
MAPSCENEDATA_TEAMS_FIELD.has_default_value = false
MAPSCENEDATA_TEAMS_FIELD.default_value = {}
MAPSCENEDATA_TEAMS_FIELD.message_type = MAPTEAMDATA
MAPSCENEDATA_TEAMS_FIELD.type = 11
MAPSCENEDATA_TEAMS_FIELD.cpp_type = 10

MAPSCENEDATA_LOWMODEL_FIELD.name = "LowModel"
MAPSCENEDATA_LOWMODEL_FIELD.full_name = ".MapSceneData.LowModel"
MAPSCENEDATA_LOWMODEL_FIELD.number = 18
MAPSCENEDATA_LOWMODEL_FIELD.index = 19
MAPSCENEDATA_LOWMODEL_FIELD.label = 1
MAPSCENEDATA_LOWMODEL_FIELD.has_default_value = false
MAPSCENEDATA_LOWMODEL_FIELD.default_value = ""
MAPSCENEDATA_LOWMODEL_FIELD.type = 9
MAPSCENEDATA_LOWMODEL_FIELD.cpp_type = 9

MAPSCENEDATA_ALPHASPEED_FIELD.name = "AlphaSpeed"
MAPSCENEDATA_ALPHASPEED_FIELD.full_name = ".MapSceneData.AlphaSpeed"
MAPSCENEDATA_ALPHASPEED_FIELD.number = 21
MAPSCENEDATA_ALPHASPEED_FIELD.index = 20
MAPSCENEDATA_ALPHASPEED_FIELD.label = 1
MAPSCENEDATA_ALPHASPEED_FIELD.has_default_value = true
MAPSCENEDATA_ALPHASPEED_FIELD.default_value = -1
MAPSCENEDATA_ALPHASPEED_FIELD.type = 2
MAPSCENEDATA_ALPHASPEED_FIELD.cpp_type = 6

MAPSCENEDATA_TRANSFERRADIUS_FIELD.name = "TransferRadius"
MAPSCENEDATA_TRANSFERRADIUS_FIELD.full_name = ".MapSceneData.TransferRadius"
MAPSCENEDATA_TRANSFERRADIUS_FIELD.number = 22
MAPSCENEDATA_TRANSFERRADIUS_FIELD.index = 21
MAPSCENEDATA_TRANSFERRADIUS_FIELD.label = 1
MAPSCENEDATA_TRANSFERRADIUS_FIELD.has_default_value = true
MAPSCENEDATA_TRANSFERRADIUS_FIELD.default_value = -1
MAPSCENEDATA_TRANSFERRADIUS_FIELD.type = 2
MAPSCENEDATA_TRANSFERRADIUS_FIELD.cpp_type = 6

MAPSCENEDATA_MAPEFFECTAURA_FIELD.name = "MapEffectAura"
MAPSCENEDATA_MAPEFFECTAURA_FIELD.full_name = ".MapSceneData.MapEffectAura"
MAPSCENEDATA_MAPEFFECTAURA_FIELD.number = 23
MAPSCENEDATA_MAPEFFECTAURA_FIELD.index = 22
MAPSCENEDATA_MAPEFFECTAURA_FIELD.label = 1
MAPSCENEDATA_MAPEFFECTAURA_FIELD.has_default_value = false
MAPSCENEDATA_MAPEFFECTAURA_FIELD.default_value = ""
MAPSCENEDATA_MAPEFFECTAURA_FIELD.type = 9
MAPSCENEDATA_MAPEFFECTAURA_FIELD.cpp_type = 9

MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.name = "MapEffecttransfer"
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.full_name = ".MapSceneData.MapEffecttransfer"
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.number = 24
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.index = 23
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.label = 1
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.has_default_value = false
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.default_value = ""
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.type = 9
MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD.cpp_type = 9

MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.name = "MapEffectArrive"
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.full_name = ".MapSceneData.MapEffectArrive"
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.number = 25
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.index = 24
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.label = 1
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.has_default_value = false
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.default_value = ""
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.type = 9
MAPSCENEDATA_MAPEFFECTARRIVE_FIELD.cpp_type = 9

MAPSCENEDATA_PATHGRAPHS_FIELD.name = "PathGraphs"
MAPSCENEDATA_PATHGRAPHS_FIELD.full_name = ".MapSceneData.PathGraphs"
MAPSCENEDATA_PATHGRAPHS_FIELD.number = 26
MAPSCENEDATA_PATHGRAPHS_FIELD.index = 25
MAPSCENEDATA_PATHGRAPHS_FIELD.label = 3
MAPSCENEDATA_PATHGRAPHS_FIELD.has_default_value = false
MAPSCENEDATA_PATHGRAPHS_FIELD.default_value = {}
MAPSCENEDATA_PATHGRAPHS_FIELD.message_type = MAPPOSITIONGRAPH
MAPSCENEDATA_PATHGRAPHS_FIELD.type = 11
MAPSCENEDATA_PATHGRAPHS_FIELD.cpp_type = 10

MAPSCENEDATA.name = "MapSceneData"
MAPSCENEDATA.full_name = ".MapSceneData"
MAPSCENEDATA.nested_types = {}
MAPSCENEDATA.enum_types = {}
MAPSCENEDATA.fields = {MAPSCENEDATA_MAPID_FIELD, MAPSCENEDATA_SCENENAME_FIELD, MAPSCENEDATA_SCENEFILENAME_FIELD, MAPSCENEDATA_CLIENTSCENENAME_FIELD, MAPSCENEDATA_MAPSIMPLIFY_FIELD, MAPSCENEDATA_MAPSIMPLIFYROTATE1_FIELD, MAPSCENEDATA_MAPSIMPLIFYROTATE2_FIELD, MAPSCENEDATA_MAPPOSX_FIELD, MAPSCENEDATA_MAPPOSY_FIELD, MAPSCENEDATA_MAPPIVOTX_FIELD, MAPSCENEDATA_MAPPIVOTY_FIELD, MAPSCENEDATA_UIWORLDRATIO_FIELD, MAPSCENEDATA_MAPDETAILED_FIELD, MAPSCENEDATA_MAPDETAILEDROTATE1_FIELD, MAPSCENEDATA_MAPDETAILEDROTATE2_FIELD, MAPSCENEDATA_SERVERUIRADIO_FIELD, MAPSCENEDATA_PVP_FIELD, MAPSCENEDATA_SPRAYS_FIELD, MAPSCENEDATA_TEAMS_FIELD, MAPSCENEDATA_LOWMODEL_FIELD, MAPSCENEDATA_ALPHASPEED_FIELD, MAPSCENEDATA_TRANSFERRADIUS_FIELD, MAPSCENEDATA_MAPEFFECTAURA_FIELD, MAPSCENEDATA_MAPEFFECTTRANSFER_FIELD, MAPSCENEDATA_MAPEFFECTARRIVE_FIELD, MAPSCENEDATA_PATHGRAPHS_FIELD}
MAPSCENEDATA.is_extendable = false
MAPSCENEDATA.extensions = {}
MAPBASEPLAYMODEDATA_TYPE_FIELD.name = "Type"
MAPBASEPLAYMODEDATA_TYPE_FIELD.full_name = ".MapBasePlaymodeData.Type"
MAPBASEPLAYMODEDATA_TYPE_FIELD.number = 5
MAPBASEPLAYMODEDATA_TYPE_FIELD.index = 0
MAPBASEPLAYMODEDATA_TYPE_FIELD.label = 1
MAPBASEPLAYMODEDATA_TYPE_FIELD.has_default_value = true
MAPBASEPLAYMODEDATA_TYPE_FIELD.default_value = -1
MAPBASEPLAYMODEDATA_TYPE_FIELD.type = 17
MAPBASEPLAYMODEDATA_TYPE_FIELD.cpp_type = 1

MAPBASEPLAYMODEDATA_DESC1_FIELD.name = "Desc1"
MAPBASEPLAYMODEDATA_DESC1_FIELD.full_name = ".MapBasePlaymodeData.Desc1"
MAPBASEPLAYMODEDATA_DESC1_FIELD.number = 1
MAPBASEPLAYMODEDATA_DESC1_FIELD.index = 1
MAPBASEPLAYMODEDATA_DESC1_FIELD.label = 1
MAPBASEPLAYMODEDATA_DESC1_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_DESC1_FIELD.default_value = ""
MAPBASEPLAYMODEDATA_DESC1_FIELD.type = 9
MAPBASEPLAYMODEDATA_DESC1_FIELD.cpp_type = 9

MAPBASEPLAYMODEDATA_DESC2_FIELD.name = "Desc2"
MAPBASEPLAYMODEDATA_DESC2_FIELD.full_name = ".MapBasePlaymodeData.Desc2"
MAPBASEPLAYMODEDATA_DESC2_FIELD.number = 2
MAPBASEPLAYMODEDATA_DESC2_FIELD.index = 2
MAPBASEPLAYMODEDATA_DESC2_FIELD.label = 1
MAPBASEPLAYMODEDATA_DESC2_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_DESC2_FIELD.default_value = ""
MAPBASEPLAYMODEDATA_DESC2_FIELD.type = 9
MAPBASEPLAYMODEDATA_DESC2_FIELD.cpp_type = 9

MAPBASEPLAYMODEDATA_MODENAME_FIELD.name = "ModeName"
MAPBASEPLAYMODEDATA_MODENAME_FIELD.full_name = ".MapBasePlaymodeData.ModeName"
MAPBASEPLAYMODEDATA_MODENAME_FIELD.number = 3
MAPBASEPLAYMODEDATA_MODENAME_FIELD.index = 3
MAPBASEPLAYMODEDATA_MODENAME_FIELD.label = 1
MAPBASEPLAYMODEDATA_MODENAME_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_MODENAME_FIELD.default_value = ""
MAPBASEPLAYMODEDATA_MODENAME_FIELD.type = 9
MAPBASEPLAYMODEDATA_MODENAME_FIELD.cpp_type = 9

MAPBASEPLAYMODEDATA_UIBG_FIELD.name = "Uibg"
MAPBASEPLAYMODEDATA_UIBG_FIELD.full_name = ".MapBasePlaymodeData.Uibg"
MAPBASEPLAYMODEDATA_UIBG_FIELD.number = 4
MAPBASEPLAYMODEDATA_UIBG_FIELD.index = 4
MAPBASEPLAYMODEDATA_UIBG_FIELD.label = 1
MAPBASEPLAYMODEDATA_UIBG_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_UIBG_FIELD.default_value = ""
MAPBASEPLAYMODEDATA_UIBG_FIELD.type = 9
MAPBASEPLAYMODEDATA_UIBG_FIELD.cpp_type = 9

MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.name = "MainCameras"
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.full_name = ".MapBasePlaymodeData.MainCameras"
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.number = 6
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.index = 5
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.label = 3
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.default_value = {}
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.message_type = MAPCAMERADATA
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.type = 11
MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD.cpp_type = 10

MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.name = "SlaveCameras"
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.full_name = ".MapBasePlaymodeData.SlaveCameras"
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.number = 7
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.index = 6
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.label = 3
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.default_value = {}
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.message_type = MAPCAMERADATA
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.type = 11
MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD.cpp_type = 10

MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.name = "Liftings"
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.full_name = ".MapBasePlaymodeData.Liftings"
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.number = 8
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.index = 7
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.label = 3
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.default_value = {}
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.message_type = MAPLIFTINGCONFIG
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.type = 11
MAPBASEPLAYMODEDATA_LIFTINGS_FIELD.cpp_type = 10

MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.name = "CharacterAnim"
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.full_name = ".MapBasePlaymodeData.CharacterAnim"
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.number = 9
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.index = 8
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.label = 1
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.default_value = ""
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.type = 9
MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD.cpp_type = 9

MAPBASEPLAYMODEDATA_READYFILE_FIELD.name = "ReadyFile"
MAPBASEPLAYMODEDATA_READYFILE_FIELD.full_name = ".MapBasePlaymodeData.ReadyFile"
MAPBASEPLAYMODEDATA_READYFILE_FIELD.number = 10
MAPBASEPLAYMODEDATA_READYFILE_FIELD.index = 9
MAPBASEPLAYMODEDATA_READYFILE_FIELD.label = 1
MAPBASEPLAYMODEDATA_READYFILE_FIELD.has_default_value = false
MAPBASEPLAYMODEDATA_READYFILE_FIELD.default_value = ""
MAPBASEPLAYMODEDATA_READYFILE_FIELD.type = 9
MAPBASEPLAYMODEDATA_READYFILE_FIELD.cpp_type = 9

MAPBASEPLAYMODEDATA_READYTIME_FIELD.name = "ReadyTime"
MAPBASEPLAYMODEDATA_READYTIME_FIELD.full_name = ".MapBasePlaymodeData.ReadyTime"
MAPBASEPLAYMODEDATA_READYTIME_FIELD.number = 11
MAPBASEPLAYMODEDATA_READYTIME_FIELD.index = 10
MAPBASEPLAYMODEDATA_READYTIME_FIELD.label = 1
MAPBASEPLAYMODEDATA_READYTIME_FIELD.has_default_value = true
MAPBASEPLAYMODEDATA_READYTIME_FIELD.default_value = -1
MAPBASEPLAYMODEDATA_READYTIME_FIELD.type = 2
MAPBASEPLAYMODEDATA_READYTIME_FIELD.cpp_type = 6

MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.name = "ControlTime"
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.full_name = ".MapBasePlaymodeData.ControlTime"
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.number = 12
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.index = 11
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.label = 1
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.has_default_value = true
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.default_value = -1
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.type = 2
MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD.cpp_type = 6

MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.name = "ChangePriTime"
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.full_name = ".MapBasePlaymodeData.ChangePriTime"
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.number = 13
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.index = 12
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.label = 1
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.has_default_value = true
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.default_value = -1
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.type = 2
MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD.cpp_type = 6

MAPBASEPLAYMODEDATA.name = "MapBasePlaymodeData"
MAPBASEPLAYMODEDATA.full_name = ".MapBasePlaymodeData"
MAPBASEPLAYMODEDATA.nested_types = {}
MAPBASEPLAYMODEDATA.enum_types = {}
MAPBASEPLAYMODEDATA.fields = {MAPBASEPLAYMODEDATA_TYPE_FIELD, MAPBASEPLAYMODEDATA_DESC1_FIELD, MAPBASEPLAYMODEDATA_DESC2_FIELD, MAPBASEPLAYMODEDATA_MODENAME_FIELD, MAPBASEPLAYMODEDATA_UIBG_FIELD, MAPBASEPLAYMODEDATA_MAINCAMERAS_FIELD, MAPBASEPLAYMODEDATA_SLAVECAMERAS_FIELD, MAPBASEPLAYMODEDATA_LIFTINGS_FIELD, MAPBASEPLAYMODEDATA_CHARACTERANIM_FIELD, MAPBASEPLAYMODEDATA_READYFILE_FIELD, MAPBASEPLAYMODEDATA_READYTIME_FIELD, MAPBASEPLAYMODEDATA_CONTROLTIME_FIELD, MAPBASEPLAYMODEDATA_CHANGEPRITIME_FIELD}
MAPBASEPLAYMODEDATA.is_extendable = false
MAPBASEPLAYMODEDATA.extensions = {}
MAPTEAMDATA_GUARD_FIELD.name = "Guard"
MAPTEAMDATA_GUARD_FIELD.full_name = ".MapTeamData.Guard"
MAPTEAMDATA_GUARD_FIELD.number = 1
MAPTEAMDATA_GUARD_FIELD.index = 0
MAPTEAMDATA_GUARD_FIELD.label = 1
MAPTEAMDATA_GUARD_FIELD.has_default_value = false
MAPTEAMDATA_GUARD_FIELD.default_value = ""
MAPTEAMDATA_GUARD_FIELD.type = 9
MAPTEAMDATA_GUARD_FIELD.cpp_type = 9

MAPTEAMDATA_PEDESTAL_FIELD.name = "Pedestal"
MAPTEAMDATA_PEDESTAL_FIELD.full_name = ".MapTeamData.Pedestal"
MAPTEAMDATA_PEDESTAL_FIELD.number = 2
MAPTEAMDATA_PEDESTAL_FIELD.index = 1
MAPTEAMDATA_PEDESTAL_FIELD.label = 1
MAPTEAMDATA_PEDESTAL_FIELD.has_default_value = false
MAPTEAMDATA_PEDESTAL_FIELD.default_value = ""
MAPTEAMDATA_PEDESTAL_FIELD.type = 9
MAPTEAMDATA_PEDESTAL_FIELD.cpp_type = 9

MAPTEAMDATA_SPAWNPOINTS_FIELD.name = "SpawnPoints"
MAPTEAMDATA_SPAWNPOINTS_FIELD.full_name = ".MapTeamData.SpawnPoints"
MAPTEAMDATA_SPAWNPOINTS_FIELD.number = 3
MAPTEAMDATA_SPAWNPOINTS_FIELD.index = 2
MAPTEAMDATA_SPAWNPOINTS_FIELD.label = 3
MAPTEAMDATA_SPAWNPOINTS_FIELD.has_default_value = false
MAPTEAMDATA_SPAWNPOINTS_FIELD.default_value = {}
MAPTEAMDATA_SPAWNPOINTS_FIELD.message_type = MAPPRS
MAPTEAMDATA_SPAWNPOINTS_FIELD.type = 11
MAPTEAMDATA_SPAWNPOINTS_FIELD.cpp_type = 10

MAPTEAMDATA_LIFTING_FIELD.name = "Lifting"
MAPTEAMDATA_LIFTING_FIELD.full_name = ".MapTeamData.Lifting"
MAPTEAMDATA_LIFTING_FIELD.number = 4
MAPTEAMDATA_LIFTING_FIELD.index = 3
MAPTEAMDATA_LIFTING_FIELD.label = 1
MAPTEAMDATA_LIFTING_FIELD.has_default_value = false
MAPTEAMDATA_LIFTING_FIELD.default_value = ""
MAPTEAMDATA_LIFTING_FIELD.type = 9
MAPTEAMDATA_LIFTING_FIELD.cpp_type = 9

MAPTEAMDATA_ID_FIELD.name = "Id"
MAPTEAMDATA_ID_FIELD.full_name = ".MapTeamData.Id"
MAPTEAMDATA_ID_FIELD.number = 5
MAPTEAMDATA_ID_FIELD.index = 4
MAPTEAMDATA_ID_FIELD.label = 1
MAPTEAMDATA_ID_FIELD.has_default_value = true
MAPTEAMDATA_ID_FIELD.default_value = -1
MAPTEAMDATA_ID_FIELD.type = 17
MAPTEAMDATA_ID_FIELD.cpp_type = 1

MAPTEAMDATA_COLOR_FIELD.name = "Color"
MAPTEAMDATA_COLOR_FIELD.full_name = ".MapTeamData.Color"
MAPTEAMDATA_COLOR_FIELD.number = 6
MAPTEAMDATA_COLOR_FIELD.index = 5
MAPTEAMDATA_COLOR_FIELD.label = 1
MAPTEAMDATA_COLOR_FIELD.has_default_value = false
MAPTEAMDATA_COLOR_FIELD.default_value = nil
MAPTEAMDATA_COLOR_FIELD.message_type = PUBLICSTRUCT_PB_COLOR4PB
MAPTEAMDATA_COLOR_FIELD.type = 11
MAPTEAMDATA_COLOR_FIELD.cpp_type = 10

MAPTEAMDATA_PEDESTALPOSITION_FIELD.name = "PedestalPosition"
MAPTEAMDATA_PEDESTALPOSITION_FIELD.full_name = ".MapTeamData.PedestalPosition"
MAPTEAMDATA_PEDESTALPOSITION_FIELD.number = 7
MAPTEAMDATA_PEDESTALPOSITION_FIELD.index = 6
MAPTEAMDATA_PEDESTALPOSITION_FIELD.label = 1
MAPTEAMDATA_PEDESTALPOSITION_FIELD.has_default_value = false
MAPTEAMDATA_PEDESTALPOSITION_FIELD.default_value = nil
MAPTEAMDATA_PEDESTALPOSITION_FIELD.message_type = PUBLICSTRUCT_PB_VECTOR3PB
MAPTEAMDATA_PEDESTALPOSITION_FIELD.type = 11
MAPTEAMDATA_PEDESTALPOSITION_FIELD.cpp_type = 10

MAPTEAMDATA.name = "MapTeamData"
MAPTEAMDATA.full_name = ".MapTeamData"
MAPTEAMDATA.nested_types = {}
MAPTEAMDATA.enum_types = {}
MAPTEAMDATA.fields = {MAPTEAMDATA_GUARD_FIELD, MAPTEAMDATA_PEDESTAL_FIELD, MAPTEAMDATA_SPAWNPOINTS_FIELD, MAPTEAMDATA_LIFTING_FIELD, MAPTEAMDATA_ID_FIELD, MAPTEAMDATA_COLOR_FIELD, MAPTEAMDATA_PEDESTALPOSITION_FIELD}
MAPTEAMDATA.is_extendable = false
MAPTEAMDATA.extensions = {}
MAPSPRAYDATA_NAME_FIELD.name = "Name"
MAPSPRAYDATA_NAME_FIELD.full_name = ".MapSprayData.Name"
MAPSPRAYDATA_NAME_FIELD.number = 1
MAPSPRAYDATA_NAME_FIELD.index = 0
MAPSPRAYDATA_NAME_FIELD.label = 1
MAPSPRAYDATA_NAME_FIELD.has_default_value = false
MAPSPRAYDATA_NAME_FIELD.default_value = ""
MAPSPRAYDATA_NAME_FIELD.type = 9
MAPSPRAYDATA_NAME_FIELD.cpp_type = 9

MAPSPRAYDATA_POSITION_FIELD.name = "Position"
MAPSPRAYDATA_POSITION_FIELD.full_name = ".MapSprayData.Position"
MAPSPRAYDATA_POSITION_FIELD.number = 2
MAPSPRAYDATA_POSITION_FIELD.index = 1
MAPSPRAYDATA_POSITION_FIELD.label = 1
MAPSPRAYDATA_POSITION_FIELD.has_default_value = false
MAPSPRAYDATA_POSITION_FIELD.default_value = nil
MAPSPRAYDATA_POSITION_FIELD.message_type = PUBLICSTRUCT_PB_VECTOR3PB
MAPSPRAYDATA_POSITION_FIELD.type = 11
MAPSPRAYDATA_POSITION_FIELD.cpp_type = 10

MAPSPRAYDATA_DPI_FIELD.name = "Dpi"
MAPSPRAYDATA_DPI_FIELD.full_name = ".MapSprayData.Dpi"
MAPSPRAYDATA_DPI_FIELD.number = 3
MAPSPRAYDATA_DPI_FIELD.index = 2
MAPSPRAYDATA_DPI_FIELD.label = 1
MAPSPRAYDATA_DPI_FIELD.has_default_value = true
MAPSPRAYDATA_DPI_FIELD.default_value = -1
MAPSPRAYDATA_DPI_FIELD.type = 17
MAPSPRAYDATA_DPI_FIELD.cpp_type = 1

MAPSPRAYDATA_COEFFICIENT_FIELD.name = "Coefficient"
MAPSPRAYDATA_COEFFICIENT_FIELD.full_name = ".MapSprayData.Coefficient"
MAPSPRAYDATA_COEFFICIENT_FIELD.number = 4
MAPSPRAYDATA_COEFFICIENT_FIELD.index = 3
MAPSPRAYDATA_COEFFICIENT_FIELD.label = 1
MAPSPRAYDATA_COEFFICIENT_FIELD.has_default_value = true
MAPSPRAYDATA_COEFFICIENT_FIELD.default_value = -1
MAPSPRAYDATA_COEFFICIENT_FIELD.type = 2
MAPSPRAYDATA_COEFFICIENT_FIELD.cpp_type = 6

MAPSPRAYDATA.name = "MapSprayData"
MAPSPRAYDATA.full_name = ".MapSprayData"
MAPSPRAYDATA.nested_types = {}
MAPSPRAYDATA.enum_types = {}
MAPSPRAYDATA.fields = {MAPSPRAYDATA_NAME_FIELD, MAPSPRAYDATA_POSITION_FIELD, MAPSPRAYDATA_DPI_FIELD, MAPSPRAYDATA_COEFFICIENT_FIELD}
MAPSPRAYDATA.is_extendable = false
MAPSPRAYDATA.extensions = {}
MAPPVPDATA_BASEDATA_FIELD.name = "BaseData"
MAPPVPDATA_BASEDATA_FIELD.full_name = ".MapPvpData.BaseData"
MAPPVPDATA_BASEDATA_FIELD.number = 1
MAPPVPDATA_BASEDATA_FIELD.index = 0
MAPPVPDATA_BASEDATA_FIELD.label = 1
MAPPVPDATA_BASEDATA_FIELD.has_default_value = false
MAPPVPDATA_BASEDATA_FIELD.default_value = nil
MAPPVPDATA_BASEDATA_FIELD.message_type = MAPBASEPLAYMODEDATA
MAPPVPDATA_BASEDATA_FIELD.type = 11
MAPPVPDATA_BASEDATA_FIELD.cpp_type = 10

MAPPVPDATA_ADDHERE_FIELD.name = "AddHere"
MAPPVPDATA_ADDHERE_FIELD.full_name = ".MapPvpData.AddHere"
MAPPVPDATA_ADDHERE_FIELD.number = 2
MAPPVPDATA_ADDHERE_FIELD.index = 1
MAPPVPDATA_ADDHERE_FIELD.label = 1
MAPPVPDATA_ADDHERE_FIELD.has_default_value = false
MAPPVPDATA_ADDHERE_FIELD.default_value = ""
MAPPVPDATA_ADDHERE_FIELD.type = 9
MAPPVPDATA_ADDHERE_FIELD.cpp_type = 9

MAPPVPDATA.name = "MapPvpData"
MAPPVPDATA.full_name = ".MapPvpData"
MAPPVPDATA.nested_types = {}
MAPPVPDATA.enum_types = {}
MAPPVPDATA.fields = {MAPPVPDATA_BASEDATA_FIELD, MAPPVPDATA_ADDHERE_FIELD}
MAPPVPDATA.is_extendable = false
MAPPVPDATA.extensions = {}
MAPPRS_POSITION_FIELD.name = "Position"
MAPPRS_POSITION_FIELD.full_name = ".MapPRS.Position"
MAPPRS_POSITION_FIELD.number = 1
MAPPRS_POSITION_FIELD.index = 0
MAPPRS_POSITION_FIELD.label = 1
MAPPRS_POSITION_FIELD.has_default_value = false
MAPPRS_POSITION_FIELD.default_value = nil
MAPPRS_POSITION_FIELD.message_type = PUBLICSTRUCT_PB_VECTOR3PB
MAPPRS_POSITION_FIELD.type = 11
MAPPRS_POSITION_FIELD.cpp_type = 10

MAPPRS_EULARROTATION_FIELD.name = "EularRotation"
MAPPRS_EULARROTATION_FIELD.full_name = ".MapPRS.EularRotation"
MAPPRS_EULARROTATION_FIELD.number = 2
MAPPRS_EULARROTATION_FIELD.index = 1
MAPPRS_EULARROTATION_FIELD.label = 1
MAPPRS_EULARROTATION_FIELD.has_default_value = false
MAPPRS_EULARROTATION_FIELD.default_value = nil
MAPPRS_EULARROTATION_FIELD.message_type = PUBLICSTRUCT_PB_VECTOR3PB
MAPPRS_EULARROTATION_FIELD.type = 11
MAPPRS_EULARROTATION_FIELD.cpp_type = 10

MAPPRS_SCALE_FIELD.name = "Scale"
MAPPRS_SCALE_FIELD.full_name = ".MapPRS.Scale"
MAPPRS_SCALE_FIELD.number = 3
MAPPRS_SCALE_FIELD.index = 2
MAPPRS_SCALE_FIELD.label = 1
MAPPRS_SCALE_FIELD.has_default_value = false
MAPPRS_SCALE_FIELD.default_value = nil
MAPPRS_SCALE_FIELD.message_type = PUBLICSTRUCT_PB_VECTOR3PB
MAPPRS_SCALE_FIELD.type = 11
MAPPRS_SCALE_FIELD.cpp_type = 10

MAPPRS.name = "MapPRS"
MAPPRS.full_name = ".MapPRS"
MAPPRS.nested_types = {}
MAPPRS.enum_types = {}
MAPPRS.fields = {MAPPRS_POSITION_FIELD, MAPPRS_EULARROTATION_FIELD, MAPPRS_SCALE_FIELD}
MAPPRS.is_extendable = false
MAPPRS.extensions = {}
MAPCAMERADATA_PATH_FIELD.name = "Path"
MAPCAMERADATA_PATH_FIELD.full_name = ".MapCameraData.Path"
MAPCAMERADATA_PATH_FIELD.number = 1
MAPCAMERADATA_PATH_FIELD.index = 0
MAPCAMERADATA_PATH_FIELD.label = 1
MAPCAMERADATA_PATH_FIELD.has_default_value = false
MAPCAMERADATA_PATH_FIELD.default_value = ""
MAPCAMERADATA_PATH_FIELD.type = 9
MAPCAMERADATA_PATH_FIELD.cpp_type = 9

MAPCAMERADATA_STARTTIME_FIELD.name = "StartTime"
MAPCAMERADATA_STARTTIME_FIELD.full_name = ".MapCameraData.StartTime"
MAPCAMERADATA_STARTTIME_FIELD.number = 2
MAPCAMERADATA_STARTTIME_FIELD.index = 1
MAPCAMERADATA_STARTTIME_FIELD.label = 1
MAPCAMERADATA_STARTTIME_FIELD.has_default_value = true
MAPCAMERADATA_STARTTIME_FIELD.default_value = -1
MAPCAMERADATA_STARTTIME_FIELD.type = 2
MAPCAMERADATA_STARTTIME_FIELD.cpp_type = 6

MAPCAMERADATA_ENDTIME_FIELD.name = "EndTime"
MAPCAMERADATA_ENDTIME_FIELD.full_name = ".MapCameraData.EndTime"
MAPCAMERADATA_ENDTIME_FIELD.number = 3
MAPCAMERADATA_ENDTIME_FIELD.index = 2
MAPCAMERADATA_ENDTIME_FIELD.label = 1
MAPCAMERADATA_ENDTIME_FIELD.has_default_value = true
MAPCAMERADATA_ENDTIME_FIELD.default_value = -1
MAPCAMERADATA_ENDTIME_FIELD.type = 2
MAPCAMERADATA_ENDTIME_FIELD.cpp_type = 6

MAPCAMERADATA.name = "MapCameraData"
MAPCAMERADATA.full_name = ".MapCameraData"
MAPCAMERADATA.nested_types = {}
MAPCAMERADATA.enum_types = {}
MAPCAMERADATA.fields = {MAPCAMERADATA_PATH_FIELD, MAPCAMERADATA_STARTTIME_FIELD, MAPCAMERADATA_ENDTIME_FIELD}
MAPCAMERADATA.is_extendable = false
MAPCAMERADATA.extensions = {}
MAPLIFTINGCONFIG_STARTTIME_FIELD.name = "StartTime"
MAPLIFTINGCONFIG_STARTTIME_FIELD.full_name = ".MapLiftingConfig.StartTime"
MAPLIFTINGCONFIG_STARTTIME_FIELD.number = 1
MAPLIFTINGCONFIG_STARTTIME_FIELD.index = 0
MAPLIFTINGCONFIG_STARTTIME_FIELD.label = 1
MAPLIFTINGCONFIG_STARTTIME_FIELD.has_default_value = true
MAPLIFTINGCONFIG_STARTTIME_FIELD.default_value = -1
MAPLIFTINGCONFIG_STARTTIME_FIELD.type = 2
MAPLIFTINGCONFIG_STARTTIME_FIELD.cpp_type = 6

MAPLIFTINGCONFIG_SPEED_FIELD.name = "Speed"
MAPLIFTINGCONFIG_SPEED_FIELD.full_name = ".MapLiftingConfig.Speed"
MAPLIFTINGCONFIG_SPEED_FIELD.number = 2
MAPLIFTINGCONFIG_SPEED_FIELD.index = 1
MAPLIFTINGCONFIG_SPEED_FIELD.label = 1
MAPLIFTINGCONFIG_SPEED_FIELD.has_default_value = true
MAPLIFTINGCONFIG_SPEED_FIELD.default_value = -1
MAPLIFTINGCONFIG_SPEED_FIELD.type = 2
MAPLIFTINGCONFIG_SPEED_FIELD.cpp_type = 6

MAPLIFTINGCONFIG.name = "MapLiftingConfig"
MAPLIFTINGCONFIG.full_name = ".MapLiftingConfig"
MAPLIFTINGCONFIG.nested_types = {}
MAPLIFTINGCONFIG.enum_types = {}
MAPLIFTINGCONFIG.fields = {MAPLIFTINGCONFIG_STARTTIME_FIELD, MAPLIFTINGCONFIG_SPEED_FIELD}
MAPLIFTINGCONFIG.is_extendable = false
MAPLIFTINGCONFIG.extensions = {}
MAPPOSITIONGRAPH_ID_FIELD.name = "Id"
MAPPOSITIONGRAPH_ID_FIELD.full_name = ".MapPositionGraph.Id"
MAPPOSITIONGRAPH_ID_FIELD.number = 1
MAPPOSITIONGRAPH_ID_FIELD.index = 0
MAPPOSITIONGRAPH_ID_FIELD.label = 1
MAPPOSITIONGRAPH_ID_FIELD.has_default_value = true
MAPPOSITIONGRAPH_ID_FIELD.default_value = -1
MAPPOSITIONGRAPH_ID_FIELD.type = 17
MAPPOSITIONGRAPH_ID_FIELD.cpp_type = 1

MAPPOSITIONGRAPH_VERTICES_FIELD.name = "Vertices"
MAPPOSITIONGRAPH_VERTICES_FIELD.full_name = ".MapPositionGraph.Vertices"
MAPPOSITIONGRAPH_VERTICES_FIELD.number = 2
MAPPOSITIONGRAPH_VERTICES_FIELD.index = 1
MAPPOSITIONGRAPH_VERTICES_FIELD.label = 3
MAPPOSITIONGRAPH_VERTICES_FIELD.has_default_value = false
MAPPOSITIONGRAPH_VERTICES_FIELD.default_value = {}
MAPPOSITIONGRAPH_VERTICES_FIELD.message_type = PUBLICSTRUCT_PB_VECTOR3PB
MAPPOSITIONGRAPH_VERTICES_FIELD.type = 11
MAPPOSITIONGRAPH_VERTICES_FIELD.cpp_type = 10

MAPPOSITIONGRAPH_EDGES_FIELD.name = "Edges"
MAPPOSITIONGRAPH_EDGES_FIELD.full_name = ".MapPositionGraph.Edges"
MAPPOSITIONGRAPH_EDGES_FIELD.number = 3
MAPPOSITIONGRAPH_EDGES_FIELD.index = 2
MAPPOSITIONGRAPH_EDGES_FIELD.label = 3
MAPPOSITIONGRAPH_EDGES_FIELD.has_default_value = false
MAPPOSITIONGRAPH_EDGES_FIELD.default_value = {}
MAPPOSITIONGRAPH_EDGES_FIELD.message_type = PUBLICSTRUCT_PB_VECTOR2INTPB
MAPPOSITIONGRAPH_EDGES_FIELD.type = 11
MAPPOSITIONGRAPH_EDGES_FIELD.cpp_type = 10

MAPPOSITIONGRAPH.name = "MapPositionGraph"
MAPPOSITIONGRAPH.full_name = ".MapPositionGraph"
MAPPOSITIONGRAPH.nested_types = {}
MAPPOSITIONGRAPH.enum_types = {}
MAPPOSITIONGRAPH.fields = {MAPPOSITIONGRAPH_ID_FIELD, MAPPOSITIONGRAPH_VERTICES_FIELD, MAPPOSITIONGRAPH_EDGES_FIELD}
MAPPOSITIONGRAPH.is_extendable = false
MAPPOSITIONGRAPH.extensions = {}

MapBasePlaymodeData = protobuf.Message(MAPBASEPLAYMODEDATA)
MapCameraData = protobuf.Message(MAPCAMERADATA)
MapLiftingConfig = protobuf.Message(MAPLIFTINGCONFIG)
MapPRS = protobuf.Message(MAPPRS)
MapPositionGraph = protobuf.Message(MAPPOSITIONGRAPH)
MapPvpData = protobuf.Message(MAPPVPDATA)
MapSceneData = protobuf.Message(MAPSCENEDATA)
MapSprayData = protobuf.Message(MAPSPRAYDATA)
MapTeamData = protobuf.Message(MAPTEAMDATA)
