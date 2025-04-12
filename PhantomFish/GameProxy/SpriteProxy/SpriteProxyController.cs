using UnityEngine;
using BettaSDK;

public class SpriteProxyController : ISpriteProxy
{
    private SpriteManager _spriteManager;
    public SpriteProxyController(SpriteManager spriteManager)
    {
        _spriteManager = spriteManager;
    }

    public BaseSprite CreateSprite(int tableId, Vector3 position)
    {
        return _spriteManager.CreateSprite(tableId, position);
    }

    public BaseSprite GetSprite(int spriteId)
    {
        return _spriteManager.GetSprite(spriteId);
    }

    public BaseSprite GetSprite<T>(int spriteId) where T : BaseSprite
    {
        return _spriteManager.GetSprite<T>(spriteId);
    }

    public void Release()
    {
        _spriteManager = null;
    }
}
