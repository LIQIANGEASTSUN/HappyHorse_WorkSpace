
import os
import json
import config

from . import writeFile  # 使用相对导入

def IsValidCol(cs):
    return cs in {"C", "S", "CS"}  # 可简化为这样

# 根据类型转化为对应的数据格式
def convert_value(value, type_str):
    """
    根据类型字符串转换值（支持空值处理）
    规则：
    1. 当 value 为 None、空字符串或纯空格时，返回 None（JSON 输出为 null）
    2. 数组类型（[]或[][]）的空值需递归处理每个元素
    """
    # 修正语法：补全括号
    if value is None or str(value).strip() == "":
        return None

    type_str = type_str.lower().strip() if type_str else "string"  # 默认类型
    
    try:
        # 二维数组处理（类型标记以 [][] 结尾）
        if type_str.endswith("[][]"):
            base_type = type_str[:-4]
            if not isinstance(value, str):
                value = str(value)
            # 按行拆分（允许行内有空值）
            return [
                [convert_value(item.strip(), base_type) for item in row.split(",") if item.strip() != ""]
                for row in value.split(";") if row.strip() != ""
            ] or None  # 如果结果为空列表则返回 None
        
        # 一维数组处理（类型标记以 [] 结尾）
        ######################################
        elif type_str.endswith("[]"):
            base_type = type_str[:-2]
            
            # 处理已经是列表格式的输入（如 "[1,2]"）
            if isinstance(value, str) and value.startswith("[") and value.endswith("]"):
                try:
                    # 安全解析列表字符串（兼容 JSON 格式）
                    parsed_list = json.loads(value.replace("'", '"'))  # 将单引号转为双引号
                    if not isinstance(parsed_list, list):
                        parsed_list = [parsed_list]
                except json.JSONDecodeError:
                    parsed_list = [value[1:-1]]  # 如果解析失败，去掉方括号
                
                return [convert_value(item, base_type) for item in parsed_list] or None
            
            # 常规字符串处理（如 "1,2"）
            if not isinstance(value, str):
                value = str(value)
            
            # 处理空字符串情况
            if not value.strip():
                return None
                
            return [convert_value(item.strip(), base_type) for item in value.split(",") if item.strip()] or None
        ######################################
        
        # 基本类型处理
        elif type_str == "int":
            return int(float(value))  # 先转float避免 "3.0" 报错
        elif type_str == "float":
            return float(value)
        elif type_str == "long":
            return int(value)  # Python 3 中 int 即长整型
        elif type_str == "string":
            return str(value) if str(value).strip() != "" else None
        else:
            return str(value)  # 未知类型默认转为字符串
            
    except (ValueError, AttributeError, TypeError) as e:
        print(f"WARNING: 类型转换失败 | 值: '{value}' | 目标类型: {type_str} | 错误: {str(e)}")
        return None  # 转换失败时返回 None

def SaveToJson(sheet_data):
    print("SaveToJson")
    try:
        data = sheet_data["data"]
        JsonData = []
        
        propertyNameRowData = data[config.PROPERTY_NAME_ROW]
        propertyTypeRowData = data[config.PROPERTY_ROW]
        clientServerRowData = data[config.CS_ROW]
        for row in range(4, len(data)):
            rowData = data[row]
            
            jsonRow = {}
            for col in range(len(rowData)):
                propertyName = propertyNameRowData[col]
                #print(rowData[col])
                cs = clientServerRowData[col]
                if IsValidCol(cs):
                    propertyType = propertyTypeRowData[col]
                    jsonRow[propertyName] = convert_value(rowData[col], propertyType)
                
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
