local config = [====[ syntax = "proto2";
option optimize_for = CODE_SIZE;

// -----------------------------------------
// 数据集合体
// -----------------------------------------

message DStrStr {
  required string key = 1;
  required string value = 2;
}

message DStrInt {
  required string key = 1;
  required int32 value = 2;
}

message DStrLong {
  required string key = 1;
  required int64 value = 2;
}

message DIntInt {
  required int32 key = 1;
  required int32 value = 2;
}

//坐标
message DPos {
  required int32 x = 1;
  required int32 y = 2;
} 

//地图元素
message DMapObj {
  required string id = 1;   //地图元素唯一id
  required int32 level = 2; //地图元素等级
  required DPos pos = 3;    //地图元素坐标
  required int32 tid = 4;   //地图元素模板id
}

//道具
message DItem {
  required int32 sn = 1;     // SN
  required int32 num = 2;    // 数量
  required int64 itemId = 3; // 物品Id
}

//宠物
message DPet {
  required int32 id = 1;    // 唯一id
  required int32 type = 2;  // 宠物类型
  required int32 level = 3; // 等级
  required int32 up = 4;    // 是否上阵 0:未上阵 1:上阵
}

//建筑解锁进度
message DUnlockBuildingsProgress{
  required string id = 1;           // id
  repeated DIntInt progress = 2;    // 解锁进度
}

// 产出
message DProduction {
  required string id = 1;             // id
  required int32 level = 2;           // 开始生产的等级
  repeated DIntInt recipe = 3;        // 生产配方
  required int64 startTime = 4;       // 生产开始时间
  required int64 endTime = 5;         // 生产结束时间
  repeated DIntInt outItem = 6;       // 产出
  required int32 status = 7;          // 状态 0:已生成 1:生产中

}

// 装备
message DEquip {
  required int32 id = 1;             // id
  required int32 type = 2;           // 类型
  required int32 level = 3;          // 等级
  required int32 up = 4;             // 是否穿戴 0:未穿戴 1:穿戴
}

//------------------------- 初始下发信息 SPO -------------------------

//玩家信息初始下发
message DHumanInfoSPO {
  required int64 pid = 1;
  required string name = 2;
  required int32 level = 3;
  required int32 exp = 4;
}

//道具信息初始下发
message DItemInfoSPO { repeated DItem items = 1; }

//场景信息初始下发
message DSceneInfoSPO {
  required int32 sceneId = 1;               //玩家当前场景
  repeated DMapObj putBuildings = 2;        //玩家摆放的建筑
  repeated string removeBuildings = 3;      //玩家删除的建筑
  required int32 island = 4;                //玩家当前岛屿sn
  repeated int32 unlockIslands = 5;          //玩家解锁岛屿列表
  repeated DUnlockBuildingsProgress unlockBuildingsProgress = 6;    //玩家解锁建筑列表进度
  repeated DProduction production = 7;                              //玩家生产队列
  repeated int32 linkIslands = 8;          //玩家连接岛屿列表
}

message DPetInfoSPO {
  repeated DPet pets = 1; //玩家拥有的宠物列表
}

message DEquipInfoSPO {
  repeated DEquip equips = 1;            //玩家装备列表
}

//任务信息初始下发
message DTaskInfoSPO {
  repeated DIntInt progress = 1;  //任务进度
  repeated int32 finish = 2;      //已结束的任务
}

//------------------------- end -------------------------
// -----------------------------------------
// equip
//

// -----------------------------------------
// 结构体
//


// -----------------------------------------
//装备升级
message CSEquipLvUp {
    required int32 id = 1;
  }
  
message SCEquipLvUp {
    required int32 id = 1;
    required int32 level = 2;
}

//获得装备
message SCAddEquip {
  required int32 id = 1;
  required int32 type = 2;
  required int32 level = 3; 
}

//装备切换
message CSEquipChange {
  required int32 id = 1;
}

message SCEquipChange {
  required int32 id = 1;
}
// -----------------------------------------
// account
//

// -----------------------------------------
// 结构体
//


// -----------------------------------------
// 客户端请求：登录请求
message CSLogin {
  required string channelId = 1;    // 渠道id
  required string userIdentity = 2; // 用户标识，SDKUserId或用户名
  required string token = 3;        // token
  required string deviceId = 4;     // 设备id
  required string version = 5;      // 客户端版本号
}

// 服务器返回：登录请求返回结果
message SCLogin {
  required int32 resultCode = 1; // 0=成功
}

// 客户端请求：登出
message CSLogout {
}
// -----------------------------------------
// common
//

// -----------------------------------------

//心跳
message CSPing {
}

message SCPing {
  required int64 time = 1; //时间戳
}

// 服务器推送：错误提示
message SCHint {
  required int32 strId = 1;           // 提示表的id
  repeated string param = 2; // 参数的值
}

// GM工具
message CSGM {
  repeated string params = 1; // params
}

message SCGM {
}
// -----------------------------------------
// human
//

// -----------------------------------------
// 结构体
//

// -----------------------------------------

//角色登录
message CSRoleLogin {
  required int64 humanId = 1; //角色ID
}

//角色登录结果
message SCRoleLogin {
  required int32 resultCode = 1; //执行结果编码
}

// 登陆成功后推送所有模块的数据
message SCSPO {
  required DHumanInfoSPO humanInfo = 1;
  optional DItemInfoSPO itemInfo = 2;
  optional DSceneInfoSPO sceneInfo = 3;
  optional DPetInfoSPO petInfo = 4;
  optional DTaskInfoSPO taskInfo = 5;
  optional DEquipInfoSPO equipInfo = 6;
}

//角色升级
message SCRoleLevelUp {
	required string humanId 		= 1;      // 角色id
	required int32 level 				= 2;      // 等级
	required int32 exp 				  = 3;      // 经验
}
// -----------------------------------------
// item
//

// -----------------------------------------
// 结构体
//


// -----------------------------------------

//test
message CSTestItem {
  required int64 humanId = 1;
}

//test
message SCTestItem {
  required int32 resultCode = 1;
}
// -----------------------------------------
// group
//

// -----------------------------------------
// 结构体
//



// -----------------------------------------
//创建玩家群
message CSCreateGroup {
  required int64 humanId = 1;
}

message SCCreateGroup {
  required int64 groupId = 1;
}
// -----------------------------------------
// scene
//

// -----------------------------------------
// 结构体
//

// -----------------------------------------

//摆放建筑
message CSPutBuildings {
  required int32 tid = 1;         // 建筑模板id
  required DPos pos = 2;          // 建筑物位置坐标
  required string instanceId = 3; // 客户端生成建筑id
}

message SCPutBuildings {
  required string id = 1;         // 建筑物唯一id
  required string instanceId = 2; // 客户端生成建筑id
  required int32 errorCode = 3;   //错误码 成功:0
}

//移动建筑
message CSMoveBuildings {
  required string id = 1;  // 建筑物唯一id
  required DPos toPos = 2; // 建筑物位置坐标
}

message SCMoveBuildings {
  required string id = 1;       // 建筑物唯一id
  required int32 errorCode = 2; //错误码 成功:0
}

//删除建筑
message CSRemoveBuildings {
  required string id = 1; // 建筑物唯一id
}

message SCRemoveBuildings {
  required string id = 1; // 建筑物唯一id
}

//清理场景元素
message CSCleanObj {
  required string id = 1; // 场景元素id
}

message SCCleanObj {
  required string id = 1; // 场景元素id
}

//切换岛屿
message CSChangeIsland {
  required int32 sn = 1; // 岛屿sn
}

message SCChangeIsland {
  required int32 sn = 1; // 岛屿sn
}

//连接岛屿
message CSLinkIsland {
  required int32 sn = 1; // 岛屿sn
}

message SCLinkIsland {
  required int32 sn = 1; // 岛屿sn
}

//解锁建筑
message CSUnlockBuildings {
  required string id = 1; // id
  repeated DIntInt cost = 2; //解锁消耗
}

message SCUnlockBuildings {
  required string id = 1; // id
  required int32 status = 2; // 0:未解锁 1:已解锁
}

//升级建筑
message CSLevelBuildings {
  required string id = 1;  // 建筑物唯一id
}

message SCLevelBuildings {
  required string id = 1;     // 建筑物唯一id
  required int32 level = 2;   // 建筑等级
}


//开始生产
message CSStartProduction {
  required string id = 1;  // 建筑物唯一id
}

message SCStartProduction {
  required string id = 1;  // 建筑物唯一id
}

//结束生产 推送
message SCFinishProduction {
  required string id = 1;  // 建筑物唯一id
}

//领取产出
message CSTakeProduction {
  required string id = 1;  // 建筑物唯一id
}

message SCTakeProduction {
  required string id = 1;  // 建筑物唯一id
}

//回收道具
message CSRecycle {
  repeated DIntInt items = 1; //回收道具列表
}

message SCRecycle {
}

//装饰工厂订单
message CSDecorateOrder {
  required string id = 1;       //建筑物唯一id
  repeated DIntInt costs = 2;   //消耗道具列表
  repeated DIntInt rewards = 3; //产出道具列表
}

message SCDecorateOrder {
  required string id = 1;       //建筑物唯一id
}

//解锁岛屿
message CSUnlockIsland {
  required int32 sn = 1; // 岛屿sn
}

message SCUnlockIsland {
  required int32 sn = 1; // 岛屿sn
}

//开始生产订单
message CSStartProductionOrder {
  required string id = 1;  // 建筑物唯一id
}

message SCStartProductionOrder {
  required string id = 1;  // 建筑物唯一id
}
// -----------------------------------------
// item
//

// -----------------------------------------
// 结构体
//


// -----------------------------------------
//角色道具变化 返回的是最终值 不是变化值
message SCItemChanged {
  repeated DItem add = 1; // 数量增加 
	repeated DItem del = 2; // 数量减少
}
// -----------------------------------------
// pet
//

// -----------------------------------------
// 结构体
//

// -----------------------------------------
//获得宠物推送
message SCAddPet {
  required int32 petId = 1; //宠物唯一id
  required int32 type = 2; //宠物类型
  required int32 level = 3; //宠物等级
}


//上阵宠物
message CSPetUp {
  required int32 petId = 1; //宠物唯一id
}

message SCPetUp {
  required int32 petId = 1; //宠物唯一id
}

//下阵宠物
message CSPetDown {
  required int32 petId = 1; //宠物唯一id
}

message SCPetDown {
  required int32 petId = 1; //宠物唯一id
}

//宠物升级
message CSPetLevelUp {
  required int32 petId = 1; //宠物唯一id
}

message SCPetLevelUp {
  required int32 petId = 1; //宠物唯一id
  required int32 level = 2; //宠物等级
}

// -----------------------------------------
// extend
//

// -----------------------------------------
// 结构体
//


// -----------------------------------------

// -----------------------------------------
// task
//

// -----------------------------------------
// 结构体
//


// -----------------------------------------
//任务结束领奖
message CSTaskFinish {
    required int32 sn = 1;         // 任务sn
}

message SCTaskFinish {
    required int32 sn = 1;         // 任务sn
}
]====] return config