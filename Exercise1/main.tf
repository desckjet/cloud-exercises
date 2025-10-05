module "multicloud_instance" {
  source = "./modules/multicloud-instance"

  providers = {
    aws     = aws
    azurerm = azurerm
  }

  aws_config   = var.aws_config
  azure_config = var.azure_config
  tags         = var.tags
}
