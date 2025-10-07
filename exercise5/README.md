# Exercise 5 - CloudFormation HA VPC

## Description

This practice deploys a highly available and secure VPC using AWS CloudFormation. The template includes resources distributed across multiple availability zones, load balanced by an Application Load Balancer and served by an Auto Scaling Group of EC2 instances running NGINX.

## Main Components

- **Networking**: /16 VPC with two public and two private subnets distributed across different zones, internet gateway, NAT gateways per AZ, and dedicated route tables.
- **Security**: Security Groups that restrict HTTP to ALB and application traffic from ALB to instances, plus differentiated NACLs for public and private subnets.
- **Compute**: Launch Template with Amazon Linux (via SSM), Auto Scaling Group with desired capacity of 2 instances and HTTP load balancing via ALB + Target Group.
- **Automation**: User data installs and enables NGINX, publishing a welcome page with the AZ from which the request is served.

## File Structure

```
exercise5/
├── README.md
├── parameters/
│   └── stack-params.json        # Sample parameters for CLI
└── templates/
    ├── main.yaml                # Main template (parent stack)
    └── nested/
        ├── compute.yaml         # Child stack: ALB, ASG, SG, IAM
        └── networking.yaml      # Child stack: VPC, subnets, routes, NACL
```

## Key Parameters

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `EnvironmentName` | Prefix for resource tagging (2-15 characters) | _(required)_ |
| `VpcCidr` | Main VPC CIDR | `10.0.0.0/16` |
| `PublicSubnetCidrs` | List with 2 CIDRs for public subnets | `10.0.0.0/24,10.0.1.0/24` |
| `PrivateSubnetCidrs` | List with 2 CIDRs for private subnets | `10.0.10.0/24,10.0.11.0/24` |
| `InstanceType` | Instance type for ASG | `t2.micro` |
| `KeyName` | Optional key pair name for SSH | `""` |
| `SSHCidr` | CIDR allowed for SSH on servers | `10.0.0.0/16` |
| `AmiId` | AMI or SSM parameter for instances | `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64` |
| `DesiredCapacity` | Desired ASG capacity | `2` |
| `MinSize` / `MaxSize` | Minimum and maximum ASG capacity | `2` / `4` |

> `AmiId` accepts two formats: an AMI ID (`ami-xxxxxxxx`) or an SSM parameter path (e.g., `/aws/service/ami-amazon-linux-latest/...`). If you provide a direct AMI, it will be used as is; if you specify an SSM path, the stack will resolve it automatically.

## Deployment with AWS CLI

1. ### Validate the template
   ```bash
   aws cloudformation validate-template \
     --template-body file://templates/main.yaml

   aws cloudformation validate-template \
     --template-body file://templates/nested/compute.yaml
   ```

2. ### Package and deploy with helper script
   ```bash
   ./scripts/package_and_deploy.sh \
     --region us-east-1 \
     --bucket my-cfn-artifacts-bucket \
     --stack exercise5 \
     --parameters parameters/stack-params.json
   ```

   > The script checks/creates the bucket (with versioning), runs `aws cloudformation package` and then `deploy`. Use `--force-bucket` to force recreation if you want to overwrite an existing bucket.

3. ### Query main outputs
   ```bash
   STACK_NAME=exercise5

   aws cloudformation describe-stacks \
     --stack-name "${STACK_NAME}" \
     --query "Stacks[0].Outputs"
   ```

4. ### Delete the stack
   ```bash
   STACK_NAME=exercise5

   aws cloudformation delete-stack --stack-name "${STACK_NAME}"
   ```

## Security Considerations

- Keep `SSHCidr` restricted to necessary administrative addresses (ideally your corporate IP or VPN range).
- The Launch Template enforces IMDSv2 and attaches the managed role `AmazonSSMManagedInstanceCore` for access via AWS Systems Manager Session Manager instead of exposing SSH.
- NACLs separate public and private traffic, closing unused ports and limiting access to internal resources.

## Suggested Next Steps

- Add HTTPS to ALB (ACM certificate + listener 443).
- Incorporate alarms and scaling policies based on CPU or latency metrics.
- Connect the VPC to additional services (RDS, bastion host, etc.) reusing the same template as base stack.
