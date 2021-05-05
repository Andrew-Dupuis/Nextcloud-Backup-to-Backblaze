# Nextcloud-Backup-to-Backblaze

Shell script to perform a complete, compressed, single-file, and GFS-versioned backup of a Nextcloud instance to Backblaze B2. Basic structure and scheduling is based on https://kevq.uk/how-to-backup-nextcloud/, with the addition of Backblaze B2 CLI, GFS backup logic, and use of pigz for compression acceleration.

## Behavior 

Runs a nextcloud.export command, then tar's the export and compresses it with pigz to create a today.tar.gz backup file. Any existing today.tar.gz file is moved to and overwrites yesteday.tar.gz. Then, today.tar.gz is stored 
- Daily Backups are stored to Daily/{Weekday}.tar.gz and overwritten 1 week later
- Each Monday, Weekly Backups are copied within B2 from Daily/{Weekday}.tar.gz to Weekly/{Week-Number}.tar.gz and overwritten 1 month later
- On the FIRST of each month, Monthly Backups are copied within B2 from Daily/{Weekday}.tar.gz to Monthly/{Month-Year}.tar.gz and are stored persistantly

## Dependencies

- Backblaze CLI (https://www.backblaze.com/b2/docs/quick_command_line.html)
- pigz (https://zlib.net/pigz/)

## Setup 

1. Download the shell script and move it to /usr/sbin/ (something like sudo mv ~/Downloads/Nextcloud-Backup-to-Backblase/nc2backblaze.sh /usr/sbin/nc2backblaze.sh
2. Make the new bash file executable with sudo chmod +x /usr/sbin/nc2backblaze.sh
3. For security purposes, its a good idea to create a separate "backup" user without login rights on your linux installation for this script. Do so with "sudo adduser backup; sudo usermod -s /sbin/nologin backup"
4. Allow nc2backblaze to run as a sudoer under the "backup" user with: "sudo visudo; ncbackup ALL=(ALL) NOPASSWD: /usr/sbin/nc2backblaze.sh" 
5. Schedule the nc2backblaze script to run as a daily chron job by editing crontab for the "backup" user (sudo crontab -u backup -e) then adding the line "0 2 * * * sudo /usr/sbin/nc2backblaze.sh". This will run the backup at 2am daily.   

## Usage

nc2backblaze B2ApplicationKeyID B2ApplicationKey B2BackupBucketName LocalBackupDirectory NextcloudExportDirectory

| Argument | Description |
|----------|-------------|
| B2ApplicationKeyID | the applicationID for the application key you created in Backblaze for this shell script |
| B2ApplicationKey | the application key you created in Backblaze for this shell script |
| B2BackupBucketName | the name of the Backblaze B2 bucket where you'd like your backup heirarchy to be stored |
| LocalBackupDirectory | filepath to keep local backups and all backup logs (currently, only todays and yesterday's compressed backups are stored there by default) |
| NextcloudExportDirectory | filepath to which your Nextcloud installation saves all files upon running nextcloud.export (for Snap installs, this is /var/snap/nextcloud/common/backups) |
