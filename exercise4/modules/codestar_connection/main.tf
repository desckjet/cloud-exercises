locals {
  connection_name = var.codestar_connection_name != "" ? var.codestar_connection_name : "${var.name_prefix}-github"
}

resource "aws_codestarconnections_connection" "github" {
  name          = local.connection_name
  provider_type = "GitHub"
  tags          = var.tags
}
