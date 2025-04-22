using System.Collections.Generic;
using UnityEngine;
 
public class DynamicAtlasManager : MonoBehaviour
{
    public int atlasSize = 1024;
    public TextureFormat textureFormat = TextureFormat.RGBA32;
    public bool useMipmaps = false;
 
    private static DynamicAtlasManager _instance;
    public static DynamicAtlasManager Instance
    {
        get
        {
            if (_instance == null)
            {
                GameObject go = new GameObject("DynamicAtlasManager");
                _instance = go.AddComponent<DynamicAtlasManager>();
            }
 
            return _instance;
        }
    }
 
    private Dictionary<string, Texture2D> _atlasDictionary;
    private Dictionary<string, Rect> _spriteRects;
    private Dictionary<string, Sprite> _originalSpritesCache;
 
    void Awake()
    {
        _atlasDictionary = new Dictionary<string, Texture2D>();
        _spriteRects = new Dictionary<string, Rect>();
        _originalSpritesCache = new Dictionary<string, Sprite>();
    }
 
    public void AddSpritesToDynamicAtlas(string atlasName, Sprite[] sprites)
    {
        if (sprites == null || sprites.Length == 0) return;
 
        Texture2D atlas;
        if (_atlasDictionary.ContainsKey(atlasName))
        {
            atlas = _atlasDictionary[atlasName];
        }
        else
        {
            atlas = new Texture2D(atlasSize, atlasSize, textureFormat, useMipmaps);
            atlas.filterMode = FilterMode.Bilinear;
            _atlasDictionary.Add(atlasName, atlas);
        }
 
        for (int i = 0; i < sprites.Length; i++)
        {
            if (null == sprites[i])
            {
                Debug.LogError("i:" + i);
            }
            if (!_originalSpritesCache.ContainsKey(sprites[i].name))
            {
                _originalSpritesCache.Add(sprites[i].name, sprites[i]);
            }
        }
 
        int xOffset = 0;
        int yOffset = 0;
        int maxHeight = 0;
 
        for (int i = 0; i < sprites.Length; i++)
        {
            Sprite sprite = sprites[i];
            Texture2D spriteTexture = sprite.texture;
 
            if (xOffset + sprite.rect.width > atlas.width)
            {
                xOffset = 0;
                yOffset += maxHeight;
                maxHeight = 0;
            }
 
            // Copy the texture using CopyTexture method
            Graphics.CopyTexture(spriteTexture, 0, 0, (int)sprite.rect.x, (int)sprite.rect.y, (int)sprite.rect.width, (int)sprite.rect.height, atlas, 0, 0, xOffset, yOffset);
 
            _spriteRects[sprite.name] = new Rect(xOffset, yOffset, sprite.rect.width, sprite.rect.height);
 
            xOffset += (int)sprite.rect.width;
            maxHeight = Mathf.Max(maxHeight, (int)sprite.rect.height);
        }
    }
 
 
    public Sprite GetSpriteFromDynamicAtlas(string atlasName, string spriteName)
    {
        if (!_atlasDictionary.ContainsKey(atlasName) || !_spriteRects.ContainsKey(spriteName))
        {
            return null;
        }
 
        Texture2D atlas = _atlasDictionary[atlasName];
        Rect spriteRect = _spriteRects[spriteName];
 
        // Get the original sprite
        if (!_originalSpritesCache.ContainsKey(spriteName))
        {
            return null;
        }
 
        Sprite originalSprite = _originalSpritesCache[spriteName];
 
        // Calculate the border of the new sprite based on the original sprite's border
        Vector4 border = originalSprite.border;
 
        // Create the new sprite with the correct border
        return Sprite.Create(atlas, spriteRect, new Vector2(0.5f, 0.5f), originalSprite.pixelsPerUnit, 0, SpriteMeshType.Tight, border);
    }
}