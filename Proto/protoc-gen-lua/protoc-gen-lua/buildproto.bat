rem �л���.protoЭ�����ڵ�Ŀ¼  
cd H:\Proto\protoc-gen-lua\protoc-gen-lua\luascript  
rem ����ǰ�ļ����е�����Э���ļ�ת��Ϊlua�ļ�  
for %%i in (*.proto) do (    
echo %%i  
"H:\Proto\protoc-gen-lua\protoc-gen-lua\protoc.exe" --plugin=protoc-gen-lua="H:\Proto\protoc-gen-lua\protoc-gen-lua\plugin\protoc-gen-lua.bat" --lua_out=. %%i  
  
)  
echo end  
pause