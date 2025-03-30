
import os

def write_string_to_file(file_path, content, encoding='utf-8'):
    """
    将字符串写入文件，如果文件存在则先删除
    
    :param file_path: 文件路径（包括文件名）
    :param content: 要写入的字符串内容
    :param encoding: 文件编码（默认utf-8）
    :return: True表示成功，False表示失败
    """
    try:
        # 检查并删除已存在的文件
        if os.path.exists(file_path):
            os.remove(file_path)
            #print(f"已删除旧文件: {file_path}")
        
        # 确保目录存在
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        # 写入文件
        with open(file_path, 'w', encoding=encoding) as file:
            file.write(content)
        
        print(f"内容已成功写入: {file_path}")
        return True
        
    except Exception as e:
        print(f"写入文件失败: {e}")
        return False