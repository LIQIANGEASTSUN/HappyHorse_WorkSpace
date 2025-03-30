

import os.path
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/documents.readonly"]

tokenJson = "credentials/token.json"
credentialsJson = "credentials/credentials.json"

# The ID of a sample document.
DOCUMENT_ID = "1Zobv9DrEkxnaEirzoMtr5Zx1gCOzGHSvC5m_WQPq9Ao"

# 替换 readDocument 的逻辑，直接读取 Sheets 数据
def read_sheet_content(service):
    """读取第一个 Sheet 的所有非空数据"""
    try:
        # 1. 获取第一个 Sheet 的名称
        spreadsheet = service.spreadsheets().get(
            spreadsheetId=DOCUMENT_ID
        ).execute()
        sheet_name = spreadsheet['sheets'][0]['properties']['title']  # 第一个 Sheet 的名称

        # 2. 读取整个 Sheet 的数据（不指定 range）
        result = (
            service.spreadsheets()
            .values()
            .get(spreadsheetId=DOCUMENT_ID, range=sheet_name)
            .execute()
        )
        values = result.get("values", [])

        # 3. 过滤空行（跳过全为空的行）
        data = [row for row in values if any(cell.strip() for cell in row)]
        
        if not data:
            print("没有找到非空数据。")
        else:
            print(f"共读取 {len(data)} 行非空数据：")
            for row in data:
                print(row)        

    except HttpError as err:
        print(f"Google Sheets API 错误: {err}")
        return []

           
           
# https://docs.google.com/spreadsheets/d/1Zobv9DrEkxnaEirzoMtr5Zx1gCOzGHSvC5m_WQPq9Ao/edit?gid=0#gid=0