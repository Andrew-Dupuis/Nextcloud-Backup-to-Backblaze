# Nextcloud-Backup-to-Backblaze

Shell script to perform a GFS backup of a Nextcloud instance to Backblaze B2

## Behavior 

Runs a nextcloud.export command, then tar's the export and compresses it with pigz to create a today.tar.gz backup file. Any existing today.tar.gz file is moved to and overwrites yesteday.tar.gz. Then, today.tar.gz is stored 
- Daily Backups are stored to Daily/{Weekday}.tar.gz and overwritten 1 week later
- Each Monday, Weekly Backups are copied within B2 from Daily/{Weekday}.tar.gz to Weekly/{Week-Number}.tar.gz and overwritten 1 month later
- On the FIRST of each month, Monthly Backups are copied within B2 from Daily/{Weekday}.tar.gz to Monthly/{Month-Year}.tar.gz and are stored persistantly


## Usage

nc2backblaze B2ApplicationKeyID B2ApplicationKey B2BackupBucketName LocalBackupDirectory NextcloudExportDirectory

| Argument | Description |
|----------|-------------|
| B2ApplicationKeyID | the applicationID for the application key you created in Backblaze for this shell script |
| B2ApplicationKey | the application key you created in Backblaze for this shell script |
| B2BackupBucketName | the name of the Backblaze B2 bucket where you'd like your backup heirarchy to be stored |
| LocalBackupDirectory | filepath to keep local backups and all backup logs (currently, only todays and yesterday's compressed backups are stored there by default) |
| NextcloudExportDirectory | filepath to which your Nextcloud installation saves all files upon running nextcloud.export (for Snap installs, this is /var/snap/nextcloud/common/backups) |
