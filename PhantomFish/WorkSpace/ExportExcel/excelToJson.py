
import os
import json
import config

from . import writeFile  # 使用相对导入

# sheet_data = {
#     "file" : file,
#     "excel_name" : file['name'], 
#     "sheet_id" : file['id'],
#     "sheet_name" : "",
#     "data" : None
# }

def IsValidCol(cs):
    return cs in {"C", "S", "CS"}  # 可简化为这样

def SaveToJson(sheet_data):
    """
    将字符串写入文件，如果文件存在则先删除
    
    :param file_path: 文件路径（包括文件名）
    :param content: 要写入的字符串内容
    :param encoding: 文件编码（默认utf-8）
    :return: True表示成功，False表示失败
    """
    
    print("SaveToJson")
    try:
        data = sheet_data["data"]
        JsonData = []
        
        propertyNameRowData = data[config.PROPERTY_NAME_ROW]
        clientServerRowData = data[config.CS_ROW]
        for row in range(4, len(data)):
            rowData = data[row]
            
            jsonRow = {}
            for col in range(len(rowData)):
                propertyName = propertyNameRowData[col]
                #print(rowData[col])
                cs = clientServerRowData[col]
                if IsValidCol(cs):
                    jsonRow[propertyName] = rowData[col]
                
            JsonData.append(jsonRow)
        
        # 转换为 JSON 字符串
        json_str = json.dumps(
            JsonData,
            indent=4,               # 缩进4空格
            ensure_ascii=False      # 关键参数：禁用 ASCII 转义
        )
        
        #print(json_str)
        excel_name = sheet_data["excel_name"]
        file_path = f"E:/HappyHorse_WorkSpace/PhantomFish/Json/{excel_name}.json"
        writeFile.write_string_to_file(file_path, json_str, 'utf-8')
    except Exception as e:
        print(f"写入文件失败: {e}")
