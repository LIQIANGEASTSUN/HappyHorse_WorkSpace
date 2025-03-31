
import os
import json

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
            return convert_value_two_array(value, type_str)
        elif type_str.endswith("[]"):
            return convert_value_one_array(value, type_str)
        # 基本类型处理
        elif type_str == "int":
            return convert_value_int(value)  # 先转float避免 "3.0" 报错
        elif type_str == "float":
            return convert_value_float(value)
        elif type_str == "long":
            return convert_value_long(value)  # Python 3 中 int 即长整型
        elif type_str == "string":
            return convert_value_string(value)
        elif type_str == "json":
            return convert_value_string(value)
        else:
            return convert_value_string(value)  # 未知类型默认转为字符串
            
    except (ValueError, AttributeError, TypeError) as e:
        print(f"WARNING: 类型转换失败 | 值: '{value}' | 目标类型: {type_str} | 错误: {str(e)}")
        return None  # 转换失败时返回 None

# 转化为 int
def convert_value_int(value):
    try:
        return int(float(value))  # 先转float避免 "3.0" 报错
    except ValueError as e:
        print("捕获异常:", e)
    return 0

# 转化为 float
def convert_value_float(value):
    try:
        return float(value)
    except ValueError as e:
        print("捕获异常:", e)
    return 0

def convert_value_long(value):
    return convert_value_int(value)  # Python 3 中 int 即长整型

# 转化为 float
def convert_value_string(value):
    try:
        return str(value) if str(value).strip() != "" else None
    except ValueError as e:
        print("捕获异常:", e)
    return None
    

# 转化为 json
def convert_value_json(value):
    return convert_value_string(value)

# 转化为 一唯数组, # 一维数组处理（类型标记以 [] 结尾）
def convert_value_one_array(value, type_str):
    print("convert_value_one_array:" + value)
    base_type = type_str[:-2]
    
    if isinstance(value, str):
        value = value.strip(' ')
        value = value.strip('"')
    
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

    return None
        

# 转化为 二唯数组, # 二维数组处理（类型标记以 [][] 结尾）
def convert_value_two_array(value, type_str):
    print("convert_value_two_array:" + value)
    base_type = type_str[:-4]
    
    if isinstance(value, str):
        value = value.strip(' ')
        value = value.strip('"')

    # 处理已经是列表格式的输入（如 "[[1,2],[3,4]]"）
    if isinstance(value, str) and value.startswith("[[") and value.endswith("]]"):
        try:
            # 安全解析列表字符串（兼容 JSON 格式）
            parsed_list = json.loads(value)
            if not isinstance(parsed_list, list):
                parsed_list = [[parsed_list]]  # 如果不是列表，包装成二维数组
            elif not all(isinstance(x, list) for x in parsed_list):
                parsed_list = [parsed_list]    # 如果是一维列表，包装成二维数组
        except json.JSONDecodeError:
            # 如果解析失败，尝试手动处理
            value = value[2:-2]  # 去掉最外层方括号
            parsed_list = [[item.strip() for item in row.split(",")] 
            for row in value.split("],[")]
        
        return [
            [convert_value(item, base_type) for item in row]
                for row in parsed_list
        ] or None
        
    return None