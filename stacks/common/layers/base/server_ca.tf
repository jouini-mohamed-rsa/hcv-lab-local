resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.server_ca_secret_namespace
  }
}

resource "tls_private_key" "server_ca_key" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Server Root CA certificate (self-signed)
resource "tls_self_signed_cert" "server_ca_cert" {
  private_key_pem = tls_private_key.server_ca_key.private_key_pem

  # Subject information from your [req_distinguished_name] section
  subject {
    common_name         = "Server Root CA"
    organization        = "HashiCorp"
    organizational_unit = "RTS"
  }

  validity_period_hours = 8760
  early_renewal_hours   = 720
  
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}


resource "kubernetes_secret" "server_ca_tls" {
  metadata {
    name      = "server-ca-tls"
    namespace = kubernetes_namespace.vault.id
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.server_ca_cert.cert_pem
    "tls.key" = tls_private_key.server_ca_key.private_key_pem
  }
}

# Write the CA certificate to a local file for client use
resource "local_file" "vault_client_cert_file" {
  content  = tls_self_signed_cert.server_ca_cert.cert_pem
  filename = format("%s/ca.crt", var.server_ca_cert_dir)
}

resource "local_file" "vault_client_key_file" {
  content  = tls_self_signed_cert.server_ca_cert.private_key_pem
  filename = format("%s/ca.key", var.server_ca_cert_dir)
}