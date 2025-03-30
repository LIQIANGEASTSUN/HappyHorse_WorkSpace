
import os.path
import FolderList

from ExportExcel import ExportExcelCenter
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
# 同时请求 Drive 和 Sheets 的权限
SCOPES = [
    "https://www.googleapis.com/auth/drive.readonly",
    "https://www.googleapis.com/auth/spreadsheets.readonly"
]

# credentials.json 凭证文件，如果项目重新生成凭证，需要重新下载更新
credentialsJson = "credentials/credentials.json"

# 每次修改 SCOPES 需要删除 token.json，重新运行时会重新生成
tokenJson = "credentials/token.json"

def main():
  creds = None
  # The file token.json stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  if os.path.exists(tokenJson):
    creds = Credentials.from_authorized_user_file(tokenJson, SCOPES)
  # If there are no (valid) credentials available, let the user log in.
  if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
      creds.refresh(Request())
    else:
      flow = InstalledAppFlow.from_client_secrets_file(
          credentialsJson, SCOPES
      )
      creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open(tokenJson, "w") as token:
      token.write(creds.to_json())

  try:
    # 初始化两个服务的客户端
    drive_service = build("drive", "v3", credentials=creds)  # Drive API
    sheets_service = build("sheets", "v4", credentials=creds)  # Sheets API
    print("获取所有Excel")
    sheet_datas = FolderList.list_files_in_folder(drive_service, sheets_service)
    print("开始导出 Excel")
    ExportExcelCenter.exportAllExcel(sheets_service, sheet_datas)

  except HttpError as err:
    print(err)


if __name__ == "__main__":
  print("start quickstart")
  main()