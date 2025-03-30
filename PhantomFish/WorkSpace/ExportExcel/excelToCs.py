
import os
import config

from . import writeFile  # 使用相对导入

def IsValidCol(cs):
    return cs in {"C", "S", "CS"}  # 可简化为这样

def SaveToCS(sheet_data):
    print("SaveToCS")
    try:
        data = sheet_data["data"]
        JsonData = []

        note_row_data = data[config.NOTE_ROW]
        property_name_row_data = data[config.PROPERTY_NAME_ROW]
        property_row_data = data[config.PROPERTY_ROW]
        clientServerRowData = data[config.CS_ROW]

        className = sheet_data["sheet_name"]
        lines = []
        lines.append("using BettaSDK;")
        lines.append("")
        lines.append(f"public class {className} : IJsonConfigBase {config.LB}")
        lines.append("")

        for col in range(len(property_name_row_data)):
            cs = clientServerRowData[col]
            if not IsValidCol(cs):
                continue

            note = note_row_data[col]
            type_ = property_row_data[col]  # 使用type_避免与Python关键字冲突
            property_name = property_name_row_data[col]
            
            lines.append("    ///<summary>")
            note_lines = note.split("\n")
            # 输出验证
            for line in note_lines:
                lines.append(f"    /// {line}")
            lines.append("    ///<summary>")
            lines.append(f"    public {type_} {property_name}")
            lines.append(f"    {config.LB}")
            lines.append("        get;")
            lines.append("        private set;")
            lines.append(f"    {config.RB}")
            lines.append("")

        lines.append(config.RB)

        cs_string = "\n".join(lines)
        excel_name = sheet_data["excel_name"]
        file_path = f"E:/HappyHorse_WorkSpace/PhantomFish/CS/{excel_name}.cs"
        writeFile.write_string_to_file(file_path, cs_string, 'utf-8')
        return True
    except Exception as e:
        print(f"写入文件失败: {e}")
        return False
        
    return False
