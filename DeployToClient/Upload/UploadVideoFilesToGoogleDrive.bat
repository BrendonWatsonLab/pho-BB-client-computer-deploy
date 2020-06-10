@echo off 
Rem Uploads the video and data files to Google Drive for backup purposes
cd "C:\Common\bin\rclone-v1.50.1-windows-amd64"
C:
rclone copy "E:\" "GDrive:BehavioralBoxData/unconverted_videos"
REM rclone copy "E:\Transcoded Videos" "GDrive:BehavioralBoxData/videos"
echo "Done!"