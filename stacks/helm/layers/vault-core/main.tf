module "vault-core" {
  source = "../../modules/vault"

  is_vault_affinity_enabled       = false 
  is_vault_aws_kms_enabled        = true
  is_vault_enterprise             = true
  vault_client_tls_cert_dir       = "/Users/mohamed.jouini/training/vault/certifications/client"
  is_vault_ingress_enabled        = true
  vault_license_file_path         = "/Users/mohamed.jouini/training/vault/license/vault.hclic"
  is_vault_mtls_enabled           = true
  is_vault_tls_enabled            = true
  is_vault_ui_enabled             = true

  helm_namespace                  = "vault-core"
  helm_override                   = true

  vault_aws_region                = "us-east-1"
  vault_host                      = "vault.localhost"
  vault_kms_key_id                = ""
  vault_version                   = "1.19"
  vault_replicas                  = "3"

## AWS KMS Key used to unseal vault
  aws_tags = {
    env               = "dev"
    region            = "us-east-1"
    owner             = "mahamed"
    lab_name          = "vault-lab"
    vault_cluster_name = "vault-core"
  }
}