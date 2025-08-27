
locals {

  aws_creds_content = file("~/.aws/credentials")
  aws_creds_sha     = sha256(local.aws_creds_content)

  default_aws_tags = {
    team_region   = "emea"
    team_name     = "rts/rsa"
  }
  merged_aws_tags = merge(local.default_aws_tags, var.aws_tags)

  vault_values_yaml = templatefile("${path.module}/dotenv/overrides.yaml.tpl", {
    is_vault_aws_kms_enabled       = var.is_vault_aws_kms_enabled
    is_vault_affinity_enabled      = var.is_vault_affinity_enabled
    is_vault_mtls_enabled          = var.is_vault_mtls_enabled
    is_vault_tls_enabled           = var.is_vault_tls_enabled
    is_vault_enterprise            = var.is_vault_enterprise
    is_vault_ingress_enabled       = var.is_vault_ingress_enabled
    is_vault_ui_enabled            = var.is_vault_ui_enabled
    vault_aws_region               = var.vault_aws_region
    vault_aws_cred_cfm             = var.is_vault_aws_kms_enabled ? kubernetes_config_map.local_aws_credentials[0].metadata[0].name : ""
    vault_kms_key_id               = data.terraform_remote_state.common.outputs.unseal_key_id
    vault_license_secret_name      = var.vault_license_secret_name
    vault_server_tls_secret_name   = var.server_tls_secret_name
    vault_client_tls_secret_name   = var.vault_client_tls_secret_name
    vault_version                  = var.vault_version
    vault_replicas                 = var.vault_replicas
    vault_aws_region               = var.vault_aws_region
    vault_host                     = var.vault_host
  })
}