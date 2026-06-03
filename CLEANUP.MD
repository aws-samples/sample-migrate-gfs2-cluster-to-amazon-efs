# Cleanup

Follow these steps in order to destroy all resources created by this pattern. Deleting resources out of order may fail due to dependencies.

## 1. Remove fstab entries on EC2 hosts

On each EC2 instance that was configured by the SSM document:

```bash
# Unmount EFS filesystems
umount /app
umount /data

# Remove the EFS entries from /etc/fstab using the specific access point IDs from your EFS stack outputs
AP_APP="<AccessPointAppId from stack output>"
AP_DATA="<AccessPointDataId from stack output>"
sed -i "/${AP_APP}/d; /${AP_DATA}/d" /etc/fstab
```

## 2. Delete the SSM document

```bash
aws ssm delete-document --name "EfsSetupDocument"
```

## 3. Delete the DataSync stack

Delete the CloudFormation stack created from `datasync-task.yaml`. This removes:

- DataSync task
- DataSync NFS source location
- DataSync EFS destination location
- CloudWatch Logs log group

```bash
aws cloudformation delete-stack --stack-name <datasync-stack-name>
aws cloudformation wait stack-delete-complete --stack-name <datasync-stack-name>
```

## 4. Delete the EFS stack

Delete the CloudFormation stack created from `efs-cloudformation.yaml`. This removes:

- EFS file system policy
- EFS access points (`/app` and `/data`)
- EFS mount targets (both AZs)
- EFS file system
- EFS security group (and self-referencing ingress rule)

```bash
aws cloudformation delete-stack --stack-name <efs-stack-name>
aws cloudformation wait stack-delete-complete --stack-name <efs-stack-name>
```

> **Note:** If mount targets are still in use by connected clients, the stack deletion will fail. Ensure all NFS mounts are unmounted (step 1) before proceeding.


## 5. Verify cleanup

Confirm all resources have been removed:

```bash
# Verify no DataSync tasks remain
aws datasync list-tasks

# Verify no EFS file systems remain
aws efs describe-file-systems

# Verify SSM document is gone
aws ssm describe-document --name "EfsSetupDocument"

# Verify CloudWatch log group is gone
aws logs describe-log-groups --log-group-name-prefix <datasync-stack-name>
```
