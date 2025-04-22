
# UI 屏幕飘字

#### 屏幕中间弹出一条提示文本

从屏幕中间开始向上移动

代码在 UITipsController.cs
具体文本代码是 UITipsItem.cs


UITipsController 中使用了复用池



``` csharp

// 执行复用池使用 类复用池 UITipsItem
PoolManager.Instance.SetSpawnClassCapacity<UITipsItem>(5);

// 显示 提示文本 调用下面代码

UITipsController.Instance.ShowTips("测试 Tips");

```











