module "vault" {
  source = "../../base"

  helm_chart            = "vault"
  #helm_chart            = "vault"
  helm_version          = "0.27.0"
  helm_repository       = "https://helm.releases.hashicorp.com"
  helm_namespace        = var.helm_namespace
  helm_create_namespace = var.helm_create_namespace

  helm_atomic          = var.helm_atomic
  helm_cleanup_on_fail = var.helm_cleanup_on_fail
  helm_force_update    = var.helm_force_update
  helm_override        = var.helm_override
  helm_recreate_pods   = var.helm_recreate_pods
  helm_skip_crds       = var.helm_skip_crds
  helm_timeout         = var.helm_timeout

  helm_metadata        = {
    "globalAnnotations.product"         = "vault"
    "globalAnnotations.platform"        = "docker Desktop"
    "globalAnnotations.arch"            = "arm64"
    "globalAnnotations.repository"      = "remote"
  }
  helm_values         = local.vault_values_yaml
}