@echo ƽ̨
SET DEVICE=%1
if exist %DEVICE%.swf goto aaa
@echo air SDKĿ¼
SET FRAME=%AIR_SDK%frameworks

@echo ƽ̨��Ҫ��xml
SET SOURCE_SWC_PATH=..\src\%DEVICE%-app.xml
@echo copy xml����ǰĿ¼
copy /B /Y %SOURCE_SWC_PATH% .
@echo ��ʼ���swf
amxmlc -library-path+=../../StarlingFeathers/bin/StarlingFeathers.swc -load-config %FRAME%\airmobile-config.xml   -debug=false -optimize=true -output %DEVICE%.swf -- ../src/%DEVICE%.mxml
:aaa