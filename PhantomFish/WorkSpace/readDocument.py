

import os.path
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
           