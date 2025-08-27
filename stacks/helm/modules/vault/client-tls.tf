# Private key for the client cert
resource "tls_private_key" "client_tls_key" {
  count = var.is_vault_mtls_enabled ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

# CSR for the client cert
resource "tls_cert_request" "client_tls_csr" {
  count = var.is_vault_mtls_enabled ? 1 : 0

  private_key_pem = tls_private_key.client_tls_key[0].private_key_pem

  subject {
    common_name  = "vault-client"
    organization = "HashiCorp"
  }
}

# Sign client cert with CA and use extended usage = clientAuth
resource "tls_locally_signed_cert" "client_tls_cert" {
  count = var.is_vault_mtls_enabled ? 1 : 0

  cert_request_pem   = tls_cert_request.client_tls_csr[0].cert_request_pem
  ca_private_key_pem = data.terraform_remote_state.common.outputs.server_ca_private_key_pem
  ca_cert_pem        = data.terraform_remote_state.common.outputs.server_ca_cert_pem

  validity_period_hours = 8760
  early_renewal_hours   = 720

  allowed_uses = [
    "digital_signature",
    "client_auth",
    "key_agreement"
  ]
}

# Optional: Create a Kubernetes secret for the client cert
resource "kubernetes_secret" "vault_client_tls" {
  count = var.is_vault_mtls_enabled ? 1 : 0

  metadata {
    name      = var.vault_client_tls_secret_name
    namespace = var.helm_namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.client_tls_cert[0].cert_pem
    "tls.key" = tls_private_key.client_tls_key[0].private_key_pem
    "ca.crt"  = data.terraform_remote_state.common.outputs.server_ca_cert_pem
  }
}


## Copy certificates to local files for easy access
resource "local_file" "vault_client_cert_file" {
  count    = var.is_vault_mtls_enabled ? 1 : 0
  content  = tls_locally_signed_cert.client_tls_cert[0].cert_pem
  filename = format("%s/client.crt", var.vault_client_tls_cert_dir)
}

resource "local_file" "vault_client_key_file" {
  count    = var.is_vault_mtls_enabled ? 1 : 0
  content  = tls_private_key.client_tls_key[0].private_key_pem
  filename = format("%s/client.key", var.vault_client_tls_cert_dir)
}

resource "local_file" "vault_ca_cert_file" {
  count    = var.is_vault_mtls_enabled ? 1 : 0
  content  = data.terraform_remote_state.common.outputs.server_ca_cert_pem
  filename = format("%s/ca.crt", var.vault_client_tls_cert_dir)
}