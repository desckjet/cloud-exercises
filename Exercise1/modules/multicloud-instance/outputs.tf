output "aws" {
  description = "Key attributes for the AWS EC2 deployment."
  value = {
    instance_id          = aws_instance.this.id
    security_group_id    = aws_security_group.instance.id
    iam_role_name        = aws_iam_role.this.name
    iam_instance_profile = aws_iam_instance_profile.this.name
    vpc_id               = aws_vpc.this.id
    subnet_id            = aws_subnet.public.id
  }
}

output "azure" {
  description = "Key attributes for the Azure VM deployment."
  value = {
    vm_resource_id       = azurerm_linux_virtual_machine.this.id
    network_interface_id = azurerm_network_interface.this.id
    resource_group_name  = azurerm_resource_group.this.name
    identity_id          = azurerm_user_assigned_identity.this.id
    subnet_id            = azurerm_subnet.this.id
    virtual_network_id   = azurerm_virtual_network.this.id
  }
}
