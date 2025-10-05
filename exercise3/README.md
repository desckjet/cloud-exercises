# Exercise 3 – CloudFormation Drift Detection

This exercise walks you through deploying an AWS CloudFormation stack, introducing drift intentionally, detecting it, and remediating the stack.

## Architecture

The `template.yaml` template provisions:
- The CloudFormation stack is always named `exercise3`; the helper scripts assume that default.
- A VPC with a public subnet and Internet access.
- A security group that exposes HTTP (80) and SSH (22).
- An IAM role with the SSM managed policy plus limited S3 access.
- An instance profile that attaches the role to the EC2 instance.
- An Amazon Linux 2 instance in us-east-1 (fixed AMI) with Nginx installed for the demo.
- No EC2 key pair; access uses EC2 Instance Connect or SSM Session Manager through the attached IAM role.

## Prerequisites

- AWS CLI v2 configured with credentials and a default region (must be `us-east-1`).
- Permissions to create IAM roles and networking resources (`CAPABILITY_NAMED_IAM` is required).

## Initial Deployment

```bash
cd exercise3
./scripts/deploy.sh
```

Optional environment variables let you override the stack name before running the script:

```bash
STACK_NAME=my-stack ./scripts/deploy.sh
```

The deployment publishes the local template with baked-in settings (the instance is always `t2.micro`).

## Introduce Drift Intentionally

1. Identify key resources:
   ```bash
   aws cloudformation describe-stack-resources --stack-name exercise3
   ```
2. Modify resources outside CloudFormation, for example:
   - Add a manual security group rule to allow port 443.
     ```bash
     aws ec2 authorize-security-group-ingress \
       --group-id <sg-id> \
       --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges='[{CidrIp=0.0.0.0/0}]'
     ```
   - Remove the inline policy from the role (keep `AmazonSSMManagedInstanceCore` attached) using the console or CLI.

Make only one or two changes so the drift output stays easy to interpret.

## Detect Drift

```bash
./scripts/detect_drift.sh
```

The script starts `DetectStackDrift`, waits for completion, and lists resources flagged as `MODIFIED`, `DELETED`, or `NOT_CHECKED`.

### Manual workflow to fix drift

`remediate.sh` replays the template exactly as-is; if the change set comes back empty, CloudFormation skips resources even if they are drifted. To force CFN to touch specific resources without changing their final state:

1. Identify the logical resource id(s) drifted with `detect_drift.sh`.
2. Edit `template.yaml` to introduce a temporary, harmless change per resource type EX:
   - **Security group (`InstanceSecurityGroup`)** – change the `GroupDescription` (for example append `(force update)`).
   - **IAM role (`InstanceRole`)** – change the inline `PolicyName` to something different (for example `exercise3-inline-1`).
3. Save the template and run `./scripts/remediate.sh` so the stack enters `UPDATE_IN_PROGRESS` and CloudFormation reapplies the configuration.
4. After the stack reports `IN_SYNC`, remove the temporary edits from `template.yaml` and redeploy to return the file to its original form.

Run `detect_drift.sh` again to confirm the stack is `IN_SYNC`.

## Cleanup

To remove the lab resources:

```bash
aws cloudformation delete-stack --stack-name exercise3
aws cloudformation wait stack-delete-complete --stack-name exercise3
```

Remember to clean up any resource you created outside the stack (e.g., extra security group rules) before deletion to avoid blockers.
