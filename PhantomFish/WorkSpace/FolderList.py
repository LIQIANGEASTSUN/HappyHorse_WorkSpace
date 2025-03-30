

import os.path

from googleapiclient.errors import HttpError

folder_id = "1LZi_KeDMpdgfAHbR-REqV7__JNpVR-sL"

def list_files_in_folder(drive_service, sheets_service):
    sheet_datas = []
    try:
        # 查询文件夹中的 Google Sheets 和 .xlsx 文件
        query = f"'{folder_id}' in parents and (mimeType='application/vnd.google-apps.spreadsheet' or mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')"
        results = drive_service.files().list(
            q=query,
            fields="files(id, name, mimeType)"
        ).execute()
        files = results.get("files", [])

        for file in files:
            print(f"文件名: {file['name']}, ID: {file['id']}, 类型: {file['mimeType']}")

            # 如果是 Google Sheets，用 Sheets API 读取
            if file['mimeType'] == 'application/vnd.google-apps.spreadsheet':
                sheet_data = read_sheet_content(sheets_service, file)
                #print("mimeType", file['mimeType'])
                sheet_datas.append(sheet_data)
                
        return sheet_datas

    except HttpError as err:
        print(f"API 错误: {err}")
        return sheet_datas
    except Exception as e:
        print(f"意外错误: {e}")
        return sheet_datas
        
def read_sheet_content(sheets_service, file):
    """读取第一个 Sheet 的所有非空数据"""
    sheet_id = file['id']
    sheet_data = {
        "file" : file,
        "excel_name" : file['name'], 
        "sheet_id" : file['id'],
        "sheet_name" : "",
        "data" : None
    }
        
    try:
        # 1. 获取第一个 Sheet 的名称
        spreadsheet = sheets_service.spreadsheets().get(
            spreadsheetId=sheet_id
        ).execute()
        sheet_name = spreadsheet['sheets'][0]['properties']['title']  # 第一个 Sheet 的名称
        sheet_data["sheet_name"] = sheet_name

        # 2. 读取整个 Sheet 的数据（不指定 range）
        result = (
            sheets_service.spreadsheets()
            .values()
            .get(spreadsheetId=sheet_id, range=sheet_name)
            .execute()
        )
        values = result.get("values", [])

        # 3. 过滤空行（跳过全为空的行）
        data = [row for row in values if any(cell.strip() for cell in row)]
        
        if not data:
            print("没有找到非空数据。")
        else:
            #print(f"共读取 {len(data)} 行非空数据：")
            sheet_data["data"] = data       

        return sheet_data
    except HttpError as err:
        print(f"Google Sheets API 错误: {err}")
        return sheet_data
    except Exception as e:
        print(f"意外错误: {e}")
        return sheet_data