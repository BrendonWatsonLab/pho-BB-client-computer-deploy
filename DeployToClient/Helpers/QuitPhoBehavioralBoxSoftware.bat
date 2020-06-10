@echo off
REM Quits any existing instance of the phoBehavioralBoxController software and then opens a new one.
powershell.exe -command "Set-ExecutionPolicy Bypass -Force"
powershell.exe -command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force"

REM Quit any existing instances of the software:
powershell.exe -command ".\Helpers\QuitPhoBehavioralBoxSoftware.ps1"
