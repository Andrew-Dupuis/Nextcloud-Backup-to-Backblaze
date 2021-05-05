#!/bin/bash
 
while getopts ":h" option; do
   case $option in
      h) # display Help
         echo "usage: nc2backblaze B2ApplicationKeyID B2ApplicationKey B2BackupBucketName LocalBackupDirectory NextcloudExportDirectory"
         exit;;
   esac
done
 
B2ApplicationKeyID="$1"
B2ApplicationKey="$2"
B2BackupBucketName="$3"
LocalBackupDirectory="$4"
NextcloudExportDirectory="$5"
 
# Determine Day/Date Info
# Top Level Folders: Monthly || Weekly || Daily
# Monthly Backups are stored forever on the FIRST of each month and stored in
#   named folders labeled "Month Year" (ex: January_2020, March_2021) 
# Weekly Backups are overwritten MONDAY of each week and stored in numbered folders 
#   based on the current week-of-month (ex: Week_1 = first monday, Week_2 = second monday, etc) 
# Daily Backups are overwritten each day and stored to named folder representing 
#   the current day-of-week (ex: Monday, Friday)
 
# Day of Week Name (String) 
DOW=$(date +%A)
# Week of Month Number (int)
WOM=$((($(date +%-d)-1)/7+1))
# Day of Month (int)
DOM=$(date +%d)
# Month of Year Name (String)
MOY=$(date +%B) 
# Year Number
YEAR=$(date +%Y)
 
#Output to a log file
mkdir -p $LocalBackupDirectory/Logs
exec &> $LocalBackupDirectory/Logs/"$(date '+%Y-%m-%d').txt"
echo "Starting Nextcloud export..."
 
# Run a Nextcloud backup
#nextcloud.export
#echo "Backup export complete"
 
# Rename existing local backup to be "Yesterday"
mv $LocalBackupDirectory/today.tar.gz $LocalBackupDirectory/yesterday.tar.gz || echo "No previous backup existed to rename to 'yesterday.tar.gz'"
 
# Tarball backup folder
echo "Tarballing backup..."
tar -cf $LocalBackupDirectory/today.tar $NextcloudExportDirectory/*
echo "Backup tarball completed"
 
# Compressing backup folder
echo "Compressing backup tarball..."
pigz $LocalBackupDirectory/today.tar
echo "Nextcloud backup compressed successfully to ${LocalBackupDirectory}"
 
# Remove uncompressed backup data
#rm -rf $NextcloudExportDirectory/*
 
# Upload compressed backup to proper backblaze directories
b2-linux authorize-account $B2ApplicationKeyID $B2ApplicationKey
 
# (daily, and return the fileID)
Response=$(b2-linux upload-file $B2BackupBucketName $LocalBackupDirectory/today.tar.gz Daily/"${DOW}.tar.gz")
FileID=$(echo "$Response" | awk '/"fileId"/ {gsub(/"/,"",$2);gsub(/,/,"",$2);print $2}')
 
# (weekly)
if [ "$DOW" = "Monday" ];then
    echo "It's Monday: Copying Daily Backup to Weekly Short-Term"
    b2-linux copy-file-by-id $FileID $B2BackupBucketName Weekly/"Week-${WOM}.tar.gz"
else
    echo "It's not Monday: No Need to Copy Daily Backup to Weekly Short-Term"
fi
 
# (monthly)
if [ "$DOM" -eq 1 ];then
    echo "It's the First of the Month: Copying Daily Backup to Monthly Long-Term"
    b2-linux copy-file-by-id $FileID $B2BackupBucketName Monthly/"${MOY}-${YEAR}.tar.gz"
else
    echo "It's not the First of the Month: No Need to Copy Daily Backup to Monthly Long-Term"
fi
 
echo "Nextcloud backup process closing"
