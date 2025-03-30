
import os.path

# 使用相对导入
from . import readExcel    
from . import excelToJson
from . import excelToCs
from . import exportCsAnalysis

from googleapiclient.errors import HttpError

def exportAllExcel(sheets_service, sheet_datas):
    print("exportAllExcel")
    # readExcel.read_sheet_content(sheets_service)
    for sheet_data in sheet_datas:
        # 如果是 Google Sheets，用 Sheets API 读取
        exportExcel(sheets_service, sheet_data)
            
    exportCsAnalysis.sheet_datas_to_cs_analysis(sheet_datas)
    
    # sheet_data = {
#     "file" : file,
#     "excel_name" : file['name'], 
#     "sheet_id" : file['id'],
#     "sheet_name" : "",
#     "data" : None
# }

                
def exportExcel(sheets_service, sheet_data):
    print("")
    print(f"文件名: {sheet_data['excel_name']}, ID: {sheet_data['sheet_id']}, 类型: {sheet_data['file']['mimeType']}")
    sheetId = sheet_data["sheet_id"]
    #print("exportExcel  sheetId:", sheetId)
    # readExcel.read_sheet_content(sheets_service)
    
    excelToJson.SaveToJson(sheet_data)
    excelToCs.SaveToCS(sheet_data)

