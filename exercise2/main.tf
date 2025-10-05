data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  base_name = format("%s-%s", var.project_name, var.environment)
  azs       = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )

  launch_template_ami = length(trimspace(var.launch_template_ami_id)) > 0 ? var.launch_template_ami_id : data.aws_ami.al2023.id

  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    if command -v dnf >/dev/null 2>&1; then
      dnf -y update
      dnf -y install nginx
    else
      yum -y update
      if command -v amazon-linux-extras >/dev/null 2>&1; then
        amazon-linux-extras enable nginx1
        amazon-linux-extras install -y nginx1
      fi
      yum -y install nginx || true
    fi
    systemctl enable nginx
    systemctl start nginx
  EOT
}

module "networking" {
  source = "./modules/networking"

  base_name          = local.base_name
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_newbits     = var.subnet_newbits
  availability_zones = local.azs
  tags               = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  base_name             = local.base_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  ami_id                = local.launch_template_ami
  instance_type         = var.launch_template_instance_type
  user_data             = local.user_data
  asg_min_size          = var.asg_min_size
  asg_max_size          = var.asg_max_size
  asg_desired_capacity  = var.asg_desired_capacity
  alb_health_check_path = var.alb_health_check_path
  tags                  = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  base_name               = local.base_name
  asg_name                = module.compute.asg_name
  scale_out_cpu_threshold = var.scale_out_cpu_threshold
  scale_in_cpu_threshold  = var.scale_in_cpu_threshold
  tags                    = local.common_tags
}
