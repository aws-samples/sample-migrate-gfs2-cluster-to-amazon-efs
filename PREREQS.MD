# Prerequisites

- Target Account with a VPC and two or more private subnets across different availability zones.
- AWS Direct Connect from customer on-premises to AWS region is recommended. The solution can work with AWS VPN, however the data transfer time will be longer.
- Access to target account with IAM policy to create EFS filesystems, EFS Access points, DataSync, MGN and AWS Systems Manager.
- VPC interface endpoints for AWS MGN, SSM, DataSync, EC2 and S3 across subnets in two AZs.
- VPC endpoint Security group which allows traffic from the VPC CIDR range and the on-premises CIDR range to the VPC endpoints. The on-premises range must be able to reach VPC endpoints for EC2, S3, MGN and DataSync.
- Access to on-premises Linux servers with sudo privileges (install AWS MGN agent, list cluster configuration with pcs command, edit /etc/fstab and disable services with systemctl).
- On-premises firewall allows outbound traffic for the ports required for MGN and DataSync (1500, 443 & 2049) from the on-premises servers to target AWS account.
- Security group for EC2 instances - referred to as Application Security group. This security group must allow TCP outbound traffic on 443 (SSM) and 2049 (NFS).
- Customer Managed Key (CMK) for EFS encryption.
- IAM Role with included Instance profile with the following AWS managed policies - AmazonSSMManagedInstanceCore, AmazonSSMPatchAssociation and AmazonElasticFileSystemClientFullAccess.
- AWS KMS keys for EBS and EFS for encryption at rest.
- IAM role with AWSApplicationMigrationAgentInstallationPolicy policy attached. This role will be used to generate temporary credentials for MGN agent installation.
- (Optional) MGN test launch private subnet with no on-premises connectivity.
- MGN test launch security group which does not allow any inbound traffic and allows outbound traffic only to AWS SSM on TCP/443 port.
