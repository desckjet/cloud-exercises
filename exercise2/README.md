# Exercise 2 - Auto Scaling Web Application with Monitoring

## Project Description

This exercise implements a scalable web application infrastructure on AWS with automatic scaling based on CPU metrics. The infrastructure includes:

- **VPC and Networking**: Multi-AZ private network with public and private subnets
- **Auto Scaling Group**: EC2 instances running Nginx with automatic scaling capabilities
- **Load Balancer**: Application Load Balancer for high availability and traffic distribution
- **Monitoring**: CloudWatch alarms and auto scaling policies based on CPU utilization
- **High Availability**: Multi-AZ deployment for fault tolerance

## File Structure

```
exercise2/
├── README.md
├── backend.tf                     # Terraform backend configuration
├── main.tf                        # Main configuration
├── outputs.tf                     # Infrastructure outputs
├── providers.tf                   # Provider configuration
├── terraform.tfvars.example       # Example variables
├── variables.tf                   # Variable definitions
├── versions.tf                    # Terraform and provider versions
└── modules/
    ├── compute/                    # Module for EC2, ASG, and ALB
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── monitoring/                 # Module for CloudWatch and scaling policies
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

## Main Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `project_name` | Project identifier for resource naming | - |
| `environment` | Environment name (dev, staging, prod) | - |
| `aws_region` | AWS region for resources | - |
| `az_count` | Number of availability zones to use | `2` |
| `vpc_cidr_block` | CIDR block for the VPC | `"10.0.0.0/16"` |
| `launch_template_instance_type` | EC2 instance type | `"t2.micro"` |
| `asg_min_size` | Minimum instances in ASG | `2` |
| `asg_max_size` | Maximum instances in ASG | `4` |
| `asg_desired_capacity` | Desired instances in ASG | `2` |
| `scale_out_cpu_threshold` | CPU % to trigger scale out | `60` |
| `scale_in_cpu_threshold` | CPU % to trigger scale in | `20` |

## Features

### Auto Scaling Policies
- **Scale Out**: Automatically adds instances when CPU utilization exceeds 60%
- **Scale In**: Automatically removes instances when CPU utilization drops below 20%
- **Health Checks**: Load balancer performs health checks on `/` path

### High Availability
- **Multi-AZ Deployment**: Resources deployed across multiple availability zones
- **Load Balancing**: Application Load Balancer distributes traffic evenly
- **Fault Tolerance**: Auto Scaling Group replaces unhealthy instances automatically

### Monitoring
- **CloudWatch Alarms**: CPU utilization monitoring
- **Auto Scaling Policies**: Automatic instance scaling based on metrics
- **Health Monitoring**: Load balancer health checks

## Outputs

After deployment, you will get:

- **VPC ID**: The ID of the created VPC
- **Subnet IDs**: Public and private subnet identifiers
- **Load Balancer DNS**: URL to access the web application
- **Auto Scaling Group Name**: Name of the ASG for monitoring

## Testing Auto Scaling

### Access the Application
```bash
# Get the load balancer DNS from terraform output
terraform output alb_dns_name

# Access the application in your browser
# http://<alb-dns-name>
```

### Generate Load to Test Scaling
```bash
# Install stress testing tool on the instances
# The auto scaling will trigger when CPU usage exceeds 60%

# Monitor scaling activity
aws autoscaling describe-scaling-activities --auto-scaling-group-name <asg-name>

# Watch CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=<asg-name> \
  --statistics Average \
  --start-time 2023-01-01T00:00:00Z \
  --end-time 2023-01-01T01:00:00Z \
  --period 300
```

## Resource Cleanup

To remove all infrastructure:

```bash
terraform destroy
```

**Note**: Confirm the deletion by typing `yes` when prompted.

## Architecture Components

### Networking Module
- VPC with public and private subnets
- Internet Gateway for public subnet access
- NAT Gateway for private subnet internet access
- Route tables and security groups

### Compute Module
- Launch Template with Amazon Linux 2023
- Auto Scaling Group with multi-AZ deployment
- Application Load Balancer with target group
- Security groups for web traffic

### Monitoring Module
- CloudWatch alarms for CPU utilization
- Auto Scaling policies for scale out/in
- SNS integration for notifications (optional)

## Troubleshooting

### Instances Not Scaling
- Check CloudWatch alarms status
- Verify CPU utilization metrics
- Ensure Auto Scaling policies are attached

### Load Balancer Health Checks Failing
- Verify nginx is running on instances: `systemctl status nginx`
- Check security group rules allow HTTP traffic
- Verify health check path returns HTTP 200

### Instances Not Launching
- Check Launch Template configuration
- Verify AMI availability in the selected region
- Ensure subnet has available IP addresses

### Permission Errors
Ensure your AWS user has permissions for:
- EC2 (instances, security groups, load balancers)
- Auto Scaling
- CloudWatch
- VPC networking resources