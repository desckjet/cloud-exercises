# Exercise 1 – Multicloud Instance Module

This exercise defines a reusable Terraform module capable of provisioning an EC2 instance in AWS and a Linux virtual machine in Azure with supporting networking, security, and identity resources. The root module shows how to compose both clouds together while keeping configuration isolated through structured variables.

## Layout

- `providers.tf` – required providers (Terraform >= 1.13.3) with S3 backend configured inline.
- `variables.tf` – typed variable declarations for AWS and Azure settings passed into the module.
- `main.tf` – invokes the `modules/multicloud-instance` module.
- `modules/multicloud-instance` – implementation of the AWS and Azure infrastructure (networking, security groups, IAM/managed identity, compute).
- `terraform.tfvars.example` – sample variable file illustrating the required inputs.

## Usage

1. **Configure variables**: Create a `terraform.tfvars` (or use `-var-file`) based on `terraform.tfvars.example`. The module can automatically generate the key pair in AWS if you provide `aws_config.ssh_public_key` (or reuse an existing one with `aws_config.key_name`).

2. **Set up credentials**: Export AWS and Azure credentials or configure profiles before running Terraform.

3. **Bootstrap remote backend**: Create the S3 bucket for remote state with a `targeted apply`:

   a. Temporarily comment out the `backend "s3"` block in `versions.tf`.
   
   b. Run `terraform init -backend=false`.
   
   c. Run the targets that create and protect the bucket:

   ```bash
   terraform apply \
     -target=aws_s3_bucket.tf_state \
     -target=aws_s3_bucket_public_access_block.tf_state \
     -target=aws_s3_bucket_versioning.tf_state \
     -target=aws_s3_bucket_server_side_encryption_configuration.tf_state
   ```

4. **Configure remote backend**: Uncomment the `backend "s3"` block in `versions.tf`. 
   NOTE: in terraform 1.13+ is not neccesary to use a DynamoDB table to lock/unlock, Is managed by S3 `use_lockfile = true`.

5. **Initialize and apply**:

   ```bash
   # Configure the backend
   terraform init -reconfigure
   terraform plan
   terraform apply
   ```

The module automatically:

- Builds networking primitives (VPC/subnet, virtual network/subnet).
- Configures security groups (AWS) and NSGs (Azure) with SSH ingress rules.
- Provisions IAM resources (EC2 instance profile and role) and an Azure user-assigned managed identity with a reader role assignment.
- Creates compute instances with public IP support that can be disabled via variables.

## SSH Access to Instances

### AWS

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<ip>
```

### Azure

```bash
ssh -i ~/.ssh/id_rsa azureuser@<ip>
```

## Destroy Infrastructure

When you need to clean up everything, run:

```bash
terraform destroy
```
