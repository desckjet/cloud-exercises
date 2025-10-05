terraform {
  required_version = ">= 1.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.47"
    }
  }
}

locals {
  base_tags  = merge({ ManagedBy = "Terraform" }, var.tags)
  aws_tags   = merge(local.base_tags, try(var.aws_config.tags, {}))
  azure_tags = merge(local.base_tags, try(var.azure_config.tags, {}))
  aws_key_pair_name = (
    var.aws_config.key_name != null ? var.aws_config.key_name :
    var.aws_config.ssh_public_key != null ? "${var.aws_config.name_prefix}-key" :
    null
  )
}

# AWS resources
resource "aws_vpc" "this" {
  cidr_block           = var.aws_config.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.aws_tags, {
    Name = "${var.aws_config.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.aws_tags, {
    Name = "${var.aws_config.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.aws_config.public_subnet_cidr_block
  map_public_ip_on_launch = var.aws_config.enable_public_ip

  tags = merge(local.aws_tags, {
    Name = "${var.aws_config.name_prefix}-public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.aws_tags, {
    Name = "${var.aws_config.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "instance" {
  name        = "${var.aws_config.name_prefix}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = var.aws_config.allowed_ssh_cidr_blocks
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.aws_tags, {
    Name = "${var.aws_config.name_prefix}-sg"
  })
}

# IAM role for the EC2 instance to enable expansion (e.g., SSM access)
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.aws_config.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = local.aws_tags
}

resource "aws_iam_role_policy" "inline" {
  count  = var.aws_config.iam_inline_policy_json == null ? 0 : 1
  name   = "${var.aws_config.name_prefix}-inline"
  role   = aws_iam_role.this.id
  policy = var.aws_config.iam_inline_policy_json
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.aws_config.name_prefix}-profile"
  role = aws_iam_role.this.name
}

resource "aws_key_pair" "this" {
  count      = var.aws_config.ssh_public_key != null ? 1 : 0
  key_name   = local.aws_key_pair_name
  public_key = var.aws_config.ssh_public_key
  tags       = local.aws_tags
}

resource "aws_instance" "this" {
  ami                         = var.aws_config.ami_id
  instance_type               = var.aws_config.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = local.aws_key_pair_name
  associate_public_ip_address = var.aws_config.enable_public_ip
  iam_instance_profile        = aws_iam_instance_profile.this.name
  vpc_security_group_ids      = [aws_security_group.instance.id]

  root_block_device {
    delete_on_termination = true
    volume_size           = var.aws_config.root_volume_size_gb
    volume_type           = "gp3"
  }

  tags = merge(local.aws_tags, {
    Name = "${var.aws_config.name_prefix}-ec2"
  })
}

# Azure resources
resource "azurerm_resource_group" "this" {
  name     = var.azure_config.resource_group_name
  location = var.azure_config.location
  tags     = local.azure_tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.azure_config.name_prefix}-vnet"
  address_space       = var.azure_config.vnet_address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.azure_tags
}

resource "azurerm_subnet" "this" {
  name                 = "${var.azure_config.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.azure_config.subnet_address_prefix]
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.azure_config.name_prefix}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.azure_tags
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.azure_config.allowed_ssh_source_addresses
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_public_ip" "this" {
  count               = var.azure_config.enable_public_ip ? 1 : 0
  name                = "${var.azure_config.name_prefix}-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.azure_tags
}

resource "azurerm_network_interface" "this" {
  name                = "${var.azure_config.name_prefix}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.azure_tags

  ip_configuration {
    name                          = "${var.azure_config.name_prefix}-ipcfg"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.azure_config.enable_public_ip ? azurerm_public_ip.this[0].id : null
  }
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "${var.azure_config.name_prefix}-id"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.azure_tags
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = "${var.azure_config.name_prefix}-vm"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  size                            = var.azure_config.vm_size
  admin_username                  = var.azure_config.admin_username
  network_interface_ids           = [azurerm_network_interface.this.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.azure_config.admin_username
    public_key = var.azure_config.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.azure_config.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.azure_config.image_reference.publisher
    offer     = var.azure_config.image_reference.offer
    sku       = var.azure_config.image_reference.sku
    version   = var.azure_config.image_reference.version
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  tags = merge(local.azure_tags, {
    Name = "${var.azure_config.name_prefix}-vm"
  })
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
