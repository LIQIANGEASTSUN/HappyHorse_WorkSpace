

import os.path
from googleapiclient.errors import HttpError

folder_id = "1LZi_KeDMpdgfAHbR-REqV7__JNpVR-sL"

def list_files_in_folder(drive_service):
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
                print("mimeType", file['mimeType'])
                
        return files

    except HttpError as err:
        print(f"API 错误: {err}")
        return []
    except Exception as e:
        print(f"意外错误: {e}")
        return []