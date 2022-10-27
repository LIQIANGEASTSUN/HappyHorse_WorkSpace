
set pb_path=H:\Proto\Proto\protoc2.4.1win32

REM protoc.exe -I=%pb_path% --cpp_out=%pb_path%\Out %pb_path%\01001_01100_account.proto

protoc.exe -I=%pb_path% --java_out=%pb_path%\Out %pb_path%\01001_01100_account.proto

REM protoc.exe -I=%pb_path% --lua_out=%pb_path%\Out %pb_path%\01001_01100_account.proto

Rem protoc.exe -I=F:\Proto\protoc2.4.1win32 --csharp_out=F:\Proto\protoc2.4.1win32\Out F:\Proto\protoc2.4.1win32\01001_01100_account.proto