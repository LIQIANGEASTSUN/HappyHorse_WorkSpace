using BettaSDK;
using UnityEngine;
using System.Threading.Tasks;
using System;

public class JsonCsAnalysis {

    public const int TotalCount = 8;
    private Action OneLoadSuccess;

    public void SetLoadCalconfig.LBack(Action oneLoadSuccess)
    {
        OneLoadSuccess = oneLoadSuccess;
    }

    public async void Analysis()
    {
        await LoadAllJson();
    }

    private async Task LoadAllJson()
    {
       await LoadJson<XassetCfg_Sheet>("XassetCfg.json");
       await LoadJson<UiPanelCfg>("UiPanelCfg.json");
       await LoadJson<SpriteGraphicCfg>("SpriteGraphicCfg.json");
       await LoadJson<UiBubbleCfg>("UiBubbleCfg.json");
       await LoadJson<TextLocalizationCfg>("TextLocalizationCfg.json");
       await LoadJson<SpriteCfg>("SpriteCfg.json");
       await LoadJson<CharacterCfg>("CharacterCfg.json");
       await LoadJson<ArticleCfg>("ArticleCfg.json");
    }

    public async Task LoadJson<T>(string fileName) where T : class, IJsonConfigBase
    {
        string path = FileUtils.CombinePath("Assets", "SubAssets", "JsonAssets", fileName);
        AssetHandle<TextAsset> assetHandle = await ResourcesManager.Instance.LoadAssetASync<TextAsset>(path);
        if (null != assetHandle.Asset)
        {
            DebugLoger.Log("LoadJson Complete:" + fileName);
            fileName = System.IO.Path.GetFileNameWithoutExtension(fileName);
            JsonConfigCenter.Instance.AddConfig<T>(fileName, assetHandle.Asset.text);
            OneLoadSuccess?.Invoke();
        }
        else
        {
            Debug.LogError("Load CSV fail: " + path);
        }
    }

}