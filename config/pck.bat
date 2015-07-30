@echo 平台
SET DEVICE=%1
if exist %DEVICE%.swf goto aaa
@echo air SDK目录
SET FRAME=%AIR_SDK%frameworks

@echo 平台需要的xml
SET SOURCE_SWC_PATH=..\src\%DEVICE%-app.xml
@echo copy xml到当前目录
copy /B /Y %SOURCE_SWC_PATH% .
@echo 开始打包swf
amxmlc -library-path+=../../StarlingFeathers/bin/StarlingFeathers.swc -load-config %FRAME%\airmobile-config.xml   -debug=false -optimize=true -output %DEVICE%.swf -- ../src/%DEVICE%.mxml
:aaa