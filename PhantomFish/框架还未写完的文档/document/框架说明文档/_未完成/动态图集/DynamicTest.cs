using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DynamicTest : MonoBehaviour
{
    private SpriteRenderer[] spriteRenderers;
    private Sprite[] sprites;

    private int count = 8;

    // Start is called before the first frame update
    void Start()
    {
        Create();
    }

    private async void Create()
    {
        spriteRenderers = new SpriteRenderer[count];
        sprites = new Sprite[count];
        int col = 3;
        for (int i = 0; i < count; ++i)
        {
            GameObject go = new GameObject(i.ToString());
            go.transform.SetParent(transform);
            float x = i * 1.0f / 3;
            float y = i % col * 2;
            go.transform.localPosition = new Vector3(x, y, 0);
            spriteRenderers[i] = go.AddComponent<SpriteRenderer>();
            string path = string.Format("Assets/SubAssets/Res/Sprite/Article/sc_obj_burgeen_level0{0}.png", i + 1);
            AssetHandle<Sprite> assetHandle = await ResourcesManager.GetInstance().LoadAssetSync<Sprite>(path);
            if (null == assetHandle.Asset)
            {
                Debug.LogError("TTTTT I:" + i);
                continue;
            }
            sprites[i] = assetHandle.Asset;
            spriteRenderers[i].sprite = sprites[i];
        }
    }

    private void GenerateAtlas()
    {
        DynamicAtlasManager.Instance.AddSpritesToDynamicAtlas("ABC", sprites);

        for (int i = 0; i < count; i++)
        {
            SpriteRenderer spriteRenderer = spriteRenderers[i];
            spriteRenderer.sprite = DynamicAtlasManager.Instance.GetSpriteFromDynamicAtlas("ABC", sprites[i].name);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            GenerateAtlas();
        }
    }
}
