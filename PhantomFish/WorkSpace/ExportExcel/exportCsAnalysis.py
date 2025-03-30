
import os
import config

from . import writeFile  # 使用相对导入

def sheet_datas_to_cs_analysis(sheet_datas):
    lb = "{"
    rb = "}"
    assets = '"Assets"'
    sub_assets = '"SubAssets"'
    json_assets = '"JsonAssets"'

    class_name = "JsonCsAnalysis"
    lines = []
    lines.append("using BettaSDK;")
    lines.append("using UnityEngine;")
    lines.append("using System.Threading.Tasks;")
    lines.append("using System;")
    lines.append("")
    lines.append(f"public class {class_name} {lb}")
    lines.append("")
    lines.append(f"    public const int TotalCount = {len(sheet_datas)};")
    lines.append("    private Action OneLoadSuccess;")
    lines.append("")
    lines.append("    public void SetLoadCallBack(Action oneLoadSuccess)")
    lines.append(f"    {lb}")
    lines.append("        OneLoadSuccess = oneLoadSuccess;")
    lines.append(f"    {rb}")
    lines.append("")
    lines.append("    public async void Analysis()")
    lines.append(f"    {lb}")
    lines.append("        await LoadAllJson();")
    lines.append(f"    {rb}")
    lines.append("")
    lines.append("    private async Task LoadAllJson()")
    lines.append(f"    {lb}")
    _append_class_info(sheet_datas, lines)
    lines.append(f"    {rb}")
    lines.append("")
    lines.append("    public async Task LoadJson<T>(string fileName) where T : class, IJsonConfigBase")
    lines.append(f"    {lb}")
    lines.append(f"        string path = FileUtils.CombinePath({assets}, {sub_assets}, {json_assets}, fileName);")
    lines.append("        AssetHandle<TextAsset> assetHandle = await ResourcesManager.Instance.LoadAssetASync<TextAsset>(path);")
    lines.append("        if (null != assetHandle.Asset)")
    lines.append(f"        {lb}")
    lines.append('            DebugLoger.Log("LoadJson Complete:" + fileName);')
    lines.append("            fileName = System.IO.Path.GetFileNameWithoutExtension(fileName);")
    lines.append("            JsonConfigCenter.Instance.AddConfig<T>(fileName, assetHandle.Asset.text);")
    lines.append("            OneLoadSuccess?.Invoke();")
    lines.append(f"        {rb}")
    lines.append("        else")
    lines.append(f"        {lb}")
    lines.append('            Debug.LogError("Load CSV fail: " + path);')
    lines.append(f"        {rb}")
    lines.append(f"    {rb}")
    lines.append("")
    lines.append(rb)
    
    cs_string = "\n".join(lines)
    file_path = f"E:/HappyHorse_WorkSpace/PhantomFish/CS/{class_name}.cs"
    writeFile.write_string_to_file(file_path, cs_string, 'utf-8')


def _append_class_info(sheet_datas, lines):
    for sheet_data in sheet_datas:
        file_name = sheet_data["excel_name"]
        sheet_name = sheet_data["sheet_name"]
        #print(f"文件名: {file_name}")
        #print(f"工作表名: {sheet_name}")

        # In Python version, data is already in sheet_data["data"]
        # No need for getValues() equivalent
        
        class_name = sheet_name
        lines.append(f'       await LoadJson<{class_name}>("{file_name}.json");')