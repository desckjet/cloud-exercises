data "aws_caller_identity" "current" {}

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
  pipeline_name          = "${var.name_prefix}-codepipeline"
  codebuild_project_name = "${var.name_prefix}-codebuild"
  codedeploy_app_name    = "${var.name_prefix}-codedeploy-app"
  codedeploy_group_name  = "${var.name_prefix}-codedeploy-dg"
  target_azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  compute_ami_id         = length(trimspace(var.compute_ami_id)) > 0 ? var.compute_ami_id : data.aws_ami.al2023.id
  user_data              = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    token=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    region=$(curl -s -H "X-aws-ec2-metadata-token: $${token}" \
      http://169.254.169.254/latest/dynamic/instance-identity/document \
      | awk -F'"' '/region/ {print $4}')

    dnf update -y
    dnf install -y ruby wget nginx

    cd /tmp
    wget "https://aws-codedeploy-$${region}.s3.$${region}.amazonaws.com/latest/install"
    chmod +x ./install
    ./install auto

    systemctl enable --now codedeploy-agent
    systemctl enable --now amazon-ssm-agent
    systemctl enable --now nginx
  EOT
}

module "networking" {
  source = "./modules/networking"

  name_prefix        = var.name_prefix
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_newbits     = var.subnet_newbits
  availability_zones = local.target_azs
  tags               = var.tags
}

module "instance_profile" {
  source = "./modules/iam_instance_profile"

  name_prefix = var.name_prefix
  tags        = var.tags
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

module "compute" {
  source = "./modules/compute"

  name_prefix               = var.name_prefix
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_subnet_ids        = module.networking.private_subnet_ids
  ami_id                    = local.compute_ami_id
  instance_type             = var.compute_instance_type
  iam_instance_profile_name = module.instance_profile.instance_profile_name
  user_data                 = local.user_data
  asg_min_size              = var.asg_min_size
  asg_max_size              = var.asg_max_size
  asg_desired_capacity      = var.asg_desired_capacity
  alb_health_check_path     = var.alb_health_check_path
  tags                      = var.tags
}

module "artifact_bucket" {
  source = "./modules/artifact_bucket"

  name_prefix                   = var.name_prefix
  artifact_bucket_name          = var.artifact_bucket_name
  artifact_bucket_force_destroy = var.artifact_bucket_force_destroy
  tags                          = var.tags
}

module "codestar_connection" {
  source = "./modules/codestar_connection"

  name_prefix              = var.name_prefix
  codestar_connection_name = var.codestar_connection_name
  tags                     = var.tags
}

module "codebuild" {
  source = "./modules/codebuild"

  name_prefix                     = var.name_prefix
  project_name                    = local.codebuild_project_name
  artifact_bucket_arn             = module.artifact_bucket.bucket_arn
  aws_region                      = var.aws_region
  tags                            = var.tags
  codebuild_environment_image     = var.codebuild_environment_image
  codebuild_compute_type          = var.codebuild_compute_type
  codebuild_environment_type      = var.codebuild_environment_type
  codebuild_privileged_mode       = var.codebuild_privileged_mode
  codebuild_build_timeout         = var.codebuild_build_timeout
  codebuild_environment_variables = var.codebuild_environment_variables
  codebuild_buildspec             = var.codebuild_buildspec
}

module "codedeploy" {
  source = "./modules/codedeploy"

  name_prefix                  = var.name_prefix
  app_name                     = local.codedeploy_app_name
  deployment_group_name        = local.codedeploy_group_name
  codedeploy_deployment_config = var.codedeploy_deployment_config
  codedeploy_target_tag_key    = var.codedeploy_target_tag_key
  codedeploy_target_tag_value  = var.codedeploy_target_tag_value
  tags                         = var.tags
}

module "codepipeline" {
  source = "./modules/codepipeline"

  name_prefix                       = var.name_prefix
  pipeline_name                     = local.pipeline_name
  artifact_bucket_name              = module.artifact_bucket.bucket_name
  artifact_bucket_arn               = module.artifact_bucket.bucket_arn
  codestar_connection_arn           = module.codestar_connection.arn
  aws_region                        = var.aws_region
  aws_account_id                    = data.aws_caller_identity.current.account_id
  github_owner                      = var.github_owner
  github_repository                 = var.github_repository
  github_branch                     = var.github_branch
  codebuild_project_name            = module.codebuild.project_name
  codebuild_project_arn             = module.codebuild.project_arn
  codebuild_role_arn                = module.codebuild.service_role_arn
  codedeploy_application_name       = module.codedeploy.application_name
  codedeploy_application_arn        = module.codedeploy.application_arn
  codedeploy_deployment_group_name  = module.codedeploy.deployment_group_name
  codedeploy_deployment_group_arn   = module.codedeploy.deployment_group_arn
  codedeploy_role_arn               = module.codedeploy.service_role_arn
  codedeploy_deployment_config_name = var.codedeploy_deployment_config
  tags                              = var.tags
}
