resource "tls_private_key" "server_tls_key" {
  count = var.is_vault_tls_enabled ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}


# Generate a CSR for Vault
resource "tls_cert_request" "server_tls_csr" {
  count = var.is_vault_tls_enabled ? 1 : 0

  private_key_pem = tls_private_key.server_tls_key[0].private_key_pem

  subject {
    common_name  = "vault.localhost"
    organization = "HashiCorp"
  }

  dns_names = [
    "vault.localhost",
    "vault-0.vault-internal",
    "vault-1.vault-internal",
    "vault-2.vault-internal",
    "ingress.local"
  ]
  ip_addresses = [
    "127.0.0.1",
    "::1"
  ]
}

# CA signs the CSR to issue Vault cert
resource "tls_locally_signed_cert" "server_tls_cert" {
  count = var.is_vault_tls_enabled ? 1 : 0

  cert_request_pem = tls_cert_request.server_tls_csr[0].cert_request_pem
  ca_private_key_pem = data.terraform_remote_state.common.outputs.server_ca_private_key_pem
  ca_cert_pem        = data.terraform_remote_state.common.outputs.server_ca_cert_pem

  validity_period_hours = 8760
  early_renewal_hours   = 720

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "kubernetes_secret" "server_tls" {
  count = var.is_vault_tls_enabled ? 1 : 0

  metadata {
    name      = var.server_tls_secret_name
    namespace = var.helm_namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.server_tls_cert[0].cert_pem
    "tls.key" = tls_private_key.server_tls_key[0].private_key_pem
    "ca.crt"  = data.terraform_remote_state.common.outputs.server_ca_cert_pem
  }
}
