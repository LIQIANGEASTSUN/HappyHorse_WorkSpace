local config = [====[{
"100":{"id":"100","unlockLevel":12,"sceneOpenTime":7,"sceneCloseTime":12,"sceneOpenCD":3,"nextScene":"102","sceneID":"21Christmas","reward":[[30,4220,50],[60,4220,60],[90,4220,70],[120,4220,80],[150,27522,1]],"taskButtonIcon":"ui_task_type03","sceneIconShow":1},
"102":{"id":"102","unlockLevel":12,"sceneOpenTime":7,"sceneCloseTime":12,"sceneOpenCD":3,"nextScene":"103","sceneID":"22AdvIsland","reward":[[30,4243,50],[60,4243,60],[90,4243,70],[120,4243,80],[150,27524,1]],"taskButtonIcon":"ui_task_type04","sceneIconShow":1},
"103":{"id":"103","unlockLevel":12,"sceneOpenTime":7,"sceneCloseTime":12,"sceneOpenCD":3,"nextScene":"104","sceneID":"2204CallGodBall","reward":[[30,1003,50],[70,4315,3],[140,34000,10],[230,11001,1],[320,1003,150],[410,4315,5],[550,141701,1]],"taskButtonIcon":"ui_task_type05","sceneIconShow":1},
"104":{"id":"104","unlockLevel":12,"sceneOpenTime":7,"sceneCloseTime":12,"sceneOpenCD":3,"nextScene":0.0,"sceneID":"2205DragonMuseum","reward":[[30,1003,50],[70,4387,3],[140,34000,10],[230,11001,1],[320,1003,150],[410,4387,8],[550,142001,1]],"taskButtonIcon":"ui_task_type06","sceneIconShow":1}
}]====]
return table.deserialize(config)