local config = [====[
syntax = "proto2";
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


  message DItemSPO {
    repeated DStrInt itemData = 1;
    repeated DStrStr testMap = 2;
    required int32 testInt = 3;
  }
// -----------------------------------------
// account
//

// -----------------------------------------
// 结构体
//


// -----------------------------------------
// 客户端请求：登录请求
message LoginRequest {
  required string channelId = 1;    // 渠道id
  required string userIdentity = 2; // 用户标识，SDKUserId或用户名
  required string token = 3;        // token
  required string deviceId = 4;     // 设备id
  required string version = 5;      // 客户端版本号
}

// 服务器返回：登录请求返回结果
message LoginResponse {
  required int32 resultCode = 1; // 0=成功
}

// 客户端请求：登出
message LogoutRequest {
}
// -----------------------------------------
// common
//

// -----------------------------------------

//心跳

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
  required DItemSPO item = 1;
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
}]====]

return config