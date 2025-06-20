resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.helm_namespace
  }
}


resource "kubernetes_secret" "vault_license" {
  count = var.is_vault_enterprise ? 1 : 0
  
  metadata {
    name      = var.vault_license_secret_name
    namespace = kubernetes_namespace.vault.id
  }

  data = {
    #"license.hclic" = filebase64("${path.module}/dotenv/vault.hclic")
    "license.hclic" = file("${path.module}/dotenv/vault.hclic")
  }

  type = "Opaque"
}