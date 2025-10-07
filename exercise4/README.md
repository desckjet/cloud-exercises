# Exercise 4 - AWS CI/CD Pipeline with CodePipeline

## Project Description

This exercise implements a complete CI/CD pipeline on AWS using CodePipeline, CodeBuild, and CodeDeploy. The infrastructure includes:

- **VPC and Networking**: Private network with public and private subnets
- **Auto Scaling Group**: EC2 instances with Application Load Balancer
- **CI/CD Pipeline**: CodePipeline with GitHub integration via CodeStar Connection
- **Build Process**: CodeBuild to compile and package the application
- **Deployment**: CodeDeploy for automatic deployment to EC2 instances
- **Artifact Storage**: S3 bucket to store build artifacts

## File Structure

```
exercise4/
├── README.md
├── backend.tf                     # Terraform backend configuration
├── main.tf                        # Main configuration
├── outputs.tf                     # Infrastructure outputs
├── providers.tf                   # Provider configuration
├── terraform.tfvars.example       # Example variables
├── variables.tf                   # Variable definitions
├── versions.tf                    # Terraform and provider versions
└── modules/
    ├── artifact_bucket/            # Module for S3 artifacts bucket
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── codebuild/                  # Module for CodeBuild
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── codedeploy/                 # Module for CodeDeploy
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── codepipeline/               # Module for CodePipeline
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── codestar_connection/        # Module for GitHub connection
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── compute/                    # Module for EC2 and Auto Scaling
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── iam_instance_profile/       # Module for IAM roles
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── networking/                 # Module for VPC and networking
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

## Initial Setup

### 1. Prepare Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables according to your configuration
vim terraform.tfvars
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan the Infrastructure

```bash
terraform plan
```

### 4. Apply the Configuration

```bash
terraform apply
```

## Source Repository

This exercise uses a sample application repository for the CI/CD pipeline:
- **Repository**: https://github.com/desckjet/code-deploy
- **Purpose**: Contains a simple web application with CodeDeploy configuration files
- **Includes**: 
  - `buildspec.yml` for CodeBuild build instructions
  - `appspec.yml` for CodeDeploy deployment configuration
  - Simple web application files

## AWS CodeStar Connection Setup

**⚠️ IMPORTANT**: After `terraform apply`, you must manually configure the CodeStar connection:

1. Go to the AWS CodePipeline console
2. Navigate to **Settings > Connections**
3. Find the connection created by Terraform
4. Click **Update pending connection**
5. Authorize the connection with GitHub following the OAuth flow
6. Confirm that the status changes to **Available**

Without this step, the pipeline won't be able to access your GitHub repository.

## Main Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `name_prefix` | Prefix for all resources | `"exercise4"` |
| `aws_region` | AWS region | `"us-east-1"` |
| `github_owner` | Repository owner | - |
| `github_repository` | Repository name | - |
| `github_branch` | Branch to monitor | `"main"` |
| `compute_instance_type` | EC2 instance type | `"t2.micro"` |
| `asg_min_size` | ASG minimum size | `1` |
| `asg_max_size` | ASG maximum size | `3` |

## Outputs

After deployment, you will get:

- **Load Balancer DNS**: URL to access the application
- **CodePipeline Name**: Name of the created pipeline
- **CodeStar Connection ARN**: Connection ARN (pending authorization)

## Resource Cleanup

To remove all infrastructure:

```bash
terraform destroy
```

**Note**: Confirm the deletion by typing `yes` when prompted.

## Troubleshooting

### CodeStar Connection Error
If the pipeline fails, verify that the CodeStar connection is authorized in the AWS console.

### Permission Errors
Ensure your AWS user has the necessary permissions to create CodePipeline, CodeBuild, CodeDeploy, EC2, VPC, IAM, and S3 resources.

### Unhealthy EC2 Instances
Check the user-data logs at `/var/log/cloud-init-output.log` on the EC2 instances.