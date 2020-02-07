@echo off
REM Installs Registry Files
REM cd "S:\Behavioral Box Computer Setup - 9-5-2019\Scripts\Registry"
REM S:

echo "Installing registry entries..."
regedit /s "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare\Behavioral Box Computer Setup - 9-5-2019\Scripts\Registry\disable-cortana.reg"
regedit /s "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare\Behavioral Box Computer Setup - 9-5-2019\Scripts\Registry\DISABLE-REMOTE-UAC-RESTRICTIONS.REG"

REM "DISABLE-REMOTE-UAC-RESTRICTIONS.REG"
REM regedit /s "disable-cortana.reg"

echo "done."



