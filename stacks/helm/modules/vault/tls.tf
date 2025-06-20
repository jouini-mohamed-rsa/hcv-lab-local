resource "tls_private_key" "vault_tls_key" {
  count = var.is_vault_tls_enabled ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 2048
}


# Generate a CSR for Vault
resource "tls_cert_request" "vault_tls_csr" {
  count = var.is_vault_tls_enabled ? 1 : 0

  private_key_pem = tls_private_key.vault_tls_key[0].private_key_pem

  subject {
    common_name  = "vault.localhost"
    organization = "HashiCorp"
  }

  dns_names = [
    "vault.localhost"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
}

# CA signs the CSR to issue Vault cert
resource "tls_locally_signed_cert" "vault_tls_cert" {
  count = var.is_vault_tls_enabled ? 1 : 0

  cert_request_pem = tls_cert_request.vault_tls_csr[0].cert_request_pem
  ca_private_key_pem = data.terraform_remote_state.lab_ca.outputs.lab_ca_private_key_pem
  ca_cert_pem        = data.terraform_remote_state.lab_ca.outputs.lab_ca_cert_pem

  validity_period_hours = 8760
  early_renewal_hours   = 720

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "vault_tls" {
  count = var.is_vault_tls_enabled ? 1 : 0

  metadata {
    name      = var.vault_tls_secret_name
    namespace = var.helm_namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.vault_tls_cert[0].cert_pem
    "tls.key" = tls_private_key.vault_tls_key[0].private_key_pem
    "ca.crt"  = data.terraform_remote_state.lab_ca.outputs.lab_ca_cert_pem
  }
}
