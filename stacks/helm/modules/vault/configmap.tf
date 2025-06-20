resource "kubernetes_config_map" "local_aws_credentials" {
  count = var.is_vault_aws_kms_enabled ? 1 : 0
  metadata {
    name      = "aws-credentials"
    namespace = var.helm_namespace
  }

  data = {
    credentials = file("~/.aws/credentials")
  }
}