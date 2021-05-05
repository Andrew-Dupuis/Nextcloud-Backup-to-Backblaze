# Nextcloud-Backup-to-Backblaze

Shell script to backup a Nextcloud instance to Backblaze B2. 

## Usage

nc2backblaze B2ApplicationKeyID B2ApplicationKey B2BackupBucketName LocalBackupDirectory NextcloudExportDirectory

| Argument | Description |
|----------|-------------|
|B2ApplicationKeyID | the applicationID for the application key you created in Backblaze for this shell script |
|B2ApplicationKey | the application key you created in Backblaze for this shell script |
|B2BackupBucketName | the name of the Backblaze B2 bucket where you'd like your backup heirarchy to be stored |
|LocalBackupDirectory | filepath to keep local backups and all backup logs (currently, only todays and yesterday's compressed backups are stored there by default) |
|NextcloudExportDirectory | filepath to which your Nextcloud installation saves all files upon running nextcloud.export (for Snap installs, this is /var/snap/nextcloud/common/backups) |
