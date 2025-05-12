# AWS IAM Setup
- Group: StudentPortalAdmins
- Policies:
  - StudentEC2Access: EC2 management.
  - StudentS3Access: S3 bucket access.
  - StudentBeanstalkAccess: Beanstalk management.
- User: student-user, attached to StudentPortalAdmins.
- Tested: ec2:Describe, s3:List, elasticbeanstalk:Describe.