

import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/documents.readonly"]

tokenJson = "credentials/token.json"
credentialsJson = "credentials/credentials.json"

# The ID of a sample document.
#DOCUMENT_ID = "195j9eDD3ccgjQRttHhJPymLJUCOUjs-jmwTrekvdjFE"
DOCUMENT_ID = "1Zq5szx0HVm88GoANtkW8aNyec5OuA30o7aKmEpm0qEY"

def print_document_content(service):
    # Retrieve the documents contents from the Docs service.
    document = service.documents().get(documentId=DOCUMENT_ID).execute()
    print(f"The title of the document is: {document.get('title')}")

    """递归打印文档内容"""
    if 'body' in document and 'content' in document['body']:
        for content in document['body']['content']:
            if 'paragraph' in content:
                for element in content['paragraph']['elements']:
                    if 'textRun' in element:
                        print(element['textRun']['content'], end='')
            # 可以添加对其他元素类型的处理，如表格、图片等
           

def main():
  """Shows basic usage of the Docs API.
  Prints the title of a sample document.
  """
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
    service = build("docs", "v1", credentials=creds)
    print("文档内容:")
    print_document_content(service)

  except HttpError as err:
    print(err)


if __name__ == "__main__":
  print("start quickstart")
  main()