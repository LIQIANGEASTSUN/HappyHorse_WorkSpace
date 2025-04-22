
# 头顶 UI 气泡、血条、等级等



下面例子，跟随道具显示一个道具等级的气泡，实现步骤


#### 1、添加气泡类型枚举

```charp
    /// <summary>
    /// 气泡类型
    /// </summary>
    public enum UIBubbleType
    {

        /// <summary>
        /// 道具等级信息气泡
        /// </summary>
        ArticleLevelInfo = 10001,

    }
```


#### 2、创建一个数据类型，继承 IUIBubbleData
这个数据是这个气泡逻辑需要用到的
```charp
public class BubbleArticleLevelInfoData : IUIBubbleData
{
    public int spriteId;
}
```

#### 3、添加气泡类 UIBubbleArticleLevelInfo.cs

UIBubbleArticleLevelInfo 继承 UIBubbleBase

```csharp
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UIFrame;
using PFramework;

public class BubbleArticleLevelInfoData : IUIBubbleData
{
    public int spriteId;
}

public class UIBubbleArticleLevelInfo : UIBubbleBase
{
    private Image _icon;
    private TMP_Text _txt_level;

    private BaseSprite _sprite;

    /// <summary>
    /// 气泡预制体加载完成会调用 Show 方法
    /// </summary>
    public override void Show()
    {
        base.Show();
        // 打开气泡时传递进来的数据，转化为 BubbleArticleLevelInfoData 类型
        BubbleArticleLevelInfoData data = IUIBubbleData as BubbleArticleLevelInfoData;

        // 获取这个气泡用到的组件
        _icon = TransformUtils.Find<Image>(Transform, "icon");
        _txt_level = TransformUtils.Find<TMP_Text>(Transform, "txt_level");

        _txt_level.text = "level:1";
        // 从传递进来的数据中获取 spriteId
        _sprite = GameServer.Instance.SpriteProxy.GetSprite(data.spriteId);
    }

    /// <summary>
    /// 每帧执行 Update 方法
    /// </summary>
    public override void Update()
    {
        base.Update();
        FollowSprite();
    }

    /// <summary>
    /// 气泡 跟随 Sprite
    /// </summary>
    private void FollowSprite()
    {
        if (null == _sprite)
        {
            return;
        }

        // 跟随逻辑，坐标转换
        Vector2 screenPoint = PositionConvert.WorldPointToScreenPoint(_sprite.Position);
        Vector2 uiPosition = PositionConvert.ScreenPointToUILocalPoint(ParentRect, screenPoint);
        RectTransform.anchoredPosition = uiPosition;
    }

}


```


#### 4、调用创建 气泡

```csharp
    // 实例气泡需要用到的数据
    BubbleArticleLevelInfoData data = new BubbleArticleLevelInfoData();
    data.spriteId = baseSprite.SpriteId;
    
    // 调用 创建气泡
    // 传递气泡类型枚举
    // 传递气泡需要的数据
    UIFrame.UIBubbleController.Instance.CreateBubble(UIFrame.UIBubbleType.ArticleLevelInfo, data);
```


#### 5、销毁气泡

```csharp
    // 销毁气泡
    // 获取 气泡 InstanceId
    UIBubbleController.Instance.DestroyBubble(InstanceId);
```


