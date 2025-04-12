using UnityEngine;
using BettaSDK;

public interface ISpriteProxy
{
    BaseSprite CreateSprite(int tableId, Vector3 position);

    BaseSprite GetSprite(int spriteId);

    BaseSprite GetSprite<T>(int spriteId) where T : BaseSprite;

}
