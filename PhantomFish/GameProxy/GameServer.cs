using BettaSDK;

public class GameServer : SingletonObject<GameServer>
{
    private ISpriteProxy _spriteProxy;

    private GameServer() {   }

    public ISpriteProxy SpriteProxy
    {
        get
        {
            return _spriteProxy;
        }
    }

    public void SetSpriteProxy(ISpriteProxy spriteProxy)
    {
        _spriteProxy = spriteProxy;
    }

}
