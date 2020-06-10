@echo off 
Rem Uploads the video and data files to Google Drive for backup purposes
cd "C:\Common\bin\rclone-v1.50.1-windows-amd64"
C:
rclone copy "C:\Common\data" "GDrive:BehavioralBoxData/eventData"
echo "Done!"