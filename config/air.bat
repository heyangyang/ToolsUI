set DEV=ToolsUI
call pck.bat ToolsUI
adt -package -storetype pkcs12 -keystore ../tjzh.p12 -storepass tjzh tjzh.air %DEV%-app.xml %DEV%.swf  config.xml
pause