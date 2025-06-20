resource "kubernetes_namespace" "vault" {
  metadata {
    name = "kube-services"
  }
}
resource "tls_private_key" "lab_ca_key" {

  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "lab_ca_cert" {

  private_key_pem = tls_private_key.lab_ca_key.private_key_pem

  subject {
    common_name  = "lab.localhost"
    organization = "HashiCorp"
  }

  validity_period_hours = 8760
  early_renewal_hours   = 720
  
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["lab.localhost"]
}

resource "kubernetes_secret" "lab_ca_tls" {


  metadata {
    name      = "lab-ca-tls"
    namespace = kubernetes_namespace.vault.id
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.lab_ca_cert.cert_pem
    "tls.key" = tls_private_key.lab_ca_key.private_key_pem
  }
}
