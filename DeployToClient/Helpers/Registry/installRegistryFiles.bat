@echo off
REM Installs Registry Files
REM cd "S:\Behavioral Box Computer Setup - 9-5-2019\Scripts\Registry"
REM S:

echo "Installing registry entries..."
regedit /s "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\Registry\DISABLE-CORTANA.REG"
regedit /s "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\Registry\DISABLE-REMOTE-UAC-RESTRICTIONS.REG"

REM "DISABLE-REMOTE-UAC-RESTRICTIONS.REG"
REM regedit /s "disable-cortana.reg"

echo "done."



