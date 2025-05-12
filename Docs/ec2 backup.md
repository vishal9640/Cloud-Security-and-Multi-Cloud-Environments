# EC2 Security and Backup
- Security Group: wordpress-access
  - Inbound: HTTP (80, global), SSH (your IP)
  - Outbound: MySQL (3306, 23.97.227.76)
- Backup: Script for LAMP WordPress
  - File: /home/ec2-user/backup-wp.sh
  - Path: /var/www/html
  - S3: s3://student-portal-wp-content/backups/
  - Schedule: Daily at 2 AM
- Tested: Backup created, stored in S3